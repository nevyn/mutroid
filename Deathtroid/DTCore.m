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

@implementation DTCore

-(id)init;
{
    client = [[DTClient alloc] init];
    server = [[DTServer alloc] init];
    return self;
}

-(void)draw;
{
    [client draw];
}

@end
