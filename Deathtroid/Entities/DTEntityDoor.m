//
//  DTDoor.m
//  Deathtroid
//
//  Created by Joachim Bengtsson on 2011-10-09.
//  Copyright (c) 2011 Third Cog Software. All rights reserved.
//

#import "DTEntityDoor.h"
#import "Vector2.h"
#import "DTWorld.h"
#import "DTServer.h"
#import "DTEntityPlayer.h"

@implementation DTEntityDoor
@synthesize destinationRoom, destinationPosition;
-(id)init;
{
    if(!(self = [super init])) return nil;
    
    self.gravity = NO;
    
    return self;
}
-(id)updateFromRep:(NSDictionary*)rep;
{
    [super updateFromRep:rep];
    $doif(@"destinationRoom", destinationRoom = o);
    $doif(@"destinationPosition", destinationPosition = [[Vector2 alloc] initWithRep:o]);
    return self;
}
-(NSDictionary*)rep;
{
    NSMutableDictionary *rep = $mdict(
        @"destinationRoom", destinationRoom,
        @"destinationPosition", destinationPosition.rep
    );
    [rep addEntriesFromDictionary:[super rep]];
    return rep;
}
+ (NSArray*)fieldDescriptors
{
    return [[super fieldDescriptors] arrayByAddingObjectsFromArray:@[
        DTFIELD(@"destinationRoom", RoomReference),
        DTFIELD(@"destinationPosition", Vector2),
    ]];
}

-(void)didCollideWithEntity:(DTEntity *)other;
{
}
@end
