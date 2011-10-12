//
//  DTEntityRenderer.h
//  Deathtroid
//
//  Created by Amanda Rösler on 2011-10-11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DTCamera;
@class DTResourceManager;
@class DTEntity;

@interface DTRenderEntities : NSObject

@property (nonatomic, retain) NSMutableArray *entities;
@property (nonatomic, retain) DTResourceManager *resources;

- (void) setEntitiesToDraw:(NSArray*)entities_;
- (void) addEntity:(DTEntity*)entity;
- (void) removeEntity:(DTEntity*)entity;
- (void) tick:(float)delta;
- (void) draw:(DTCamera*)camera frameCount:(uint64_t)frameCount;

@end
