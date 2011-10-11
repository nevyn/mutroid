//
//  DTEntityZoomer.h
//  Deathtroid
//
//  Created by Per Borgman on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTEntityEnemyBase.h"

typedef enum {
    ZoomerPositionCeiling,
    ZoomerPositionGround,
    ZoomerPositionWallLeft,
    ZoomerPositionWallRight,
} ZoomerPosition;


@interface DTEntityZoomer : DTEntityEnemyBase {
    float   speed;
    MutableVector2 *orientation;
    CGPoint target;
    BOOL clockwise;
    BOOL targetIsWall;
}

-(id)init;
- (BOOL) reachedTarget:(Vector2*) move;
- (BOOL) hasPassedTarget:(Vector2*) move;
- (CGPoint) findTarget:(Vector2*)move from:(Vector2*)from to:(Vector2*)to inverted:(BOOL)inverted;
- (CGPoint) findHole:(Vector2*)move from:(Vector2*)from to:(Vector2*)to;
- (CGPoint) findWall:(Vector2*)move from:(Vector2*)from to:(Vector2*)to;
- (void) updateLookDirection;
- (void) updateRotation;
- (Vector2*) getStartVectorWithOffset:(BOOL)offset moveVector:(Vector2*)move;
- (Vector2*) getEndVectorWithOffset:(BOOL)offset moveVector:(Vector2*)move;
- (Vector2*) getVectorWithOffset:(BOOL)offset moveVector:(Vector2*)move isStart:(BOOL)isStart;

@property (nonatomic) ZoomerPosition crawlPosition;
@property (nonatomic, retain) MutableVector2 *orientation;
@property (nonatomic) CGPoint target;
@property (nonatomic) BOOL clockwise;
@property (nonatomic) BOOL targetIsWall;
@property (nonatomic) float speed;

@property (nonatomic) float deltaCounter; // debug

@end
