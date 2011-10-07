//
//  QSTView.m
//  Quest
//
//  Created by Per Borgman on 20/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DTView.h"

#import <OpenGL/gl.h>

#import "DTCore.h"

@implementation DTView

@synthesize core;

-(void)awakeFromNib {
	// Hinder drawRect until core is created.
	//[self setNeedsDisplay:NO];
}

-(BOOL)acceptsFirstResponder {
	return YES;
}

- (void)drawRect:(NSRect)rect {
    // Update graphics here
    [core draw];
	[[self openGLContext] flushBuffer];
}

-(void)keyDown:(NSEvent *)theEvent {
    
	//[core.inputSystem pressedKey:[theEvent keyCode] repeated:[theEvent isARepeat]];
}

-(void)keyUp:(NSEvent *)theEvent {
	//[core.inputSystem releasedKey:[theEvent keyCode]];
}

-(void)flagsChanged:(NSEvent *)theEvent {
}

@end
