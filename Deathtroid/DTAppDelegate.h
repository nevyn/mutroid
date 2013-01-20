//
//  DTAppDelegate.h
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoaLibSpotify/CocoaLibSpotify.h>
#import "DTAudioController.h"

@class DTView, DTCore;

@interface DTAppDelegate : NSObject <NSApplicationDelegate> {
    NSTimer		*loopTimer;
    float       interval;
}

+ (DTAppDelegate*)sharedAppDelegate;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet DTView *view;
@property (assign) IBOutlet NSTextField *customHost;
@property (assign) IBOutlet NSTabView *tabView;
@property (assign) IBOutlet NSLevelIndicator *healthIndicator;
@property (assign) IBOutlet NSTextField *healthText;
@property (assign) IBOutlet NSTextField *messages;
@property (assign) IBOutlet NSTextField *highscores;


-(IBAction)startGame:(id)sender;
-(IBAction)joinSelected:(id)sender;
-(IBAction)joinCustom:(id)sender;

@property(assign) IBOutlet NSTextField *spUser;
@property(assign) IBOutlet NSTextField *spPass;
@property(assign) IBOutlet NSTextField *spStatusLabel;
- (IBAction)spotifyLogin:(id)sender;
@property(readonly) DTAudioController *audioOut;

@end
