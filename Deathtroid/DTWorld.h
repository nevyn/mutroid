//
//  DTWorld.h
//  Deathtroid
//
//  Created by Per Borgman on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DTMap, DTRoom, Vector2, DTEntity, DTServer, DTServerRoom, DTResourceManager, DTBBox;

@interface DTTraceResult : NSObject
-(id)initWithX:(BOOL)_x y:(BOOL)_y slope:(BOOL)_slope collisionPosition:(Vector2*)colPos entity:(DTEntity*)_entity velocity:(Vector2*)_velocity;
@property (nonatomic) BOOL x, y;
@property (nonatomic,strong) DTEntity *entity;
@property (nonatomic,strong) Vector2 *collisionPosition;
@property (nonatomic,strong) Vector2 *velocity;   // Entity's velocity at impact
@property (nonatomic) BOOL slope;
@end


@interface DTWorld : NSObject

-(id)initWithRoom:(DTRoom*)_room;

-(DTTraceResult*)traceBox:(DTBBox*)box from:(Vector2*)from to:(Vector2*)to exclude:(DTEntity*)exclude ignoreEntities:(BOOL)ignore;
-(DTTraceResult*)traceBox:(DTBBox*)box from:(Vector2*)from to:(Vector2*)to exclude:(DTEntity*)exclude ignoreEntities:(BOOL)ignore inverted:(BOOL)inverted;
-(DTTraceResult*)traceBoxStep:(DTBBox*)box origin:(Vector2*)origin dx:(float)dx dy:(float)dy map:(DTMap*)map exclude:(DTEntity*)exclude ignore:(BOOL)ignore inverted:(BOOL)inverted;

-(BOOL)boxCollideBoxA:(Vector2*)boxA sizeA:(Vector2*)sizeA boxB:(Vector2*)boxB sizeB:(Vector2*)sizeB;

@property (nonatomic,weak) DTServer *server; // nil if world is on client
@property (nonatomic,weak) DTRoom *room;
@property (nonatomic,readonly) DTServerRoom *sroom; // nil if on client
// for entities to find new resources if needed. This is probably a bad idea; want to 
// pull all client-side work out of the entities (see: DTRenderEntities), but not sure
// how to do sound yet.
@property (nonatomic,strong) DTResourceManager *resources;
@end
