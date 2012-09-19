//
//  DTDoor.h
//  Deathtroid
//
//  Created by Joachim Bengtsson on 2011-10-09.
//  Copyright (c) 2011 Third Cog Software. All rights reserved.
//

#import "DTEntity.h"

@interface DTEntityDoor : DTEntity
@property(nonatomic,copy) NSString *destinationRoom;
@property(nonatomic,strong) Vector2 *destinationPosition;
-(void)didCollideWithEntity:(DTEntity*)other;

- (Vector2*)spawnLocation;
@end
