#import <Foundation/Foundation.h>
#import "Vector2.h"
@class DTClient;

@interface DTEditor : NSObject
@property(weak) DTClient *client;

- (void)leftMouseDownOrMoved:(Vector2*)viewCoordInPixels;
- (void)leftMouseUp;
- (void)rightMouseDownOrMoved:(Vector2*)viewCoordInPixels;
- (void)rightMouseUp;

- (void)draw;

- (void)save;

@property int currentLayerIndex;
@property int currentTileIndex;
@end
