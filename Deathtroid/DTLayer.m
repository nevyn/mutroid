//
//  Layer.m
//  SuperJetpack
//
//  Created by Per Borgman on 1/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DTLayer.h"

#import "DTMap.h"

@implementation DTColor
@synthesize r,g,b,a;
@end
@interface DTLayerState ()
@property float cycleCounter;
@end
@implementation DTLayerState
@end

@implementation DTLayer

@synthesize tilesetName;
@synthesize map;
@synthesize depth;
@synthesize autoScrollSpeed;
@synthesize repeatX, repeatY;
@synthesize cycleSource, cycleColors, cycleFPS;

-(id)init
{
    if(!(self = [super init])) return nil;
    

	startPosition = [Vector2 vectorWithX:0. y:0.];
	
	autoScrollSpeed = CGPointMake(0.f, 0.f);
		
	map = [[DTMap alloc] init];
    [map setWidth:16 height:12];
    tilesetName = @"brinstarbase";
    depth = 1;
    
    return self;
}
-(void)updateFromRep:(NSDictionary*)rep;
{
    tilesetName = [rep objectForKey:@"tileset"];

    depth = [[rep objectForKey:@"depth"]?:$num(1) floatValue];

    repeatX = [[rep objectForKey:@"repeatX"] boolValue];
    repeatY = [[rep objectForKey:@"repeatY"] boolValue];

    NSDictionary *cc = [rep objectForKey:@"colorCycle"];
    if(cc) {
        NSArray *source = [cc objectForKey:@"source"];
        cycleSource = [[DTColor alloc] init];
        cycleSource.r = ([[source objectAtIndex:0] intValue] + 1) / 256.;
        cycleSource.g = ([[source objectAtIndex:1] intValue] + 1) / 256.;
        cycleSource.b = ([[source objectAtIndex:2] intValue] + 1) / 256.;
        cycleSource.a = ([[source objectAtIndex:3] intValue] + 1) / 256.;
                
        NSArray *colors = [cc objectForKey:@"colors"];
        cycleColors = [NSMutableArray array];
        for(NSArray *color in colors) {
            DTColor *c = [[DTColor alloc] init];
            c.r = ([[color objectAtIndex:0] intValue] + 1) / 256.;
            c.g = ([[color objectAtIndex:1] intValue] + 1) / 256.;
            c.b = ([[color objectAtIndex:2] intValue] + 1) / 256.;
            c.a = ([[color objectAtIndex:3] intValue] + 1) / 256.;
            [cycleColors addObject:c]; 
        }
        
        cycleFPS = [[cc objectForKey:@"fps"] floatValue];
    }
    
    [map updateFromRep:rep];
}
-(id)rep
{
    NSMutableDictionary *mapRep = [self.map.rep mutableCopy];
    mapRep[@"tileset"] = tilesetName;
    mapRep[@"depth"] = @(depth);
    mapRep[@"repeatX"] = @(repeatX);
    mapRep[@"repeatY"] = @(repeatY);
    if(cycleSource) {
        NSMutableArray *colors = [NSMutableArray arrayWithCapacity:cycleColors.count];
        for(DTColor *c in cycleColors)
            [colors addObject:@[
                @(c.r*256 - 1),
                @(c.g*256 - 1),
                @(c.b*256 - 1),
                @(c.a*256 - 1)
            ]];
        mapRep[@"colorCycle"] = @{
            @"source": @[
                @(cycleSource.r*256 - 1),
                @(cycleSource.g*256 - 1),
                @(cycleSource.b*256 - 1),
                @(cycleSource.a*256 - 1)
            ],
            @"colors": colors,
            @"fps": @(cycleFPS)
        };
    }
    
    return mapRep;
}

-(void)tick:(float)delta inState:(DTLayerState*)state
{
    if(cycleColors) {
        state.cycleCounter += delta;
        if(state.cycleCounter > 1.0/cycleFPS) {
            state.cycleCounter = 0.0f;
            state.cycleCurrent++;
            if(state.cycleCurrent >= [cycleColors count]) state.cycleCurrent = 0;
        }
    }
}


@end
