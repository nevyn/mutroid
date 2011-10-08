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
#import "DTEntity.h"

@interface DTClient () <TCAsyncHashProtocolDelegate>
@end

@implementation DTClient {
	TCAsyncHashProtocol *_proto;
}
@synthesize entities;

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
    
    entities = [NSMutableArray array];
    
    DTEntity *playerEnt = [[DTEntity alloc] init];
    [entities addObject:playerEnt];
    
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
    
    //glTranslatef(0, 0, -10);
    
    glBegin(GL_TRIANGLES);
    glColor3f(1., 1, 1.);
    
    glVertex3f(0., 0., 0.);
    glVertex3f(1., 0., 0.);
    glVertex3f(0., 1., 0.);
    
    glEnd();
}

-(void)walkLeft; { printf("Gå vänster\n"); }
-(void)stopWalkLeft; { printf("Sluta gå vänster\n"); }
-(void)walkRight; { printf("Gå höger\n"); }
-(void)stopWalkRight; { printf("Sluta gå höger\n"); }


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
