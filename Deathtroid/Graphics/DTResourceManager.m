//
//  DTResourceManager.m
//  Deathtroid
//
//  Created by Patrik Sjöberg on 2011-10-09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTResourceManager.h"
#import "DTResource.h"
#import <AssertMacros.h>


static NSMutableDictionary *resourceLoaders = nil;

@interface DTResourceManager ()

@property (nonatomic, strong) NSMutableDictionary *loadedResources;
@property (nonatomic, copy) NSURL *pathURL;

@end

@implementation DTResourceManager

@synthesize loadedResources, pathURL;


+(void)registerResourceLoader:(id)klass withTypeName:(NSString *)name;
{
	if(!resourceLoaders) resourceLoaders = [NSMutableDictionary new];
	[resourceLoaders setObject:klass forKey:name];
}

+(id<DTResourceLoader>)resourceLoaderForTypeName:(NSString *)name{
	if(!resourceLoaders) return nil;
	id loaderClass = [resourceLoaders objectForKey:name];
	return [loaderClass new];
}

-(id)init
{
	if(![super init]) return nil;
	self.loadedResources = [NSMutableDictionary new];
	return self;
}

-(id)initWithBaseURL:(NSURL *)rootPath
{
	if(![self init]) return nil;
	
	self.pathURL = rootPath;
	
	return self;
}

-(NSURL *)pathForResourceId:(NSString *)resource_id
{
	if(!resource_id.dt_isValidResourceIdentifier){
		[NSException raise:@"Invalid resource id: '%@'. Resources identifiers must have the format '[name].[type].resource'." format:resource_id];
	}
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray *props = [NSArray arrayWithObjects:NSURLNameKey, NSURLIsDirectoryKey, nil];
	NSDirectoryEnumerator *dirEnumerator = [fm enumeratorAtURL:self.pathURL includingPropertiesForKeys:props options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
	
	for(NSURL *url in dirEnumerator){
		NSNumber *isDirectory;
		
		[url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
		
		if(![isDirectory boolValue]) continue;
		
		if([[url pathExtension] isEqualToString:@"resource"]){
			NSString *this_id = [url lastPathComponent];
			
			if([this_id isEqualToString:resource_id]){
				return url;
			}
		}
	}
	return nil;
}

-(NSURL *)pathForResourceNamed:(NSString *)wantedResource_id
{
	return [self pathForResourceId:[wantedResource_id stringByAppendingPathExtension:@"resource"]];
}

-(id<DTResource>)loadResourceNamed:(NSString *)name
{
	NSURL *path = [self pathForResourceNamed:name];
	id<DTResourceLoader>loader = [DTResourceManager resourceLoaderForTypeName:path.dt_resourceType];
	if(!loader) NSLog(@"Warning!: No loader for resource %@", name);
	return [loader loadResourceAtURL:path usingManager:self];
}

-(id<DTResource>)resourceNamed:(NSString *)name;
{
	id<DTResource> resource = [self.loadedResources objectForKey:name];
	if(!resource){
		resource = [self loadResourceNamed:name];
		if(resource) [self.loadedResources setObject:resource forKey:name];
	}
	if(!resource) NSLog(@"Failed to load resource named %@", name);
	return resource;
}

@end




