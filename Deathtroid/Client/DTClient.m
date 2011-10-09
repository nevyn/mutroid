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

@interface DTClient () <TCAsyncHashProtocolDelegate>
@property (nonatomic, strong) DTResourceManager *resources;
@end

@implementation DTClient {
	TCAsyncHashProtocol *_proto;
    __weak DTEntity *followThis;
}
@synthesize physics;
@synthesize rooms, playerEntity, levelRepo, currentRoom;
@synthesize camera;
@synthesize resources, healthCallback;

-(id)init;
{
    return [self initConnectingTo:@"localhost" port:kDTServerDefaultPort];
}
-(id)initConnectingTo:(NSString *)host port:(NSUInteger)port;
{
    if(!(self = [super init])) return nil;
	
	self.resources = [[DTResourceManager alloc] initWithBaseURL:[[NSBundle mainBundle] URLForResource:@"resources" withExtension:nil]];
	
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
}

-(void)draw;
{
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
	glDisable(GL_TEXTURE_2D);

    glTranslatef(-camera.position.x, -camera.position.y, 0);
        
    for(DTEntity *entity in currentRoom.entities.allValues) {
        glPushMatrix();
        glTranslatef(entity.position.x, entity.position.y, 0);
        glBegin(GL_QUADS);
        if(entity.damageFlashTimer > 0) {
            glColor3f(1., entity.damageFlashTimer*5, entity.damageFlashTimer*5);
        } else
            glColor3f(1., 0, 0.);
        glVertex3f(0., 0., 0.);
        glVertex3f(entity.size.x, 0., 0.);
        glVertex3f(entity.size.x, entity.size.y, 0.);
        glVertex3f(0., entity.size.y, 0);
        glEnd();
        glColor3f(0,0,1.);
        glBegin(GL_POINTS);
        if(entity.lookDirection == EntityDirectionLeft)
            glVertex3f(0, entity.size.y/3, 0);
        else if(entity.lookDirection == EntityDirectionRight)
            glVertex3f(entity.size.x, entity.size.y/3, 0);
        glEnd();
        glPopMatrix();
    }
}


#pragma mark Network
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port;
{
	NSLog(@"Connected to server: %@", sock);
	[_proto readHash];
	
}
-(void)onSocketDidDisconnect:(AsyncSocket *)sock;
{
	NSLog(@"Lost connection to server: %@", sock);
}

#define done() { 	[_proto readHash]; return; }
-(void)protocol:(TCAsyncHashProtocol*)proto receivedHash:(NSDictionary*)hash;
{
    NSString *command = [hash objectForKey:@"command"];
    
    if([command isEqual:@"updateEntityDeltas"]) {
        NSDictionary *reps = $notNull([hash objectForKey:@"reps"]);
        NSString *roomName = $notNull([hash objectForKey:@"room"]);
        DTRoom *room = $notNull([rooms objectForKey:roomName]);
        
        for(NSString *key in reps) {
            DTEntity *ent = $notNull([room.entities objectForKey:key]);
            [ent updateFromRep:[reps objectForKey:key]];
        }
        
    } else if([command isEqual:@"addEntity"]) {
        NSString *roomName = $notNull([hash objectForKey:@"room"]);
        DTRoom *room = [rooms objectForKey:roomName];
        if(!room)
            done();
        
        NSString *key = $notNull([hash objectForKey:@"uuid"]);
        NSDictionary *rep = $notNull([hash objectForKey:@"rep"]);
        
        DTEntity *ent = [[DTEntity alloc] initWithRep:rep];
        ent.uuid = key;
        ent.world = room.world;
        
        [room.entities setObject:ent forKey:key];
        
    } else if([command isEqual:@"playerEntity"]) {
        NSString *key = $notNull([hash objectForKey:@"uuid"]);
        NSString *roomName = $notNull([hash objectForKey:@"room"]);
        DTRoom *room = $notNull([rooms objectForKey:roomName]);
        
        currentRoom = room;
        playerEntity = [room.entities objectForKey:key];
        
    }else if([command isEqual:@"removeEntity"]) {
        NSString *key = $notNull([hash objectForKey:@"uuid"]);
        NSString *roomName = $notNull([hash objectForKey:@"room"]);
        DTRoom *room = [rooms objectForKey:roomName];
        if(!room) done();
        
        [room.entities removeObjectForKey:key];
    
    } else if([command isEqual:@"cameraFollow"]) {
        NSString *roomName = $notNull([hash objectForKey:@"room"]);
        DTRoom *room = $notNull([rooms objectForKey:roomName]);
        
        DTEntity *f = $notNull([room.entities objectForKey:[hash objectForKey:@"uuid"]]);
        followThis = f; // silence stupid warning :/
        
    } else if([command isEqual:@"loadRoom"]) {
        NSString *uuid = $notNull([hash objectForKey:@"uuid"]);
        
        // TODO<nevyn>: reuse loaded room instance
        
        [levelRepo fetchRoomNamed:$notNull([hash objectForKey:@"name"]) ofClass:[DTRoom class] whenDone:^(DTRoom *room, NSError *err) {
            if(!room) {
                [NSApp presentError:err];
                return;
            }
            [rooms setObject:room forKey:uuid];
            room.uuid = uuid;
            
            for(NSString *key in $notNull([hash objectForKey:@"entities"])) {
                NSDictionary *rep = [[hash objectForKey:@"entities"] objectForKey:key];
                DTEntity *ent = [[DTEntity alloc] initWithRep:rep];
                ent.uuid = key;
                ent.world = room.world;
                [room.entities setObject:ent forKey:key];
            }
        }];
    } else if([command isEqual:@"entityDamaged"]) {
        NSString *roomName = $notNull([hash objectForKey:@"room"]);
        DTRoom *room = [rooms objectForKey:roomName];
        if(!room) done();
        
        DTEntity *e = $notNull([room.entities objectForKey:[hash objectForKey:@"uuid"]]);
        
        int d = [[hash objectForKey:@"damage"] intValue];
        [e damage:d];
    } else NSLog(@"Unknown server command: %@", hash);
    
    done()
}

#pragma mark Dunno
-(void)walkLeft;
{
    playerEntity.moving = true;
    playerEntity.moveDirection = EntityDirectionLeft;
	[_proto sendHash:$dict(@"action", @"walk",   @"direction", @"left")];
}
-(void)stopWalk;
{
    playerEntity.moving = false;
	[_proto sendHash:$dict(@"action", @"walk",   @"direction", @"stop")];
}
-(void)walkRight;
{
    playerEntity.moving = true;
    playerEntity.moveDirection = EntityDirectionRight;
	[_proto sendHash:$dict(@"action", @"walk",   @"direction", @"right")];
}
-(void)jump;
{
    [(DTEntityPlayer*)playerEntity jump];
    [_proto sendHash:$dict(@"action", @"jump")];
}
-(void)shoot;
{
    [_proto sendHash:$dict(@"action",@"shoot")];
}


@end
