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
@protocol DTRoomDelegate;

@interface DTRoom : DTResource
@property (nonatomic,readonly) NSMutableArray *layers;
@property (nonatomic,strong) DTMap *collisionLayer;
@property (nonatomic,strong,readonly) NSString *name;
@property (nonatomic,strong) NSString *uuid;
@property (nonatomic,strong) NSMutableDictionary *entityTemplates;
@property (nonatomic,weak) id<DTRoomDelegate> delegate;

- (id)rep;
@end

@protocol DTRoomDelegate <NSObject>
- (void)roomChanged:(DTRoom*)room;
@end