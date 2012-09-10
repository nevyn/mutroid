//
//  Map.h
//  SuperJetpack
//
//  Created by Per Borgman on 1/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol DTMapDelegate;
@class MutableVector2;

/** @class Map
    @abstract A single tilemap
*/
@interface DTMap : NSObject
@property (nonatomic,assign) int *tiles, *attr;
@property (nonatomic,assign) int width, height;
@property (nonatomic,weak) id<DTMapDelegate> delegate;

- (const int*)tileAtX:(int)x y:(int)y;
- (void)setTile:(int)index atX:(int)x y:(int)y;

- (const int*)attrAtX:(int)x y:(int)y;
- (void)setAttr:(int)attr atX:(int)x y:(int)y;

-(id)initWithRep:(NSDictionary*)rep;
-(id)rep;

@end

enum {
    TileAttributeFlipX = 1 << 0,
    TileAttributeFlipY = 1 << 1,
    TileAttributeRotate90 = 1 << 2,
};

@protocol DTMapDelegate <NSObject>
- (void)attrOrTileChangedInMap:(DTMap*)map;
@end