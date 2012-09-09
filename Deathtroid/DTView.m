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
#import "DTEditor.h"
#import "DTMap.h"
#import <Carbon/Carbon.h>

#define GAME_WIDTH 256
#define GAME_HEIGHT 224

@implementation DTView
{
    GLuint FramebufferName;
    GLuint renderedTexture;
}

@synthesize core;

- (void)setCore:(DTCore *)core_
{
    core = core_;
    
    __weak DTCore *weakCore = core;
	[core.input.mapper registerActionWithName:@"editor.flipX" action:^{
        NSPoint p = [self convertPoint:[self.window mouseLocationOutsideOfEventStream] fromView:nil];
        [weakCore.editor toggleAttribute:TileAttributeFlipX at:[self convertPointToGameCoordinate:p]];
    }];
	[core.input.mapper registerActionWithName:@"editor.flipY" action:^{
        NSPoint p = [self convertPoint:[self.window mouseLocationOutsideOfEventStream] fromView:nil];
        [weakCore.editor toggleAttribute:TileAttributeFlipY at:[self convertPointToGameCoordinate:p]];
    }];
	[core.input.mapper registerActionWithName:@"editor.rotate" action:^{
        NSPoint p = [self convertPoint:[self.window mouseLocationOutsideOfEventStream] fromView:nil];
        [weakCore.editor toggleAttribute:TileAttributeRotate90 at:[self convertPointToGameCoordinate:p]];
    }];

    [core.input.mapper mapKey:kVK_ANSI_U toAction:@"editor.flipX"];
    [core.input.mapper mapKey:kVK_ANSI_I toAction:@"editor.flipY"];
    [core.input.mapper mapKey:kVK_ANSI_O toAction:@"editor.rotate"];
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
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glColor3f(1, 1, 1);
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
    glViewport(0, 0, GAME_WIDTH, GAME_HEIGHT);
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
    glTexImage2D(GL_TEXTURE_2D, 0,GL_RGB, GAME_WIDTH, GAME_HEIGHT, 0,GL_RGB, GL_UNSIGNED_BYTE, 0);
    
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
    glViewport(0, 0, GAME_WIDTH, GAME_HEIGHT);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0., 16.0f, 14.f, 0., -1., 1.);
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
    
    int i = [[theEvent characters] intValue];
    if(i > 0)
        core.editor.currentLayerIndex = i - 1;
}

-(void)keyUp:(NSEvent *)theEvent {
	[core.input releasedKey:[theEvent keyCode]];
}

- (Vector2*)convertPointToGameCoordinate:(NSPoint)p
{
    MutableVector2 *vec2 = [MutableVector2 vectorWithX:p.x y:p.y];
    vec2.x *= GAME_WIDTH/self.bounds.size.width;
    vec2.y *= GAME_HEIGHT/self.bounds.size.height;
    return vec2;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self mouseDragged:theEvent];
}
- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    [core.editor leftMouseDownOrMoved:[self convertPointToGameCoordinate:p]];
}
- (void)mouseUp:(NSEvent *)theEvent
{
    [core.editor leftMouseUp];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    [self rightMouseDragged:theEvent];
}
- (void)rightMouseDragged:(NSEvent *)theEvent
{
    NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    [core.editor rightMouseDownOrMoved:[self convertPointToGameCoordinate:p]];
}
- (void)rightMouseUp:(NSEvent *)theEvent
{
    [core.editor rightMouseUp];
}


-(void)flagsChanged:(NSEvent *)theEvent {
}

- (IBAction)toggleFullScreen:(id)sender
{
    if(!self.isInFullScreenMode) {
        [self enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];
    } else {
        [self exitFullScreenModeWithOptions:nil];
    }
}

- (IBAction)saveDocument:(id)sender
{
    [core.editor save];
}

- (void)undo:(id)sender
{
    [core.editor.undo undo];
}
- (void)redo:(id)sender
{
    [core.editor.undo redo];
}

@end
