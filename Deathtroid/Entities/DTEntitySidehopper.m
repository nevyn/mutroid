//
//  DTEntitySidehopper.m
//  Deathtroid
//
//  Created by Per Borgman on 10/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTEntitySidehopper.h"

#import "Vector2.h"
#import "DTWorld.h"

@implementation DTEntitySidehopper

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    self.size.x = 1.5;
    
    self.maxHealth = self.health = 5;
    self.destructible = YES;
    
    idleTimer = 0;
    
    return self;
}

-(void)tick:(double)delta;
{
    [super tick:delta];

    if(idleTimer > 0)
        idleTimer -= delta;
    if(idleTimer < 0) {
        idleTimer = 0;
        self.velocity.y = -10;
        
        // Find exciting thing to jump towards (probably nearest player)
        
        self.velocity.x = rand()%2 < 1 ? -5 : 5;
        
        self.onGround = false;
    }
}

-(void)didCollideWithWorld:(DTTraceResult *)info;
{
    if(info.velocity.y > 0) {
        idleTimer = 1;
        self.velocity.x = 0;
    }
}

@end
