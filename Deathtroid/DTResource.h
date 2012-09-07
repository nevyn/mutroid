//
//  DTResource.h
//  Deathtroid
//
//  Created by Patrik Sjöberg on 2011-10-09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTResourceManager.h"

@protocol DTResource <NSObject>

@required
@property (nonatomic, copy, readonly) NSString *resourceId;

@optional

@end


@interface DTResource : NSObject <DTResource>
-(id)initWithResourceId:(NSString *)rid;
@end



#pragma mark DTResourceLoader

@protocol DTResourceLoader <NSObject>
-(id<DTResource>)loadResourceAtURL:(NSURL *)url usingManager:(DTResourceManager *)manager;
@end

@interface DTResourceLoader : NSObject <DTResourceLoader>

@property (nonatomic, strong, readonly) NSDictionary *definition;
@property (nonatomic, strong, readonly) NSURL *path;
-(id<DTResource>)loadResourceAtURL:(NSURL *)url usingManager:(DTResourceManager *)manager;

- (id<DTResource>)createResourceWithManager:(DTResourceManager *)manager;
- (void)loadResource:(id<DTResource>)resource usingManager:(DTResourceManager *)manager error:(NSError **)error;
@end