//
//  DTAppDelegate.h
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DTView, DTCore;

@interface DTAppDelegate : NSObject <NSApplicationDelegate> {
    NSTimer		*loopTimer;
    float       interval;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet DTView *view;
@property (assign) IBOutlet NSTextField *customHost;
@property (assign) IBOutlet NSTabView *tabView;
@property (assign) IBOutlet NSLevelIndicator *healthIndicator;
@property (assign) IBOutlet NSTextField *healthText;


-(IBAction)startGame:(id)sender;
-(IBAction)joinSelected:(id)sender;
-(IBAction)joinCustom:(id)sender;

@end
