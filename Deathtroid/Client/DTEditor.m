#import "DTEditor.h"
#import "DTClient.h"
#import "DTCamera.h"
#import "DTRoom.h"
#import "DTWorldRoom.h"
#import "DTLayer.h"
#import "DTMap.h"
#import "DTTexture.h"
#import "DTProgram.h"

@implementation DTEditor
- (id)init
{
    if(!(self = [super init]))
        return nil;
    _undo = [[NSUndoManager alloc] init];
    return self;
}

- (Vector2*)roomCoordFromViewCoord:(Vector2*)viewCoord
{
    MutableVector2 *ret = [viewCoord mutableCopy];
    [ret divideWithScalar:16];
    [ret addVector:self.client.camera.position];
    ret.y = 12 - ret.y;
    return ret;
}

- (void)leftMouseDownOrMoved:(Vector2*)viewCoordInPixels {}
- (void)leftMouseUp {}
- (void)rightMouseDownOrMoved:(Vector2*)viewCoordInPixels {}
- (void)rightMouseUp {}
- (void)draw {}

- (void)undo:(id)sender
{
    [self.undo undo];
}
- (void)redo:(id)sender
{
    [self.undo redo];
}

- (void)save
{
    [[DTResourceManager sharedManager] saveResource:self.client.currentRoom.room];
}

@end
