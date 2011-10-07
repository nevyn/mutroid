//
//  DTAppDelegate.m
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTAppDelegate.h"

#import "DTView.h"
#import "DTCore.h"

#import <OpenGL/gl.h>

@interface DTAppDelegate ()
@property (nonatomic,strong) DTCore *core;
@end

@implementation DTAppDelegate

@synthesize window = _window;
@synthesize view = _view;
@synthesize core;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    glViewport(0, 0, 640, 480);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0., 10.0f, 7.5f, 0., -1., 1.);
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
    
    core = [[DTCore alloc] init];
    _view.core = core;
    
    
    // LOOP-DE-LOOP
    float interval = 1.0f / 60.0f;
    loopTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(tick:) userInfo:nil repeats:YES];
}

-(void)tick:(NSTimer*)theTimer;
{
    //[server tick];
    //[client tick];
    
    // Should maybe be moved to client
    // Updated separately because engine systems may run with different framerates
    [_view setNeedsDisplay:YES];
}

@end
