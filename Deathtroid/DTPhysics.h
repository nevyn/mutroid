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

typedef void(^CollisionAction)(DTEntity*,DTEntity*);

@interface DTCollisionPair : NSObject {
    Class           classA;
    Class           classB;
    CollisionAction action;
}
-(id)initWithClassA:(Class)a b:(Class)b action:(CollisionAction)_action;
-(void)runWithEntityA:(DTEntity*)a b:(DTEntity*)b;
@end

@interface DTPhysics : NSObject

-(void)runWithEntities:(NSArray*)entities world:(DTWorld*)world delta:(double)delta;
-(void)moveEntity:(DTEntity*)entity world:(DTWorld*)world delta:(double)delta;

@property (nonatomic,strong) NSMutableArray *pairs;

@end
