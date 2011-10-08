//
//  Map.h
//  SuperJetpack
//
//  Created by Per Borgman on 1/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MutableVector2;

// Map
//
// A single tilemap

@interface DTMap : NSObject {
	int		*tiles;
	
	// In tiles
	int		width, height;
}

@property (nonatomic,assign) int *tiles;
@property (nonatomic,assign) int width, height;

-(id)initWithRep:(NSDictionary*)rep;

@end
