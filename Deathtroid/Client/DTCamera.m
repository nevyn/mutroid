//
//  DTCamera.m
//  Deathtroid
//
//  Created by Per Borgman on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTCamera.h"

#import "Vector2.h"

@implementation DTCamera

@synthesize position;

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    position = [MutableVector2 vectorWithX:0 y:0];
    
    return self;
}

@end
