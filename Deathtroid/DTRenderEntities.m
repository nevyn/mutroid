//
//  DTEntityRenderer.m
//  Deathtroid
//
//  Created by Amanda Rösler on 2011-10-11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTRenderEntities.h"
#import "DTEntity.h"
#import "DTCamera.h"
#import "DTEntityPlayer.h"
#import "DTResourceManager.h"
#import "DTTexture.h"
#import "DTProgram.h"
#import "DTSpriteMap.h"
#import "Vector2.h"
#import <OpenGL/gl.h>
#import "DTAnimation.h"
#import "DTEntityZoomer.h"

static const CGSize kTileSizeInPixels = {16, 16};

@interface DTEntityGfxState : NSObject
-(id)initWithEntity:(DTEntity*)ent;
@property(nonatomic,strong) NSString *uuid;
@property(nonatomic) uint64_t currentFrame;
@property(nonatomic) NSTimeInterval secondsSinceLastFrame;
@end
@implementation DTEntityGfxState
@synthesize uuid, currentFrame, secondsSinceLastFrame;
-(id)initWithEntity:(DTEntity *)ent;
{
    if(!(self = [super init])) return nil;
    self.uuid = ent.uuid;
    return self;
}
@end

@implementation DTRenderEntities {
    NSMutableDictionary *gfxState;
}

@synthesize resources;

- (id) init {
    
    if(!(self = [super init])) return nil;

    gfxState = [NSMutableDictionary dictionary];
    self.resources = [DTResourceManager sharedManager];
    
    return self;
}

-(DTEntityGfxState*)stateForEntity:(DTEntity*)entity;
{
    return [gfxState objectForKey:entity.uuid] ?: ({
        id data = [[DTEntityGfxState alloc] initWithEntity:entity];
        [gfxState setObject:data forKey:entity.uuid];
        data;
    });
}
- (void) tick:(float)delta forEntity:(DTEntity*)entity;
{
    DTEntityGfxState *entityData = [self stateForEntity:entity];
    
    float secondsSinceLastFrame = entityData.secondsSinceLastFrame;
    int fps = (int)[entity.animation framesPerSecondForAnimation:entity.currentState];
    int frameCount = (int)[entity.animation frameCountForAnimation:entity.currentState];
    
    float timeBetweenFrames = 1.0/fps;
    
    if (secondsSinceLastFrame >= timeBetweenFrames) {
        entityData.secondsSinceLastFrame = 0.;
        entityData.currentFrame++;
        if(entityData.currentFrame >= frameCount)
            entityData.currentFrame = 0;
    } else
        entityData.secondsSinceLastFrame += delta;
}

- (void) drawEntity:(DTEntity*)entity camera:(DTCamera*)camera frameCount:(uint64_t)frameCount;
{
    DTEntityGfxState *entityData = [self stateForEntity:entity];
    
    if([$castIf(DTEntityPlayer, entity) immune] && (frameCount/2)%2)
        return;
    
    // XX: Switched animation without running tick. Why is tick separate from drawEntity anyway?
    if(entityData.currentFrame >= [entity.animation frameCountForAnimation:entity.currentState]) {
        entityData.currentFrame = 0;
        entityData.secondsSinceLastFrame = 0.;
    }

    
    DTSpriteMap *spriteMap = [entity.animation spriteMapForAnimation:entity.currentState];
    [spriteMap.texture use];
    DTSpriteMapFrame frame = [entity.animation frameAtIndex:entityData.currentFrame forAnimation:entity.currentState];
    
    glPushMatrix();
    glTranslatef(entity.position.x, entity.position.y, 0);
    glRotatef(entity.rotation, 0, 0, 1);
  
    glBegin(GL_QUADS);
    
//      if(entity.damageFlashTimer > 0)
//          DO SOMETHING HERE!?!?
//      }
    
    CGSize sizeInPixels = spriteMap.frameSize;
    CGSize sizeInTiles = {sizeInPixels.width/kTileSizeInPixels.width, sizeInPixels.height/kTileSizeInPixels.height};
    float w = sizeInTiles.width, h = sizeInTiles.height;
    glColor3f(1., 1., 1.);
    glTexCoord2fv((float*)&frame.coords[0]); glVertex3f(-w/2, -h + entity.size.max.y, 0.);
    glTexCoord2fv((float*)&frame.coords[1]); glVertex3f(-w/2, entity.size.max.y, 0.);
    glTexCoord2fv((float*)&frame.coords[2]); glVertex3f(+w/2, entity.size.max.y, 0);
    glTexCoord2fv((float*)&frame.coords[3]); glVertex3f(+w/2, -h + entity.size.max.y, 0.);
    glEnd();
    
    
    glColor3f(0,0,1.);
    glBegin(GL_POINTS);
    if(entity.lookDirection == EntityDirectionLeft)
        glVertex3f(0, 0.5, 0);
    else if(entity.lookDirection == EntityDirectionRight)
        glVertex3f(entity.size.max.x, 0.5, 0);
    glEnd();
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"]) {
        DTProgram *p = [resources resourceNamed:@"main.program"];
        [p unuse];

        glColor3f(1., 1., 1.);
        glBegin(GL_LINE_LOOP);
        glTexCoord2f(0.0, 0.0);
        glVertex3f(entity.size.max.x, entity.size.min.y, 0.);
        glVertex3f(entity.size.max.x, entity.size.max.y, 0.);
        glVertex3f(entity.size.min.x, entity.size.max.y, 0);
        glVertex3f(entity.size.min.x, entity.size.min.y, 0.);
        glEnd();
        
        glBegin(GL_QUADS);
        glColor3f(entity.onGround ? 1.0 : 0.0, entity.onGround ? 0.0 : 1.0, 0.0);
        glVertex2f(-1, -1);
        glVertex2f(-0.5, -1);
        glVertex2f(-0.5, -0.5);
        glVertex2f(-1, -0.5);
        glEnd();
        
        [p use];
    }
    glPopMatrix();
    
    
}

- (void) deleteGfxStateForEntity:(DTEntity*)entity;
{
    [gfxState removeObjectForKey:entity.uuid];
}
- (void) emptyGfxState;
{
    [gfxState removeAllObjects];
}

@end
