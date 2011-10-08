//
//  Layer.m
//  SuperJetpack
//
//  Created by Per Borgman on 1/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DTLayer.h"

#import "DTMap.h"

@implementation DTLayer

@synthesize map;
@synthesize currentPosition;
@synthesize scrollSpeed;

-(id)init {
	currentPosition = [MutableVector2 vector];
	startPosition = [Vector2 vectorWithX:0. y:0.];
	
	scrollSpeed = CGPointMake(1.0f, 1.0f);
	autoScrollSpeed = CGPointMake(0.f, 0.f);
		
	map = [[DTMap alloc] init];
	
	return self;
}

-(void)tick:(float)delta {
	currentPosition.x += autoScrollSpeed.x * delta;
	currentPosition.y += autoScrollSpeed.y * delta;
	
	[self clampPosition];
}

-(void)clampPosition {
}

@end
