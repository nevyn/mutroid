//
//  DTCamera.m
//  Deathtroid
//
//  Created by Per Borgman on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTCamera.h"

#import "Vector2.h"
#import "DTRoom.h"
#import "DTLayer.h"
#import "DTMap.h"

@implementation DTCamera

@synthesize position;

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    position = [MutableVector2 vectorWithX:0 y:0];
    
    return self;
}
- (id)copyWithZone:(NSZone *)zone
{
    DTCamera *other = [DTCamera new];
    other->position = [MutableVector2 vectorWithVector2:position];
    return other;
}

- (void)setPositionFromEntity:(Vector2*)entityPosition;
{
    self.position.x = entityPosition.x - kScreenWidthInTiles/2.;
    self.position.y = entityPosition.y - kScreenHeightInTiles/2.;
}
- (void)clampToRoom:(DTRoom*)room;
{
    self.position.x = CLAMP(self.position.x, 0, [room.layers.lastObject map].width-kScreenWidthInTiles);
    self.position.y = CLAMP(self.position.y, 0, [room.layers.lastObject map].height-kScreenHeightInTiles);
}

@end
