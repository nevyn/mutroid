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
#import "DTSound.h"
#import "DTResourceManager.h"
#import "DTAnimation.h"

@implementation DTEntityBullet { BOOL playedSound; }
@synthesize owner;

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    self.gravity = false;
    self.size.min.x = self.size.min.y = -0.4;
    self.size.max.x = self.size.max.y = 0.4;        
    
    self.animation = [[DTResourceManager sharedManager] animationNamed:@"power_bullet.animation"];
    
    return self;
}

-(void)tick:(double)delta;
{
    [super tick:delta];
    
    if(!playedSound && !self.world.server) {
        [[self makeVoice:@"baseshot"] playUntilFinished];
        playedSound = YES;
    }

    
    if(self.moveDirection == EntityDirectionLeft) {
        self.velocity.x = -20;
        self.currentState = @"flying-left";
    } else {
        self.velocity.x = 20;
        self.currentState = @"flying-right";
    }
}

-(void)didCollideWithWorld:(DTTraceResult *)info;
{
    [self.world.sroom destroyEntityKeyed:self.uuid];
}

@end
