//
//  DTCore.m
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTCore.h"

#import "DTClient.h"
#import "DTServer.h"
#import "DTInput.h"
#import <Carbon/Carbon.h>

@implementation DTCore

@synthesize input;

-(id)init;
{
    input = [[DTInput alloc] init];
    
    [input.mapper registerStateActionWithName:@"WalkLeft" beginAction:^{ [client walkLeft]; } endAction:^{ [client stopWalkLeft]; }];
    [input.mapper registerStateActionWithName:@"WalkRight" beginAction:^{ [client walkRight]; } endAction:^{ [client stopWalkRight]; }];
    [input.mapper registerActionWithName:@"Jump" action:^{ [client jump]; }];
    
    [input.mapper mapKey:kVK_ANSI_A toAction:@"WalkLeft"];
    [input.mapper mapKey:kVK_ANSI_D toAction:@"WalkRight"];
    [input.mapper mapKey:49 toAction:@"Jump"];
     
    server = [[DTServer alloc] init];
    server.client = client;
    client = [[DTClient alloc] init];
    client.server = server;
    client.entities = server.entities;
    client.level = server.level;
    
    return self;
}

-(void)draw;
{
    [client draw];
}

-(void)tick:(double)delta;
{
    [server tick:delta];
}

@end
