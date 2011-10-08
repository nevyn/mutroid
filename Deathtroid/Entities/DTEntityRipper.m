//
//  DTEntityRipper.m
//  Deathtroid
//
//  Created by Per Borgman on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTEntityRipper.h"

#import "Vector2.h"

@implementation DTEntityRipper

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    speed = 2;
    
    self.velocity.x = speed;
    self.moveDirection = EntityDirectionRight;
    self.collisionType = EntityCollisionTypeStop;
    
    return self;
}

-(void)didCollideWithWorld:(DTCollisionInfo*)info;
{
    self.moveDirection = self.moveDirection == EntityDirectionRight ? EntityDirectionLeft : EntityDirectionRight;
    if(self.moveDirection == EntityDirectionLeft) self.velocity.x = -speed;
    else self.velocity.x = speed;
}

-(void)didCollideWithEntity:(DTEntity*)other;
{
    
}

@end
