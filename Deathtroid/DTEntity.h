//
//  DTEntity.h
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Vector2;

typedef enum {
    Left,
    LeftUp,
    Up,
    RightUp,
    Right,
    RightDown,
    Down,
    LeftDown
} EntityDirection;

@interface DTEntity : NSObject

@property (nonatomic,strong) Vector2 *position;
@property (nonatomic,strong) Vector2 *velocity;
@property (nonatomic) EntityDirection walkDirection;
@property (nonatomic) EntityDirection lookDirection;

@end

