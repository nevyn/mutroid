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
	
	DTLayer *layer = [[DTLayer alloc] init];
	[layers addObject:layer];
    
    entityLayerIndex = 0;
	
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
