//
//  DTEntityExplosion.m
//  Deathtroid
//
//  Created by Joachim Bengtsson on 2012-09-09.
//
//

#import "DTEntityExplosion.h"
#import "Vector2.h"
#import "DTResourceManager.h"
#import "DTAnimation.h"
#import "DTWorld.h"
#import "DTServerRoom.h"

@implementation DTEntityExplosion {
    BOOL playedSound;
}
-(id)init;
{
    if(!(self = [super init])) return nil;
    
    self.gravity = false;
    self.size.min.x = self.size.min.y = -0.5;
    self.size.max.x = self.size.max.y = 0.5;
    
    self.animation = [[DTResourceManager sharedManager] animationNamed:@"power_explosion.animation"];
    self.currentState = @"exploding";
    
    NSTimeInterval interval = [self.animation frameCountForAnimation:self.currentState] * 1./[self.animation framesPerSecondForAnimation:self.currentState];
    [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(kaboom) userInfo:nil repeats:NO];
    
    return self;
}

-(void)tick:(double)delta;
{
    [super tick:delta];
    
    if(!playedSound && !self.world.server) {
        [[self makeVoice:@"burst"] playUntilFinished];
        playedSound = YES;
    }
}

-(void)kaboom
{
    NSLog(@"Kaboom!");
    [self.world.sroom destroyEntityKeyed:self.uuid];
}

@end
