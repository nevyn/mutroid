#import "DTEditorEntities.h"
#import "DTEntity.h"
#import "DTEntityTemplate.h"
#import "DTCore.h"
#import "DTClient.h"
#import "DTRoom.h"
#import "DTWorldRoom.h"
#import "DTTexture.h"
#import "DTResourceManager.h"
#import "DTProgram.h"

@implementation DTEditorEntities {
    DTEntityTemplate *_selection, *_dragging;
    Vector2 *_draggingOffset;
}
- (NSMutableDictionary*)currentTemplates
{
    return self.client.currentRoom.room.entityTemplates;
}

- (void)draw
{
    if(!self.active)
        return;
    
    for(DTEntityTemplate *template in self.currentTemplates.allValues)
        [self drawTemplate:template];
}
- (void)drawTemplate:(DTEntityTemplate*)template
{
    glPushMatrix();
    
    glLoadIdentity();
    glTranslatef(0, 2, 0);
    glTranslatef(template.position.x, template.position.y, 0);
    
    DTTexture *texture = [self texForTemplate:template];
    float w = 1; //texture.pixelSize.width/16.;
    float h = 1; //texture.pixelSize.height/16.;
    
    if(template == _selection) {
        DTProgram *program = [[DTResourceManager sharedManager] resourceNamed:@"main.program"];
        [program unuse];
        glBegin(GL_QUADS);
        glColor3f(.2,.2,.4);
            glTexCoord2f(0, 0); glVertex2f(-.1, -.1);
            glTexCoord2f(0, 1); glVertex2f(-.1, h+.1);
            glTexCoord2f(1, 1); glVertex2f(w+.1, h+.1);
            glTexCoord2f(1, 0); glVertex2f(w+.1, -.1);
        glEnd();
        [program use];
    }
    
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

- (DTEntityTemplate*)hitTest:(Vector2*)roomCoord
{
    for(DTEntityTemplate *template in self.currentTemplates.allValues) {
        if(CGRectContainsPoint([self frameForTemplate:template], roomCoord.point))
            return template;
    }
    return nil;
}

- (DTTexture*)texForTemplate:(DTEntityTemplate*)template
{
    NSString *texName = @"lasse";
    return [[DTResourceManager sharedManager] resourceNamed:$sprintf(@"%@.texture", texName)];
}

- (CGRect)frameForTemplate:(DTEntityTemplate*)template
{
    float w = 1; //texture.pixelSize.width/16.;
    float h = 1; //texture.pixelSize.height/16.;
    return CGRectMake(
        template.position.x,
        template.position.y,
        w, h
    );
}

- (void)leftMouseDownOrMoved:(Vector2*)viewCoordInPixels
{
    Vector2 *tileCoord = [self roomCoordFromViewCoord:viewCoordInPixels];
    
    if(!_dragging) {
        if((_selection = _dragging = [self hitTest:tileCoord])) {
            _draggingOffset = [tileCoord vectorBySubtractingVector:_dragging.position];
        } else {
            _selection = _dragging = [DTEntityTemplate new];
            CGRect newFrame = [self frameForTemplate:_dragging];
            _draggingOffset = [[Vector2 vectorWithX:newFrame.size.width/2 y:newFrame.size.height/2] integralVector];
            [self.currentTemplates setObject:_selection forKey:_selection.uuid];
        }
    }
    
    _dragging.position = [[[[tileCoord.mutableCopy
        subtractVector:_draggingOffset]
        multiplyWithScalar:16]
        makeIntegral]
        divideWithScalar:16];
}
- (void)leftMouseUp
{
    _dragging = nil;
    _draggingOffset = nil;
}
- (void)rightMouseDownOrMoved:(Vector2*)viewCoordInPixels
{

}
- (void)rightMouseUp
{

}

- (IBAction)delete:(id)sender
{
    if(!_selection) {
        NSBeep();
        return;
    }
    [[self currentTemplates] removeObjectForKey:_selection.uuid];
    _selection = nil;
}

@end
