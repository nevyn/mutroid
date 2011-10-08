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

@end

@implementation DTEntity

@synthesize position, velocity, size, moveDirection, lookDirection, collisionType;

-(id)init {
    if(!(self = [super init])) return nil;
    
    position = [MutableVector2 vectorWithX:5 y:1];
    velocity = [MutableVector2 vectorWithX:0 y:0];
    size = [MutableVector2 vectorWithX:0.8 y:1.75];
    
    collisionType = EntityCollisionTypeStop;
    
    return self;
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
