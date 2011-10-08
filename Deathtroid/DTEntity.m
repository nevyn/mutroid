//
//  DTEntity.m
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTEntity.h"

#import "Vector2.h"

@implementation DTCollisionInfo
@synthesize x,y,entity,collisionPosition,velocity;
-(id)initWithX:(BOOL)_x y:(BOOL)_y entity:(DTEntity*)_entity collisionPosition:(Vector2*)colPos velocity:(Vector2*)_velocity;
{
    if(!(self = [super init])) return nil;
    x = _x;
    y = _y;
    entity = _entity;
    collisionPosition = colPos;
    velocity = _velocity;
    return self;
}
@end

@implementation DTEntity

@synthesize world, uuid;
@synthesize position, velocity, size, moveDirection, lookDirection, collisionType, gravity;

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    printf("SEN DENNA!\n");
    
    position = [MutableVector2 vectorWithX:5 y:1];
    velocity = [MutableVector2 vectorWithX:0 y:0];
    size = [MutableVector2 vectorWithX:0.8 y:1.75];
    
    collisionType = EntityCollisionTypeStop;
    gravity = true;
    
    return self;
}
-(id)initWithRep:(NSDictionary*)rep;
{
    Class klass = NSClassFromString([rep objectForKey:@"class"]);
    if(klass && ![klass isEqual:[self class]])
        self = [klass alloc];
    
    return [[self init] updateFromRep:rep];
}

#define $doif(key, then) ({id o = [rep objectForKey:key]; if(o) { then; } });

-(id)updateFromRep:(NSDictionary*)rep;
{
    $doif(@"position", position = [[MutableVector2 alloc] initWithRep:o]);
    $doif(@"velocity", velocity = [[MutableVector2 alloc] initWithRep:o]);
    $doif(@"size", size = [[MutableVector2 alloc] initWithRep:o]);
    
    $doif(@"moveDirection", moveDirection = [o intValue]);
    $doif(@"lookDirection", lookDirection = [o intValue]);
    $doif(@"collisionType", collisionType = [o intValue]);
    
    return self;
}
-(NSDictionary*)rep;
{
    return $dict(
        @"position", [position rep],
        @"velocity", [velocity rep],
        @"size", [size rep],
        @"moveDirection", $num(moveDirection),
        @"lookDirection", $num(lookDirection),
        @"collisionType", $num(collisionType)
    );
}

-(void)tick:(double)delta;
{
    // CHeck state changes osv
}

-(void)didCollideWithWorld:(DTCollisionInfo*)info;
{
    /*
    if(info.x) { printf("Hej"); velocity.x = 0; position.x = info.position.x; } else position.x += info.velocity.x;
    if(info.y) { velocity.y = 0; position.y = info.position.y; } else position.y += info.velocity.y;
     */
}

-(void)didCollideWithEntity:(DTEntity*)other; {}

@end
