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
{
    GLuint FramebufferName;
    GLuint renderedTexture;
}

@synthesize core;

-(void)awakeFromNib {
	// Hinder drawRect until core is created.
	//[self setNeedsDisplay:NO];
}

-(BOOL)acceptsFirstResponder {
	return YES;
}

- (void)drawRect:(NSRect)rect {
    if (FramebufferName == 0) {
        [self setupFrameRenderbuffer];
    }
    
    // Update graphics here
    [self useFramebuffer];
    [core draw];
    [self useScreenbuffer];

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glBindTexture(GL_TEXTURE_2D, renderedTexture);
    
    glColor3f(1, 1, 0);
    glBegin(GL_QUADS);
    glTexCoord2f(0, 1);
    glVertex3f(-1, -1, 0);
    glTexCoord2f(1, 1);
    glVertex3f(1, -1, 0);
    glTexCoord2f(1, 0);
    glVertex3f(1, 1, 0);
    glTexCoord2f(0, 0);
    glVertex3f(-1,  1, 0);
    glEnd();
    
	[[self openGLContext] flushBuffer];
}

- (void)reshape
{

}

- (void)setupFrameRenderbuffer
{
    //set up a texture buffer at game size
    glViewport(0, 0, 320, 240);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0., 20.0f, 15.f, 0., -1., 1.);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    // The framebuffer, which regroups 0, 1, or more textures, and 0 or 1 depth buffer.
    glGenFramebuffers(1, &FramebufferName);
    glBindFramebuffer(GL_FRAMEBUFFER, FramebufferName);
    
    // The texture we're going to render to
    glGenTextures(1, &renderedTexture);
    
    // "Bind" the newly created texture : all future texture functions will modify this texture
    glBindTexture(GL_TEXTURE_2D, renderedTexture);
    
    // Give an empty image to OpenGL ( the last "0" )
    glTexImage2D(GL_TEXTURE_2D, 0,GL_RGB, 320, 240, 0,GL_RGB, GL_UNSIGNED_BYTE, 0);
    
    // Poor filtering. Needed !
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    
    // Set "renderedTexture" as our colour attachement #0
    glFramebufferTextureEXT(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, renderedTexture, 0);

    // Set the list of draw buffers.
    GLenum DrawBuffers[2] = {GL_COLOR_ATTACHMENT0};
    glDrawBuffers(1, DrawBuffers); // "1" is the size of DrawBuffers
    
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
        [NSException raise:@"Render" format:@"Frame buffer failed"];
}

- (void)useFramebuffer
{
    glBindFramebuffer(GL_FRAMEBUFFER, FramebufferName);
    //set up a texture buffer at game size
    glViewport(0, 0, 320, 240);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0., 20.0f, 15.f, 0., -1., 1.);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

- (void)useScreenbuffer
{
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    //set up a view buffer to draw the backbuffer to
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(-1, 1, 1, -1, -1., 1.);
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
