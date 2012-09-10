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
@class DTEditor;

@interface DTCore : NSObject
@property (nonatomic,strong) DTInput *input;
@property (nonatomic,strong) DTEditor *editor;

-(void)draw;
-(void)tick:(double)delta;
-(DTClient*)client;

// To know if server and client are running in the same process
+ (NSString*)appInstanceIdentifier;
@end
