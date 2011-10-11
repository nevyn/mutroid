//
//  DTEntityEnemyBase.m
//  Deathtroid
//
//  Created by Joachim Bengtsson on 2011-10-09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTEntityEnemyBase.h"
#import "DTEntityPlayer.h"
#import "Vector2.h"

@implementation DTEntityEnemyBase
@synthesize touchDamage;
-(id)init;
{
	if(!(self = [super init])) return nil;

	self.touchDamage = 5;
	
	return self;
}
@end
