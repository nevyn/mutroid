//
//  Level.m
//  SuperJetpack
//
//  Created by Per Borgman on 1/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DTLevel.h"

#import "DTLayer.h"

@implementation DTLevel

@synthesize layers;
@synthesize entityLayerIndex;

-(id)init {
	if(!(self = [super init])) return nil;
	
	layers = [NSMutableArray array];
	
    DTLayer *layer2 = [[DTLayer alloc] init];
    layer2.depth = 0.5;
    [layers addObject:layer2];
	DTLayer *layer = [[DTLayer alloc] init];
	[layers addObject:layer];
    
    entityLayerIndex = 1;
	
	return self;
}

-(void)tick:(float)delta {
	for(DTLayer *lay in layers)
		[lay tick:delta];
}

/*
-(void)moveEntity:(MovingEntity*)anEntity toLayer:(int)layerNum {
	for(int l=0;l < [layers count];l++) {
		Layer *layer = [layers objectAtIndex:l];
		if(l==layerNum)
			[layer addEntity:anEntity];
		else
			[layer removeEntity:anEntity];
	}
}
*/

@end
