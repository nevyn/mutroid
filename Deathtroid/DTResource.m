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
@end

@implementation DTResourceLoader
@synthesize definition;

/// Must be overridden
-(id<DTResource>)loadResourceAtURL:(NSURL *)url usingManager:(DTResourceManager *)manager;
{
	//Load definition file
	NSData *data = [NSData dataWithContentsOfURL:[url URLByAppendingPathComponent:@"definition"]];
	NSError *error = nil;
	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
	if(error){
		NSLog(@"Error: %@", error);
		[NSException raise:NSInvalidArgumentException format:@"%@", error];
	}
	self.definition = dict;
	return nil;
}
@end