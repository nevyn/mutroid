
#import "DTServer.h"
#import "TCAsyncHashProtocol.h"

@interface DTServer () <TCAsyncHashProtocolDelegate>
@end

#import "AsyncSocket.h"
#import "DTWorld.h"
#import "DTLevel.h"
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

static const int kMaxServerFramerate = 5;

typedef void(^EntCtor)(DTEntity*);
@interface DTServer ()
-(id)createEntity:(Class)class setup:(EntCtor)setItUp;
@end

@implementation DTServer {
    AsyncSocket *_sock;
	NSMutableArray *players;
    NSDictionary *previousDelta;
    NSTimeInterval secondsSinceLastDelta;
}

@synthesize physics;
@synthesize entities;
@synthesize level, world;

-(id)init;
{
    return [self initListeningOnPort:kDTServerDefaultPort];
}
-(id)initListeningOnPort:(NSUInteger)port;
{
    if(!(self = [super init])) return nil;
    
    physics = [[DTPhysics alloc] init];
    
    players = [NSMutableArray array];
    entities = [NSMutableDictionary dictionary];
    
    
    level = [[DTLevel alloc] initWithName:@"test"];
    world = [[DTWorld alloc] initWithLevel:level];
    world.server = self;
        
    [self createEntity:[DTEntityRipper class] setup:(EntCtor)^(DTEntityRipper *ripper) {
        ripper.position.x = 11;
        ripper.position.y = 7;
        ripper.size.y = 0.5;
    }];
    
    [self createEntity:[DTEntityRipper class] setup:(EntCtor)^(DTEntityRipper *ripper) {
        ripper.position.x = 5;
        ripper.position.y = 5.2;
        ripper.size.y = 0.5;
    }];

    /*
    [self createEntity:[DTEntityZoomer class] setup:(EntCtor)^(DTEntityZoomer *zoomer) {    
        zoomer.position.x = 8;
        zoomer.position.y = 8;
    }];
    */

    _sock = [[AsyncSocket alloc] initWithDelegate:self];
	_sock.delegate = self;
	NSError *err = nil;
	if(![_sock acceptOnPort:port error:&err]) {
		[NSApp presentError:err];
		return nil;
	}
    
    return self;
}

#pragma mark Network

-(void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket;
{
	NSLog(@"Gained client: %@", newSocket);
	TCAsyncHashProtocol *clientProto = [[TCAsyncHashProtocol alloc] initWithSocket:newSocket delegate:self];
	
	DTPlayer *player = [DTPlayer new];
	player.proto = clientProto;
	[players addObject:player];

    [clientProto sendHash:$dict(
        @"command", @"loadLevel",
        @"name", level.name
    )];
    
    // Send world state
    for(NSString *key in entities)
        [clientProto sendHash:$dict(
            @"command", @"addEntity",
            @"uuid", key,
            @"rep", [[entities objectForKey:key] rep]
        )];

	
    player.entity = [self createEntity:[DTEntityPlayer class] setup:nil];
    [clientProto sendHash:$dict(
        @"command", @"cameraFollow",
        @"uuid", player.entity.uuid
    )];
    [clientProto sendHash:$dict(
        @"command", @"playerEntity",
        @"uuid", player.entity.uuid
    )];
	
	[clientProto readHash];
}
-(void)onSocketDidDisconnect:(AsyncSocket *)sock;
{
	NSLog(@"Lost client: %@", sock);
	sock.delegate = nil;
	for(DTPlayer *player in players)
		if(player.proto.socket == sock) {
            [self destroyEntityKeyed:player.entity.uuid];
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

	NSString *action = [hash objectForKey:@"action"];
	
	if([action isEqual:@"walk"]) {
		NSString *direction = [hash objectForKey:@"direction"];
        if([direction isEqual:@"left"]) { player.entity.moving = true; player.entity.moveDirection = EntityDirectionLeft; }
        else if([direction isEqual:@"right"]) { player.entity.moving = true; player.entity.moveDirection = EntityDirectionRight; }
        else if([direction isEqual:@"stop"]) { player.entity.moving = false; }
	} else if([action isEqual:@"jump"]) {
        [(DTEntityPlayer*)player.entity jump];
    } else if([action isEqual:@"shoot"]) {
        [self createEntity:[DTEntityBullet class] setup:(EntCtor)^(DTEntityBullet *e) {
            e.position = [MutableVector2 vectorWithVector2:player.entity.position];
            e.moveDirection = e.lookDirection = player.entity.lookDirection;
        }];
    } else NSLog(@"Unknown command %@", hash);
	
	[proto readHash];
}

-(void)broadcast:(NSDictionary*)d;
{
    for(DTPlayer *player in players)
        [player.proto sendHash:d];
}

-(id)createEntity:(Class)class setup:(EntCtor)setItUp;
{
    DTEntity *ent = [[class alloc] init];
    ent.world = world;
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidS = (__bridge_transfer NSString*)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    ent.uuid = uuidS;
    
    [entities setObject:ent forKey:uuidS];
    
    if(setItUp) setItUp(ent);
    
    [self broadcast:$dict(
        @"command", @"addEntity",
        @"uuid", uuidS,
        @"rep", [ent rep]
    )];
    return ent;
}

-(void)destroyEntityKeyed:(NSString*)key;
{
    [self broadcast:$dict(
        @"command", @"removeEntity",
        @"uuid", key
    )];
    [entities removeObjectForKey:key];
}

-(NSDictionary*)optimizeDelta:(NSDictionary*)new;
{
    // todo: Save old delta, remove any attrs that haven't changed
    NSDictionary *old = previousDelta;
    previousDelta = new;
    
    if(!old) return new;
    
    NSMutableDictionary *slimmed = [NSMutableDictionary dictionaryWithCapacity:new.count];
    
    for(NSString *uuid in new.allKeys) {
        NSDictionary *oldRep = [old objectForKey:uuid];
        NSDictionary *newRep = [new objectForKey:uuid];
        if(!oldRep) { [slimmed setObject:newRep forKey:uuid]; break; }
        
        NSMutableDictionary *onlyChangedKeys = [NSMutableDictionary dictionaryWithCapacity:newRep.count];
        for(NSString *attr in newRep.allKeys)
            if(![[oldRep objectForKey:attr] isEqual:[newRep objectForKey:attr]])
                [onlyChangedKeys setObject:[newRep objectForKey:attr] forKey:attr];
        
        if(onlyChangedKeys.count > 0)
            [slimmed setObject:onlyChangedKeys forKey:uuid];
    }
    
    return slimmed;
}


-(void)tick:(double)delta;
{   
    // Physics!
    //for(DTPlayer *player in players) {
    //}
    
    [physics runWithEntities:entities.allValues world:world delta:delta];
    
    for(DTEntity *entity in entities.allValues)
        [entity tick:delta];
        
    secondsSinceLastDelta += delta;
    if(secondsSinceLastDelta > 1./kMaxServerFramerate) { // push 5 times/sec
        NSDictionary *reps = [self optimizeDelta:[entities sp_map: ^(NSString *k, id v) {
            return [v rep];
        }]];
        [self broadcast:$dict(
            @"command", @"updateEntityDeltas",
            @"reps", reps
        )];
        secondsSinceLastDelta = 0;
    }
}

#pragma mark physics and shit




/*
collides: function(a, b) {
    if(a.position.x + a.size.w < b.position.x) return false;
    if(a.position.x > b.position.x + b.size.w) return false;
    if(a.position.y + a.size.h < b.position.y) return false;
    if(a.position.y > b.position.y + b.size.h) return false;
    return true;
}
*/

@end
