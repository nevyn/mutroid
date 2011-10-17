//
//  Level.h
//  SuperJetpack
//
//  Created by Per Borgman on 1/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DTResource.h"

@class DTWorld;

@interface DTRoom : DTResource

@property (nonatomic,strong) NSMutableArray *layers;
@property (nonatomic) NSUInteger entityLayerIndex;
@property (nonatomic,strong,readonly) NSString *name;
@property (nonatomic,strong) NSString *uuid;
@property (nonatomic,strong) DTWorld *world; // room maths

@property (nonatomic,strong) NSArray *initialEntityReps;
@property (nonatomic,strong) NSMutableDictionary *entities;

-(id)initWithPath:(NSURL*)path resourceId:(NSString*)rid;

-(void)tick:(float)delta;

// Moves or adds an entity to a specific layer.
// Layers are numbered from 0 and up, incresing towards
// the camera.
//-(void)moveEntity:(MovingEntity*)anEntity toLayer:(int)layerNum;

@end
