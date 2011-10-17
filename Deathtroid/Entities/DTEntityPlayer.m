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

@implementation DTEntityPlayer {
    float   acceleration;
    float   maxMoveSpeed;
    float   brakeSpeed;
	float   immunityTimer;
}

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    acceleration = 0.4;
    maxMoveSpeed = 5;
    brakeSpeed = 0.2;
    self.destructible = YES;
    
    self.maxHealth = self.health = 99;
            
    return self;
}

-(void)tick:(double)delta;
{
    [super tick:delta];
	
	if(immunityTimer > 0) immunityTimer -= delta;

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

-(void)jump;
{
	if(!self.onGround) return;
	
    self.onGround = false;
    self.velocity.y = -15;
}
-(void)shoot;
{
    [self.world.sroom createEntity:[DTEntityBullet class] setup:(EntCtor)^(DTEntityBullet *e) {
        e.position = [MutableVector2 vectorWithVector2:self.position];
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
	
	return YES;
}

-(BOOL)immune; { return immunityTimer > 0; }
-(void)setImmune:(BOOL)immune; { immunityTimer = 1.0; }

@end