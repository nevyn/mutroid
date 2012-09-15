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
@class DTSpriteMap;
@class DTAnimation;
#import "FISound.h"

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


@interface DTBBox : NSObject {}
-(id)initWithRep:(NSDictionary*)rep;
@property (nonatomic,strong) MutableVector2 *min, *max;
@end



@interface DTEntity : NSObject
-(id)init; // overload, but don't call. Set up default state. 'world' and 'uuid' are set.
-(id)initWithRep:(NSDictionary*)rep world:(DTWorld*)world uuid:(NSString*)uuid; // call, but don't overload
-(id)updateFromRep:(NSDictionary*)rep; // overload, update with state from server
-(NSDictionary*)rep; // overload, returning state the client wants from server

-(void)didCollideWithWorld:(DTTraceResult*)info;

-(void)tick:(double)delta;

-(BOOL)damage:(int)damage from:(Vector2*)damagerLocation killer:(DTEntity*)killer;
-(void)remove;

-(void)sendToCounterpart:(NSDictionary*)hash; // from server, send to all clients' counterpart entities
-(void)receivedFromCounterpart:(NSDictionary*)hash; // override this

-(FISound*)makeVoice:(NSString*)soundName; // bound to entity's location

@property (nonatomic) int health;
@property (nonatomic) int maxHealth;
@property (nonatomic) BOOL destructible;
@property (nonatomic,strong) MutableVector2 *position;
@property (nonatomic,strong) MutableVector2 *velocity;
@property (nonatomic,strong) DTBBox *size;
@property (nonatomic) EntityDirection moveDirection;
@property (nonatomic) EntityDirection lookDirection;
@property (nonatomic) EntityCollisionType collisionType;
@property (nonatomic) BOOL gravity;
@property (nonatomic) BOOL moving;  // Actually physically flexing its muscles to induce forward motion
@property (nonatomic) BOOL onGround;

@property (nonatomic) float damageFlashTimer;

@property (nonatomic,weak) DTWorld *world;
@property (nonatomic,strong) NSString *uuid;
@property (nonatomic,strong) NSString *templateUUID;
@property (nonatomic,readonly) NSString *typeName;

@property (nonatomic, retain) NSString *currentState;

// protected

@property (nonatomic, retain) DTAnimation* animation;
@property (nonatomic, assign) float rotation;

@end

