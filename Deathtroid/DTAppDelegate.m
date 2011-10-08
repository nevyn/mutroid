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
@synthesize customHost;
@synthesize tabView;


-(void)start2;
{
   core = [[DTCore alloc] init];
    _view.core = core;
    
    // LOOP-DE-LOOP
    interval = 1.0f / 60.0f;
    loopTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(tick:) userInfo:nil repeats:YES];
}
-(void)start;
{
    [tabView selectTabViewItemAtIndex:1];
    [self performSelector:@selector(start2) withObject:nil afterDelay:0.05];
}

-(IBAction)startGame:(id)sender;
{
    
    [self start];
}
-(IBAction)joinSelected:(id)sender;
{


    [self start];
}
-(IBAction)joinCustom:(id)sender;
{
	[[NSUserDefaults standardUserDefaults] setObject:customHost.stringValue forKey:@"host"];
    
    [self start];
}

-(void)tick:(NSTimer*)theTimer;
{
    [core tick:interval];
    
    // Should maybe be moved to client
    // Updated separately because engine systems may run with different framerates
    [_view setNeedsDisplay:YES];
}

@end
