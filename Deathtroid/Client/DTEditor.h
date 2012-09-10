#import <Foundation/Foundation.h>
#import "Vector2.h"
@class DTClient;

@interface DTEditor : NSResponder
@property(weak) DTClient *client;

- (void)leftMouseDownOrMoved:(Vector2*)viewCoordInPixels;
- (void)leftMouseUp;
- (void)rightMouseDownOrMoved:(Vector2*)viewCoordInPixels;
- (void)rightMouseUp;
- (void)toggleAttribute:(int)flag at:(Vector2*)viewCoordInPixels;

- (void)draw;

- (void)save;

@property int currentLayerIndex;
@property int currentTileIndex;

@property(readonly) NSUndoManager *undo;
@end

@protocol DTEditorUIDelegate <NSObject>

@end