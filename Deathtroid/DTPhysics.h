//
//  DTPhysics.h
//  Deathtroid
//
//  Created by Per Borgman on 10/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 
 Physics simulation, used by both client and server

*/

@class DTWorld, DTEntity;

@interface DTPhysics : NSObject

-(void)runWithEntities:(NSArray*)entities world:(DTWorld*)world delta:(double)delta;
-(void)moveEntity:(DTEntity*)entity world:(DTWorld*)world delta:(double)delta;

@end
