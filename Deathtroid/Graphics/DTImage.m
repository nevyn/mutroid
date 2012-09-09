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

- (id<DTResource>)createResourceWithManager:(DTResourceManager *)manager
{
    return [[DTImage alloc] initWithResourceId:self.path.dt_resourceId];
}

-(BOOL)loadResource:(DTImage *)image usingManager:(DTResourceManager *)manager error:(NSError *__autoreleasing *)error
{
	NSString *imagePath = [self.definition objectForKey:@"file"];
	NSURL *imageURL = [manager absolutePathForFileName:imagePath];
	
	[image loadFromURL:imageURL];
    return YES;
}

@end


@implementation DTResourceManager (DTImage)
-(DTImage *)imageNamed:(NSString *)name;
{
	return [self resourceNamed:name];
}
@end