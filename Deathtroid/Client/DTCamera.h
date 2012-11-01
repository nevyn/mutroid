//
//  DTCamera.h
//  Deathtroid
//
//  Created by Per Borgman on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Vector2, MutableVector2, DTRoom;

@interface DTCamera : NSObject <NSCopying>

@property (nonatomic,strong) MutableVector2 *position;

- (void)setPositionFromEntity:(Vector2*)entityPosition;
- (void)clampToRoom:(DTRoom*)room;
@end
