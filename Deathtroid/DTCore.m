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
    
    [input.mapper registerStateActionWithName:@"WalkLeft" beginAction:^{ [client walkLeft]; } endAction:^{ [client stopWalkLeft]; }];
    [input.mapper registerStateActionWithName:@"WalkRight" beginAction:^{ [client walkRight]; } endAction:^{ [client stopWalkRight]; }];
    
    [input.mapper mapKey:0 toAction:@"WalkLeft"];
    [input.mapper mapKey:2 toAction:@"WalkRight"];
     
    server = [[DTServer alloc] init];
    client = [[DTClient alloc] init];
    return self;
}

-(void)draw;
{
    [client draw];
}

@end
