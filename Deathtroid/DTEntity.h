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
@class DTTraceResult;

#define $doif(key, then) ({id o = [rep objectForKey:key]; if(o) { then; } });

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


@interface DTEntity : NSObject
-(id)init;
-(id)initWithRep:(NSDictionary*)rep;
-(id)updateFromRep:(NSDictionary*)rep;
-(NSDictionary*)rep;

-(void)didCollideWithWorld:(DTTraceResult*)info;
-(void)didCollideWithEntity:(DTEntity*)other;

-(void)tick:(double)delta;

-(BOOL)damage:(int)damage from:(Vector2*)damagerLocation;

@property (nonatomic) int health;
@property (nonatomic) int maxHealth;
@property (nonatomic) BOOL destructible;
@property (nonatomic,strong) MutableVector2 *position;
@property (nonatomic,strong) MutableVector2 *velocity;
@property (nonatomic,strong) MutableVector2 *size;
@property (nonatomic) EntityDirection moveDirection;
@property (nonatomic) EntityDirection lookDirection;
@property (nonatomic) EntityCollisionType collisionType;
@property (nonatomic) BOOL gravity;
@property (nonatomic) BOOL moving;  // Actually physically flexing its muscles to induce forward motion
@property (nonatomic) BOOL onGround;

@property (nonatomic) float damageFlashTimer;

@property (nonatomic,weak) DTWorld *world;
@property (nonatomic,strong) NSString *uuid;

@end

