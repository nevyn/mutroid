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
@class DTServerRoom;
@class TCAsyncHashProtocol;

@interface DTPlayer : NSObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic,weak) DTEntity *entity;
@property (nonatomic,weak) DTServerRoom *room;
@property (nonatomic,strong) TCAsyncHashProtocol *proto;

@end