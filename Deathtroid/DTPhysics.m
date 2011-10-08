//
//  DTPhysics.m
//  Deathtroid
//
//  Created by Per Borgman on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTPhysics.h"

#import "DTWorld.h"
#import "DTEntity.h"
#import "Vector2.h"

@implementation DTPhysics

-(void)runWithEntities:(NSArray*)entities world:(DTWorld*)world delta:(double)delta;
{
    for(DTEntity *entity in entities) {
        if(entity.gravity && entity.velocity.y < 10)
            entity.velocity.y += 0.5;
        
        [self moveEntity:entity world:world delta:delta];
    }
}

-(void)moveEntity:(DTEntity*)entity world:(DTWorld*)world delta:(double)delta;
{
    Vector2 *move = [entity.velocity vectorByMultiplyingWithScalar:delta];
    
    DTTraceResult *info = [world traceBox:entity.size from:entity.position to:[entity.position vectorByAddingVector:move]];
    
    if(info==nil) { [entity.position addVector:move]; }
    else {
        if(entity.collisionType == EntityCollisionTypeNone || !info.x) entity.position.x += move.x;
        else { entity.position.x = info.collisionPosition.x; entity.velocity.x = 0; }
        if(entity.collisionType == EntityCollisionTypeNone || !info.y) entity.position.y += move.y;
        else { entity.position.y = info.collisionPosition.y; entity.velocity.y = 0; }
    }
    
    if(info.x || info.y) [entity didCollideWithWorld:info];
}


@end
