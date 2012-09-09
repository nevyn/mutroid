//
//  DTEditor.m
//  Deathtroid
//
//  Created by Joachim Bengtsson on 2012-09-09.
//
//

#import "DTEditor.h"
#import "DTClient.h"
#import "DTCamera.h"
#import "DTRoom.h"
#import "DTWorldRoom.h"
#import "DTLayer.h"
#import "DTMap.h"
#import "DTTexture.h"
#import "DTProgram.h"

@implementation DTEditor {
    Vector2 *_drawEditorAt;
}
- (Vector2*)tileCoordFromViewCoord:(Vector2*)viewCoord
{
    MutableVector2 *ret = [viewCoord mutableCopy];
    [ret divideWithScalar:16];
    [ret addVector:self.client.camera.position];
    ret.y = 12 - ret.y;
    return ret;
}
- (DTLayer*)currentLayer
{
    NSArray *layers = self.client.currentRoom.room.layers;
    if(_currentLayerIndex < 0 || _currentLayerIndex >= layers.count)
        return nil;
    return layers[_currentLayerIndex];
}
- (void)leftMouseDownOrMoved:(Vector2*)viewCoordInPixels
{
    Vector2 *tileCoord = [self tileCoordFromViewCoord:viewCoordInPixels];
    
    DTLayer *layer = [self currentLayer];
    int *tile = [layer.map tileAtX:tileCoord.x y:tileCoord.y];
    if(!tile) return;
    
    *tile = _currentTileIndex;
}

- (void)leftMouseUp
{

}

- (void)rightMouseDownOrMoved:(Vector2*)viewCoordInPixels
{
    Vector2 *tileCoord = [self tileCoordFromViewCoord:viewCoordInPixels];
    if(!_drawEditorAt) {
        DTLayer *layer = [self currentLayer];
        int *tile = [layer.map tileAtX:tileCoord.x y:tileCoord.y];
        if(tile) {
            DTTexture *texture = [[DTResourceManager sharedManager] resourceNamed:$sprintf(@"%@.texture", layer.tilesetName)];
            float w = texture.pixelSize.width/16.;

            MutableVector2 *p = tileCoord.mutableCopy;
            Vector2 *currentChoice = [Vector2 vectorWithX:*tile%(int)w y:*tile/(int)w + 1];
            [p subtractVector:currentChoice];
            p.x += .5; p.y += .5;
            _drawEditorAt = p.copy;
        } else {
            _drawEditorAt = tileCoord;
        }
    }
    
    Vector2 *coordInSheet = [tileCoord vectorBySubtractingVector:_drawEditorAt];
    DTLayer *layer = [self currentLayer];
	DTTexture *texture = [[DTResourceManager sharedManager] resourceNamed:$sprintf(@"%@.texture", layer.tilesetName)];
    float w = texture.pixelSize.width/16.;
    float h = texture.pixelSize.height/16.;
    if(coordInSheet.x < 0 || coordInSheet.y < 0 || coordInSheet.x >= w || coordInSheet.y >= h)
        self.currentTileIndex = 0;
    else
        self.currentTileIndex = floor(coordInSheet.y)*floor(w) + floor(coordInSheet.x) + 1;
}

- (void)rightMouseUp
{
    _drawEditorAt = nil;
}

- (void)draw
{
    if(!_drawEditorAt) return;
    
    DTProgram *program = [[DTResourceManager sharedManager] resourceNamed:@"main.program"];

    DTLayer *layer = [self currentLayer];
	DTTexture *texture = [[DTResourceManager sharedManager] resourceNamed:$sprintf(@"%@.texture", layer.tilesetName)];
    float w = texture.pixelSize.width/16.;
    float h = texture.pixelSize.height/16.;
        
    glPushMatrix();
    
    glLoadIdentity();
    glTranslatef(_drawEditorAt.x, _drawEditorAt.y+2, 0);

    [program unuse];
	glBegin(GL_QUADS);
	glColor3f(0,0,0);
        glTexCoord2f(0, 0); glVertex2f(0, 0);
        glTexCoord2f(0, 1); glVertex2f(0, h);
        glTexCoord2f(1, 1); glVertex2f(w, h);
        glTexCoord2f(1, 0); glVertex2f(w, 0);
    glEnd();
    
    [program use];
	[texture use];
	glBegin(GL_QUADS);
	glColor3f(1,1,1);
        glTexCoord2f(0, 0); glVertex2f(0, 0);
        glTexCoord2f(0, 1); glVertex2f(0, h);
        glTexCoord2f(1, 1); glVertex2f(w, h);
        glTexCoord2f(1, 0); glVertex2f(w, 0);
    glEnd();
    
    glPopMatrix();
}

- (void)save
{
    [self.client.currentRoom.room saveToDisk];
}

@end
