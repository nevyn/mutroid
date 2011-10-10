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
#import "DTClient.h"

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
@synthesize healthIndicator, healthText, messages, highscores;


-(void)start2;
{
   core = [[DTCore alloc] init];
    _view.core = core;
    
    // LOOP-DE-LOOP
    interval = 1.0f / 60.0f;
    loopTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(tick:) userInfo:nil repeats:YES];
    
	__block int oldMax = 0, oldCur = 0;
    core.client.healthCallback = ^(int max, int cur) {
		if(oldMax != max) {
			healthIndicator.maxValue = max;
			healthIndicator.criticalValue = max/3;
			healthIndicator.warningValue = max/2;
			oldMax = max;
		}
		if(oldCur != cur) {
			healthIndicator.floatValue = cur;
			healthText.stringValue = $sprintf(@"%d", cur);
			oldCur = cur;
		}
    };
	core.client.scoresCallback = ^(NSDictionary *newScores) {
		NSArray *players = [newScores keysSortedByValueUsingSelector:@selector(compare:)];
		NSMutableString *scoresString = [NSMutableString string];
		for(NSString *player in players) {
			[scoresString appendFormat:@"%14@ %2.1f\n", player, [[newScores objectForKey:player] floatValue]];
		}
		highscores.stringValue = scoresString;
	};
	core.client.messageCallback = ^(NSString *newString) {
		messages.stringValue = [newString stringByAppendingFormat:@"\n%@", messages.stringValue];
	};
}
-(void)start;
{
    [tabView selectTabViewItemAtIndex:1];
    [self performSelector:@selector(start2) withObject:nil afterDelay:0.05];
}

-(IBAction)startGame:(id)sender;
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"host"];
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
