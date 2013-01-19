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
#import "DTServerRoom.h"

static int gettile(int *tiles, int x, int y, int width, int height) {
    if(x < 0 || x >= width || y < 0 || y >= height) return 0;
    else return tiles[y * width + x];
}

@implementation DTTraceResult
@synthesize x,y,entity,collisionPosition,velocity,slope;
-(id)initWithX:(BOOL)_x y:(BOOL)_y slope:(BOOL)_slope collisionPosition:(Vector2*)colPos entity:(DTEntity*)_entity velocity:(Vector2*)_velocity;
{
    if(!(self = [super init])) return nil;
    
    x = _x;
    y = _y;
    entity = _entity;
    collisionPosition = colPos;
    velocity = _velocity;
    slope = _slope;
    
    return self;
}
@end


@implementation DTWorld

-(id)initWithRoom:(DTRoom*)room
{
    if(!(self = [super init])) return nil;
    _room = room;
    return self;
}



-(DTTraceResult*)traceBox:(DTBBox*)box from:(Vector2*)from to:(Vector2*)to exclude:(DTEntity*)exclude ignoreEntities:(BOOL)ignore;
{
    DTTraceResult *res = [self traceBox:box from:from to:to exclude:exclude ignoreEntities:ignore inverted:false];
    res.collisionTile = gettile([_room collisionLayer].tiles, to.x, to.y, [_room collisionLayer].width, [_room collisionLayer].height);
    return res;
}

-(DTTraceResult*)traceBox:(DTBBox*)box from:(Vector2*)from to:(Vector2*)to exclude:(DTEntity*)exclude ignoreEntities:(BOOL)ignore inverted:(BOOL)inverted;
{
    Vector2 *move = [to vectorBySubtractingVector:from];
    
    float length = [move length];
    
    if(length == 0.0) {
        return [[DTTraceResult alloc] initWithX:NO y:NO slope:NO collisionPosition:nil entity:nil velocity:nil];
    }
    
    int   steps = ceil(length);
    
    float stepX = move.x / steps;
    float stepY = move.y / steps;
        
    DTMap *map = [_room collisionLayer];

    for(int i=0; i<=steps; i++) {
        // Remember that we essentially send in a single position here.
        // i == 0 can be skipped, we assume that the current position is a valid one.
        DTTraceResult *result = [self traceBoxStep:box origin:(Vector2*)from dx:i*stepX dy:i*stepY map:map exclude:exclude ignore:ignore inverted:inverted];
        if(result.x || result.y) return result;
    }
    
    return [[DTTraceResult alloc] initWithX:NO y:NO slope:NO collisionPosition:nil entity:nil velocity:nil];
}

