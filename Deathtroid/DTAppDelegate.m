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
#import "DTResourceManager.h"
#import <CocoaLibSpotify/CocoaLibSpotify.h>

#import <OpenGL/gl.h>

__weak DTAppDelegate *__singleton;

@interface DTAppDelegate () <SPSessionDelegate>
@property (nonatomic,strong) DTCore *core;
@end

@implementation DTAppDelegate

+ (DTAppDelegate*)sharedAppDelegate
{
    return __singleton;
}

@synthesize window = _window;
@synthesize view = _view;
@synthesize core;
@synthesize customHost;
@synthesize tabView;
@synthesize healthIndicator, healthText, messages, highscores;

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    __singleton = self;
    
    NSString *currentPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"resourcePath"];
    if(!currentPath || [currentPath rangeOfString:@".app"].location != NSNotFound)
        [[NSUserDefaults standardUserDefaults] setObject:[DTResourceManager sharedManager].baseURL.path forKey:@"resourcePath"];
    
    NSError *err;
    if(![SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"spkey" ofType:@"key"]] userAgent:@"Mutroid" loadingPolicy:SPAsyncLoadingManual error:&err])
        NSLog(@"No spfy :( %@", err);
    _audioOut = [DTAudioController new];
    [[SPSession sharedSession] setDelegate:self];
    [[SPSession sharedSession] setAudioDeliveryDelegate:_audioOut];

    if(_spUser.stringValue.length && _spPass.stringValue.length)
        [self spotifyLogin:nil];
}
- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)spotifyLogin:(id)sender
{
    [[SPSession sharedSession] attemptLoginWithUserName:self.spUser.stringValue password:self.spPass.stringValue];
}

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
    
    [self.view performSelector:@selector(enterFullScreenMode:withOptions:) withObject:[NSScreen mainScreen] afterDelay:0.5];
}
-(void)start;
{
    if(_usernameField.stringValue.length == 0 || ![self.spStatusLabel.stringValue isEqual:@"Logged in"]) {
        NSRunAlertPanel(@"Missing username or spotify", @"You have to provide a username, and you have to log into spotify, before you can play.", @"OK", nil, nil);
        return;
    }
    
    [DTResourceManager sharedManager].baseURL = [NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] objectForKey:@"resourcePath"]];
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
    if(core.drawing)
        [_view setNeedsDisplay:YES];
}

- (IBAction)toggleDebug:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:![[NSUserDefaults standardUserDefaults] boolForKey:@"debug"] forKey:@"debug"];
}

#pragma woot Spotify
-(void)sessionDidLoginSuccessfully:(SPSession *)aSession
{
    self.spStatusLabel.stringValue = @"Logged in";
}
-(void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error
{
    self.spStatusLabel.stringValue = [NSString stringWithFormat:@"Err: %@", error.localizedDescription];
}

@end

@interface PathTransformer : NSValueTransformer
@end
@implementation PathTransformer
+ (Class)transformedValueClass
{
    return [NSURL class];
}
+ (BOOL)allowsReverseTransformation
{
    return YES;
}
- (id)transformedValue:(id)value
{
   return (value) ? [NSURL fileURLWithPath:value] : nil;
}
- (id)reverseTransformedValue:(id)value
{
   return [value path];
}
@end
