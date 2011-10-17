//
//  DTPlayerEntity.h
//  Deathtroid
//
//  Created by Per Borgman on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTEntity.h"

@interface DTEntityPlayer : DTEntity
@property(nonatomic) BOOL immune;

-(id)init;
-(void)tick:(double)delta;

-(void)jump;
-(void)shoot;

@end
