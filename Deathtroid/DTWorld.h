//
//  DTWorld.h
//  Deathtroid
//
//  Created by Per Borgman on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DTMap, DTLevel, DTCollisionInfo, Vector2;

@interface DTWorld : NSObject

-(DTCollisionInfo*)traceBox:(Vector2*)box from:(Vector2*)from to:(Vector2*)to;
-(DTCollisionInfo*)traceBoxStep:(Vector2*)position size:(Vector2*)size vx:(float)vx vy:(float)vy map:(DTMap*)map;

@property (nonatomic,weak) DTLevel *level;

@end
