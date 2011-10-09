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
}

-(id)init;
- (BOOL) reachedTarget:(Vector2*) move;
- (BOOL) hasPassedTarget:(Vector2*) move;
- (CGPoint) findHole:(Vector2*)move;
- (CGPoint) findWall:(Vector2*)move;
- (void) updateLookDirection;

@property (nonatomic) ZoomerPosition crawlPosition;
@property (nonatomic, retain) MutableVector2 *orientation;
@property (nonatomic) CGPoint target;

@end
