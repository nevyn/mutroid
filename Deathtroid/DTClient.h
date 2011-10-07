//
//  DTClient.h
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTClient : NSObject
-(id)init; // to local
-(id)initConnectingTo:(NSString*)host port:(NSUInteger)port;
-(void)draw;

-(void)walkLeft;
-(void)stopWalkLeft;
-(void)walkRight;
-(void)stopWalkRight;

@end
