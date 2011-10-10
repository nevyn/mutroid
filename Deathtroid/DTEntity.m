//
//  DTEntity.m
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTEntity.h"

#import "Vector2.h"
#import "DTWorld.h"
#import "DTServer.h"
#import "DTRoom.h"
#import "DTSpriteMap.h"

@implementation DTEntity

@synthesize world, uuid;
@synthesize position, velocity, size, moveDirection, lookDirection, collisionType, gravity, moving, onGround, health, destructible;
@synthesize damageFlashTimer, maxHealth;
@synthesize walkSprite, currentWalkSpriteFrame, walkAnimationCounter, rotation;

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    health = 1;
    maxHealth = 1;
    destructible = NO;
        
    position = [MutableVector2 vectorWithX:5 y:1];
    velocity = [MutableVector2 vectorWithX:0 y:0];
    size = [MutableVector2 vectorWithX:0.8 y:1.75];
    
    collisionType = EntityCollisionTypeStop;
    gravity = true;
    moving = false;
    onGround = false;
    
    moveDirection = EntityDirectionRight;
    lookDirection = EntityDirectionRight;
    
    self.currentWalkSpriteFrame = 0;
    self.walkAnimationCounter = 0.0;
    self.rotation = 0.0;
    
    return self;
}
-(id)initWithRep:(NSDictionary*)rep;
{
    Class klass = NSClassFromString([rep objectForKey:@"class"]);
    if(klass && ![klass isEqual:[self class]])
        self = [klass alloc];
    
    return [[self init] updateFromRep:rep];
}

-(id)updateFromRep:(NSDictionary*)rep;
{
    $doif(@"position", position = [[MutableVector2 alloc] initWithRep:o]);
    $doif(@"velocity", velocity = [[MutableVector2 alloc] initWithRep:o]);
    $doif(@"size", size = [[MutableVector2 alloc] initWithRep:o]);
    
    $doif(@"gravity", gravity = [o boolValue]);
    $doif(@"moving", moving = [o boolValue]);
    $doif(@"onGround", onGround = [o boolValue]);
    $doif(@"maxHealth", maxHealth = [o intValue]);
    
    $doif(@"moveDirection", moveDirection = [o intValue]);
    $doif(@"lookDirection", lookDirection = [o intValue]);
    $doif(@"collisionType", collisionType = [o intValue]);
    
    DTResourceManager *resources = [[DTResourceManager alloc] initWithBaseURL:[[NSBundle mainBundle] URLForResource:@"resources" withExtension:nil]];
    $doif(@"walkSprite", walkSprite = [resources spriteMapNamed:o]);
    
    return self;
}
-(NSDictionary*)rep;
{
    NSMutableDictionary *rep = $mdict(
        @"class", NSStringFromClass([self class]),
        
        @"position", [position rep],
        @"velocity", [velocity rep],
        @"size", [size rep],
        
        @"gravity", $num(gravity),
        @"moving", $num(moving),
        @"onGround", $num(onGround),
        
        @"maxHealth", $num(maxHealth),
        
        @"moveDirection", $num(moveDirection),
        @"lookDirection", $num(lookDirection),
        @"collisionType", $num(collisionType)
    );
    if(self.walkSprite) [rep setObject:self.walkSprite.resourceId forKey:@"walkSprite"];
    
    return rep;
}

-(void)tick:(double)delta;
{
    [self animateWalk:delta];
    
    if(damageFlashTimer > 0)
        damageFlashTimer -= delta;
}

- (void) animateWalk:(double)delta {
    
    if (walkSprite) {
    
        self.walkAnimationCounter += delta;
    
        int fps = 2; // TODO: get this value from DTResource
        float totalNumFrames = self.walkSprite.frameCount;
    
        if (self.walkAnimationCounter >= 1.0/fps) {
            
            self.currentWalkSpriteFrame++;
            if (self.currentWalkSpriteFrame >= totalNumFrames) self.currentWalkSpriteFrame = 0;
        
            self.walkAnimationCounter = 0.0;
        }
    }
}

-(void)didCollideWithWorld:(DTTraceResult*)info; {}
-(void)didCollideWithEntity:(DTEntity*)other; {}

-(BOOL)damage:(int)damage from:(Vector2*)damagerLocation;
{
    if(!destructible) return NO;
    health -= damage;
    damageFlashTimer = 0.2;
    [world.server entityDamaged:self damage:damage location:damagerLocation];
	return YES;
}

-(NSString*)description;
{
    return $sprintf(@"<%@ %@/0x%x in %@>", NSStringFromClass([self class]), self.uuid, self, self.world.room);
}
@end
