//
//  DTClient.m
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTClient.h"
#import "TCAsyncHashProtocol.h"
#import <OpenGL/gl.h>

#import "DTRoom.h"
#import "DTLayer.h"
#import "DTMap.h"
#import "DTEntity.h"
#import "Vector2.h"
#import "DTCamera.h"
#import "DTPhysics.h"
#import "DTWorld.h"
#import "DTEntity.h"
#import "DTEntityPlayer.h"
#import "DTLevelRepository.h"

#import "DTResourceManager.h"
#import "DTTexture.h"
#import "DTSpriteMap.h"
#import "DTRenderEntities.h"

@interface DTClient () <TCAsyncHashProtocolDelegate>
@property (nonatomic, strong) DTResourceManager *resources;
@end

@implementation DTClient {
	TCAsyncHashProtocol *_proto;
    __weak DTEntity *followThis;
	uint64_t frameCount;
}
@synthesize physics;
@synthesize rooms, playerEntity, levelRepo, currentRoom;
@synthesize camera;
@synthesize resources, healthCallback, scoresCallback, messageCallback;
@synthesize entityRenderer;

-(id)init;
{
    return [self initConnectingTo:@"localhost" port:kDTServerDefaultPort];
}
-(id)initConnectingTo:(NSString *)host port:(NSUInteger)port;
{
    if(!(self = [super init])) return nil;
	
	self.resources = [[DTResourceManager alloc] initWithBaseURL:[[NSBundle mainBundle] URLForResource:@"resources" withExtension:nil]];
    self.entityRenderer = [[DTRenderEntities alloc] init];
	
	AsyncSocket *socket = [[AsyncSocket alloc] initWithDelegate:self];
	socket.delegate = _proto = [[TCAsyncHashProtocol alloc] initWithSocket:socket delegate:self];
	NSError *err = nil;
	if(![socket connectToHost:host onPort:port error:&err]) {
		[NSApp presentError:err];
		return nil;
	}
    
    rooms = [NSMutableDictionary dictionary];
    
    // Insert code here to initialize your application
    glViewport(0, 0, 640, 480);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0., 20.0f, 15.f, 0., -1., 1.);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glDisable(GL_DEPTH_TEST);
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
    
    glDisable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    
    //glEnable(GL_TEXTURE_2D);
    glPointSize(5.0f);
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    
    camera = [[DTCamera alloc] init];
    
#if DUMB_CLIENT
    physics = nil;
#else
    physics = [[DTPhysics alloc] init];
#endif

        
    return self;
}

-(void)tick:(double)delta;
{
    // Ticka de som ska tickas?
    camera.position.x = followThis.position.x - 10;
    
    for(DTEntity *entity in currentRoom.entities.allValues)
        [entity tick:delta];
    
    if(currentRoom.world)
        [physics runWithEntities:currentRoom.entities.allValues world:currentRoom.world delta:delta];
        
    if(self.healthCallback) self.healthCallback(followThis.maxHealth, followThis.health);
    
    [self.entityRenderer tick:delta];
}

-(void)draw;
{
	frameCount++;
	
    glClear(GL_COLOR_BUFFER_BIT);
    glLoadIdentity();
	glEnable(GL_TEXTURE_2D);
    	
    for(DTLayer *layer in currentRoom.layers) {
        DTTexture *texture = [resources resourceNamed:$sprintf(@"%@.texture", layer.tilemapName)];
        [texture use];
        glPushMatrix();
        glTranslatef(-camera.position.x * layer.depth, -camera.position.y * layer.depth, 0);
        glBegin(GL_QUADS);
        glColor3f(1,1,1);
        DTMap *map = layer.map;
        for(int i=0; i<(layer.repeatX?2:1); i++) {
            for(int h=0; h<map.height; h++) {
                for(int w=0; w<map.width; w++) {
                
                    int x = i*map.width + w;
                    int y = h;
                
                    int tile = map.tiles[h*map.width+w];
                    if(tile == 0) continue;
                    tile--;
                    float r = 0.125;
                    float u = r * (int)(tile % 8);
                    float v = r * (int)(tile / 8);
                    glTexCoord2f(u, v); glVertex2f(x, y);
                    glTexCoord2f(u+r, v); glVertex2f(x+1, y);
                    glTexCoord2f(u+r, v+r); glVertex2f(x+1, y+1);
                    glTexCoord2f(u, v+r); glVertex2f(x, y+1);
                }
            }
        }
        glEnd();
        glPopMatrix();
    }
	//glDisable(GL_TEXTURE_2D);
	
    [self.entityRenderer draw:camera frameCount:frameCount];
}


