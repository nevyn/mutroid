#import "DTServer.h"
#import "TCAsyncHashProtocol.h"

@interface DTServer () <TCAsyncHashProtocolDelegate>
@end

#import "AsyncSocket.h"
#import "DTLevel.h"
#import "DTLayer.h"
#import "DTMap.h"
#import "DTPlayer.h"
#import "DTEntity.h"
#import "DTEntityRipper.h"
#import "Vector2.h"

@implementation DTServer {
    AsyncSocket *_sock;
	NSMutableArray *players;
}

@synthesize entities;
@synthesize client, level;

-(id)init;
{
    return [self initListeningOnPort:kDTServerDefaultPort];
}
-(id)initListeningOnPort:(NSUInteger)port;
{
    if(!(self = [super init])) return nil;
    
    players = [NSMutableArray array];
    entities = [NSMutableArray array];
    
    level = [[DTLevel alloc] init];

  //  DTPlayer *player = [[DTPlayer alloc] init];
  //  player.entity = [[DTEntity alloc] init];
  //  [entities addObject:player.entity];
  //  [players addObject:player];
    
    DTEntityRipper *ripper = [[DTEntityRipper alloc] init];
    ripper.position.x = 11;
    ripper.position.y = 7;
    ripper.size.y = 0.5;
    [entities addObject:ripper];
    
    ripper = [[DTEntityRipper alloc] init];
    ripper.position.x = 5;
    ripper.position.y = 5.2;
    ripper.size.y = 0.5;
    [entities addObject:ripper];
        
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
        
        if(entity.velocity.y < 10)
            entity.velocity.y += 0.1;
    }
    
    for(DTEntity *entity in entities) {
        [self collideEntityWithWorld:entity delta:delta];
    }
}


-(void)collideEntityWithWorld:(DTEntity*)entity delta:(double)delta;
{
    float vx = entity.velocity.x * delta;
    float vy = entity.velocity.y * delta;
    
    int steps = ceil(vx*vx+vy*vy);
    
    DTMap *map = ((DTLayer*)[level.layers objectAtIndex:level.entityLayerIndex]).map;
    
    for(int i=0; i<steps; ++i) {
        BOOL collided = [self collideEntityWithWorldStep:entity vx:vx/steps vy:vy/steps map:map];
        if(collided) {
            //[entity didCollideWithWorld];
            break;
        }        
    }    
}


-(BOOL)collideEntityWithWorldStep:(DTEntity*)entity vx:(float)vx vy:(float)vy map:(DTMap*)map;
{
    int *tiles = map.tiles;
    
    BOOL collidedX = false;
    BOOL collidedY = false;
    
    float gx = entity.position.x;
    float gy = entity.position.y;
    float oldvx = entity.velocity.x;
    float oldvy = entity.velocity.y;
    
    if(vx != 0.0f) {
        gx += vx;
        float coordx = vx < 0 ? gx : gx + entity.size.x - 0.0001;
        int from = (int)gy;
        int to = (int)(gy + entity.size.y - 0.0001);
        for(int y=from; y<=to; ++y) {
            if(tiles[y*map.width+(int)coordx] > 0) {
                gx = vx < 0 ? ceil(coordx) : floor(coordx) - entity.size.x;
                collidedX = true;
                break;
            }
        }
    }
    
    if(vy != 0.0f) {
        gy += vy;
        float coordy = vy < 0 ? gy : gy + entity.size.y - 0.0001;
        int from = (int)gx;
        int to = (int)(gx + entity.size.x - 0.0001);
        for(int x=from; x<=to; ++x) {
            if(tiles[(int)coordy*map.width+x] > 0) {
                gy = vy < 0 ? ceil(coordy) : floor(coordy) - entity.size.y;
                collidedY = true;
                break;
            }
        }
    }
    
    entity.position.x += vx;
    entity.position.y += vy;
        
    if(collidedX || collidedY) {
        
        if(entity.collisionType == EntityCollisionTypeStop) {
            if(collidedX) { entity.position.x = gx; entity.velocity.x = 0; }
            if(collidedY) { entity.position.y = gy; entity.velocity.y = 0; }
        }
        
        DTCollisionInfo *info = [[DTCollisionInfo alloc] init];
        info.x = collidedX;
        info.y = collidedY;
        info.entity = nil;
        info.collisionPosition = [Vector2 vectorWithX:gx y:gy];
        info.velocity = [Vector2 vectorWithX:oldvx y:oldvy];
        [entity didCollideWithWorld:info];
    }
    return collidedX || collidedY;
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
