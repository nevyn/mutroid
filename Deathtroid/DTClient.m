//
//  DTClient.m
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTClient.h"

#import <OpenGL/gl.h>

@implementation DTClient
-(id)init;
{
    return [self initConnectingTo:@"localhost" port:kDTServerDefaultPort];
}
-(id)initConnectingTo:(NSString *)host port:(NSUInteger)port;
{
    if(!(self = [super init])) return nil;
    
    // TODO<nevyn>: connect somewhere
    
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

@end
