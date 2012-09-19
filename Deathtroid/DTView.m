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
#import "DTEditorTilemap.h"
#import "DTEditorEntities.h"
#import "DTMap.h"
#import "DTClient.h"
#import "DTServer.h"
#import <Carbon/Carbon.h>
#import "SPDepends.h"
#import "DTEntityEditor.h"
#import "DTRoomEditor.h"
#import "DTResourceManager.h"
#import "DTRoom.h"
#import "DTLayer.h"
#import "DTWorldRoom.h"

#define GAME_WIDTH 256
#define GAME_HEIGHT 224

@interface DTView ()
@property DTRoomEditor *roomProps;
@end

@implementation DTView
{
    GLuint FramebufferName;
    GLuint renderedTexture;
    DTEditor *_currentEditor;
    NSUndoManager *_undo;
    NSMutableDictionary *_entityProps;
    
    NSResponder *_myNextResponder;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [[super initWithCoder:aDecoder] commonInit];
}
- (id)initWithFrame:(NSRect)frameRect
{
    return [[super initWithFrame:frameRect] commonInit];
}
- (id)commonInit
{
    _entityProps = [NSMutableDictionary dictionary];
    return self;
}

- (void)setCore:(DTCore *)core_
{
    _core = core_;
    
    __weak DTCore *weakCore = _core;
	[_core.input.mapper registerActionWithName:@"editor.flipX" action:^{
        NSPoint p = [self convertPoint:[self.window mouseLocationOutsideOfEventStream] fromView:nil];
        [weakCore.tilemapEditor toggleAttribute:TileAttributeFlipX at:[self convertPointToGameCoordinate:p]];
    }];
	[_core.input.mapper registerActionWithName:@"editor.flipY" action:^{
        NSPoint p = [self convertPoint:[self.window mouseLocationOutsideOfEventStream] fromView:nil];
        [weakCore.tilemapEditor toggleAttribute:TileAttributeFlipY at:[self convertPointToGameCoordinate:p]];
    }];
	[_core.input.mapper registerActionWithName:@"editor.rotate" action:^{
        NSPoint p = [self convertPoint:[self.window mouseLocationOutsideOfEventStream] fromView:nil];
        [weakCore.tilemapEditor toggleAttribute:TileAttributeRotate90 at:[self convertPointToGameCoordinate:p]];
    }];

    [_core.input.mapper mapKey:kVK_ANSI_U toAction:@"editor.flipX"];
    [_core.input.mapper mapKey:kVK_ANSI_I toAction:@"editor.flipY"];
    [_core.input.mapper mapKey:kVK_ANSI_O toAction:@"editor.rotate"];
    
    __weak __typeof(self) weakSelf = self;
    __block bool dontupdate;
    SPAddDependency(self, @"current layer", @[_core, @"tilemapEditor.currentLayerIndex"], ^{
        NSMenu *menu = weakSelf.currentLayerMenu.submenu;
        for(NSMenuItem *item in menu.itemArray)
            item.state = NSOffState;
        int newIndex = weakSelf.core.tilemapEditor.currentLayerIndex;
        [menu itemWithTag:newIndex].state = NSOnState;
        if(!dontupdate)
            weakSelf.roomProps.layersController.selectionIndex = newIndex;
    });
    SPAddDependency(self, @"selected layer", @[self, @"roomProps.layersController.selectionIndex"], ^{
        dontupdate = YES;
        weakSelf.core.tilemapEditor.currentLayerIndex = weakSelf.roomProps.layersController.selectionIndex;
        dontupdate = NO;
    });
        
    _core.tilemapEditor.undo = _core.entitiesEditor.undo = _undo = [NSUndoManager new];
    
    [self setCurrentEditor:nil];
}

-(BOOL)acceptsFirstResponder {
	return YES;
}

- (void)setNextResponder:(NSResponder *)aResponder
{
    _myNextResponder = aResponder;
    if(_currentEditor)
        [_currentEditor setNextResponder:aResponder];
}

