//
//  DTEntityZoomer.m
//  Deathtroid
//
//  Created by Per Borgman on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTEntityZoomer.h"
#import "DTResourceManager.h"
#import "Vector2.h"
#import "DTWorld.h"
#import "DTAnimation.h"

@implementation DTEntityZoomer
@synthesize crawlPosition;
@synthesize orientation;
@synthesize target;
@synthesize clockwise;
@synthesize speed;
@synthesize targetIsWall;

@synthesize deltaCounter; // debug

-(id)init;
{
    if(!(self = [super init])) return nil;
        
    self.size.min.x = -0.5;
    self.size.min.y = -0.5;
    self.size.max.x = 0.5;
    self.size.max.y = 0.5;
    self.maxHealth = self.health = 2;
    
    self.gravity = NO;
    self.clockwise = YES;
    self.collisionType = EntityCollisionTypeNone;
    crawlPosition = ZoomerPositionGround;
    
    self.speed = 2;
    self.destructible = YES;
    self.velocity.x = speed;
    self.targetIsWall = NO;
    
    // (1, 0) Claws pointing right
    // (-1, 0) Claws pointing left
    // (0, 1) Claws pointing down
    // (0, -1) Claws pointing up
    self.orientation = [MutableVector2 vectorWithX:0 y:1];
    self.target = CGPointMake(-1, -1);
    
    self.deltaCounter = 0.0; // debug
    
    DTResourceManager *resourceManager = [[DTResourceManager alloc] initWithBaseURL:[[NSBundle mainBundle] URLForResource:@DT_RESOURCE_DIR withExtension:nil]];

    self.animation = [resourceManager animationNamed:@"zoomer.animation"];
    return self;
}

-(void)tick:(double)delta;
{
    [super tick:delta];
        
    self.deltaCounter += delta;
    
    Vector2 *move = [self.velocity vectorByMultiplyingWithScalar:delta];
    
    if (self.world.server && [self reachedTarget:move]) return;

    Vector2 *from = [self getStartVectorWithOffset:YES moveVector:move];
    Vector2 *to = [self getEndVectorWithOffset:YES moveVector:move];
    
    CGPoint hole = [self findHole:move from:from to:to];
    
    from = [self getStartVectorWithOffset:NO moveVector:move];
    to = [self getEndVectorWithOffset:NO moveVector:move];
    
    CGPoint wall = [self findWall:move from:from to:to];
    
    if (hole.x >= 0 && hole.y >= 0) {
        
        self.target = hole;
        self.targetIsWall = NO;
    }
    else if (wall.x >= 0 && wall.y >= 0) {
        
        self.target = wall;
        self.targetIsWall = YES;
    }

}

- (Vector2*) getStartVectorWithOffset:(BOOL)offset moveVector:(Vector2*)move {
    return [self getVectorWithOffset:offset moveVector:move isStart:YES];
}

- (Vector2*) getEndVectorWithOffset:(BOOL)offset moveVector:(Vector2*)move  {
    return [self getVectorWithOffset:offset moveVector:move isStart:NO];
}

- (Vector2*) getVectorWithOffset:(BOOL)offset moveVector:(Vector2*)move isStart:(BOOL)isStart {
    
    float offsetForward;
    float offsetSide = 0;
    
    Vector2 *vector;
    
    if (move.x != 0.0f) {
        
        offsetForward = move.x > 0 ? 1.3 : -1.3;        
        if (offset) offsetSide = 0.5;
        
        float posX = move.x > 0 ? floor(self.position.x) : ceil(self.position.x); 
        
        if (isStart) vector = [Vector2 vectorWithX:posX y:self.position.y+(offsetSide*self.orientation.y)];
        else vector = [Vector2 vectorWithX:posX+move.x+offsetForward y:self.position.y+(offsetSide*self.orientation.y)];
    }
    else if (move.y != 0.0f) {
        
        offsetForward = move.y > 0 ? 1.3 : -1.3;        
        if (offset) offsetSide = 0.5;

        float posY = move.y > 0 ? floor(self.position.y) : ceil(self.position.y); 
        
        if (isStart) vector = [Vector2 vectorWithX:self.position.x+(offsetSide*self.orientation.x) y:posY];
        else vector = [Vector2 vectorWithX:self.position.x+(offsetSide*self.orientation.x) y:posY+move.y+offsetForward];
    }
    
    return vector;
}

