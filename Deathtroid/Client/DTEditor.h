#import <Foundation/Foundation.h>
#import "Vector2.h"
@class DTClient;

@interface DTEditor : NSResponder
@property(weak) DTClient *client;

- (void)leftMouseDownOrMoved:(Vector2*)viewCoordInPixels;
- (void)leftMouseUp;
- (void)rightMouseDownOrMoved:(Vector2*)viewCoordInPixels;
- (void)rightMouseUp;

- (void)draw;
- (void)save;

// Set this to get undo support
@property(strong) NSUndoManager *undo;
@property BOOL active;
@end


@interface DTEditor (ForSubclasses)
- (Vector2*)roomCoordFromViewCoord:(Vector2*)viewCoord;
@end