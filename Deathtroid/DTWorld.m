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
#import "DTLevel.h"

@implementation DTWorld

@synthesize level;

-(DTCollisionInfo*)traceBox:(Vector2*)box from:(Vector2*)from to:(Vector2*)to;
{
    Vector2 *move = [to vectorBySubtractingVector:from];
    float l = [move length];
    float stepLength = l>1 ? 1/l : 1;
        
    int steps = (int)ceil(l);
    
    DTMap *map = ((DTLayer*)[level.layers objectAtIndex:level.entityLayerIndex]).map;

    // Potentiell bug här, det kan bli så att move.x*(steps*stepLength) blir större än to.x. Får fixa det när det blir ett problem.
    
    for(int i=0; i<steps; i++) {
        DTCollisionInfo *result = [self traceBoxStep:from size:box vx:move.x*(steps*stepLength) vy:move.y*(steps*stepLength) map:map];
        if(result != nil) return result;
    }
    
    return nil;
}

-(DTCollisionInfo*)traceBoxStep:(Vector2*)position size:(Vector2*)size vx:(float)vx vy:(float)vy map:(DTMap*)map;
{
    int *tiles = map.tiles;
    
    BOOL collidedX = false;
    BOOL collidedY = false;
    
    float gx = position.x;
    float gy = position.y;
        
    if(vx != 0.0f) {
        gx += vx;
        float coordx = vx < 0 ? gx : gx + size.x - 0.0001;
        int from = (int)gy;
        int to = (int)(gy + size.y - 0.0001);
        for(int y=from; y<=to; ++y) {
            if(tiles[y*map.width+(int)coordx] > 0) {
                gx = vx < 0 ? ceil(coordx) : floor(coordx) - size.x;
                collidedX = true;
                break;
            }
        }
    }
    
    if(vy != 0.0f) {
        gy += vy;
        float coordy = vy < 0 ? gy : gy + size.y - 0.0001;
        int from = (int)gx;
        int to = (int)(gx + size.x - 0.0001);
        for(int x=from; x<=to; ++x) {
            if(tiles[(int)coordy*map.width+x] > 0) {
                gy = vy < 0 ? ceil(coordy) : floor(coordy) - size.y;
                collidedY = true;
                break;
            }
        }
    }
        
    if(collidedX || collidedY) {
        return [[DTCollisionInfo alloc] initWithX:collidedX y:collidedY entity:nil collisionPosition:[Vector2 vectorWithX:gx y:gy] velocity:nil];
    }
    return nil;
}

@end