- (CGPoint) findTarget:(Vector2*)move from:(Vector2*)from to:(Vector2*)to inverted:(BOOL)inverted {
    
    CGPoint newTarget = CGPointMake(-1, -1);
    
    DTTraceResult *res = [self.world traceBox:self.size 
                                         from:from
                                           to:to 
                                      exclude:self
                               ignoreEntities:YES
                                     inverted:inverted];
    
    if(res && (res.x || res.y)) {
        
        if (move.x > 0)
            newTarget = CGPointMake(ceil(res.collisionPosition.x), self.position.y);
        else if (move.x < 0)
            newTarget = CGPointMake(floor(res.collisionPosition.x), self.position.y);
        else if (move.y > 0)
            newTarget = CGPointMake(self.position.x, ceil(res.collisionPosition.y));
        else if (move.y < 0)
            newTarget = CGPointMake(self.position.x, floor(res.collisionPosition.y));
        
    }
    
    return newTarget;

    
}

- (CGPoint) findHole:(Vector2*)move from:(Vector2*)from to:(Vector2*)to {
    return [self findTarget:move from:from to:to inverted:YES];
}

- (CGPoint) findWall:(Vector2*)move from:(Vector2*)from to:(Vector2*)to {
    return [self findTarget:move from:from to:to inverted:NO];
}

- (BOOL) reachedTarget:(Vector2*) move {
    
    if (self.target.x >= 0 && self.target.y >= 0) {
        
        if ([self hasPassedTarget:move]) {
            
            self.position.x = target.x;
            self.position.y = target.y;
            
            MutableVector2 *newVelocity = [MutableVector2 vectorWithX:0 y:0];
                
            // Top
            if (self.orientation.y > 0) {
                newVelocity = [MutableVector2 vectorWithX:0 y:self.speed];
                self.orientation.x = -1; self.orientation.y = 0;
            }
            
            // Right
            else if (self.orientation.x < 0) {
                newVelocity = [MutableVector2 vectorWithX:-self.speed y:0];
                self.orientation.x = 0; self.orientation.y = -1;
            }
            
            // Bottom
            else if (self.orientation.y < 0) {
                newVelocity = [MutableVector2 vectorWithX:0 y:-self.speed];
                self.orientation.x = 1; self.orientation.y = 0;
            }
            
            // Left
            else if (self.orientation.x > 0) {
                newVelocity = [MutableVector2 vectorWithX:self.speed y:0];
                self.orientation.x = 0; self.orientation.y = 1;
            }
            
            if (!clockwise) {
            
                self.orientation.x *= -1;
                self.orientation.y *= -1;
            }
            
            if (self.targetIsWall) {
                
                newVelocity.x *= -1;
                newVelocity.y *= -1;
                self.orientation.x *= -1;
                self.orientation.y *= -1;
            }
                        
            self.velocity = newVelocity;
                        
            [self updateLookDirection];
            [self updateRotation];
            
            self.target = CGPointMake(-1, -1);
            
            return YES;
        }
    }
    
    return NO;
}

- (BOOL) hasPassedTarget:(Vector2*) move {
    
    if (move.x > 0 && self.position.x >= self.target.x && self.position.y == self.target.y) return YES;
    else if (move.x < 0 && self.position.x <= self.target.x && self.position.y == self.target.y) return YES;
    else if (move.y > 0 && self.position.y >= self.target.y && self.position.x == self.target.x) return YES;
    else if (move.y < 0 && self.position.y <= self.target.y && self.position.x == self.target.x) return YES;
    
    return NO;
}

- (void) updateLookDirection {
    
    if (self.velocity.x > 0) self.lookDirection = EntityDirectionRight;
    else if (self.velocity.x < 0) self.lookDirection = EntityDirectionLeft;
    else if (self.velocity.y > 0) self.lookDirection = EntityDirectionDown;
    else if (self.velocity.y < 0) self.lookDirection = EntityDirectionUp;
}

- (void) updateRotation {
    //if(self.world.server) return;
    
    if (self.orientation.y > 0) self.rotation = 0.0;
    else if (self.orientation.x < 0) self.rotation = 90.0;
    else if (self.orientation.y < 0) self.rotation = 180.0;
    else if (self.orientation.x > 0) self.rotation = 270.0;
}

       
-(id)updateFromRep:(NSDictionary*)rep;
{
    [super updateFromRep:rep];
    $doif(@"crawlPosition", crawlPosition = [o intValue]);
    $doif(@"orientation", orientation = [[MutableVector2 alloc] initWithRep:o]);

    return self;
}
       
-(NSDictionary*)rep;
{
    NSMutableDictionary *rep = $mdict(
      @"crawlPosition", $num(crawlPosition),
      @"orientation", [orientation rep]
    );
    [rep addEntriesFromDictionary:[super rep]];
    return rep;
}

@end
