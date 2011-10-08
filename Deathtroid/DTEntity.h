//
//  DTEntity.h
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MutableVector2;

typedef enum {
    EntityDirectionNone,
    EntityDirectionLeft,
    EntityDirectionLeftUp,
    EntityDirectionUp,
    EntityDirectionRightUp,
    EntityDirectionRight,
    EntityDirectionRightDown,
    EntityDirectionDown,
    EntityDirectionLeftDown
} EntityDirection;

@interface DTEntity : NSObject

@property (nonatomic,strong) MutableVector2 *position;
@property (nonatomic,strong) MutableVector2 *velocity;
@property (nonatomic) EntityDirection walkDirection;
@property (nonatomic) EntityDirection lookDirection;

@end

