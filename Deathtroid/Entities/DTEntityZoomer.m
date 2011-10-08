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

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    self.size.x = 1;
    self.size.y = 1;
    
    self.gravity = false;
    self.collisionType = EntityCollisionTypeNone;
    
    self.velocity.x = 2;
    
    return self;
}

-(void)tick:(double)delta;
{
    // Check beneath
    DTCollisionInfo *info = [self.world traceBox:self.size from:self.position to:[Vector2 vectorWithX:self.position.x y:self.position.y+0.5]];
    return;
    if(!info.y) self.velocity.y = 2;
}                             

@end
