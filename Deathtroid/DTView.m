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
#import "DTInput.h"

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
- (void)reshape
{
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0., 20.0f, 15.f, 0., -1., 1.);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}
-(void)keyDown:(NSEvent *)theEvent {
    [core.input pressedKey:[theEvent keyCode] repeated:[theEvent isARepeat]];
}

-(void)keyUp:(NSEvent *)theEvent {
	[core.input releasedKey:[theEvent keyCode]];
}

-(void)flagsChanged:(NSEvent *)theEvent {
}

@end
