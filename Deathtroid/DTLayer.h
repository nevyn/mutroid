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

@interface DTColor : NSObject
@property (nonatomic) float r,g,b,a;
@end

// A level layer
//
// A layer consists of a tilemap and a couple
// of entities.

@interface DTLayer : NSObject {
	DTMap				*map;
				
	BOOL			repeatX, repeatY;
    
    DTColor         *cycleSource;
    NSMutableArray  *cycleColors;
    float           cycleFPS;
    float           cycleCounter;
    int             cycleCurrent;
	
	// Make sure to clamp.
	MutableVector2	*currentPosition;
	Vector2			*startPosition;
}

@property (nonatomic,strong) NSString *tilemapName;

@property (nonatomic,strong) DTMap *map;
@property (nonatomic,strong) MutableVector2 *currentPosition;

@property (nonatomic) float depth;
@property (nonatomic) CGPoint autoScrollSpeed;

@property (nonatomic) BOOL repeatX, repeatY;

@property (nonatomic,strong) DTColor *cycleSource;
@property (nonatomic,strong) NSMutableArray *cycleColors;
@property (nonatomic) float cycleFPS;
@property (nonatomic) int cycleCurrent;

-(id)initWithRep:(NSDictionary*)rep;

-(void)tick:(float)delta;

-(void)clampPosition;

@end
