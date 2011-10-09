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

@interface DTClient () <TCAsyncHashProtocolDelegate>
@end

@implementation DTClient {
	TCAsyncHashProtocol *_proto;
    __weak DTEntity *followThis;
}
@synthesize physics;
@synthesize entities, level, world, playerEntity, levelRepo;
@synthesize camera;

-(id)init;
{
    return [self initConnectingTo:@"localhost" port:kDTServerDefaultPort];
}
-(id)initConnectingTo:(NSString *)host port:(NSUInteger)port;
{
    if(!(self = [super init])) return nil;
	
	AsyncSocket *socket = [[AsyncSocket alloc] initWithDelegate:self];
	socket.delegate = _proto = [[TCAsyncHashProtocol alloc] initWithSocket:socket delegate:self];
	NSError *err = nil;
	if(![socket connectToHost:host onPort:port error:&err]) {
		[NSApp presentError:err];
		return nil;
	}
    
    entities = [NSMutableDictionary dictionary];
    
    // Insert code here to initialize your application
    glViewport(0, 0, 640, 480);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0., 20.0f, 15.f, 0., -1., 1.);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glDisable(GL_DEPTH_TEST);
    //glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
    glDisable(GL_CULL_FACE);
    //glEnable(GL_BLEND);
    //glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    
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
    
    for(DTEntity *entity in entities.allValues)
        [entity tick:delta];
    
    if(world)
        [physics runWithEntities:entities.allValues world:world delta:delta];
}

-(void)draw;
{
    glClear(GL_COLOR_BUFFER_BIT);
    glLoadIdentity();
        
    for(DTLayer *layer in level.layers) {
        glPushMatrix();
        glTranslatef(-camera.position.x * layer.depth, -camera.position.y * layer.depth, 0);
        glBegin(GL_QUADS);
        glColor3f(layer.depth, layer.depth, layer.depth);
        DTMap *map = layer.map;
        for(int h=0; h<map.height; h++) {
            for(int w=0; w<map.width; w++) {
                if(map.tiles[h*map.width+w] == 0) continue;
                glVertex2f(w, h);
                glVertex2f(w+1, h);
                glVertex2f(w+1, h+1);
                glVertex2f(w, h+1);
            }
        }
        glEnd();
        glPopMatrix();
    }

    glTranslatef(-camera.position.x, -camera.position.y, 0);
        
    for(DTEntity *entity in entities.allValues) {
        glPushMatrix();
        glTranslatef(entity.position.x, entity.position.y, 0);
        glBegin(GL_QUADS);
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

-(void)protocol:(TCAsyncHashProtocol*)proto receivedHash:(NSDictionary*)hash;
{
    NSString *command = [hash objectForKey:@"command"];
    
    if([command isEqual:@"updateEntityDeltas"]) {
        NSDictionary *reps = $notNull([hash objectForKey:@"reps"]);
        
        for(NSString *key in reps) {
            DTEntity *ent = $notNull([entities objectForKey:key]);
            [ent updateFromRep:[reps objectForKey:key]];
        }
        
    } else if([command isEqual:@"addEntity"]) {
        NSString *key = $notNull([hash objectForKey:@"uuid"]);
        NSDictionary *rep = $notNull([hash objectForKey:@"rep"]);
        
        DTEntity *ent = [[DTEntity alloc] initWithRep:rep];
        ent.uuid = key;
        // TODO<nevyn>: Per, laga detta.
//        ent.world = world;
        
        [entities setObject:ent forKey:key];
        
    } else if([command isEqual:@"playerEntity"]) {
        NSString *key = $notNull([hash objectForKey:@"uuid"]);
        playerEntity = [entities objectForKey:key];
        
    }else if([command isEqual:@"removeEntity"]) {
        NSString *key = $notNull([hash objectForKey:@"uuid"]);
        
        [entities removeObjectForKey:key];
    
    } else if([command isEqual:@"cameraFollow"]) {
        DTEntity *f = $notNull([entities objectForKey:[hash objectForKey:@"uuid"]]);
        followThis = f; // silence stupid warning :/
        
    } else if([command isEqual:@"loadLevel"]) {
        level = nil;
        [entities removeAllObjects];
        [levelRepo fetchRoomNamed:$notNull([hash objectForKey:@"name"]) whenDone:^(DTRoom *newLevel, NSError *err) {
            if(!newLevel) {
                [NSApp presentError:err];
                return;
            }
            level = newLevel;
            world = [[DTWorld alloc] initWithLevel:newLevel];
        }];
    } else NSLog(@"Unknown server command: %@", hash);
    
	[_proto readHash];
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
