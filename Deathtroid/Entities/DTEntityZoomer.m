//
//  DTEntityZoomer.m
//  Deathtroid
//
//  Created by Per Borgman on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTEntityZoomer.h"

#import "Vector2.h"
#import "DTWorld.h"

@implementation DTEntityZoomer
@synthesize crawlPosition;
@synthesize orientation;
@synthesize target;
@synthesize clockwise;
@synthesize speed;
@synthesize targetIsWall;

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    self.size.x = 1;
    self.size.y = 1;
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
    
    return self;
}

-(void)tick:(double)delta;
{
    [super tick:delta];
    //if(!self.world.server) return;
    
    Vector2 *move = [self.velocity vectorByMultiplyingWithScalar:delta];
    
    if ([self reachedTarget:move]) return;
    
    float offsetForward;
    float offsetSide;
    Vector2 *from;
    Vector2 *to;
    
    CGPoint newTarget = CGPointMake(-1, -1);
    
    if (move.x != 0.0f) {
        
        offsetForward = move.x > 0 ? 1 : -1;
        offsetSide = self.orientation.y > 0 ? 0.5 : 1.5;
        
        float posX = move.x > 0 ? floor(self.position.x) : ceil(self.position.x); 
        
        from = [Vector2 vectorWithX:posX y:self.position.y+(offsetSide*self.orientation.y)];
        to = [Vector2 vectorWithX:posX+move.x+offsetForward y:self.position.y+(offsetSide*self.orientation.y)];
    }
    else if (move.y != 0.0f) {
        
        offsetForward = move.y > 0 ? 1 : -1;
        offsetSide = self.orientation.x > 0 ? 0.5 : 1.5;
        
        float posY = move.y > 0 ? floor(self.position.y) : ceil(self.position.y); 
        
        from = [Vector2 vectorWithX:self.position.x+(offsetSide*self.orientation.x) y:posY];
        to = [Vector2 vectorWithX:self.position.x+(offsetSide*self.orientation.x) y:posY+move.y+offsetForward];
    }
    else {
        return;
    }

    
    CGPoint hole = [self findHole:move from:from to:to];
    
    if (move.x != 0.0f) {
        
        offsetForward = move.x > 0 ? 1 : -1;
        offsetSide = 0;
        
        float posX = move.x > 0 ? floor(self.position.x) : ceil(self.position.x); 
        
        from = [Vector2 vectorWithX:posX y:self.position.y+(offsetSide*self.orientation.y)];
        to = [Vector2 vectorWithX:posX+move.x+offsetForward y:self.position.y+(offsetSide*self.orientation.y)];
    }
    else if (move.y != 0.0f) {
        
        offsetForward = move.y > 0 ? 1 : -1;
        offsetSide = 0;
        
        float posY = move.y > 0 ? floor(self.position.y) : ceil(self.position.y); 
        
        from = [Vector2 vectorWithX:self.position.x+(offsetSide*self.orientation.x) y:posY];
        to = [Vector2 vectorWithX:self.position.x+(offsetSide*self.orientation.x) y:posY+move.y+offsetForward];
    }
    else {
        return;
    }
    
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

- (CGPoint) findHole:(Vector2*)move from:(Vector2*)from to:(Vector2*)to {
    
    CGPoint newTarget = CGPointMake(-1, -1);
    
    DTTraceResult *res = [self.world traceBox:self.size 
                                         from:from
                                           to:to 
                                      exclude:self
                               ignoreEntities:YES
                                     inverted:YES];
    
    if(res && (res.x || res.y)) {
        
        if (move.x > 0)
            newTarget = CGPointMake(ceil(res.collisionPosition.x), self.position.y);
        else if (move.x < 0)
            newTarget = CGPointMake(floor(res.collisionPosition.x), self.position.y);
        else if (move.y > 0)
            newTarget = CGPointMake(self.position.x, ceil(res.collisionPosition.y));
        else if (move.y < 0)
            newTarget = CGPointMake(self.position.x, floor(res.collisionPosition.y));
        
//        if (newTarget.x != self.target.x && newTarget.y != self.target.y) {
//            NSLog(@"\n\n");
//            if(self.world.server) NSLog(@"--- SERVER --\n");
//            else NSLog(@"--- CLIENT --\n");
//        
//            NSLog(@"Current pos: %.2f, %.2f", self.position.x, self.position.y);
//            NSLog(@"From: %@, to: %@", from, to);
//        
//            // Found a hole
//            NSLog(@"Found hole at %.2f, %.2f", res.collisionPosition.x, res.collisionPosition.y);
//        
//            NSLog(@"Setting target to %f %f", newTarget.x, newTarget.y); 
//            NSLog(@"----------");
//            NSLog(@"\n\n");
//        }

    }
    
    return newTarget;

}

- (CGPoint) findWall:(Vector2*)move from:(Vector2*)from to:(Vector2*)to {
    
    CGPoint newTarget = CGPointMake(-1, -1);
    
    DTTraceResult *res = [self.world traceBox:self.size 
                                         from:from
                                           to:to 
                                      exclude:self
                               ignoreEntities:YES
                                     inverted:NO];
    
    if(res && (res.x || res.y)) {
        
        if (move.x > 0)
            newTarget = CGPointMake(ceil(res.collisionPosition.x), self.position.y);
        else if (move.x < 0)
            newTarget = CGPointMake(floor(res.collisionPosition.x), self.position.y);
        else if (move.y > 0)
            newTarget = CGPointMake(self.position.x, ceil(res.collisionPosition.y));
        else if (move.y < 0)
            newTarget = CGPointMake(self.position.x, floor(res.collisionPosition.y));
        
//        if (newTarget.x != self.target.x && newTarget.y != self.target.y) {
//            NSLog(@"\n\n");
//            if(self.world.server) NSLog(@"--- SERVER --\n");
//            else NSLog(@"--- CLIENT --\n");
//            
//            NSLog(@"Current pos: %.2f, %.2f", self.position.x, self.position.y);
//            NSLog(@"From: %@, to: %@", from, to);
//            
//            // Found a hole
//            NSLog(@"Found wall at %.2f, %.2f", res.collisionPosition.x, res.collisionPosition.y);
//            
//            NSLog(@"Setting target to %f %f", newTarget.x, newTarget.y); 
//            NSLog(@"----------");
//            NSLog(@"\n\n");
//        }
        
    }
    
    return newTarget;
    
}

- (CGPoint) findWall:(Vector2*)move {
    
    CGPoint newTarget = CGPointMake(-1, -1);
    
    // TODO: Add stuff here!
    
    return newTarget;
}

- (BOOL) reachedTarget:(Vector2*) move {
    
    if (self.target.x >= 0 && self.target.y >= 0) {
        
        if ([self hasPassedTarget:move]) {
            
            // NSLog(@"Reached target!");
//            if(self.world.server) NSLog(@"--- SERVER: REACHED TARGET --\n");
//            else NSLog(@"--- CLIENT: REACHED TARGET --\n");
            
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
                        
//            NSLog(@"New velocity: %f %f", newVelocity.x, newVelocity.y);
            self.velocity = newVelocity;
                        
            // NSLog(@"Direction is now (%f, %f)", self.direction.x, self.direction.y);
            
            // Set look direction...
            [self updateLookDirection];
            
            [self updateRotation];
            
            // Reset target
            self.target = CGPointMake(-1, -1);
            
            return YES;
        }
    }
    
    return NO;
}


//- (BOOL) reachedTarget:(Vector2*) move {
//    
//    if (self.target.x >= 0 && self.target.y >= 0) {
//        
//        if ([self hasPassedTarget:move]) {
//            
//            // NSLog(@"Reached target!");
//            if(self.world.server) NSLog(@"--- SERVER: REACHED TARGET --\n");
//            else NSLog(@"--- CLIENT: REACHED TARGET --\n");
//            
//            self.position.x = target.x;
//            self.position.y = target.y;
//            
//            float dirX = self.velocity.y > 0 ? 1 : -1;
//            float dirY = self.velocity.x > 0 ? 1 : -1;
//            
//            NSLog(@"Old velocity: %f %f",  self.velocity.x,  self.velocity.y);
//
//            MutableVector2 *newVelocity = [MutableVector2 vectorWithX:self.velocity.y*(self.orientation.x*dirX) y:self.velocity.x*(self.orientation.y*dirY)];
//            
//            NSLog(@"New velocity: %f %f", newVelocity.x, newVelocity.y);
//            self.velocity = newVelocity;
//            
//            float tempX = self.orientation.x;
//            self.orientation.x = self.orientation.y != 0 ? dirY * -1 : 0;
//            self.orientation.y = tempX != 0 ? dirX * -1 : 0;
//            
//            // NSLog(@"Direction is now (%f, %f)", self.direction.x, self.direction.y);
//            
//            // Set look direction...
//            [self updateLookDirection];
//            
//            [self updateRotation];
//            
//            // Reset target
//            self.target = CGPointMake(-1, -1);
//            
//            return YES;
//        }
//    }
//    
//    return NO;
//}

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
    if(self.world.server) return;
    
    if (self.orientation.y > 0) self.rotation = 0.0;
    else if (self.orientation.x < 0) self.rotation = 90.0;
    else if (self.orientation.y < 0) self.rotation = 180.0;
    else if (self.orientation.x > 0) self.rotation = 270.0;
}