// Checks a position. Knows direction. If there's a collision, can calculate a valid position.
// Assumes that previous position was valid
-(DTTraceResult*)traceBoxStep:(DTBBox*)box origin:(Vector2*)origin dx:(float)dx dy:(float)dy map:(DTMap*)map exclude:(DTEntity*)exclude ignore:(BOOL)ignore inverted:(BOOL)inverted;
{
    int *tiles = map.tiles;
    int width = map.width;
    int height = map.height;
    
    BOOL collidedLeft = NO;
    BOOL collidedRight = NO;
    BOOL collidedTop = NO;
    BOOL collidedBottom = NO;
    
    float goalX = origin.x;
    float goalY = origin.y;

    float delta = 0.001;

    int midTile = 0;
                
    // Move in x
    if(dx != 0.0) {
        goalX += dx;
        
        int xtopY = (int)(goalY + box.min.y + delta);
        int xbotY = (int)(goalY + box.max.y - delta);
    
        float xrightX = goalX + box.max.x - delta;
        float xleftX = goalX + box.min.x + delta;
        
        midTile = tiles[xbotY * map.width + (int)origin.x];
                
        for(int y=xtopY; y <= xbotY; y++) {
            if((midTile == 3 || midTile == 4) && y == xbotY)
                break;
        
            int tileRight = gettile(tiles, (int)xrightX, y, width, height);
            int tileLeft = gettile(tiles, (int)xleftX, y, width, height);
                              
            if(dx > 0.0 && tileRight == 1) {
                collidedRight = YES;
                goalX = floor(xrightX) - box.max.x - delta;
                break;
            }
            if(dx < 0.0 && tileLeft == 1) {
                collidedLeft = YES;
                goalX = ceil(xleftX) - box.min.x + delta;
                break;
            }
        }
    }
        
    // Then Y
    if(dy != 0.0) {
        goalY += dy;
        
        float ytopY = goalY + box.min.y + delta;
        float ybotY = goalY + box.max.y - delta;
        
        int yleftX = (int)(goalX + box.min.x + delta);
        int yrightX = (int)(goalX + box.max.x - delta);
        
        midTile = tiles[(int)ybotY * map.width + (int)goalX];
                
        for(int x = yleftX; x <= yrightX; x++) {    
            int tileTop = gettile(tiles, x, (int)ytopY, width, height);
            int tileBot = gettile(tiles, x, (int)ybotY, width, height);
            
            if(dy < 0.0 && tileTop == 1) {
                collidedTop = YES;
                goalY = ceil(ytopY) - box.min.y + delta;
                break;
            }
            if(dy > 0.0 && tileBot == 1 && (midTile != 3 && midTile != 4)) {
                collidedBottom = YES;
                goalY = floor(ybotY) - box.max.y - delta;
                break;
            }
        }
    }
    
    // Check for slopes at the valid position
    float bottom = goalY + box.max.y - delta;
    midTile = gettile(tiles, (int)goalX, (int)bottom, width, height);
    BOOL slope = NO;
    
    if(midTile == 3) {
        float penX = goalX - floor(goalX);
        float penY = bottom - floor(bottom);
        
        // On (inside) slope
        if(penX + penY > 1.0 - delta) {
            goalY = ceil(bottom) - penX - box.max.y;
            collidedBottom = YES;
            slope = YES;
        }
    } else if(midTile == 4) {
        float penX = 1 - (goalX - floor(goalX));
        float penY = bottom - floor(bottom);
        
        if(penX + penY > 1.0 - delta) {
            goalY = ceil(bottom) - penX - box.max.y;
            collidedBottom = YES;
            slope = YES;
        }
    } else if(midTile == 5) {
        float penX = goalX - floor(goalX);
        float penY = bottom - (floor(bottom) + 0.5);
        
        if(penY > 0.0) {
            penY *= 2.0f;
            if(penX + penY > 1.0 - delta) {
                goalY = ceil(bottom) - (penX / 2.0) - box.max.y;
                collidedBottom = YES;
                slope = YES;
            }
        }
    } else if(midTile == 6) {
        float penX = 1 - (goalX - floor(goalX));
        float penY = bottom - (floor(bottom) + 0.5);
        
        if(penY > 0.0) {
            penY *= 2.0f;
            if(penX + penY > 1.0 - delta) {
                goalY = ceil(bottom) - (penX / 2.0) - box.max.y;
                collidedBottom = YES;
                slope = YES;
            }
        }
    } else if(midTile == 7) {
        float penX = goalX - floor(goalX);
        float penY = bottom - floor(bottom);
        
        if(penX + penY > 1.0 - delta) {
            goalY = ceil(bottom) - (penX / 2.0) - box.max.y - 0.5;
            collidedBottom = YES;
            slope = YES;
        }
    } else if(midTile == 8) {
        float penX = 1 - (goalX - floor(goalX));
        float penY = bottom - floor(bottom);
        
        if(penX + penY > 1.0 - delta) {
            goalY = ceil(bottom) - (penX / 2.0) - box.max.y - 0.5;
            collidedBottom = YES;
            slope = YES;
        }
    }
    
    // Hack together some entity collision for now
    DTEntity *collided = nil;
    if(!ignore) {
        CGRect me = CGRectMake(origin.x+box.min.x, origin.y+box.min.y, box.max.x-box.min.x, box.max.y-box.min.y);
        for(DTEntity *other in self.sroom.entities.allValues) {
            if(exclude == other)
                continue;
            CGRect them = CGRectMake(other.position.x+other.size.min.x, other.position.y+other.size.min.y, other.size.max.x-other.size.min.x, other.size.max.y-other.size.min.y);
            if(CGRectIntersectsRect(me, them)) {
                collided = other;
                break;
            }
            
        }
    }
    
    DTTraceResult *result = [[DTTraceResult alloc]
                    initWithX:(collidedLeft || collidedRight)
                            y:(collidedBottom || collidedTop)
                        slope:slope
            collisionPosition:[Vector2 vectorWithX:goalX y:goalY]
                       entity:collided
                     velocity:nil];

    return result;
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
