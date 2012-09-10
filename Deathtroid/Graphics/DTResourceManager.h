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

+ (DTResourceManager *)sharedManager;

+(void)registerResourceLoader:(Class)klass withTypeName:(NSString *)name;


-(id)initWithBaseURL:(NSURL *)rootPath;
@property(nonatomic) NSURL *baseURL;

// sync
-(id<DTResource>)resourceNamed:(NSString *)name;
// async, not done
-(void)resourceNamed:(NSString *)name loaded:(void(^)(id<DTResource>))whenLoaded;

// writes to local disk
- (void)saveResource:(id<DTResource>)resource;

- (NSURL *)absolutePathForFileName:(NSString *)filename;
@end


@interface NSString (DTResourceManager)
-(BOOL)dt_isValidResourceIdentifier;
-(NSArray *)dt_resourceIdParts;
-(NSString *)dt_resourceName;
-(NSString *)dt_resourceType;
@end


@interface NSURL (DTResourceManager)
-(BOOL)dt_isValidResourceIdentifier;
-(NSArray *)dt_resourceIdParts;
-(NSString *)dt_resourceName;
-(NSString *)dt_resourceType;
-(NSString *)dt_resourceId;
@end

