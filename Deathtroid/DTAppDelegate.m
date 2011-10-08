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
    core = [[DTCore alloc] init];
    _view.core = core;
    
    // LOOP-DE-LOOP
    interval = 1.0f / 60.0f;
    loopTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(tick:) userInfo:nil repeats:YES];
}

-(void)tick:(NSTimer*)theTimer;
{
    [core tick:interval];
    
    // Should maybe be moved to client
    // Updated separately because engine systems may run with different framerates
    [_view setNeedsDisplay:YES];
}

@end
