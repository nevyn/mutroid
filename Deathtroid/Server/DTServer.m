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
#import "DTEntityRipper.h"
#import "DTEntityZoomer.h"
#import "Vector2.h"

@implementation DTServer {
    AsyncSocket *_sock;
	NSMutableArray *players;
}

@synthesize entities;
@synthesize client, level, world;

-(id)init;
{
    return [self initListeningOnPort:kDTServerDefaultPort];
}
-(id)initListeningOnPort:(NSUInteger)port;
{
    if(!(self = [super init])) return nil;
    
    players = [NSMutableArray array];
    entities = [NSMutableArray array];
    
    world = [[DTWorld alloc] init];
    
    level = [[DTLevel alloc] init];
    
    world.level = level;

  //  DTPlayer *player = [[DTPlayer alloc] init];
  //  player.entity = [[DTEntity alloc] init];
  //  [entities addObject:player.entity];
  //  [players addObject:player];
    
    DTEntityRipper *ripper = [[DTEntityRipper alloc] initWithWorld:world];
    ripper.position.x = 11;
    ripper.position.y = 7;
    ripper.size.y = 0.5;
    [entities addObject:ripper];
    
    ripper = [[DTEntityRipper alloc] init];
    ripper.position.x = 5;
    ripper.position.y = 5.2;
    ripper.size.y = 0.5;
    [entities addObject:ripper];
    
    DTEntityZoomer *zoomer = [[DTEntityZoomer alloc] init];
    zoomer.position.x = 8;
    zoomer.position.y = 8;
    [entities addObject:zoomer];
    
    _sock = [[AsyncSocket alloc] initWithDelegate:self];
	_sock.delegate = self;
	NSError *err = nil;
	if(![_sock acceptOnPort:port error:&err]) {
		[NSApp presentError:err];
		return nil;
	}
    
    return self;
}

-(void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket;
{
	NSLog(@"Gained client: %@", newSocket);
	TCAsyncHashProtocol *clientProto = [[TCAsyncHashProtocol alloc] initWithSocket:newSocket delegate:self];
	
	DTPlayer *player = [DTPlayer new];
	player.proto = clientProto;
	
	[players addObject:player];
	
	DTEntity *avatar = [DTEntity new];
    player.entity = avatar;
	[entities addObject:avatar];
	
	[clientProto readHash];
}
-(void)onSocketDidDisconnect:(AsyncSocket *)sock;
{
	NSLog(@"Lost client: %@", sock);
	sock.delegate = nil;
	for(DTPlayer *player in players)
		if(player.proto.socket == sock) {
			[players removeObject:player];
			break;
		}
}

-(void)protocol:(TCAsyncHashProtocol*)proto receivedHash:(NSDictionary*)hash;
{
	NSLog(@"Hello! %@", hash);
	
	DTPlayer *player = nil;
	for(DTPlayer *pl in players)
		if(pl.proto == proto) {
			player = pl; break;
		}
	NSAssert(player, @"Unknown player sent us stuff");

	NSString *action = [hash objectForKey:@"action"];
	
	if([action isEqual:@"walk"]) {
		NSString *direction = [hash objectForKey:@"direction"];
		player.direction = [direction isEqual:@"left"] ? EntityDirectionLeft :
			[direction isEqual:@"right"] ? EntityDirectionRight :
			EntityDirectionNone;
	} else if([action isEqual:@"jump"]) {
        player.entity.velocity.y = -5;
    } else NSLog(@"Unknown command %@", hash);
	
	[proto readHash];
}

-(void)tick:(double)delta;
{    
    // Physics!
    for(DTPlayer *player in players) {
        DTEntity *entity = player.entity;
        if(player.direction == EntityDirectionLeft)
            entity.velocity.x = -5;
        else if(player.direction == EntityDirectionRight)
            entity.velocity.x = 5;
        else
            entity.velocity.x = 0;
    }
    
    for(DTEntity *entity in entities) {
        if(entity.gravity && entity.velocity.y < 10)
            entity.velocity.y += 0.1;

        [self collideEntityWithWorld:entity delta:delta];
        
        [entity tick:delta];
    }
}


-(void)collideEntityWithWorld:(DTEntity*)entity delta:(double)delta;
{
    Vector2 *move = [entity.velocity vectorByMultiplyingWithScalar:delta];
    
    DTCollisionInfo *info = [world traceBox:entity.size from:entity.position to:[entity.position vectorByAddingVector:move]];
    
    if(!info.x) entity.position.x += move.x; else { entity.position.x = info.collisionPosition.x; entity.velocity.x = 0; }
    if(!info.y) entity.position.y += move.y; else { entity.position.y = info.collisionPosition.y; entity.velocity.y = 0; }
}



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
