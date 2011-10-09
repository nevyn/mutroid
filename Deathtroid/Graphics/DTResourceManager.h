//
//  DTResourceManager.h
//  Deathtroid
//
//  Created by Patrik Sjöberg on 2011-10-09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DTResource;
@protocol DTResourceLoader;

@interface DTResourceManager : NSObject

+(void)registerResourceLoader:(Class)klass withTypeName:(NSString *)name;


-(id)initWithBaseURL:(NSURL *)rootPath;

-(id<DTResource>)resourceNamed:(NSString *)name;

@end


@interface NSString (DTResourceManager)
-(BOOL)dt_isValidResourceIdentifier;
-(NSArray *)dt_resourceIdParts;
-(NSString *)dt_resourceName;
-(NSString *)dt_resourceType;
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

@interface NSURL (DTResourceManager)
-(BOOL)dt_isValidResourceIdentifier;
-(NSArray *)dt_resourceIdParts;
-(NSString *)dt_resourceName;
-(NSString *)dt_resourceType;
-(NSString *)dt_resourceId;
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


