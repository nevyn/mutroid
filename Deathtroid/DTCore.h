//
//  DTCore.h
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DTClient;
@class DTServer;
@class DTInput;

@interface DTCore : NSObject {
    DTClient    *client;
    DTServer    *server;
}

@property (nonatomic,strong) DTInput *input;

-(void)draw;
-(void)tick:(double)delta;
-(DTClient*)client;

@end
