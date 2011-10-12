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
#import "DTSpriteMap.h"
#import "Vector2.h"
#import <OpenGL/gl.h>
#import "DTAnimation.h"
#import "DTEntityZoomer.h"

@implementation DTRenderEntities

@synthesize entities;
@synthesize resources;

- (id) init {
    
    self = [super init];
    if (self) {
        self.entities = [NSMutableArray array];
        self.resources = [[DTResourceManager alloc] initWithBaseURL:[[NSBundle mainBundle] URLForResource:@"resources" withExtension:nil]];
    }
    return self;
}

- (void) setEntitiesToDraw:(NSArray*)entities_ {
    
    [entities removeAllObjects];
    
    for (DTEntity *entity in entities_)
        [self addEntity:entity];
}

- (void) addEntity:(DTEntity*)entity {
    
    NSMutableDictionary *entityData = [NSMutableDictionary dictionary];
    [entityData setObject:entity forKey:@"entity"];
    [entityData setObject:[NSNumber numberWithInt:0] forKey:@"currentFrame"];
    [entityData setObject:[NSNumber numberWithFloat:0.0] forKey:@"secondsSinceLastFrame"];
    
    [self.entities addObject:entityData];
}

- (void) removeEntity:(DTEntity *)entity {
        
    NSMutableDictionary *entityToRemove = nil;
    
    for (NSMutableDictionary *entityData in self.entities) {
        if ([[entityData objectForKey:@"entity"] isEqual:entity]) {
            entityToRemove = entityData;
            break;
        }
    }
    
    if (entityToRemove != nil) [self.entities removeObject:entityToRemove];
}

- (void) tick:(float)delta {
    
    for(NSMutableDictionary *entityData in self.entities) {
        
        DTEntity *entity = [entityData objectForKey:@"entity"];
        
        float secondsSinceLastFrame = [[entityData objectForKey:@"secondsSinceLastFrame"] floatValue];
        int fps = (int)[entity.animation framesPerSecondForAnimation:entity.currentState];
        int frameCount = (int)[entity.animation frameCountForAnimation:entity.currentState];
        
        float timeBetweenFrames = 1.0/fps;
        
        if (secondsSinceLastFrame >= timeBetweenFrames) {
            [entityData setObject:[NSNumber numberWithFloat:0.0] forKey:@"secondsSinceLastFrame"];
            int currentFrame = [[entityData objectForKey:@"currentFrame"] intValue];
            currentFrame++;
            if (currentFrame >= frameCount) currentFrame = 0;
            [entityData setObject:[NSNumber numberWithInt:currentFrame] forKey:@"currentFrame"];
        }
        else {
            [entityData setObject:[NSNumber numberWithFloat:secondsSinceLastFrame+delta] forKey:@"secondsSinceLastFrame"];
        }
    }
    
}

- (void) draw:(DTCamera*)camera frameCount:(uint64_t)frameCount {
	
    glTranslatef(-camera.position.x, -camera.position.y, 0);
    
    for(NSMutableDictionary *entityData in self.entities) {
        
        DTEntity *entity = [entityData objectForKey:@"entity"];
        
		if([$castIf(DTEntityPlayer, entity) immune] && (frameCount/2)%2)
			continue;
		
        [entity.animation.spriteMap.texture use];
        DTSpriteMapFrame frame = [entity.animation frameAtIndex:[[entityData objectForKey:@"currentFrame"] intValue] forAnimation:entity.currentState];
        
        glPushMatrix();
        glTranslatef(entity.position.x, entity.position.y, 0);
        glTranslatef(entity.size.x/2, entity.size.y/2, 0);
        glRotatef(entity.rotation, 0, 0, 1);
        glTranslatef(-entity.size.x/2, -entity.size.y/2, 0);
        glBegin(GL_QUADS);
        
//      if(entity.damageFlashTimer > 0)
//          DO SOMETHING HERE!?!?
//      }
        
		glColor3f(1., 1., 1.);
        glTexCoord2fv(&frame.coords[0]); glVertex3f(entity.size.x, 0., 0.);
        glTexCoord2fv(&frame.coords[2]); glVertex3f(entity.size.x, entity.size.y, 0.);
        glTexCoord2fv(&frame.coords[4]); glVertex3f(0., entity.size.y, 0);
        glTexCoord2fv(&frame.coords[6]); glVertex3f(0., 0., 0.);
        glEnd();
        glColor3f(0,0,1.);
        glBegin(GL_POINTS);
        if(entity.lookDirection == EntityDirectionLeft)
            glVertex3f(0, entity.size.y/3, 0);
        else if(entity.lookDirection == EntityDirectionRight)
            glVertex3f(entity.size.x, entity.size.y/3, 0);
        glEnd();
        glPopMatrix();
    }

    
}

@end
