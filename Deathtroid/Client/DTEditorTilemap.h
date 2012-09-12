#import "DTEditor.h"

@interface DTEditorTilemap : DTEditor
- (void)toggleAttribute:(int)flag at:(Vector2*)viewCoordInPixels;
@property int currentLayerIndex;
@property int currentTileIndex;
@end
