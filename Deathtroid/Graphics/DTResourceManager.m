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
#import "SCEvents.h"


static NSMutableDictionary *resourceLoaders = nil;

@interface DTResourceManager () <SCEventListenerProtocol>

@property (nonatomic, strong) NSMutableDictionary *loadedResources;
@property (nonatomic, copy) NSURL *pathURL;
@property (nonatomic, strong) SCEvents *pathObserver;
@end

@implementation DTResourceManager

@synthesize loadedResources, pathURL, isServerSide;


+ (DTResourceManager *)sharedManager
{
    static DTResourceManager *__shared = nil;
    if (!__shared)
        __shared = [[DTResourceManager alloc] initWithBaseURL:[[NSBundle mainBundle] URLForResource:@DT_RESOURCE_DIR withExtension:nil]];
    return __shared;
}

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
    self.pathObserver = [[SCEvents alloc] init];
    self.pathObserver.notificationLatency = 0.5;
    self.pathObserver.delegate = self;
    [self.pathObserver startWatchingPaths:@[rootPath.path]];
	
	return self;
}

- (void)pathWatcher:(SCEvents *)pathWatcher eventOccurred:(SCEvent *)event;
{
    for (id<DTResource> resource in [self.loadedResources allValues])
        [self reloadResource:resource];
}

- (NSURL *)absolutePathForFileName:(NSString *)filename
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray *props = @[NSURLNameKey, NSURLIsDirectoryKey];
	NSDirectoryEnumerator *dirEnumerator = [fm enumeratorAtURL:self.pathURL includingPropertiesForKeys:props options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
	
	for(NSURL *url in dirEnumerator){
		NSNumber *isDirectory;
		
		[url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
        
        if ([isDirectory boolValue])
            continue;
        
        if ([[url lastPathComponent] isEqualToString:filename])
            return url;
	}
    return nil;
}

-(NSURL *)pathForResourceId:(NSString *)resource_id
{
	if(!resource_id.dt_isValidResourceIdentifier){
		[NSException raise:@"Resource" format:@"Invalid resource id: '%@'. Resources identifiers must have the format '[name].[type].resource'.", resource_id];
	}
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray *props = @[NSURLNameKey, NSURLIsDirectoryKey, NSURLContentModificationDateKey];
	NSDirectoryEnumerator *dirEnumerator = [fm enumeratorAtURL:self.pathURL includingPropertiesForKeys:props options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
	
	for(NSURL *url in dirEnumerator){
		NSNumber *isDirectory;
		
		[url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
		
		if([[url pathExtension] isEqualToString:@"resource"]){
			NSString *this_id = [url lastPathComponent];
			
			if([this_id isEqualToString:resource_id]){
				return url;
			}
		}
	}
    
    [NSException raise:@"Resource" format:@"Resource not found: %@", resource_id];
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

- (void)reloadResourceNamed:(NSString *)name
{
    id<DTResource> resource = self.loadedResources[name];
    if (resource)
        [self reloadResource:resource];
}

- (void)reloadResource:(id<DTResource>)resource
{
    NSURL *path = [self pathForResourceNamed:resource.resourceId];
    id<DTResourceLoader> loader = [DTResourceManager resourceLoaderForTypeName:path.dt_resourceType];
    NSError *error = nil;
    [loader reloadResource:resource atURL:path usingManager:self error:&error];
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
