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

-(id)initWithRep:(NSDictionary*)rep;
{
	if(!(self = [super init])) return nil;
    
    NSArray *mapRep = $notNull([rep objectForKey:@"map"]);
    
    BOOL hasAttr = [mapRep count] == 2;
        
    width = [$notNull([rep objectForKey:@"width"]) intValue];
    height = [$notNull([rep objectForKey:@"height"]) intValue];
    
    NSAssert(width > 0 && height > 0, @"Width and height must be >0");
    
    NSArray *tileRep = hasAttr ? [mapRep objectAtIndex:0] : mapRep;
    NSArray *attrRep;
    tiles = malloc(sizeof(int)*width*height);
    
    if(hasAttr) {
        attrRep = [mapRep objectAtIndex:1];
        attr = malloc(sizeof(int)*width*height);
    }
    
    NSAssert(width*height == [tileRep count], @"Incorrect number of tiles");
    
    for(NSUInteger i = 0, c = [tileRep count]; i < c; i++) {
        tiles[i] = [[tileRep objectAtIndex:i] intValue];
        if(hasAttr)
            attr[i] = [[attrRep objectAtIndex:i] intValue];
    }
    
	return self;
}

@end
