
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
@end

@implementation DTServer {
    AsyncSocket *_sock;
	NSMutableArray *players;
    NSDictionary *previousDelta;
    NSTimeInterval secondsSinceLastDelta;
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
    [player.proto sendHash:$dict(
        @"command", @"cameraFollow",
        @"room", room.uuid,
        @"uuid", player.entity.uuid
    )];
    [player.proto sendHash:$dict(
        @"command", @"playerEntity",
        @"room", room.uuid,
        @"uuid", player.entity.uuid
    )];
}

-(void)loadLevel:(NSString*)levelName;
{
    [levelRepo fetchRoomNamed:@"test" ofClass:[DTServerRoom class] whenDone:^(DTRoom *newLevel, NSError *err) {
        DTServerRoom *sroom = (id)newLevel;
        
        sroom.delegate = self;
        [rooms setObject:sroom forKey:sroom.uuid];
        
        [self broadcast:$dict(
            @"command", @"loadRoom",
            @"uuid", sroom.uuid,
            @"name", sroom.name
        )];
        
        sroom.world.server = self;
        
        for(NSDictionary *entRep in sroom.initialEntityReps)
            [sroom createEntity:NSClassFromString([entRep objectForKey:@"class"]) setup:^(DTEntity *e) {
                [e updateFromRep:entRep];
            }];
    }];
}

#pragma mark Network

-(void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket;
{
	NSLog(@"Gained client: %@", newSocket);
	TCAsyncHashProtocol *clientProto = [[TCAsyncHashProtocol alloc] initWithSocket:newSocket delegate:self];
	
	DTPlayer *player = [DTPlayer new];
	player.proto = clientProto;
	[players addObject:player];
    
    DTServerRoom *initialRoom = [[rooms allValues] objectAtIndex:random()%rooms.allValues.count];
    
    player.room = initialRoom;

    [clientProto sendHash:$dict(
        @"command", @"loadRoom",
        @"uuid", initialRoom.uuid,
        @"name", initialRoom.name
    )];
    
    // Send room state
    for(NSString *key in initialRoom.entities)
        [clientProto sendHash:$dict(
            @"command", @"addEntity",
            @"uuid", key,
            @"room", initialRoom.uuid,
            @"rep", [[initialRoom.entities objectForKey:key] rep]
        )];

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
    
    if(!player.entity) {
        [self spawnPlayer:player];
        [proto readHash];
        return;
    }

	NSString *action = [hash objectForKey:@"action"];
	
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
    for(DTPlayer *player in players)
        [player.proto sendHash:d];
}


-(void)entityDamaged:(DTEntity*)entity damage:(int)damage;
{
    [self broadcast:$dict(
        @"command", @"entityDamaged",
        @"room", entity.world.room.uuid,
        @"uuid", entity.uuid,
        @"damage", $num(damage)
    )];
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

        for(DTEntity *entity in entities.allValues) {
            if(entity.health <= 0) [room destroyEntityKeyed:entity.uuid];
        }
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
