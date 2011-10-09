//
//  DTTexture.m
//  Deathtroid
//
//  Created by Patrik Sjöberg on 2011-10-09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTTexture.h"
#import "DTImage.h"

#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>

@interface DTTexture ()
@property (nonatomic) int textureId;
-(void)loadWithImage:(DTImage *)image;
@end

@implementation DTTexture
@synthesize textureId, pixelSize;

-(id)initWithResourceId:(NSString *)rid{
	return [super initWithResourceId:rid];
}

-(void)loadWithImage:(DTImage *)image;
{
	NSBitmapImageRep *bitmap = image.NSBitmapImageRep;
	
	unsigned char *data = [bitmap bitmapData];
	int	width  = (int)[bitmap pixelsWide];
	int	height = (int)[bitmap pixelsHigh];
	BOOL hasAlpha = [bitmap hasAlpha];
	
	pixelSize = CGSizeMake(width, height);
	
	GLuint texId;
	glGenTextures(1, &texId);
	glBindTexture(GL_TEXTURE_2D, texId);
	textureId = texId;

	
	glTexImage2D(GL_TEXTURE_2D, 0, hasAlpha?GL_RGBA:GL_RGB,
				 width, height, 0, 
				 hasAlpha?GL_RGBA:GL_RGB, GL_UNSIGNED_BYTE,
				 data);
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
}

-(void)use;
{
	glBindTexture(GL_TEXTURE_2D, self.textureId);
}
@end



@interface DTTextureLoader : DTResourceLoader

@end

@implementation DTTextureLoader

+(void)load{
	[DTResourceManager registerResourceLoader:self withTypeName:@"texture"];
}

-(id<DTResource>)loadResourceAtURL:(NSURL *)url usingManager:(DTResourceManager *)manager;
{
	[super loadResourceAtURL:url usingManager:manager];
	
	DTTexture *tex = [[DTTexture alloc] initWithResourceId:url.dt_resourceId];
	
	NSString *imageName = [self.definition objectForKey:@"image"];
	DTImage *image = [manager imageNamed:imageName];
	
	[tex loadWithImage:image];
	
	return tex;
}
@end



@implementation DTResourceManager (DTTexture)
-(DTTexture *)textureNamed:(NSString *)name;
{
	return [self resourceNamed:name];
}
@end