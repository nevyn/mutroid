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

@implementation DTCore

@synthesize input;

-(id)init;
{
    input = [[DTInput alloc] init];
    
    [input.mapper registerStateActionWithName:@"WalkLeft" beginAction:^{ [server walkLeft]; } endAction:^{ [server stopWalkLeft]; }];
    [input.mapper registerStateActionWithName:@"WalkRight" beginAction:^{ [server walkRight]; } endAction:^{ [server stopWalkRight]; }];
    
    [input.mapper mapKey:0 toAction:@"WalkLeft"];
    [input.mapper mapKey:2 toAction:@"WalkRight"];
     
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
