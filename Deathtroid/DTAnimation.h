//
//  DTAnimation.h
//  Deathtroid
//
//  Created by Amanda Rösler on 2011-10-12.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTResource.h"
#import "DTSpriteMap.h"

@interface DTAnimation : DTResource

@property (nonatomic, retain) DTSpriteMap *spriteMap;

- (DTSpriteMapFrame)frameAtIndex:(NSInteger)frameIndex forAnimation:(NSString*)animationName;
- (NSUInteger) frameCountForAnimation:(NSString*)animationName;
- (NSUInteger) framesPerSecondForAnimation:(NSString*)animationName;

@end

@interface DTResourceManager (DTAnimation)
-(DTAnimation *)animationNamed:(NSString *)name;
@end