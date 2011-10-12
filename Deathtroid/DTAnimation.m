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


@implementation DTAnimation

@synthesize spriteMap;
@synthesize animations;

-(id)initWithResourceId:(NSString *)resourceId spriteMap:(DTSpriteMap*)spriteMap_ animations:(NSMutableDictionary*)animations_
{
	if(![self initWithResourceId:resourceId]) return nil;
	
	self.spriteMap = spriteMap_;
    self.animations = animations_;
    
	return self;
}

-(DTSpriteMapFrame)frameAtIndex:(NSInteger)frameIndex forAnimation:(NSString*)animationName {
    
    NSDictionary *animation = [self.animations objectForKey:animationName];
    NSArray *frames = [animation objectForKey:@"tiles"];
    return [self.spriteMap frameAtIndex:[[frames objectAtIndex:frameIndex] intValue]];
}

- (NSUInteger) frameCountForAnimation:(NSString*)animationName {
    
    NSDictionary *animation = [self.animations objectForKey:animationName];
    return [(NSArray*)[animation objectForKey:@"tiles"] count];
}

- (NSUInteger) framesPerSecondForAnimation:(NSString*)animationName {
    
    NSDictionary *animation = [self.animations objectForKey:animationName];
    return [[animation objectForKey:@"fps"] intValue];
}

@end

@interface DTAnimationLoader : DTResourceLoader
@end

@implementation DTAnimationLoader
+(void)load{
	[DTResourceManager registerResourceLoader:self withTypeName:@"animation"];
}

-(id<DTResource>)loadResourceAtURL:(NSURL *)url usingManager:(DTResourceManager *)manager
{
	[super loadResourceAtURL:url usingManager:manager];
        
	DTSpriteMap *spriteMap = [manager spriteMapNamed:[self.definition objectForKey:@"spriteMap"]];
    
    NSMutableDictionary *animations = [NSMutableDictionary dictionary];
    NSArray *listOfAnimations = [self.definition objectForKey:@"animations"];
    for (NSDictionary *animation in listOfAnimations) {
        [animations setObject:[animation objectForKey:@"data"] forKey:(NSString*)[animation objectForKey:@"name"]];
    }
    
    DTAnimation *animation = [[DTAnimation alloc] initWithResourceId:url.dt_resourceId spriteMap:spriteMap animations:animations];
    
	return animation;
}

@end

@implementation DTResourceManager (DTAnimation)
-(DTAnimation *)animationNamed:(NSString *)name;{
	return [self resourceNamed:name];
}
@end