- (void)drawRect:(NSRect)rect {
    if (FramebufferName == 0) {
        [self setupFrameRenderbuffer];
    }
    
    // Update graphics here
    [self useFramebuffer];
    [_core draw];
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
    [_core.input pressedKey:[theEvent keyCode] repeated:[theEvent isARepeat]];
    
    int i = [[theEvent characters] intValue];
    if(i > 0 || [[theEvent characters] isEqual:@"0"])
        _core.tilemapEditor.currentLayerIndex = i - 1;
    
    [self interpretKeyEvents:@[theEvent]];
}
- (void)doCommandBySelector:(SEL)aSelector
{
    [super doCommandBySelector:aSelector];
}

-(void)keyUp:(NSEvent *)theEvent {
	[_core.input releasedKey:[theEvent keyCode]];
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
    [_currentEditor leftMouseDownOrMoved:[self convertPointToGameCoordinate:p]];
}
- (void)mouseUp:(NSEvent *)theEvent
{
    [_currentEditor leftMouseUp];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    [self rightMouseDragged:theEvent];
}
- (void)rightMouseDragged:(NSEvent *)theEvent
{
    NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    [_currentEditor rightMouseDownOrMoved:[self convertPointToGameCoordinate:p]];
}
- (void)rightMouseUp:(NSEvent *)theEvent
{
    [_currentEditor rightMouseUp];
}


-(void)flagsChanged:(NSEvent *)theEvent {
}

- (IBAction)toggleFullScreen:(id)sender
{
    if(!self.isInFullScreenMode) {
        [self enterFullScreenMode:[NSScreen mainScreen] withOptions:nil];
        [self setCurrentEditor:_currentEditor]; // trigger new cursor
    } else {
        [self exitFullScreenModeWithOptions:nil];
    }
}

- (IBAction)saveDocument:(id)sender
{
    [_currentEditor save];
}

- (IBAction)flipHorizontal:(id)sender
{
    NSPoint p = [self convertPoint:[self.window mouseLocationOutsideOfEventStream] fromView:nil];
    [_core.tilemapEditor toggleAttribute:TileAttributeFlipX at:[self convertPointToGameCoordinate:p]];
}
- (IBAction)flipVertical:(id)sender
{
    NSPoint p = [self convertPoint:[self.window mouseLocationOutsideOfEventStream] fromView:nil];
    [_core.tilemapEditor toggleAttribute:TileAttributeFlipY at:[self convertPointToGameCoordinate:p]];
}
- (IBAction)rotate90:(id)sender
{
    NSPoint p = [self convertPoint:[self.window mouseLocationOutsideOfEventStream] fromView:nil];
    [_core.tilemapEditor toggleAttribute:TileAttributeRotate90 at:[self convertPointToGameCoordinate:p]];
}

- (IBAction)toggleLayer:(NSMenuItem*)sender
{
    [_core.client setLayer:(int)sender.tag visible:![_core.client layerVisible:(int)sender.tag]];
    for(NSMenuItem *item in [sender.parentItem.submenu itemArray])
        item.state = [_core.client layerVisible:item.tag] ? NSOnState : NSOffState;
    [_roomProps.layersTable reloadData];
}
- (IBAction)chooseLayer:(NSMenuItem*)sender
{
    _core.tilemapEditor.currentLayerIndex = (int)sender.tag;
}

- (void)setCurrentEditor:(DTEditor*)editor
{
    [_currentEditor setNextResponder:nil];
    
    _currentEditor.active = NO;
    _currentEditor = editor;
    _currentEditor.active = YES;
    
    [super setNextResponder:_currentEditor];
    [_currentEditor setNextResponder:_myNextResponder];
    
    NSCursor *cursor = (editor == nil) ? [NSCursor arrowCursor] :
        (editor == _core.tilemapEditor) ? [NSCursor crosshairCursor]:
        [NSCursor pointingHandCursor];
    [cursor set];
    
    if(editor == nil && [self isInFullScreenMode])
        CGDisplayHideCursor(0);
    else
        CGDisplayShowCursor(0);
}

