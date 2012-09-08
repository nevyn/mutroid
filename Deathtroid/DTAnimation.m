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

@interface DTAnimation ()
@property (nonatomic, retain) NSMutableDictionary *animations;
@end

@interface DTSingleAnimation : NSObject
@property NSArray *tiles;
@property int fps;
@property DTSpriteMap *spriteMap;
@end
@implementation DTSingleAnimation
@end


@implementation DTAnimation

-(id)initWithResourceId:(NSString *)resourceId animations:(NSMutableDictionary*)animations_
{
	if(![self initWithResourceId:resourceId]) return nil;
	
    self.animations = animations_;
    
	return self;
}

-(DTSpriteMapFrame)frameAtIndex:(NSInteger)frameIndex forAnimation:(NSString*)animationName {
    NSArray *tiles = [self.animations[animationName] tiles];
    DTSpriteMap *map = [self spriteMapForAnimation:animationName];
    NSInteger destinationFrame = frameIndex;
    if(tiles)
        destinationFrame = [tiles[frameIndex] intValue];
    
    return [map frameAtIndex:destinationFrame];
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

- (void)loadResource:(DTAnimation *)anim usingManager:(DTResourceManager *)manager error:(NSError *__autoreleasing *)error
{
    NSMutableDictionary *animations = [NSMutableDictionary dictionary];
    NSDictionary *listOfAnimations = self.definition[@"animations"];
    for (NSString *key in listOfAnimations) {
        NSDictionary *values = listOfAnimations[key];
        DTSingleAnimation *single = [DTSingleAnimation new];
        single.fps = [values[@"fps"] floatValue];
        single.spriteMap = [manager spriteMapNamed:values[@"spriteMap"]];
        single.tiles = values[@"tiles"];
        animations[key] = single;
    }
    
    anim.animations = animations;
}

@end

@implementation DTResourceManager (DTAnimation)
-(DTAnimation *)animationNamed:(NSString *)name;{
	return [self resourceNamed:name];
}
@end
