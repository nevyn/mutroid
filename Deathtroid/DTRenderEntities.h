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
@property (nonatomic, retain) DTResourceManager *resources;

- (void) tick:(float)delta forEntity:(DTEntity*)entity;
- (void) drawEntity:(DTEntity*)entity camera:(DTCamera*)camera frameCount:(uint64_t)frameCount;

- (void) deleteGfxStateForEntity:(DTEntity*)entity;
- (void) emptyGfxState;
@end
