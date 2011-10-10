
#import "DTServer.h"
#import "TCAsyncHashProtocol.h"

@interface DTServer () <TCAsyncHashProtocolDelegate>
@end

#import "AsyncSocket.h"
#import "DTWorld.h"
#import "DTRoom.h"
#import "DTLayer.h"
#import "DTMap.h"
#import "DTPlayer.h"
#import "DTEntity.h"
#import "DTEntityPlayer.h"
#import "DTEntityRipper.h"
#import "DTEntityZoomer.h"
#import "DTEntityBullet.h"
#import "Vector2.h"
#import "DTPhysics.h"
#import "DTLevelRepository.h"
#import "DTServerRoom.h"

#if DUMB_CLIENT
static const int kMaxServerFramerate = 60;
#else
static const int kMaxServerFramerate = 5;
#endif

@interface DTServer () <DTServerRoomDelegate>
-(void)broadcast:(NSDictionary*)d;

-(void)sendRoom:(DTRoom*)room toPlayer:(DTPlayer*)player;
-(void)addPoints:(float)pts forPlayer:(DTPlayer*)who;
-(void)msg:(NSString*)msg;
@end

@implementation DTServer {
    AsyncSocket *_sock;
	NSMutableArray *players;
    NSDictionary *previousDelta;
    NSTimeInterval secondsSinceLastDelta;
	NSMutableDictionary *scoreBoard;
}

@synthesize physics;
@synthesize levelRepo, rooms;

-(id)init;
{
    return [self initListeningOnPort:kDTServerDefaultPort];
}
-(id)initListeningOnPort:(NSUInteger)port;
{
    if(!(self = [super init])) return nil;
    
    physics = [[DTPhysics alloc] init];
    
    players = [NSMutableArray array];
    rooms = [NSMutableDictionary dictionary];
	scoreBoard = [NSMutableDictionary dictionary];

    _sock = [[AsyncSocket alloc] initWithDelegate:self];
	_sock.delegate = self;
	NSError *err = nil;
	if(![_sock acceptOnPort:port error:&err]) {
		[NSApp presentError:err];
		return nil;
	}
    
    return self;
}

-(void)spawnPlayer:(DTPlayer*)player;
{
    DTServerRoom *room = player.room;
    if(player.entity)
        [room destroyEntityKeyed:player.entity.uuid];
    
    player.entity = [room createEntity:[DTEntityPlayer class] setup:nil];
    
    [self teleportPlayerForEntity:player.entity toPosition:player.entity.position inRoomNamed:player.room.name];
}

-(void)sendRoom:(DTRoom*)room toPlayer:(DTPlayer*)player;
{
    NSDictionary *entReps = [room.entities sp_map: ^(NSString *k, id v) { return [v rep]; }];

    [player.proto sendHash:$dict(
        @"command", @"loadRoom",
        @"uuid", room.uuid,
        @"name", room.name,
        @"entities", entReps
    )];
}

-(void)loadLevel:(NSString*)roomName then:(void(^)(DTServerRoom*))then;
{
    DTServerRoom *existing = nil;
    for(DTServerRoom *r in rooms.allValues) if([r.name isEqual:roomName]) { existing = r; break; }
    if(existing) {
        then(existing);
        return;
    }

    [levelRepo fetchRoomNamed:roomName ofClass:[DTServerRoom class] whenDone:^(DTRoom *newLevel, NSError *err) {
        DTServerRoom *sroom = (id)newLevel;
        
        sroom.delegate = self;
        [rooms setObject:sroom forKey:sroom.uuid];
        
        sroom.world.server = self;
        
        for(NSDictionary *entRep in sroom.initialEntityReps)
            [sroom createEntity:NSClassFromString([entRep objectForKey:@"class"]) setup:^(DTEntity *e) {
                [e updateFromRep:entRep];
            }];
            
        if(then) then(sroom);
    }];
}
-(void)loadLevel:(NSString *)roomName;
{
    [self loadLevel:roomName then:nil];
}

#pragma mark Network

