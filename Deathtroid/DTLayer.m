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

@implementation DTLayer

@synthesize tilemapName;
@synthesize map;
@synthesize depth;
@synthesize currentPosition;
@synthesize autoScrollSpeed;
@synthesize repeatX, repeatY;
@synthesize cycleSource, cycleColors, cycleFPS, cycleCurrent;

-(id)initWithRep:(NSDictionary*)rep;
{
    if(!(self = [super init])) return nil;
    
    tilemapName = [rep objectForKey:@"tilemap"];

	currentPosition = [MutableVector2 vector];
	startPosition = [Vector2 vectorWithX:0. y:0.];
	
    depth = [[rep objectForKey:@"depth"]?:$num(1) floatValue];
	autoScrollSpeed = CGPointMake(0.f, 0.f);
		
	map = [[DTMap alloc] initWithRep:rep];
    
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
    
    return self;
}

-(void)tick:(float)delta {
    if(cycleColors) {
        cycleCounter += delta;
        if(cycleCounter > 1.0/cycleFPS) {
            cycleCounter = 0.0f;
            cycleCurrent++;
            if(cycleCurrent >= [cycleColors count]) cycleCurrent = 0;
        }
    }
    


	//currentPosition.x += autoScrollSpeed.x * delta;
	//currentPosition.y += autoScrollSpeed.y * delta;
    	
	//[self clampPosition];
}

-(void)clampPosition {
}

@end
