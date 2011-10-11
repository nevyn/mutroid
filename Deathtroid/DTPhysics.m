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
    
    [pairs addObject:[[DTCollisionPair alloc] initWithClassA:[DTEntityPlayer class] b:[DTEntityRipper class] action:^(DTEntity *a, DTEntity *b){
        [a damage:((DTEntityRipper*)b).touchDamage from:b.position killer:b];
    }]];
        
    [pairs addObject:[[DTCollisionPair alloc] initWithClassA:[DTEntityPlayer class] b:[DTEntity class] action:^(DTEntity *a, DTEntity *b) {
        NSLog(@"Hej.");
    }]];
    
    [pairs addObject:[[DTCollisionPair alloc] initWithClassA:[DTEntityBullet class] b:[DTEntity class] action:^(DTEntity *a, DTEntity *b) {
        if(b == ((DTEntityBullet*)a).owner) return;

        [a remove];
        
        if(b.destructible)
            [b damage:4 from:a.position killer:((DTEntityBullet*)a).owner];
    
    }]];
    
    [pairs addObject:[[DTCollisionPair alloc] initWithClassA:[DTEntityPlayer class] b:[DTEntityDoor class] action:^(DTEntity *a, DTEntity *b) {
        if(b.world.server)
            [b.world.server teleportPlayerForEntity:a toPosition:((DTEntityDoor*)b).destinationPosition inRoomNamed:((DTEntityDoor*)b).destinationRoom];
    }]];
        
    return self;
}

-(void)runWithEntities:(NSArray*)entities world:(DTWorld*)world delta:(double)delta;
{
    for(DTEntity *entity in entities) {
        // Check if should start to fall
        DTTraceResult *down = [world traceBox:entity.size from:entity.position to:[entity.position vectorByAddingVector:[Vector2 vectorWithX:0 y:0.5]] exclude:entity ignoreEntities:YES];
        if(!down || !down.y || down.entity) entity.onGround = false;

        if(entity.gravity && entity.velocity.y < 10 && !entity.onGround) {
            entity.velocity.y += 0.5;
        }
        
        [self moveEntity:entity world:world delta:delta];
        
        for(DTEntity *other in entities) {
            if(other == entity) continue;
            
        }
    }
}

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


@end