-(void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket;
{
	NSLog(@"Gained client: %@", newSocket);
	TCAsyncHashProtocol *clientProto = [[TCAsyncHashProtocol alloc] initWithSocket:newSocket delegate:self];
	
	DTPlayer *player = [DTPlayer new];
	player.proto = clientProto;
	[players addObject:player];
    
    player.room = [[rooms allValues] objectAtIndex:random()%rooms.allValues.count];
    [self sendRoom:player.room toPlayer:player];
	[self spawnPlayer:player];
	
	[clientProto readHash];
}
-(void)onSocketDidDisconnect:(AsyncSocket *)sock;
{
	NSLog(@"Lost client: %@", sock);
	sock.delegate = nil;
	for(DTPlayer *player in players)
		if(player.proto.socket == sock) {
            if(player.entity) [player.room destroyEntityKeyed:player.entity.uuid];
			[self msg:$sprintf(@"%@ disconnected.", player.name)];
            [players removeObject:player];
            break;
		}
}

-(void)protocol:(TCAsyncHashProtocol*)proto receivedHash:(NSDictionary*)hash;
{
	DTPlayer *player = nil;
	for(DTPlayer *pl in players)
		if(pl.proto == proto) {
			player = pl; break;
		}
	NSAssert(player, @"Unknown player sent us stuff");
	
	if([hash objectForKey:@"hello"]) {
		player.name = [hash objectForKey:@"playerName"];
		[self addPoints:0 forPlayer:player];
		[self msg:$sprintf(@"%@ joined.", player.name)];
        [proto readHash];
		return;
	}
	
	NSString *action = [hash objectForKey:@"action"];
    
    if(action && !player.entity) {
        [self spawnPlayer:player];
        [proto readHash];
        return;
    }
	
	if([action isEqual:@"walk"]) {
		NSString *direction = [hash objectForKey:@"direction"];
        if([direction isEqual:@"left"]) { player.entity.moving = true; player.entity.moveDirection = EntityDirectionLeft; }
        else if([direction isEqual:@"right"]) { player.entity.moving = true; player.entity.moveDirection = EntityDirectionRight; }
        else if([direction isEqual:@"stop"]) { player.entity.moving = false; }
	} else if([action isEqual:@"jump"]) {
        [(DTEntityPlayer*)player.entity jump];
    } else if([action isEqual:@"shoot"]) {
        [player.room createEntity:[DTEntityBullet class] setup:(EntCtor)^(DTEntityBullet *e) {
            e.position = [MutableVector2 vectorWithVector2:player.entity.position];
            e.moveDirection = e.lookDirection = player.entity.lookDirection;
            e.owner = (DTEntityPlayer*)player.entity;
        }];
    } else NSLog(@"Unknown command %@", hash);
	
	[proto readHash];
}

-(void)broadcast:(NSDictionary*)d;
{
    for(DTPlayer *player in players) {
        //NSString *ruid = [d objectForKey:@"room"];
        //if(ruid && ![ruid isEqual:player.room.uuid]) continue;
        [player.proto sendHash:d];
    }
}

#pragma mark Game logic
-(DTPlayer*)playerForEntity:(DTEntity*)playerE;
{
	for(DTPlayer *pl in players) if(pl.entity == playerE) return pl;
	return nil;
}
-(void)addPoints:(float)pts forPlayer:(DTPlayer*)who;
{
	float cur = [[scoreBoard objectForKey:who.name] floatValue];
	[scoreBoard setObject:$numf(cur+pts) forKey:who.name];
	
	[self broadcast:$dict(
		@"command", @"updateScoreboard",
		@"scoreboard", scoreBoard
	)];
}
-(void)msg:(NSString*)msg;
{
	[self broadcast:$dict(
		@"command", @"displayMessage",
		@"message", msg
	)];
}


-(void)entityDamaged:(DTEntity*)entity damage:(int)damage location:(Vector2*)where killer:(DTEntity*)killer;
{
	NSMutableDictionary *d = $mdict(
        @"command", @"entityDamaged",
        @"room", entity.world.room.uuid,
        @"uuid", entity.uuid,
		@"location", where.rep,
        @"damage", $num(damage)
    );
	if(killer)
		[d setObject:killer.uuid forKey:@"killer"];
	[self broadcast:d];
}
#define $isPlayer(x) [x isKindOfClass:[DTEntityPlayer class]]
-(void)entityWasKilled:(DTEntity*)killed by:(DTEntity*)killer;
{
	if($isPlayer(killed) && $isPlayer(killer)) {// PvP
		[self addPoints:1 forPlayer:[self playerForEntity:killer]];
		[self msg:$sprintf(@"%@ got vaporized by %@.", [self playerForEntity:killed].name, [self playerForEntity:killer].name)];
	} else if($isPlayer(killed) && !$isPlayer(killer)) { // EvP
		[self addPoints:-1 forPlayer:[self playerForEntity:killed]];
		[self msg:$sprintf(@"%@ got eaten by a %@.", [self playerForEntity:killed].name, killer.typeName)];
	} else if(!$isPlayer(killed) && $isPlayer(killer)) // PvE
		[self addPoints:0.1 forPlayer:[self playerForEntity:killer]];
	
	[$cast(DTServerRoom, killed.world.room) destroyEntityKeyed:killed.uuid];
}

-(void)teleportPlayerForEntity:(DTEntity*)playerE
                    toPosition:(Vector2*)pos
                   inRoomNamed:(NSString*)roomName;
{
    DTPlayer *player = $notNull([self playerForEntity:playerE]);
    
    DTServerRoom *oldRoom = $cast(DTServerRoom, playerE.world.room);
    
    [self loadLevel:roomName then:^(DTServerRoom *newRoom) {
    
        [self sendRoom:newRoom toPlayer:player];
        
        player.entity.position = [MutableVector2 vectorWithVector2:pos];
        
        if(oldRoom != newRoom) {
            [oldRoom destroyEntityKeyed:playerE.uuid];
            [newRoom addEntityToRoom:playerE];
        }
        
        player.room = newRoom;
        
        [player.proto sendHash:$dict(
            @"command", @"cameraFollow",
            @"room", newRoom.uuid,
            @"uuid", player.entity.uuid
        )];
        [player.proto sendHash:$dict(
            @"command", @"playerEntity",
            @"room", newRoom.uuid,
            @"uuid", player.entity.uuid
        )];
        
    }];
}

-(void)tick:(double)delta;
{   
    // Physics!
    //for(DTPlayer *player in players) {
    //}
    
    for(DTServerRoom *room in rooms.allValues) {
        NSDictionary *entities = room.entities;
        
        [physics runWithEntities:entities.allValues world:room.world delta:delta];
        
        for(DTEntity *entity in entities.allValues)
            [entity tick:delta];
    }

    secondsSinceLastDelta += delta;
    if(secondsSinceLastDelta > 1./kMaxServerFramerate) { // push 5 times/sec
        for(DTServerRoom *room in rooms.allValues) {
        
            NSDictionary *reps = [room optimizeDelta:[room.entities sp_map: ^(NSString *k, id v) {
                return [v rep];
            }]];
            if(reps.count == 0) continue;
            
            [self broadcast:$dict(
                @"command", @"updateEntityDeltas",
                @"room", room.uuid,
                @"reps", reps
            )];
        }
        secondsSinceLastDelta = 0;
    }
}

#pragma Entity handling
-(void)room:(DTServerRoom*)room createdEntity:(DTEntity*)ent;
{
    NSLog(@"Added entity %@", ent);
    [self broadcast:$dict(
        @"command", @"addEntity",
        @"uuid", ent.uuid,
        @"room", room.uuid,
        @"rep", [ent rep]
    )];
}
-(void)room:(DTServerRoom*)room destroyedEntity:(DTEntity*)ent;
{
    [self broadcast:$dict(
        @"command", @"removeEntity",
        @"room", room.uuid,
        @"uuid", ent.uuid
    )];

}

@end
