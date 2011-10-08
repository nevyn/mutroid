//
//  DTEntityRipper.h
//  Deathtroid
//
//  Created by Per Borgman on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTEntity.h"

@interface DTEntityRipper : DTEntity {
    float   speed;
}

-(id)init;

-(void)didCollideWithWorld:(DTTraceResult*)info;
-(void)didCollideWithEntity:(DTEntity*)other;

@end
