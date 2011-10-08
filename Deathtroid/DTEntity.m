//
//  DTEntity.m
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTEntity.h"

#import "Vector2.h"

@implementation DTEntity

@synthesize position, velocity, walkDirection, lookDirection;

-(id)init {
    if(!(self = [super init])) return nil;
    
    position = [MutableVector2 vectorWithX:5 y:1];
    velocity = [MutableVector2 vectorWithX:0 y:0];
    
    return self;
}

@end
