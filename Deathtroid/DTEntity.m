//
//  DTEntity.m
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTEntity.h"

#import "Vector2.h"


@implementation DTEntity

@synthesize world, uuid;
@synthesize position, velocity, size, moveDirection, lookDirection, collisionType, gravity, moving;

-(id)init;
{
    if(!(self = [super init])) return nil;
        
    position = [MutableVector2 vectorWithX:5 y:1];
    velocity = [MutableVector2 vectorWithX:0 y:0];
    size = [MutableVector2 vectorWithX:0.8 y:1.75];
    
    collisionType = EntityCollisionTypeStop;
    gravity = true;
    moving = false;
    
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
        
        @"moveDirection", $num(moveDirection),
        @"lookDirection", $num(lookDirection),
        @"collisionType", $num(collisionType)
    );
}

-(void)tick:(double)delta;
{
    // CHeck state changes osv
}

-(void)didCollideWithWorld:(DTTraceResult*)info;
{
    /*
    if(info.x) { printf("Hej"); velocity.x = 0; position.x = info.position.x; } else position.x += info.velocity.x;
    if(info.y) { velocity.y = 0; position.y = info.position.y; } else position.y += info.velocity.y;
     */
}

-(void)didCollideWithEntity:(DTEntity*)other; {}

@end
