//
//  DTResource.m
//  Deathtroid
//
//  Created by Patrik Sjöberg on 2011-10-09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTResource.h"

@interface DTResource ()
@property (nonatomic, copy) NSString *resourceId;
@end

@implementation DTResource

@synthesize resourceId;

-(id)init{
	[NSException raise:@"Use designated initializer 'initWithResourceId:'" format:nil];
	return nil;
}

-(id)initWithResourceId:(NSString *)rid;
{
	if(![super init]) return nil;
	
	self.resourceId = rid;
	return self;
}

@end

@interface DTResourceLoader ()
@property (nonatomic, strong) NSDictionary *definition;
@property (nonatomic, strong) NSURL *path;
@end

@implementation DTResourceLoader
@synthesize definition;
@synthesize path;

- (id<DTResource>)createResourceWithManager:(DTResourceManager *)manager
{
    [NSException raise:@"Resource" format:@"%@ needs to override %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd)];
    return nil;
}

- (void)loadResource:(id<DTResource>)resource usingManager:(DTResourceManager *)manager error:(NSError **)error
{
    [NSException raise:@"Resource" format:@"Need to override %@", NSStringFromSelector(_cmd)];
}


- (void)loadDefinitionAtURL:(NSURL *)url usingManager:(DTResourceManager *)manager;
{
    //Load definition file
	NSData *data = [NSData dataWithContentsOfURL:url];
	NSError *jsonError = nil;
	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
	if(jsonError){
		NSLog(@"Error: %@", jsonError);
		[NSException raise:NSInvalidArgumentException format:@"%@", jsonError];
	}
	self.definition = dict;
}

- (void)reloadResource:(id<DTResource>)resource atURL:(NSURL *)url usingManager:(DTResourceManager *)manager error:(NSError **)error;
{
    self.path = url;
    [self loadDefinitionAtURL:url usingManager:manager];
    [self loadResource:resource usingManager:manager error:error];
}

-(id<DTResource>)loadResourceAtURL:(NSURL *)url usingManager:(DTResourceManager *)manager;
{
    self.path = url;
    [self loadDefinitionAtURL:url usingManager:manager];
    
    id<DTResource> resource = [self createResourceWithManager:manager];
    
    NSError *error = nil;
    [self loadResource:resource usingManager:manager error:&error];
    
	return resource;
}

@end