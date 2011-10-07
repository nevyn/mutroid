//
//  QSTView.h
//  Quest
//
//  Created by Per Borgman on 20/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DTCore;

@interface DTView : NSOpenGLView {
}

@property (nonatomic,strong) DTCore *core;

-(void)keyDown:(NSEvent *)theEvent;
-(void)keyUp:(NSEvent *)theEvent;
-(void)flagsChanged:(NSEvent *)theEvent;

@end
