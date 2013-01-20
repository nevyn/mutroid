//
//  Map.m
//  SuperJetpack
//
//  Created by Per Borgman on 1/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DTMap.h"

#import "Vector2.h"

@implementation DTMap

@synthesize tiles, attr;
@synthesize width, height;

-(void)updateFromRep:(NSDictionary*)rep
{
    NSArray *mapRep = $notNull([rep objectForKey:@"map"]);
    
    BOOL hasAttr = [mapRep count] == 2;
        
    width = [$notNull([rep objectForKey:@"width"]) intValue];
    height = [$notNull([rep objectForKey:@"height"]) intValue];
    
    NSAssert(width > 0 && height > 0, @"Width and height must be >0");
    
    [self setWidth:width height:height];
    
    NSArray *tileRep = hasAttr ? [mapRep objectAtIndex:0] : mapRep;
    NSArray *attrRep;

    if(hasAttr) {
        attrRep = [mapRep objectAtIndex:1];
    }
    
    NSAssert(width*height == [tileRep count], @"Incorrect number of tiles");
    
    for(NSUInteger i = 0, c = [tileRep count]; i < c; i++) {
        tiles[i] = [[tileRep objectAtIndex:i] intValue];
        if(hasAttr)
            attr[i] = [[attrRep objectAtIndex:i] intValue];
    }
}

- (void)setWidth:(int)width_ height:(int)height_;
{
    int oldWidth = width, oldHeight = height, *oldTiles = tiles, *oldAttr = attr;
    
    self.width = width_;
    self.height = height_;
    tiles = malloc(sizeof(int)*width*height);
    attr = malloc(sizeof(int)*width*height);
    memset(tiles, 0, sizeof(int)*width*height);
    memset(attr, 0, sizeof(int)*width*height);
    
    if(!oldTiles || !oldAttr)
        return;
    
    for(int y = 0; y < MAX(oldHeight, height); y++)
        for(int x = 0; x < MAX(oldWidth, width); x++) {
            if(y >= MIN(oldHeight, height) || x >= MIN(oldWidth, width))
                continue;
            
            tiles[y*width+x] = oldTiles[y*oldWidth+x];
            attr[y*width+x] = oldAttr[y*oldWidth+x];
        }
    
    free(oldTiles);
    free(oldAttr);
}

-(id)rep
{
    NSMutableArray *mapRep = [NSMutableArray arrayWithCapacity:width*height];
    NSMutableArray *attrRep = [NSMutableArray arrayWithCapacity:width*height];
    for(int i = 0; i < width*height; i++)
        [mapRep addObject:@(tiles[i])];
    for(int i = 0; i < width*height && attr; i++)
        [attrRep addObject:@(attr[i])];
    return @{
        @"width": @(width),
        @"height": @(height),
        @"map": attr ? @[mapRep, attrRep] : mapRep
    };
}
- (const int*)tileAtX:(int)x y:(int)y
{
    if(x < 0 || y < 0 || x >= width || y >= height )
        return NULL;
    return &tiles[y*width + x];
}
- (void)setTile:(int)index atX:(int)x y:(int)y;
{
    if(x < 0 || y < 0 || x >= width || y >= height )
        return;
    [self willChangeValueForKey:@"tiles"];
    tiles[y*width + x] = index;
    [self didChangeValueForKey:@"tiles"];
    //[_delegate attrOrTileChangedInMap:self];
}
- (const int*)attrAtX:(int)x y:(int)y
{
    if(x < 0 || y < 0 || x >= width || y >= height )
        return NULL;
    return &attr[y*width + x];
}
- (void)setAttr:(int)flag atX:(int)x y:(int)y;
{
    if(x < 0 || y < 0 || x >= width || y >= height )
        return;
    [self willChangeValueForKey:@"attr"];
    attr[y*width + x] = flag;
    [self didChangeValueForKey:@"attr"];
    [_delegate attrOrTileChangedInMap:self];
}
@end
