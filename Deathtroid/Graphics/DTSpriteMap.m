//
//  DTSpriteMap.m
//  Deathtroid
//
//  Created by Patrik Sjöberg on 2011-10-09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTSpriteMap.h"
#import "DTTexture.h"

@interface DTSpriteMap ()
@property (nonatomic) CGSize imageSize;
@property (nonatomic) CGSize frameSize;

@property (nonatomic, strong) DTTexture *texture;
@end


@implementation DTSpriteMap
@synthesize frameCount;
@synthesize imageSize, frameSize;
@synthesize texture;

-(id)initWithResourceId:(NSString *)resourceId Texture:(DTTexture *)_texture frameSize:(CGSize)_frameSize;
{
	if(![self initWithResourceId:resourceId]) return nil;
	
	self.texture = _texture;
	self.frameSize = _frameSize;
	self.imageSize = texture.pixelSize;
	return self;
}

-(DTSpriteMapFrame)frameAtIndex:(NSInteger)frameIndex
{
	float cWidth = frameSize.width / imageSize.width;
	float cHeight = frameSize.height / imageSize.height;
	
	float top = 0; //TODO: maps with several rows
	float left = frameIndex * cWidth;
	float bottom = cHeight;
	float right = left + cWidth;
	DTSpriteMapFrame frame;
	
	frame.nr = (int)frameIndex;
	frame.coords[0] = left;
	frame.coords[1] = top;
	frame.coords[2] = left;
	frame.coords[3] = bottom;
	frame.coords[4] = right;
	frame.coords[5] = bottom;
	frame.coords[6] = right;
	frame.coords[7] = top;
	return frame;
}

@end


@interface DTSpriteMapLoader : DTResourceLoader
@end

@implementation DTSpriteMapLoader
+(void)load{
	[DTResourceManager registerResourceLoader:self withTypeName:@"spritemap"];
}

-(id<DTResource>)loadResourceAtURL:(NSURL *)url usingManager:(DTResourceManager *)manager
{
	[super loadResourceAtURL:url usingManager:manager];
	NSArray *sizes = [self.definition objectForKey:@"frameSize"];
	CGSize frameSize = CGSizeMake([[sizes objectAtIndex:0] floatValue], [[sizes objectAtIndex:1] floatValue]);
	DTTexture *texture = [manager textureNamed:[self.definition objectForKey:@"texture"]];
	
	DTSpriteMap *spritemap = [[DTSpriteMap alloc] initWithResourceId:url.dt_resourceId Texture:texture frameSize:frameSize];
	
	return spritemap;
}

@end




@implementation DTResourceManager (DTSpriteMap)
-(DTSpriteMap *)spriteMapNamed:(NSString *)name;{
	return [self resourceNamed:name];
}
@end