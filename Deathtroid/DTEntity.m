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

@implementation DTEntity

@synthesize world, uuid;
@synthesize position, velocity, size, moveDirection, lookDirection, collisionType, gravity, moving, onGround, health;
@synthesize damageFlashTimer;

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    health = 1;
        
    position = [MutableVector2 vectorWithX:5 y:1];
    velocity = [MutableVector2 vectorWithX:0 y:0];
    size = [MutableVector2 vectorWithX:0.8 y:1.75];
    
    collisionType = EntityCollisionTypeStop;
    gravity = true;
    moving = false;
    onGround = false;
    
    moveDirection = EntityDirectionRight;
    lookDirection = EntityDirectionRight;
    
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
    
    $doif(@"moveDirection", moveDirection = [o intValue]);
    $doif(@"lookDirection", lookDirection = [o intValue]);
    $doif(@"collisionType", collisionType = [o intValue]);
    
    return self;
}
-(NSDictionary*)rep;
{
    return $dict(
        @"class", NSStringFromClass([self class]),
        
        @"position", [position rep],
        @"velocity", [velocity rep],
        @"size", [size rep],
        
        @"gravity", $num(gravity),
        @"moving", $num(moving),
        @"onGround", $num(onGround),
        
        @"moveDirection", $num(moveDirection),
        @"lookDirection", $num(lookDirection),
        @"collisionType", $num(collisionType)
    );
}

-(void)tick:(double)delta;
{
    if(damageFlashTimer > 0)
        damageFlashTimer -= delta;
}

-(void)didCollideWithWorld:(DTTraceResult*)info; {}
-(void)didCollideWithEntity:(DTEntity*)other; {}

-(void)damage:(int)damage;
{
    health -= damage;
    damageFlashTimer = 0.2;
    [world.server entityDamaged:self damage:damage];
}

-(NSString*)description;
{
    return $sprintf(@"<%@ %@/0x%x in %@>", NSStringFromClass([self class]), self.uuid, self, self.world.room);
}
@end
