//
//  DTImageLoader.m
//  Deathtroid
//
//  Created by Patrik Sjöberg on 2011-10-09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTImage.h"

@interface DTImage ()
@property (nonatomic, copy) NSURL *url;

-(void)loadFromURL:(NSURL *)path;
@end

@implementation DTImage

@synthesize url;

-(void)loadFromURL:(NSURL *)path;{
	self.url = path;
}

-(NSData *)imageData;
{
	unsigned char *data = [self.NSBitmapImageRep bitmapData];
	if(data)
		return [NSData dataWithBytes:data length:sizeof(data)];
	return nil;
}

-(NSImage *)NSImage;
{
	return [[NSImage alloc] initWithContentsOfURL:self.url];
}

-(NSBitmapImageRep *)NSBitmapImageRep;
{
	NSBitmapImageRep *img = [NSBitmapImageRep imageRepWithContentsOfURL:self.url];
	return img;
}

@end



@interface DTImageLoader : DTResourceLoader
@end


@implementation DTImageLoader

+(void)load{
	[DTResourceManager registerResourceLoader:self withTypeName:@"image"];
}

-(id<DTResource>)loadResourceAtURL:(NSURL *)url usingManager:(DTResourceManager *)manager;
{
	[super loadResourceAtURL:url usingManager:manager];
	
	NSString *imagePath = [self.definition objectForKey:@"file"];
	NSURL *imageURL = [NSURL URLWithString:imagePath relativeToURL:url];
	
	DTImage *image = [[DTImage alloc] initWithResourceId:url.dt_resourceId];
	[image loadFromURL:imageURL];
	return image;
}

@end


@implementation DTResourceManager (DTImage)
-(DTImage *)imageNamed:(NSString *)name;
{
	return [self resourceNamed:name];
}
@end