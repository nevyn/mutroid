//
//  DTPlayer.h
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTEntity.h"

@class DTEntity;

@interface DTPlayer : NSObject

@property (nonatomic,strong) DTEntity *entity;
@property (nonatomic) EntityDirection direction;

@end