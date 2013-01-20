
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
#import "DTServerRoom.h"
#import "DTCore.h"
#import "DTEntityTemplate.h"
#import "DTEntitySpawnLocation.h"

#if DUMB_CLIENT
static const int kMaxServerFramerate = 60;
#else
static const int kMaxServerFramerate = 10;
#endif

@interface DTServer () <DTServerRoomDelegate>
@property(nonatomic,strong) DTResourceManager *resources;

-(void)broadcast:(NSDictionary*)d;

-(void)addPoints:(float)pts forPlayer:(DTPlayer*)who;
-(void)msg:(NSString*)msg;
-(void)sendSnapshotDiff:(void(^)())forThing forRoom:(DTServerRoom*)room;
@end

@implementation DTServer {
    AsyncSocket *_sock;
	NSMutableArray *players;
    NSDictionary *previousDelta;
    NSTimeInterval secondsSinceLastDelta;
	NSMutableDictionary *scoreBoard;
}

-(id)init;
{
    return [self initListeningOnPort:kDTServerDefaultPort];
}
-(id)initListeningOnPort:(NSUInteger)port;
{
    if(!(self = [super init])) return nil;
	
	self.resources = [DTResourceManager sharedManager];

    
    _physics = [[DTPhysics alloc] init];
    
    players = [NSMutableArray array];
    _rooms = [NSMutableDictionary dictionary];
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

-(void)spawnPlayer:(DTPlayer*)player inRoom:(DTServerRoom*)room;
{
    if(player.entity)
        [room destroyEntityKeyed:player.entity.uuid];
    
    player.entity = [room createEntity:[DTEntityPlayer class] setup:nil];
    
    [self teleportPlayer:player toPosition:nil inRoomNamed:room.room.name transitionDirection:0];
}

-(void)loadLevel:(NSString*)roomName then:(void(^)(DTServerRoom*))then;
{
    DTServerRoom *existing = nil;
    for(DTServerRoom *r in _rooms.allValues) if([r.room.name isEqual:roomName]) { existing = r; break; }
    if(existing) {
        then(existing);
        return;
    }

	[_resources resourceNamed:$sprintf(@"%@.room",roomName) loaded:(void(^)(id<DTResource>))^(DTRoom* newLevel) {
        DTServerRoom *sroom = [[DTServerRoom alloc] initWithRoom:newLevel];
        
        sroom.delegate = self;
        [_rooms setObject:sroom forKey:sroom.room.uuid];
        
        sroom.world.server = self;
        sroom.world.resources = _resources;
        
        for(DTEntityTemplate *template in sroom.room.entityTemplates.allValues)
            [sroom createEntity:template.klass setup:^(DTEntity *e) {
                [e updateFromRep:template.rep];
                e.templateUUID = template.uuid;
            }];
            
        if(then) then(sroom);
    }];
}
-(void)loadLevel:(NSString *)roomName;
{
    [self loadLevel:roomName then:nil];
}

- (DTPlayer*)localPlayer
{
    for(DTPlayer *pl in players)
        if([pl.appId isEqual:[DTCore appInstanceIdentifier]])
            return pl;
    return nil;
}

#pragma mark Network

-(void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket;
{
	NSLog(@"Gained client: %@", newSocket);
	TCAsyncHashProtocol *clientProto = [[TCAsyncHashProtocol alloc] initWithSocket:newSocket delegate:self];
	
	DTPlayer *player = [DTPlayer new];
	player.proto = clientProto;
	[players addObject:player];
    
    [self loadLevel:@"mutroid" then:^(DTServerRoom *room) {
        [self spawnPlayer:player inRoom:room];
    }];
	
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

-(void)broadcast:(NSDictionary*)d;
{
    [self broadcast:d excluding:nil];
}
- (void)broadcast:(NSDictionary *)d excluding:(DTPlayer*)excluded
{
    for(DTPlayer *player in players) {
        if(player == excluded)
            continue;
        NSString *ruid = [d objectForKey:@"room"];
        if(ruid && ![ruid isEqual:player.room.room.uuid]) continue;
        [player.proto sendHash:d];
    }
}


-(void)protocol:(TCAsyncHashProtocol*)proto receivedHash:(NSDictionary*)hash payload:(NSData*)payload;
{
	DTPlayer *player = nil;
	for(DTPlayer *pl in players)
		if(pl.proto == proto) {
			player = pl; break;
		}
	NSAssert(player, @"Unknown player sent us stuff");
    
    NSString *selNs = $sprintf(@"player:%@:", [hash objectForKey:@"command"]);
    SEL sel = NSSelectorFromString(selNs);
    if([self respondsToSelector:sel])
        ((void(*)(id, SEL, id, id))[self methodForSelector:sel])(self, sel, player, hash);
    else
        NSLog(@"Unknown command from %@: %@", player, hash);
}
-(void)protocol:(TCAsyncHashProtocol*)proto receivedRequest:(NSDictionary*)hash payload:(NSData*)payload responder:(TCAsyncHashProtocolResponseCallback)responder;
{
	DTPlayer *player = nil;
	for(DTPlayer *pl in players)
		if(pl.proto == proto) {
			player = pl; break;
		}
	NSAssert(player, @"Unknown player sent us stuff");

    SEL sel = NSSelectorFromString($sprintf(@"playerRequest:%@:responder:", [hash objectForKey:@"question"]));
    if([self respondsToSelector:sel])
            ((void(*)(id, SEL, id, id, TCAsyncHashProtocolResponseCallback))[self methodForSelector:sel])(self, sel, player, hash, responder);
    else {
        responder($dict(@"error", @"Unknown request"));
        NSLog(@"Unknown request from %@: %@", player, hash);
    }
}

-(void)player:(DTPlayer*)player hello:(NSDictionary*)hash;
{
    player.name = [hash objectForKey:@"playerName"];
    player.appId = hash[@"appId"];
    [self addPoints:0 forPlayer:player];
    [self msg:$sprintf(@"%@ joined.", player.name)];
}

#pragma mark Incoming player actions

-(void)player:(DTPlayer*)player action:(NSDictionary*)hash;
{
    NSString *selNs = $sprintf(@"playerAction:%@:", [hash objectForKey:@"action"]);
    
    if(!player.entity && player.room)
        return [self spawnPlayer:player inRoom:$cast(DTServerRoom, player.room)];

    SEL sel = NSSelectorFromString(selNs);
    if([self respondsToSelector:sel])
        [self sendSnapshotDiff:^{
            ((void(*)(id, SEL, id, id))[self methodForSelector:sel])(self, sel, player, hash);
        } forRoom:player.room];
    else
        NSLog(@"Unknown action from %@: %@", player, hash);
}

-(void)playerAction:(DTPlayer*)player walk:(NSDictionary*)hash;
{
    NSString *direction = [hash objectForKey:@"direction"];
    if([direction isEqual:@"left"]) { player.entity.moving = true; player.entity.moveDirection = EntityDirectionLeft; }
    else if([direction isEqual:@"right"]) { player.entity.moving = true; player.entity.moveDirection = EntityDirectionRight; }
    else if([direction isEqual:@"stop"]) { player.entity.moving = false; }
}
-(void)playerAction:(DTPlayer*)player pressUp:(NSDictionary*)hash; {
    [(DTEntityPlayer*)player.entity pressUp];
}
-(void)playerAction:(DTPlayer*)player pressDown:(NSDictionary*)hash; {
    [(DTEntityPlayer*)player.entity pressDown];
}
-(void)playerAction:(DTPlayer*)player jump:(NSDictionary*)hash; {
    [(DTEntityPlayer*)player.entity jump];
}
-(void)playerAction:(DTPlayer*)player shoot:(NSDictionary*)hash;
{
    [(DTEntityPlayer*)player.entity shoot];
}

- (void)player:(DTPlayer*)player updateRoomFromRep:(NSDictionary*)hash
{
    DTServerRoom *room = [_rooms objectForKey:$notNull([hash objectForKey:@"room"])];
    
    if (![player.appId isEqual:[DTCore appInstanceIdentifier]]) {
        NSDictionary *rep = $notNull(hash[@"rep"]);
        [[DTResourceManager sharedManager] reloadResoure:room.room usingDefinition:rep];
    }
    [self broadcast:@{
        @"command": @"updateRoomFromRep",
        @"room": room.room.uuid,
        @"rep": room.room.rep
     } excluding:player];
}
- (void)player:(DTPlayer*)player respawnEntityFromTemplateUUID:(NSDictionary*)hash
{
    // Only local player can do this
    if (![player.appId isEqual:[DTCore appInstanceIdentifier]])
        return;
    
    // Destroy old entity
    NSString *templateUUID = hash[@"templateUUID"];
    for(DTEntity *e in player.room.entities.allValues)
        if([e.templateUUID isEqual:templateUUID])
            [player.room destroyEntityKeyed:e.uuid];
    
    // Create a new one
    DTEntityTemplate *template = player.room.room.entityTemplates[templateUUID];
    if(template)
        [player.room createEntity:template.klass setup:^(DTEntity *e) {
            [e updateFromRep:template.rep];
            e.templateUUID = template.uuid;
        }];
}

#pragma mark Incoming player requests
-(void)playerRequest:(DTPlayer*)player getRoom:(NSDictionary*)hash responder:(TCAsyncHashProtocolResponseCallback)responder;
{
    DTServerRoom *room = [_rooms objectForKey:$notNull([hash objectForKey:@"uuid"])];
    if(!room) return responder($dict(@"error", @"no such room"));
    
    NSDictionary *entReps = [room.entities sp_map: ^(NSString *k, id v) { return [v rep]; }];

    responder($dict(
        @"uuid", room.room.uuid,
        @"name", room.room.name,
        @"entities", entReps
    ));
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
        @"room", entity.world.sroom.room.uuid,
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
	
	[killed.world.sroom destroyEntityKeyed:killed.uuid];
}

-(void)teleportPlayer:(DTPlayer*)player
           toPosition:(Vector2*)pos
          inRoomNamed:(NSString*)roomName
  transitionDirection:(EntityDirection)direction
{
    __block Vector2 *pos2 = pos;
    
    if(!player)
        player = [self localPlayer];
    
    DTEntity *playerE = player.entity;
    
    DTServerRoom *oldRoom = playerE.world.sroom;
    
    [self loadLevel:roomName then:^(DTServerRoom *newRoom) {
        // Find a spawn point
        if(!pos2) for(DTEntity *e in newRoom.entities.allValues)
            if([e isKindOfClass:[DTEntitySpawnLocation class]]) {
                pos2 = [(id)e spawnLocation];
                break;
            }
        // Or at least a door
        if(!pos2) for(DTEntity *e in newRoom.entities.allValues)
            if([e respondsToSelector:@selector(spawnLocation)]) {
                pos2 = [(id)e spawnLocation];
                break;
            }
        // Very well, just somewhere then.
        if(!pos2)
            pos2 = [Vector2 vectorWithX:5 y:5];
        
        player.entity.position = pos2.mutableCopy;
        
        [oldRoom destroyEntityKeyed:playerE.uuid];
        player.room = nil;
        
        [player.proto requestHash:@{
            @"question": @"joinRoom",
            @"name": newRoom.room.name,
            @"uuid": newRoom.room.uuid,
            @"transitionDirection": @(direction),
            @"destinationPosition": [pos2 rep]
        } response:^(NSDictionary *response) {
            // client's room is now loaded, and its state is all set up.
            player.room = newRoom;
            [newRoom addEntityToRoom:playerE];
            [player.proto sendHash:$dict(
                @"command", @"playerEntity",
                @"room", newRoom.room.uuid,
                @"uuid", player.entity.uuid
            )];
            [player.proto sendHash:$dict(
                @"command", @"cameraFollow",
                @"room", newRoom.room.uuid,
                @"uuid", player.entity.uuid
            )];
        }];
    }];
}

-(void)sendSnapshotDiff:(void(^)())forThing forRoom:(DTServerRoom*)room;
{
	NSDictionary *rep = [room.entities sp_map: ^(NSString *k, id v) { return [v rep]; }];
	forThing();
	NSDictionary *rep2 = [room.entities sp_map: ^(NSString *k, id v) { return [v rep]; }];
	
	NSDictionary *diff = [room diffFromState:rep toState:rep2];
	
	if(diff.count)
		[self broadcast:$dict(
			@"command", @"updateEntityDeltas",
			@"room", room.room.uuid,
			@"reps", diff
		)];
}

-(void)tick:(double)delta;
{
    // Physics    
    for(DTServerRoom *room in _rooms.allValues)
        [_physics runWithEntities:room.entities.allValues world:room.world delta:delta];
	
	
	// Game logic
    for(DTServerRoom *room in _rooms.allValues)
		// If game logic changes an important attribute, send it.
		[self sendSnapshotDiff:^{
			for(DTEntity *entity in room.entities.allValues)
				[entity tick:delta];
		} forRoom:room];

	
	// Interval deltas, to sync physics etc.
    secondsSinceLastDelta += delta;
    if(secondsSinceLastDelta > 1./kMaxServerFramerate) { // push 5 times/sec
        for(DTServerRoom *room in _rooms.allValues) {
        
            NSDictionary *reps = [room optimizeDelta:[room.entities sp_map: ^(NSString *k, id v) {
                return [v rep];
            }]];
            if(reps.count == 0) continue;
            
            [self broadcast:$dict(
                @"command", @"updateEntityDeltas",
                @"room", room.room.uuid,
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
        @"room", room.room.uuid,
        @"rep", [ent rep]
    )];
}
-(void)room:(DTServerRoom*)room destroyedEntity:(DTEntity*)ent;
{
    [self broadcast:$dict(
        @"command", @"removeEntity",
        @"room", room.room.uuid,
        @"uuid", ent.uuid
    )];
}
-(void)room:(DTServerRoom*)room sendsHash:(NSDictionary*)hash toCounterpartsOf:(DTEntity*)ent;
{
	[self broadcast:$dict(
		@"command", @"entityCounterpartMessage",
		@"room", room.room.uuid,
		@"uuid", ent.uuid,
		@"message", hash
	)];
}

@end
