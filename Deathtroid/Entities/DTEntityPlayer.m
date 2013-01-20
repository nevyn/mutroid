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
#import "DTEntityBullet.h"
#import "DTServerRoom.h"
#import "DTResourceManager.h"
#import "DTAnimation.h"

@implementation DTEntityPlayer {
    float   acceleration;
    float   maxMoveSpeed;
    float   brakeSpeed;
	float   immunityTimer;
    float   pressedDown;
    DTEntityBullet *_lastBullet;
}

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    acceleration = 0.4;
    maxMoveSpeed = 16;
    brakeSpeed = 0.5;
    self.destructible = YES;
    
    self.maxHealth = self.health = 99;
    
    self.size.min.x = -0.49;
    self.size.max.x = 0.49;
    self.size.min.y = -3;
    self.size.max.y = 0;
    
    DTResourceManager *resourceManager = [DTResourceManager sharedManager];
    self.animation = [resourceManager animationNamed:@"samus.animation"];
    
    return self;
}

-(void)tick:(double)delta;
{
    [super tick:delta];
	
	if(immunityTimer > 0) immunityTimer -= delta;

//    if(self.moving) {
//        if(self.moveDirection == EntityDirectionRight && self.velocity.x < maxMoveSpeed) {
//            self.velocity.x += acceleration; if(self.velocity.x > maxMoveSpeed) self.velocity.x = maxMoveSpeed;
//        } else if(self.moveDirection == EntityDirectionLeft && self.velocity.x > -maxMoveSpeed) {
//            self.velocity.x -= acceleration; if(self.velocity.x < -maxMoveSpeed) self.velocity.x = -maxMoveSpeed;
//        }
//    } else if(self.velocity.x != 0) {
//        if(self.moveDirection == EntityDirectionRight) {
//            self.velocity.x -= brakeSpeed; if(self.velocity.x < 0) self.velocity.x = 0;
//        } else if(self.moveDirection == EntityDirectionLeft) {
//            self.velocity.x += brakeSpeed; if(self.velocity.x > 0) self.velocity.x = 0;
//        }
//    }
//    
//    if(self.velocity.x < 0) self.lookDirection = EntityDirectionLeft;
//    else if(self.velocity.x > 0) self.lookDirection = EntityDirectionRight;
    
    if (pressedDown >= 0) {
        pressedDown -= delta;
        if (pressedDown < 0)
            pressedDown = -1;
    }
    
    NSString *doing =
        !self.onGround ? @"jump-roll" :
        pressedDown >= 0 ? @"roll-ground" :
        @"walking";
    NSString *direction = self.lookDirection == EntityDirectionLeft ? @"left" : @"right";
    
    self.currentState = [NSString stringWithFormat:@"%@-%@", doing, direction];
    
    if ([doing isEqualToString:@"walking"]) {
        self.size.min.y = -3;
        self.size.max.y = 0;
    }
}

-(id)updateFromRep:(NSDictionary*)rep;
{
    [super updateFromRep:rep];
    $doif(@"immunityTimer", immunityTimer = [o floatValue]);
    return self;
}
-(NSDictionary*)rep;
{
    NSMutableDictionary *rep = $mdict(
        @"immunityTimer", $numf(immunityTimer)
    );
    [rep addEntriesFromDictionary:[super rep]];
    return rep;
}

-(void)pressUp {
    if(!self.onGround) return;
	
    self.onGround = false;
    self.velocity.y = -12;
    
    self.size.min.y = -1.5;
    self.size.max.y = 0;
}
-(void)pressDown {
    
    if (pressedDown >= 0) return;
    pressedDown = 0.7;
    
    self.size.min.y = -0.5;
    self.size.max.y = 0;
}
-(void)jump;
{
	if(!self.onGround) return;
	
    self.onGround = false;
    self.velocity.y = -15;
}
-(void)shoot;
{
    [_lastBullet didCollideWithWorld:nil];
    MutableVector2 *p = self.position.mutableCopy;
    p.y -= 1.7 ;
    p.x += self.lookDirection == EntityDirectionLeft ? -.9 : +.9;
    _lastBullet = [self.world.sroom createEntity:[DTEntityBullet class] setup:(EntCtor)^(DTEntityBullet *e) {
        e.position = p;
        e.moveDirection = e.lookDirection = self.lookDirection;
        e.owner = self;
    }];
}

-(BOOL)damage:(int)damage from:(Vector2*)damagerLocation killer:(DTEntity *)killer;
{
	if(self.immune) return NO;
	if(![super damage:damage from:damagerLocation killer:killer]) return NO;
	
	self.immune = YES;
	
	float strength = damage*2;
	self.velocity = [MutableVector2 vectorWithX:damagerLocation.x < self.position.x ? strength : -strength y:5];
	self.onGround = NO;
    
    if(!self.world.server)
        [[self makeVoice:@"injured"] playUntilFinished];

	
	return YES;
}

-(BOOL)immune; { return immunityTimer > 0; }
-(void)setImmune:(BOOL)immune; { immunityTimer = 1.0; }

@end