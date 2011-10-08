//
//  Level.h
//  SuperJetpack
//
//  Created by Per Borgman on 1/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DTLevel : NSObject {
}

@property (nonatomic,strong) NSMutableArray *layers;
@property (nonatomic) int entityLayerIndex;

-(id)init;

-(void)tick:(float)delta;

// Moves or adds an entity to a specific layer.
// Layers are numbered from 0 and up, incresing towards
// the camera.
//-(void)moveEntity:(MovingEntity*)anEntity toLayer:(int)layerNum;

@end
