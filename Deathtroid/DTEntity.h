//
//  DTEntity.h
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Vector2, MutableVector2;
@class DTEntity;
@class DTWorld;

typedef enum {
    EntityDirectionNone,
    EntityDirectionLeft,
    EntityDirectionLeftUp,
    EntityDirectionUp,
    EntityDirectionRightUp,
    EntityDirectionRight,
    EntityDirectionRightDown,
    EntityDirectionDown,
    EntityDirectionLeftDown
} EntityDirection;

typedef enum {
    EntityCollisionTypeNone,
    EntityCollisionTypeStop,
    EntityCollisionTypeBounce
} EntityCollisionType;

/*
typedef struct {
    BOOL        x, y;
    DTEntity    *entity;    // null = world
    Vector2     *position;
} CollisionInfo;
*/

@interface DTCollisionInfo : NSObject
@property (nonatomic) BOOL x, y;
@property (nonatomic,weak) DTEntity *entity;
@property (nonatomic,weak) Vector2 *collisionPosition;
@property (nonatomic,weak) Vector2 *velocity;   // Entity's velocity at impact
@end

@interface DTEntity : NSObject

-(id)initWithWorld:(DTWorld*)_world;

-(void)didCollideWithWorld:(DTCollisionInfo*)info;
-(void)didCollideWithEntity:(DTEntity*)other;

-(void)tick:(double)delta;

@property (nonatomic,strong) MutableVector2 *position;
@property (nonatomic,strong) MutableVector2 *velocity;
@property (nonatomic,strong) MutableVector2 *size;
@property (nonatomic) EntityDirection moveDirection;
@property (nonatomic) EntityDirection lookDirection;
@property (nonatomic) EntityCollisionType collisionType;
@property (nonatomic) BOOL gravity;
@property (nonatomic,weak) DTWorld *world;

@end

