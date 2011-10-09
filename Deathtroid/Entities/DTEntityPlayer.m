//
//  DTPlayerEntity.m
//  Deathtroid
//
//  Created by Per Borgman on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTEntityPlayer.h"

#import "Vector2.h"
#import "DTWorld.h"

@implementation DTEntityPlayer

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    acceleration = 0.4;
    maxMoveSpeed = 5;
    brakeSpeed = 0.2;
    self.destructible = YES;
    
    self.health = 10;
            
    return self;
}

-(void)tick:(double)delta;
{
    [super tick:delta];

    if(self.moving) {
        if(self.moveDirection == EntityDirectionRight && self.velocity.x < maxMoveSpeed) {
            self.velocity.x += acceleration; if(self.velocity.x > maxMoveSpeed) self.velocity.x = maxMoveSpeed;
        } else if(self.moveDirection == EntityDirectionLeft && self.velocity.x > -maxMoveSpeed) {
            self.velocity.x -= acceleration; if(self.velocity.x < -maxMoveSpeed) self.velocity.x = -maxMoveSpeed;
        }
    } else if(self.velocity.x != 0) {
        if(self.moveDirection == EntityDirectionRight) {
            self.velocity.x -= brakeSpeed; if(self.velocity.x < 0) self.velocity.x = 0;
        } else if(self.moveDirection == EntityDirectionLeft) {
            self.velocity.x += brakeSpeed; if(self.velocity.x > 0) self.velocity.x = 0;
        }               
    }
    
    if(self.velocity.x < 0) self.lookDirection = EntityDirectionLeft;
    else if(self.velocity.x > 0) self.lookDirection = EntityDirectionRight;
}

-(void)jump;
{
    self.onGround = false;
    self.velocity.y = -15;
}

@end