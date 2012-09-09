//
//  Map.h
//  SuperJetpack
//
//  Created by Per Borgman on 1/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MutableVector2;

/** @class Map
    @abstract A single tilemap
*/
@interface DTMap : NSObject {
	int		*tiles;
    int     *attr;
	
	// In tiles
	int		width, height;
}

@property (nonatomic,assign) int *tiles, *attr;
@property (nonatomic,assign) int width, height;
- (int*)tileAtX:(int)x y:(int)y;
- (int*)attrAtX:(int)x y:(int)y;

-(id)initWithRep:(NSDictionary*)rep;
-(id)rep;

@end

enum {
    TileAttributeFlipX = 1 << 0,
    TileAttributeFlipY = 1 << 1,
    TileAttributeRotate90 = 1 << 2,
};