//-(void)tick:(double)delta;
//{
//    Vector2 *move = [self.velocity vectorByMultiplyingWithScalar:delta];
//    
//    /*
//     
//        JAG VILL ATT DET SKA VARA SÅHÄR ENKELT:
//     
//        if(onGround) {
//            if(FUCK YOU
//        }
//     
//     
//    */
//    
//    if(move.x != 0.0f) {
//        float offset = move.x > 0 ? -self.size.x : self.size.x;
//        
//        DTTraceResult *res = [self.world traceBox:self.size from:[Vector2 vectorWithX:self.position.x+offset y:self.position.y+0.5] to:[Vector2 vectorWithX:self.position.x+offset+move.x y:self.position.y+0.5] exclude:self inverted:YES];
//        
//        if(res && res.x) { 
//            NSLog(@"Res X: %.2f %.2f", res.collisionPosition.x, res.collisionPosition.y);
//
//            self.velocity.x = 0; self.position.x = res.collisionPosition.x; self.velocity.y = speed; }
//        
//    } else if(move.y != 0.0f) {
//        float offset = move.y > 0 ? -self.size.y : self.size.y;
//        DTTraceResult *res = [self.world traceBox:self.size from:[Vector2 vectorWithX:self.position.x-0.5 y:self.position.y+offset] to:[Vector2 vectorWithX:self.position.x-0.5 y:self.position.y+move.y+offset] exclude:self inverted:YES];
//        if(res && res.y) { 
//            
//            NSLog(@"Res X: %.2f %.2f", res.collisionPosition.x, res.collisionPosition.y);
//            self.velocity.y = 0; self.position.y = res.collisionPosition.y; self.velocity.x = -speed; }
//
//    }
//}

       
-(id)updateFromRep:(NSDictionary*)rep;
{
    [super updateFromRep:rep];
    $doif(@"crawlPosition", crawlPosition = [o intValue]);
    return self;
}
       
-(NSDictionary*)rep;
{
    NSMutableDictionary *rep = $mdict(
      @"crawlPosition", $num(crawlPosition)
    );
    [rep addEntriesFromDictionary:[super rep]];
    return rep;
}

@end
