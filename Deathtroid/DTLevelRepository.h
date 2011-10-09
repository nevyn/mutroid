//
//  DTLevelRepository.h
//  Deathtroid
//
//  Created by Joachim Bengtsson on 2011-10-08.
//  Copyright (c) 2011 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DTRoom;

typedef void(^DTLevelFetchedCallback)(DTRoom *newLevel, NSError *err);

@interface DTLevelRepository : NSObject
@property(nonatomic,strong,readonly) DTLevelRepository *parentRepo;
-(id)initWithParentRepo:(DTLevelRepository*)parent;
-(void)fetchRoomNamed:(NSString*)name ofClass:(Class)cls whenDone:(DTLevelFetchedCallback)done;
@end

@interface DTDiskLevelRepository : DTLevelRepository
-(id)initWithRoot:(NSURL*)rootPath parent:(DTLevelRepository*)parent;
@property(nonatomic,strong,readonly) NSURL *rootPath;
@end

@interface DTOnlineRepository : DTLevelRepository
-(id)initWithBaseURL:(NSURL*)base storingLevelsIn:(DTDiskLevelRepository*)diskCache parent:(DTLevelRepository*)parent;
@property(nonatomic,strong,readonly) NSURL *baseURL;
@end
