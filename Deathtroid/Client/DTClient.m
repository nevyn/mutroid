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

#import "DTServer.h"
#import "DTLevel.h"
#import "DTLayer.h"
#import "DTMap.h"
#import "DTEntity.h"
#import "Vector2.h"

@interface DTClient () <TCAsyncHashProtocolDelegate>
@end

@implementation DTClient {
	TCAsyncHashProtocol *_proto;
}
@synthesize entities, level;

@synthesize server;

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
    
    //entities = [NSMutableArray array];
    
    //DTEntity *playerEnt = [[DTEntity alloc] init];
    //[entities addObject:playerEnt];
    
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
    //glPointSize(5.0f);
    
    
    glClearColor(0.0, 0.0, 0.0, 1.0);

    
    return self;
}

-(void)tick:(double)delta;
{
    // Ticka de som ska tickas?
}

-(void)draw;
{
    glClear(GL_COLOR_BUFFER_BIT);
    glLoadIdentity();
    
    glBegin(GL_QUADS);
    glColor3f(1, 1, 1);
    for(DTLayer *layer in level.layers) {
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
    }
    glEnd();

        
    glColor3f(1., 0, 0.);
    for(DTEntity *entity in entities) {
        glPushMatrix();
        glTranslatef(entity.position.x, entity.position.y, 0);
        glBegin(GL_QUADS);
        glVertex3f(0., 0., 0.);
        glVertex3f(1., 0., 0.);
        glVertex3f(1., 1., 0.);
        glVertex3f(0., 1.0, 0);
        glEnd();
        glPopMatrix();
    }
}


#pragma mark Network
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port;
{
	NSLog(@"Connected to server: %@", sock);
	[_proto readHash];
	[_proto sendHash:$dict(@"hello", @"world")];
	
}
-(void)onSocketDidDisconnect:(AsyncSocket *)sock;
{
	NSLog(@"Lost connection to server: %@", sock);
}

-(void)protocol:(TCAsyncHashProtocol*)proto receivedHash:(NSDictionary*)hash;
{
	NSLog(@"Hello! %@", hash);
	[_proto readHash];
}

@end