- (IBAction)chooseEditor:(id)sender
{
    NSLog(@"%ld", [sender tag]);

    if([sender tag] == EditorTypeNone) {
        [self setCurrentEditor:nil];
        [[self window] setTitle: @"Deathroid"];
    }
    else if([sender tag] == EditorTypeTilemap) {
        [self setCurrentEditor:_core.tilemapEditor];
        [[self window] setTitle: @"Deathroid – Tilemap"];
        if(!_roomProps) {
            [self showRoomProps];
            [self.window makeKeyAndOrderFront:nil];
        }
    }
    else if([sender tag] == EditorTypeEntities) {
        [self setCurrentEditor:_core.entitiesEditor];
        [[self window] setTitle: @"Deathroid – Entities"];
    }
}

- (void)showEntityProps
{
    DTEntityTemplate *template = _core.entitiesEditor.selection;
    if(!template) {
        NSBeep();
        return;
    }
    
    DTEntityEditor *editor = [_entityProps objectForKey:template.uuid];
    if(editor) {
        [editor showWindow:nil];
        return;
    }
    
    editor = [[DTEntityEditor alloc] initEditingTemplate:template];
    editor.undo = _undo;
    editor.client = _core.client;
    [editor showWindow:nil];
    [_entityProps setObject:editor forKey:template.uuid];
}
- (void)showRoomProps
{
    self.roomProps = [[DTRoomEditor alloc] initEditingRoom:_core.client.currentRoom.room];
    _roomProps.undo = _undo;
    _roomProps.client = _core.client;
    
    NSRect r = _roomProps.window.frame;
    r.origin.y = self.window.frame.origin.y;
    r.origin.x = self.window.frame.origin.x + self.window.frame.size.width;
    [_roomProps.window setFrame:r display:NO];
    [_roomProps showWindow:nil];
}

- (IBAction)editPropertiesForSelection:(id)sender
{
    if(_currentEditor == _core.entitiesEditor)
        [self showEntityProps];
    else if(_currentEditor == _core.tilemapEditor)
        [self showRoomProps];
}

- (void)editorClosed:(DTEntityEditor*)editor;
{
    [_entityProps removeObjectForKey:editor.entity.uuid];
}

- (void)openDocument:(id)sender
{
    _core.drawing = NO;
    NSOpenPanel *open = [NSOpenPanel openPanel];
    open.allowedFileTypes = @[@"resource"];
    open.canChooseFiles = YES;
    open.title = @"Select level";
    open.directoryURL = [[DTResourceManager sharedManager] baseURL];
    [open beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        _core.drawing = YES;
        if(result == NSFileHandlingPanelCancelButton)
            return;
        
        NSString *roomName = [[[[open URLs] lastObject] lastPathComponent] dt_resourceName];
        
        [_core.server teleportPlayer:nil toPosition:nil inRoomNamed:roomName];
    }];
}

- (void)newDocument:(id)sender
{
    _core.drawing = NO;
    NSSavePanel *save = [NSSavePanel savePanel];
    save.allowedFileTypes = @[@"resource"];
    save.title = @"New level name";
    save.nameFieldStringValue = @"newLevel.room.resource";
    save.directoryURL = [[DTResourceManager sharedManager] baseURL];
    [save beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        _core.drawing = YES;
        if(result == NSFileHandlingPanelCancelButton)
            return;
        
        NSURL *roomURL = save.URL;
        
        NSError *err;
        if(![@"{}" writeToURL:roomURL atomically:NO encoding:NSUTF8StringEncoding error:&err]) {
            [NSApp presentError:err];
            return;
        }
        DTRoom *fakeNewRoom = [[DTRoom alloc] initWithResourceId:roomURL.dt_resourceId];
        [fakeNewRoom.collisionLayer setWidth:16 height:12];
        [fakeNewRoom.collisionLayer setTile:1 atX:5 y:11];
        DTLayer *initialLayer = [DTLayer new];
        [initialLayer.map setTile:3 atX:5 y:11];
        [fakeNewRoom.layers addObject:initialLayer];
        
        [[DTResourceManager sharedManager] saveResource:fakeNewRoom];
        [_core.server teleportPlayer:nil toPosition:nil inRoomNamed:roomURL.dt_resourceName];
        
    }];
}

@end