#pragma mark -
#pragma mark Network
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port;
{
	NSLog(@"Connected to server: %@", sock);
	[_proto sendHash:$dict(
		@"command", @"hello",
		@"playerName", [[NSUserDefaults standardUserDefaults] objectForKey:@"playerName"]
	)];
	[_proto readHash];
	
}
-(void)onSocketDidDisconnect:(AsyncSocket *)sock;
{
	NSLog(@"Lost connection to server: %@", sock);
}






#pragma mark -
#pragma mark Server commands

-(void)protocol:(TCAsyncHashProtocol*)proto receivedHash:(NSDictionary*)hash;
{
    NSString *command = [hash objectForKey:@"command"];
    
    NSString *selNs = $sprintf(@"command:%@:", command);
    SEL sel = NSSelectorFromString(selNs);
    if([self respondsToSelector:sel])
        ((void(*)(id, SEL, id, id))[self methodForSelector:sel])(self, sel, proto, hash);
    else
        NSLog(@"Unknown command: %@", hash);
        
    [proto readHash];
}

-(void)protocol:(TCAsyncHashProtocol*)proto receivedRequest:(NSDictionary*)hash responder:(TCAsyncHashProtocolResponseCallback)responder;
{
    SEL sel = NSSelectorFromString($sprintf(@"request:%@:responder:", [hash objectForKey:@"question"]));
    if([self respondsToSelector:sel])
        ((void(*)(id, SEL, id, id, TCAsyncHashProtocolResponseCallback))[self methodForSelector:sel])(self, sel, proto, hash, responder);
    else {
        responder($dict(@"error", @"Unknown request"));
        NSLog(@"Unknown request %@", hash);
    }

	[proto readHash];

}

#pragma mark Entities
-(void)command:(id)proto updateEntityDeltas:(NSDictionary*)hash;
{
    NSDictionary *reps = $notNull([hash objectForKey:@"reps"]);
    NSString *roomName = $notNull([hash objectForKey:@"room"]);
    DTRoom *room = $notNull([rooms objectForKey:roomName]);
    
    for(NSString *key in reps) {
        DTEntity *ent = $notNull([room.entities objectForKey:key]);
        [ent updateFromRep:[reps objectForKey:key]];
    }
}
-(void)command:(id)proto addEntity:(NSDictionary*)hash;
{
    NSString *roomName = $notNull([hash objectForKey:@"room"]);
    DTRoom *room = $notNull([rooms objectForKey:roomName]);
    
    NSString *key = $notNull([hash objectForKey:@"uuid"]);
    NSDictionary *rep = $notNull([hash objectForKey:@"rep"]);
    
    DTEntity *ent = [[DTEntity alloc] initWithRep:rep];
    ent.uuid = key;
    ent.world = room.world;
    
    [self.entityRenderer addEntity:ent];
    [room.entities setObject:ent forKey:key];
}
-(void)command:(id)proto removeEntity:(NSDictionary*)hash;
{
    NSString *key = $notNull([hash objectForKey:@"uuid"]);
    NSString *roomName = $notNull([hash objectForKey:@"room"]);
    DTRoom *room = [rooms objectForKey:roomName];
    if(!room) return;
    
    [self.entityRenderer removeEntity:[room.entities objectForKey:key]];
    [room.entities removeObjectForKey:key];
}

#pragma mark about this player
-(void)command:(id)proto playerEntity:(NSDictionary*)hash;
{
    NSString *key = $notNull([hash objectForKey:@"uuid"]);
    NSString *roomName = $notNull([hash objectForKey:@"room"]);
    DTRoom *room = $notNull([rooms objectForKey:roomName]);
    
    playerEntity = [room.entities objectForKey:key];
}

-(void)command:(id)proto cameraFollow:(NSDictionary*)hash;
{
    NSString *roomName = $notNull([hash objectForKey:@"room"]);
    DTRoom *room = $notNull([rooms objectForKey:roomName]);
    
    DTEntity *f = $notNull([room.entities objectForKey:[hash objectForKey:@"uuid"]]);
    followThis = f; // silence stupid warning :/
}

