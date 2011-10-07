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
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet DTView *view;

@end
