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
- (CGPoint) findHole:(Vector2*)move from:(Vector2*)from to:(Vector2*)to;
- (CGPoint) findWall:(Vector2*)move from:(Vector2*)from to:(Vector2*)to;
- (void) updateLookDirection;
- (void) updateRotation;

@property (nonatomic) ZoomerPosition crawlPosition;
@property (nonatomic, retain) MutableVector2 *orientation;
@property (nonatomic) CGPoint target;
@property (nonatomic) BOOL clockwise;
@property (nonatomic) BOOL targetIsWall;
@property (nonatomic) float speed;

@end
