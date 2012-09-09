//
//  DTAnimation.m
//  Deathtroid
//
//  Created by Amanda Rösler on 2011-10-12.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTAnimation.h"
#import "DTSpriteMap.h"
#import "DTTexture.h"
#import "DTResource.h"

#ifndef SWAP
#define SWAP(x, y) ({ __typeof(x) tmp = (x); (x) = (y); (y) = (tmp); })
#endif

@interface DTAnimation ()
@property (nonatomic, retain) NSMutableDictionary *animations;
@end

@interface DTSingleAnimation : NSObject
@property NSArray *tiles;
@property int fps;
@property DTSpriteMap *spriteMap;
@property BOOL flipX, flipY;
@end
@implementation DTSingleAnimation
@end


@implementation DTAnimation

-(id)initWithResourceId:(NSString *)resourceId animations:(NSMutableDictionary*)animations_
{
	if(!(self = [self initWithResourceId:resourceId])) return nil;
	
    self.animations = animations_;
    
	return self;
}

-(DTSpriteMapFrame)frameAtIndex:(NSInteger)frameIndex forAnimation:(NSString*)animationName {
    DTSingleAnimation *animation = self.animations[animationName];
    
    NSArray *tiles = animation.tiles;
    DTSpriteMap *map = [self spriteMapForAnimation:animationName];
    
    NSInteger destinationFrameIndex = frameIndex;
    if(tiles)
        destinationFrameIndex = [tiles[frameIndex] intValue];
    
    DTSpriteMapFrame frame = [map frameAtIndex:destinationFrameIndex];
    
    if(animation.flipX) {
        SWAP(frame.coords[0], frame.coords[3]);
        SWAP(frame.coords[1], frame.coords[2]);
    }
    if(animation.flipY) {
        SWAP(frame.coords[0], frame.coords[1]);
        SWAP(frame.coords[2], frame.coords[3]);
    }
    
    return frame;
}

- (NSUInteger) frameCountForAnimation:(NSString*)animationName {
    return [[self.animations[animationName] spriteMap] frameCount];
}

- (NSUInteger) framesPerSecondForAnimation:(NSString*)animationName {
    return [self.animations[animationName] fps];
}
- (DTSpriteMap*) spriteMapForAnimation:(NSString*)animation
{
    return [self.animations[animation] spriteMap];
}
- (NSArray*)animationNames
{
    return self.animations.allKeys;
}
@end

@interface DTAnimationLoader : DTResourceLoader
@end

@implementation DTAnimationLoader
+(void)load{
	[DTResourceManager registerResourceLoader:self withTypeName:@"animation"];
}

- (id<DTResource>)createResourceWithManager:(DTResourceManager *)manager
{
    return [[DTAnimation alloc] initWithResourceId:self.path.dt_resourceId];
}

- (BOOL)loadResource:(DTAnimation *)anim usingManager:(DTResourceManager *)manager error:(NSError *__autoreleasing *)error
{
    NSMutableDictionary *animations = [NSMutableDictionary dictionary];
    NSDictionary *listOfAnimations = self.definition[@"animations"];
    for (NSString *key in listOfAnimations) {
        NSDictionary *values = listOfAnimations[key];
        DTSingleAnimation *single = [DTSingleAnimation new];
        single.fps = [values[@"fps"] floatValue];
        single.spriteMap = [manager spriteMapNamed:values[@"spriteMap"]];
        single.tiles = values[@"tiles"];
        single.flipX = [values[@"flip"][0] boolValue];
        single.flipY = [values[@"flip"][1] boolValue];
        
        animations[key] = single;
    }
    
    anim.animations = animations;
    
    return YES;
}

@end

@implementation DTResourceManager (DTAnimation)
-(DTAnimation *)animationNamed:(NSString *)name;{
	return [self resourceNamed:name];
}
@end
