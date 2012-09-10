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
@class DTMap;

@interface DTRoom : DTResource
@property (nonatomic,strong) NSMutableArray *layers;
@property (nonatomic,strong) DTMap *collisionLayer;
@property (nonatomic,strong,readonly) NSString *name;
@property (nonatomic,strong) NSString *uuid;
@property (nonatomic,strong) NSArray *initialEntityReps;

- (id)rep;
@end
