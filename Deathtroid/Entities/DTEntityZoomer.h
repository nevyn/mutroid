//
//  DTEntityZoomer.h
//  Deathtroid
//
//  Created by Per Borgman on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTEntity.h"

typedef enum {
    ZoomerPositionCeiling,
    ZoomerPositionGround,
    ZoomerPositionWallLeft,
    ZoomerPositionWallRight,
} ZoomerPosition;

@interface DTEntityZoomer : DTEntity {
    float   speed;
}

-(id)init;

@property (nonatomic) ZoomerPosition crawlPosition;

@end
