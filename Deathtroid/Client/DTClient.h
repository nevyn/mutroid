//
//  DTClient.h
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DTPhysics;
@class DTServer, DTRoom, DTWorld, DTEntityPlayer, DTLevelRepository;
@class DTCamera;

@interface DTClient : NSObject
-(id)init; // to local
-(id)initConnectingTo:(NSString*)host port:(NSUInteger)port;

-(void)tick:(double)delta;
-(void)draw;

-(void)walkLeft;
-(void)stopWalk;
-(void)walkRight;
-(void)jump;
-(void)shoot;

@property (nonatomic,strong) DTPhysics *physics;

@property (nonatomic,strong) DTEntityPlayer *playerEntity;

@property (nonatomic,strong) NSMutableDictionary *rooms;
@property (nonatomic,weak) DTRoom *currentRoom;
@property (nonatomic,strong) DTLevelRepository *levelRepo;

@property (nonatomic,strong) DTCamera *camera;

@end
