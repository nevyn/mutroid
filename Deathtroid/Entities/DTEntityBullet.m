//
//  DTEntityBullet.m
//  Deathtroid
//
//  Created by Per Borgman on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTEntityBullet.h"

#import "Vector2.h"
#import "DTWorld.h"
#import "DTServer.h"
#import "DTServerRoom.h"
#import "DTEntityPlayer.h"

@implementation DTEntityBullet

@synthesize owner;

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    self.gravity = false;
    self.size.x = self.size.y = 0.4;
    
    return self;
}

-(void)tick:(double)delta;
{
    [super tick:delta];
    
    if(self.moveDirection == EntityDirectionLeft) self.velocity.x = -10;
    else self.velocity.x = 10;
}

-(void)didCollideWithWorld:(DTTraceResult *)info;
{
    [self.world.sroom destroyEntityKeyed:self.uuid];
}

@end
