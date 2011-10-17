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

@synthesize loadedResources, pathURL, isServerSide;


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
-(void)resourceNamed:(NSString *)name loaded:(void(^)(id<DTResource>))whenLoaded;
{
	// todo: implement the loader chain in levelrepository
	whenLoaded([self resourceNamed:name]);
}

@end





@implementation NSString (DTResourceManager)
-(BOOL)dt_isValidResourceIdentifier;{
	NSArray *parts = [self componentsSeparatedByString:@"."];
	return parts.count == 3 && [[parts objectAtIndex:2] isEqualToString:@"resource"];
}
-(NSArray *)dt_resourceIdParts;{
	check([self dt_isValidResourceIdentifier]);
	return [self componentsSeparatedByString:@"."];
}
-(NSString *)dt_resourceName;{
	return [[self dt_resourceIdParts] objectAtIndex:0];
}
-(NSString *)dt_resourceType;{
	return [[self dt_resourceIdParts] objectAtIndex:1];
}

/// The id excluding the .resource part
-(NSString *)dt_resourceId{
	return [[[self dt_resourceIdParts] objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]] componentsJoinedByString:@"."];
}
@end


@implementation NSURL (DTResourceManager)
-(BOOL)dt_isValidResourceIdentifier;{
	return [[self lastPathComponent] dt_isValidResourceIdentifier];
}
-(NSArray *)dt_resourceIdParts;{
	return [[self lastPathComponent] dt_resourceIdParts];
}
-(NSString *)dt_resourceName;{
	return [[self lastPathComponent] dt_resourceName];
}
-(NSString *)dt_resourceType;{
	return [[self lastPathComponent] dt_resourceType];
}
-(NSString *)dt_resourceId{
	return [[self lastPathComponent] dt_resourceId];
}
@end
