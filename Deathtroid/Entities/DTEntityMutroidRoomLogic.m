//
//  DTEntityMutroidRoomLogic.m
//  Mutroid
//
//  Created by Amanda Rösler on 1/19/13.
//
//

#import "DTEntityMutroidRoomLogic.h"
#import "EchoNestFetcher.h"
#import "DTRoom.h"
#import "DTWorld.h"
#import "DTMap.h"
#import "DTLayer.h"

@implementation DTEntityMutroidRoomLogic

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    EchoNestFetcher *echo = [[EchoNestFetcher alloc] init];
    [echo findSong:@"El Scorcho" byArtist:@"Weezer" delegate:self];
    
    [((DTLayer*)[self.world.room.layers objectAtIndex:0]).map setTile:1 atX:10 y:20];

    return self;
}

-(void)tick:(double)delta {
    [super tick:delta];
    
}

- (void) foundSongData:(NSDictionary*)data {
    
}

@end
