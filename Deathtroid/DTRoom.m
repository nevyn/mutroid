//
//  Level.m
//  SuperJetpack
//
//  Created by Per Borgman on 1/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DTRoom.h"
#import "DTLayer.h"

@interface DTRoom ()
@property (nonatomic,strong,readwrite) NSString *name;
@end

@implementation DTRoom

@synthesize layers = _layers;
@synthesize entityLayerIndex;
@synthesize name = _name;
@synthesize initialEntityReps;

-(id)initWithPath:(NSURL*)path;
{
	if(!(self = [super init])) return nil;
	
    _name = [[path lastPathComponent] stringByDeletingPathExtension];
	_layers = [NSMutableArray array];
    
    NSURL *repFile = [path URLByAppendingPathComponent:@"room.json"];
    
    NSData *d = [NSData dataWithContentsOfURL:repFile];
    if(!d)
        return self = nil;

    NSError *err = nil;
    NSDictionary *rep = [NSJSONSerialization JSONObjectWithData:d options:0 error:&err];
    if(!rep) {
        [NSApp presentError:err];
        return self = nil;
    }
    
    NSArray *layerReps = $notNull([rep objectForKey:@"layers"]);
	for(NSDictionary *layerRep in layerReps)
        [_layers addObject:[[DTLayer alloc] initWithRep:layerRep]];
    
    entityLayerIndex = 1;
    
    initialEntityReps = [rep objectForKey:@"entities"];
	
	return self;
}

-(void)tick:(float)delta {
	for(DTLayer *lay in _layers)
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
