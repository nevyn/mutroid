//
//  Layer.h
//  SuperJetpack
//
//  Created by Per Borgman on 1/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Vector2.h"

@class DTMap, DTLayerState;

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
	
	// Make sure to clamp.
	Vector2			*startPosition;
}

@property (nonatomic,strong) NSString *tilesetName;

@property (nonatomic,strong) DTMap *map;

@property (nonatomic) float depth;
@property (nonatomic) CGPoint autoScrollSpeed;

@property (nonatomic) BOOL repeatX, repeatY;

@property (nonatomic,strong) DTColor *cycleSource;
@property (nonatomic,strong) NSMutableArray *cycleColors;
@property (nonatomic) float cycleFPS;

-(id)init;
-(void)updateFromRep:(NSDictionary*)rep;
-(id)rep;

-(void)tick:(float)delta inState:(DTLayerState*)state;
@end

@interface DTLayerState : NSObject
@property (nonatomic) int cycleCurrent;
@end