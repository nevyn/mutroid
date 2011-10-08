//
//  DTClient.h
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DTServer, DTLevel;
@class DTCamera;

@interface DTClient : NSObject
-(id)init; // to local
-(id)initConnectingTo:(NSString*)host port:(NSUInteger)port;

-(void)tick:(double)delta;
-(void)draw;

-(void)walkLeft;
-(void)stopWalkLeft;
-(void)walkRight;
-(void)stopWalkRight;
-(void)jump;


@property (nonatomic,strong) NSMutableDictionary *entities;

@property (nonatomic,strong) DTLevel *level;

@property (nonatomic,strong) DTCamera *camera;

@end
