//
//  DTResource.m
//  Deathtroid
//
//  Created by Patrik Sjöberg on 2011-10-09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTResource.h"

@implementation DTResource

@synthesize resourceId;

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
		[NSException raise:error.description format:nil];
	}
	self.definition = dict;
	return nil;
}
@end