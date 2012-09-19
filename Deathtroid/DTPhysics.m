//
//  DTPhysics.m
//  Deathtroid
//
//  Created by Per Borgman on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTPhysics.h"

#import "DTServer.h"
#import "DTWorld.h"
#import "DTEntity.h"
#import "Vector2.h"

#import "DTEntityPlayer.h"
#import "DTEntityRipper.h"
#import "DTEntityZoomer.h"
#import "DTEntitySidehopper.h"
#import "DTEntityBullet.h"
#import "DTEntityDoor.h"

@implementation DTCollisionPair

-(id)initWithClassA:(Class)a b:(Class)b action:(CollisionAction)_action;
{
    if(!(self = [super init])) return nil;

    classA = a;
    classB = b;
    action = _action;
    
    return self;
}

-(void)runWithEntityA:(DTEntity*)a b:(DTEntity*)b;
{
    if([a isKindOfClass:classA] && [b isKindOfClass:classB]) action(a,b);
}

@end

@implementation DTPhysics

@synthesize pairs;

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    pairs = [NSMutableArray array];
    
    [pairs addObject:[[DTCollisionPair alloc] initWithClassA:[DTEntityPlayer class] b:[DTEntityEnemyBase class] action:^(DTEntity *a, DTEntity *b){
        [a damage:((DTEntityRipper*)b).touchDamage from:b.position killer:b];
    }]];
    
    [pairs addObject:[[DTCollisionPair alloc] initWithClassA:[DTEntityBullet class] b:[DTEntity class] action:^(DTEntity *a, DTEntity *b) {
        if(b == ((DTEntityBullet*)a).owner) return;

        [a remove];
        
        if(b.destructible)
            [b damage:4 from:a.position killer:((DTEntityBullet*)a).owner];
    
    }]];
    
    [pairs addObject:[[DTCollisionPair alloc] initWithClassA:[DTEntityPlayer class] b:[DTEntityDoor class] action:^(DTEntity *a, DTEntity *b) {
        if(b.world.server)
            [b.world.server teleportPlayer:[b.world.server playerForEntity:a] toPosition:((DTEntityDoor*)b).destinationPosition inRoomNamed:((DTEntityDoor*)b).destinationRoom];
    }]];
        
    return self;
}

-(void)runWithEntities:(NSArray*)entities world:(DTWorld*)world delta:(double)delta;
{
    for(DTEntity *entity in entities) {
        if(entity.onGround)
            [self moveEntityGround:entity world:world delta:delta];
        else
            [self moveEntityAir:entity world:world delta:delta];
    }
}


-(void)moveEntityGround:(DTEntity*)entity world:(DTWorld*)world delta:(double)delta;
{
    // There is no Y on the ground
    float move = entity.velocity.x * delta;
    
    // Is there a wall in the way?
    DTTraceResult *side = [world traceBox:entity.size from:entity.position to:[Vector2 vectorWithX:entity.position.x + move y:0.0] exclude:entity ignoreEntities:NO];
    if(side.x) {
        entity.position.x = side.collisionPosition.x;
        entity.velocity.x = 0.0f;
    } else {
        entity.position.x += move;
    }
    
    [self handleEntityCollisionsInTrace:side forEntity:entity];

    // What's under us at our new position? (Air or slope?)
    DTTraceResult *down = [world traceBox:entity.size from:entity.position to:[entity.position vectorByAddingVector:[Vector2 vectorWithX:0 y:0.5]] exclude:entity ignoreEntities:YES];
    
    if(!down.y) {
        // There is nothing under us. We're off the ground!
        entity.onGround = false;
        return;
    } else {
        if(!down.slope) {
            // Normal ground
            entity.position.y = down.collisionPosition.y;
        } else {
            // Slope
            // Force y
            // This is when we walk over downward slope
            entity.position.y = down.collisionPosition.y;
        }
    }
}

-(void)moveEntityAir:(DTEntity*)entity world:(DTWorld*)world delta:(double)delta;
{
    // Gravitate
    if(entity.gravity && entity.velocity.y < 8)
        entity.velocity.y += 0.5;

    Vector2 *move = [entity.velocity vectorByMultiplyingWithScalar:delta];
    
    // Do a trace for the move
    DTTraceResult *trace = [world traceBox:entity.size from:entity.position to:[entity.position vectorByAddingVector:move] exclude:entity ignoreEntities:NO];
    
    [self handleEntityCollisionsInTrace:trace forEntity:entity];
    
    if(trace.x) {
        entity.velocity.x = 0.0f;
        entity.position.x = trace.collisionPosition.x;
    } else {
        entity.position.x += move.x;
    }

    if(trace.y) {
        // We could be on ground
        if(move.y > 0.0f)
            entity.onGround = YES;
            
        entity.velocity.y = 0.0f;
        entity.position.y = trace.collisionPosition.y;
    } else {
        entity.position.y += move.y;
    }
}

- (void)handleEntityCollisionsInTrace:(DTTraceResult*)info forEntity:(DTEntity*)entity
{
    if(!info.entity && (info.x || info.y)) {
        [entity didCollideWithWorld:info];
    } else if(info.entity) {
        NSLog(@"Kollision mellan %@ och %@", entity, info.entity);
        for(DTCollisionPair *pair in pairs) {
            [pair runWithEntityA:entity b:info.entity];
        }
    }
}

/*

-(void)moveEntity:(DTEntity*)entity world:(DTWorld*)world delta:(double)delta;
{
    Vector2 *move = [entity.velocity vectorByMultiplyingWithScalar:delta];
    
    DTTraceResult *info = [world traceBox:entity.size from:entity.position to:[entity.position vectorByAddingVector:move] exclude:entity ignoreEntities:NO];
    
    if(info==nil) { [entity.position addVector:move]; }
    else {
        if(info.entity || entity.collisionType == EntityCollisionTypeNone || !info.x) entity.position.x += move.x;
        else if(info.x) { entity.position.x = info.collisionPosition.x; entity.velocity.x = 0; }
        if(info.entity || entity.collisionType == EntityCollisionTypeNone || !info.y) entity.position.y += move.y;
        else if(info.y) {
            if(entity.velocity.y > 0 && entity.gravity) entity.onGround = YES;
            entity.position.y = info.collisionPosition.y; entity.velocity.y = 0;
        }
    }
    
    if(!info.entity && (info.x || info.y)) [entity didCollideWithWorld:info];
    else if(info.entity) {
        for(DTCollisionPair *pair in pairs) {
            [pair runWithEntityA:entity b:info.entity];
        }
    }
}

*/


@end