#pragma mark rooms
-(void)request:(id)proto joinRoom:(NSDictionary*)hash responder:(TCAsyncHashProtocolResponseCallback)responder;
{
    NSString *name = $notNull([hash objectForKey:@"name"]);
    NSString *uuid = $notNull([hash objectForKey:@"uuid"]);
    
    currentRoom = nil;
    [self.entityRenderer setEntitiesToDraw:[NSArray array]];
    
    __block DTRoom *room = [rooms objectForKey:uuid];
    void(^then)() = ^ {
        currentRoom = room;
        
        [proto requestHash:$dict(@"question", @"getRoom", @"uuid", uuid) response:^(NSDictionary *hash2) {
            NSDictionary *reps = $notNull([hash2 objectForKey:@"entities"]);
            
            for(NSString *key in reps) {
                NSDictionary *rep = [reps objectForKey:key];
                DTEntity *existing = [room.entities objectForKey:key];
                if(existing)
                    [existing updateFromRep:rep];
                else {
                    DTEntity *ent = [[DTEntity alloc] initWithRep:rep];
                    ent.uuid = key;
                    ent.world = room.world;
                    [room.entities setObject:ent forKey:key];
                }
            }
        
            NSMutableSet *toDelete = [NSMutableSet setWithArray:[room.entities allKeys]];
            [toDelete minusSet:[NSSet setWithArray:reps.allKeys]];
            for(NSArray *key in toDelete) [room.entities removeObjectForKey:key];
            
            [self.entityRenderer setEntitiesToDraw:room.entities.allValues];
        
            responder($dict(@"status", @"done"));        
        }];
    };
    
    if(!room) {
        [levelRepo fetchRoomNamed:name ofClass:[DTRoom class] whenDone:^(DTRoom *newRoom, NSError *err) {
            if(!newRoom) {
                [NSApp presentError:err];
                return;
            }
            room = newRoom;
            room.uuid = uuid;
            [rooms setObject:room forKey:uuid];
            then();
        }];
    } else then();
}
-(void)command:(id)proto entityDamaged:(NSDictionary*)hash;
{
    NSString *roomName = $notNull([hash objectForKey:@"room"]);
    DTRoom *room = $notNull([rooms objectForKey:roomName]);
    
    DTEntity *e = $notNull([room.entities objectForKey:[hash objectForKey:@"uuid"]]);
    DTEntity *other = [room.entities objectForKey:[hash objectForKey:@"killer"]];
    
    int d = [$notNull([hash objectForKey:@"damage"]) intValue];
    Vector2 *location = [[Vector2 alloc] initWithRep:$notNull([hash objectForKey:@"location"])];
    [e damage:d from:location killer:other];
}

-(void)command:(id)proto entityCounterpartMessage:(NSDictionary*)hash;
{
    NSString *roomName = $notNull([hash objectForKey:@"room"]);
    DTRoom *room = $notNull([rooms objectForKey:roomName]);
	
	DTEntity *ent = $notNull([room.entities objectForKey:[hash objectForKey:@"uuid"]]);
	
	[ent receivedFromCounterpart:$notNull([hash objectForKey:@"message"])];
}


#pragma mark meta
-(void)command:(id)proto updateScoreboard:(NSDictionary*)hash;
{
    if(self.scoresCallback) self.scoresCallback([hash objectForKey:@"scoreboard"]);
}
-(void)command:(id)proto displayMessage:(NSDictionary*)hash;
{
    if(self.messageCallback) self.messageCallback([hash objectForKey:@"message"]);
}






#pragma mark -
#pragma mark Player actions
-(void)walkLeft;
{
    playerEntity.moving = true;
    playerEntity.moveDirection = EntityDirectionLeft;
	[_proto sendHash:$dict(@"command", @"action", @"action", @"walk",   @"direction", @"left")];
}
-(void)stopWalk;
{
    playerEntity.moving = false;
	[_proto sendHash:$dict(@"command", @"action", @"action", @"walk",   @"direction", @"stop")];
}
-(void)walkRight;
{
    playerEntity.moving = true;
    playerEntity.moveDirection = EntityDirectionRight;
	[_proto sendHash:$dict(@"command", @"action", @"action", @"walk",   @"direction", @"right")];
}
-(void)jump;
{
    [(DTEntityPlayer*)playerEntity jump];
    [_proto sendHash:$dict(@"command", @"action", @"action", @"jump")];
}
-(void)shoot;
{
    [_proto sendHash:$dict(@"command", @"action", @"action",@"shoot")];
}


@end
