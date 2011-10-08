//
//  Layer.h
//  SuperJetpack
//
//  Created by Per Borgman on 1/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Vector2.h"

@class DTMap;

// A level layer
//
// A layer consists of a tilemap and a couple
// of entities.

@interface DTLayer : NSObject {
	DTMap				*map;
				
	BOOL			repeatX, repeatY;
	
	// Make sure to clamp.
	MutableVector2	*currentPosition;
	Vector2			*startPosition;
}

@property (nonatomic,strong) DTMap *map;
@property (nonatomic,strong) MutableVector2 *currentPosition;

@property (nonatomic) float depth;
@property (nonatomic) CGPoint autoScrollSpeed;

-(id)init;

-(void)tick:(float)delta;

-(void)clampPosition;

@end
