//
//  DTEntityBullet.h
//  Deathtroid
//
//  Created by Per Borgman on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTEntity.h"

@class DTEntityPlayer;

@interface DTEntityBullet : DTEntity

@property (nonatomic,weak) DTEntityPlayer *owner;

@end
