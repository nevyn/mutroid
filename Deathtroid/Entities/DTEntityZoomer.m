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

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    self.size.x = 1;
    self.size.y = 1;
    
    self.gravity = false;
    self.collisionType = EntityCollisionTypeNone;
    crawlPosition = ZoomerPositionGround;
    
    speed = 2;
    self.velocity.x = speed;
    
    return self;
}

-(void)tick:(double)delta;
{
    Vector2 *move = [self.velocity vectorByMultiplyingWithScalar:delta];
    
    /*
     
        JAG VILL ATT DET SKA VARA SÅHÄR ENKELT:
     
        if(onGround) {
            if(FUCK YOU
        }
     
     
    */
    
    if(move.x != 0.0f) {
        float offset = move.x > 0 ? -self.size.x : self.size.x;
        DTTraceResult *res = [self.world traceBox:self.size from:[Vector2 vectorWithX:self.position.x+offset y:self.position.y+0.5] to:[Vector2 vectorWithX:self.position.x+offset+move.x y:self.position.y+0.5] inverted:YES];
        if(res && res.x) { self.velocity.x = 0; self.position.x = res.collisionPosition.x; self.velocity.y = speed; }
    } else if(move.y != 0.0f) {
        float offset = move.y > 0 ? -self.size.y : self.size.y;
        DTTraceResult *res = [self.world traceBox:self.size from:[Vector2 vectorWithX:self.position.x-0.5 y:self.position.y+offset] to:[Vector2 vectorWithX:self.position.x-0.5 y:self.position.y+move.y+offset] inverted:YES];
        if(res && res.y) { self.velocity.y = 0; self.position.y = res.collisionPosition.y; self.velocity.x = -speed; }
    }
}

       
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
