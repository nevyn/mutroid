//
//  DTWorld.m
//  Deathtroid
//
//  Created by Per Borgman on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTWorld.h"

#import "DTEntity.h"
#import "Vector2.h"
#import "DTMap.h"
#import "DTLayer.h"
#import "DTRoom.h"
#import "DTServer.h"

@implementation DTTraceResult
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


@implementation DTWorld

@synthesize level, server;

-(id)initWithLevel:(DTRoom*)_level;
{
    if(!(self = [super init])) return nil;
    level = _level;
    return self;
}

-(DTTraceResult*)traceBox:(Vector2*)box from:(Vector2*)from to:(Vector2*)to exclude:(DTEntity*)exclude;
{
    return [self traceBox:box from:from to:to exclude:exclude inverted:false];
}

-(DTTraceResult*)traceBox:(Vector2*)box from:(Vector2*)from to:(Vector2*)to exclude:(DTEntity*)exclude inverted:(BOOL)inverted;
{
    Vector2 *move = [to vectorBySubtractingVector:from];
    float l = [move length];
    float stepLength = l>1 ? 1/l : 1;
    
    int steps = (int)ceil(l);
    
    if(steps > 1) printf("SNABB JÄVEL DU! %d, %f\n", steps, stepLength);
    
    DTMap *map = ((DTLayer*)[level.layers objectAtIndex:level.entityLayerIndex]).map;

    // Potentiell bug här, det kan bli så att move.x*(steps*stepLength) blir större än to.x. Får fixa det när det blir ett problem.
    for(int i=0; i<steps; i++) {
     //   if(move.x > 0 && move.x*(steps*stepLength) > to.x) 
           
        DTTraceResult *result = [self traceBoxStep:from size:box vx:move.x*(steps*stepLength) vy:move.y*(steps*stepLength) map:map exclude:exclude inverted:inverted];
        if(result != nil) return result;
    }
    
    return nil;
}

-(DTTraceResult*)traceBoxStep:(Vector2*)position size:(Vector2*)size vx:(float)vx vy:(float)vy map:(DTMap*)map exclude:(DTEntity*)exclude inverted:(BOOL)inverted;
{
    int *tiles = map.tiles;
    
    BOOL collidedX = NO;
    BOOL collidedY = NO;
    
    float gx = position.x;
    float gy = position.y;
            
    if(vx != 0.0f) {
        gx += vx;
        float coordx = vx < 0 ? gx : gx + size.x - 0.0001;
        int from = (int)gy;
        int to = (int)(gy + size.y - 0.0001);
        for(int y=from; y<=to; ++y) {
            int tile = tiles[y*map.width+(int)coordx];
            if(tile>0) {
                gx = vx < 0 ? ceil(coordx) : floor(coordx) - size.x;
                collidedX = YES;
                break;
            }
        }
        
        if(inverted) {
            collidedX = !collidedX;
            gx = vx < 0 ? ceil(coordx)-size.x : floor(coordx);
        }        
    }
    
    if(vy != 0.0f) {
        gy += vy;
        float coordy = vy < 0 ? gy : gy + size.y - 0.0001;
        int from = (int)gx;
        int to = (int)(gx + size.x - 0.0001);
        for(int x=from; x<=to; ++x) {
            int tile = tiles[(int)coordy*map.width+x];
            if(tile>0) {
                gy = vy < 0 ? ceil(coordy) : floor(coordy) - size.y;
                collidedY = YES;
                break;
            }
        }
        
        if(inverted) {
            collidedY = !collidedY;
            gy = vy < 0 ? ceil(coordy)-size.y : floor(coordy);
        }
    }
        
    if(collidedX || collidedY) {
        return [[DTTraceResult alloc] initWithX:collidedX y:collidedY entity:nil collisionPosition:[Vector2 vectorWithX:gx y:gy] velocity:nil];
    }
    
    if(server) {
        for(DTEntity *entity in server.entities.allValues) {
            if(entity == exclude) continue;
            if([self boxCollideBoxA:position sizeA:size boxB:entity.position sizeB:entity.size]) {
                return [[DTTraceResult alloc] initWithX:YES y:YES entity:entity collisionPosition:[Vector2 vectorWithVector2:position] velocity:nil];
            }
        }
    }

    return nil;
}

-(BOOL)boxCollideBoxA:(Vector2*)boxA sizeA:(Vector2*)sizeA boxB:(Vector2*)boxB sizeB:(Vector2*)sizeB;
{
    if(boxA.x + sizeA.x < boxB.x) return NO;
    if(boxA.x > boxB.x + sizeB.x) return NO;
    if(boxA.y + sizeA.y < boxB.y) return NO;
    if(boxA.y > boxB.y + sizeB.y) return NO;
    return YES;
}

@end
