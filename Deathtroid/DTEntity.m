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

@synthesize world;
@synthesize position, velocity, size, moveDirection, lookDirection, collisionType, gravity;

-(id)init {
    if(!(self = [super init])) return nil;
    
    printf("SEN DENNA!\n");
    
    position = [MutableVector2 vectorWithX:5 y:1];
    velocity = [MutableVector2 vectorWithX:0 y:0];
    size = [MutableVector2 vectorWithX:0.8 y:1.75];
    
    collisionType = EntityCollisionTypeStop;
    gravity = true;
    
    return self;
}

-(id)initWithWorld:(DTWorld*)_world {
    if(!(self = [super init])) return nil;
    
    printf("FÖRST DENNA\n");
    
    world = world;
    
    return [self init];
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
