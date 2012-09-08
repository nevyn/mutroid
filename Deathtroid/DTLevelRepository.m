//
//  DTLevelRepository.m
//  Deathtroid
//
//  Created by Joachim Bengtsson on 2011-10-08.
//  Copyright (c) 2011 Third Cog Software. All rights reserved.
//

#import "DTLevelRepository.h"
#import "DTRoom.h"
#import "DTResourceManager.h"

@implementation DTLevelRepository
@synthesize parentRepo;
-(id)initWithParentRepo:(DTLevelRepository*)parent;
{
    if(!(self = [super init])) return nil;
    
    parentRepo = parent;
    
    return self;
}
-(void)fetchRoomNamed:(NSString*)name ofClass:(Class)cls whenDone:(DTLevelFetchedCallback)done;
{
    if(parentRepo) [parentRepo fetchRoomNamed:name ofClass:cls whenDone:done];
    else done(nil, nil);
}
@end

@implementation DTDiskLevelRepository
@synthesize rootPath = _rootPath;
-(id)initWithRoot:(NSURL*)rootPath parent:(DTLevelRepository*)parent;
{
    if(!(self = [super initWithParentRepo:parent])) return nil;
    
    _rootPath = rootPath;
    
    return self;
}
-(void)fetchRoomNamed:(NSString*)name ofClass:(Class)cls whenDone:(DTLevelFetchedCallback)done;
{
    NSParameterAssert(done != nil);
    
    void(^local)() = ^ {
        NSURL *levelURL = [_rootPath URLByAppendingPathComponent:$sprintf(@"%@.dtroom",name) isDirectory:YES];
        if(![[NSFileManager defaultManager] fileExistsAtPath:levelURL.path]) {
            done(nil, $makeErr(NSPOSIXErrorDomain, ENOENT, @"No such directory"));
            return;
        }
        
        DTRoom *room = [[DTResourceManager sharedManager] resourceNamed:levelURL.dt_resourceName];
        done(room, nil);
    };
    if(self.parentRepo) [self.parentRepo fetchRoomNamed:name ofClass:cls whenDone:^(DTRoom *newLevel, NSError *err) {
        if(newLevel) {
            done(newLevel, nil);
            return;
        }
        local();
    }];
    else local();
}
@end

@implementation DTOnlineRepository {
    DTDiskLevelRepository *_diskCache;
}
@synthesize baseURL;
-(id)initWithBaseURL:(NSURL*)base storingLevelsIn:(DTDiskLevelRepository*)diskCache parent:(DTLevelRepository*)parent;{
    if(!(self = [super initWithParentRepo:parent])) return nil;
    
    baseURL = base;
    _diskCache = diskCache;
    
    return self;
}

@end