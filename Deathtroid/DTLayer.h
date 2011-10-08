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
	
	// Thinking of totally replacing scrollSpeed with this.
	float				depth;
		
	// This is how fast the layer continuously scrolls, regardless
	// of Camera movement.
	CGPoint			autoScrollSpeed;
	
	BOOL			repeatX, repeatY;
	
	// Make sure to clamp.
	MutableVector2	*currentPosition;
	Vector2			*startPosition;
}

@property (readonly,nonatomic) DTMap *map;
@property (readonly,nonatomic) MutableVector2 *currentPosition;

@property (readonly,nonatomic) CGPoint scrollSpeed;

-(id)init;

-(void)tick:(float)delta;

-(void)clampPosition;

@end
