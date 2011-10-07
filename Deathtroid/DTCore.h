//
//  DTCore.h
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DTClient;

@interface DTCore : NSObject {
    DTClient    *client;
   // DTServer    *server;
}

-(void)draw;

@end
