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
#import <CocoaLibSpotify/CocoaLibSpotify.h>

@implementation DTEntityMutroidRoomLogic
{
    EchoNestFetcher *_fetcher;
    SPTrack *_track;
}

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    [self loadTrack];
    
    //[((DTLayer*)[self.world.room.layers objectAtIndex:0]).map setTile:1 atX:10 y:20];

    return self;
}

-(void)tick:(double)delta {
    [super tick:delta];
    
}

- (void) foundSongData:(NSDictionary*)data {
    NSLog(@"Found song data %ld", data.allKeys.count);
}

- (void)loadTrack
{
    if(!self.trackURL)
        return;
    
    [SPTrack trackForTrackURL:[NSURL URLWithString:self.trackURL] inSession:[SPSession sharedSession] callback:^(SPTrack *track) {
        NSAssert(track, @"Expected track for link");
        _track = track;
        [SPAsyncLoading waitUntilLoaded:_track timeout:30 then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
            NSAssert(loadedItems.count == 1, @"Expected track to load");
            
            _fetcher = [[EchoNestFetcher alloc] init];
            [_fetcher findSong:_track.name byArtist:[_track.artists[0] name] delegate:self];
        }];
    }];
}

-(id)updateFromRep:(NSDictionary*)rep;
{
    [super updateFromRep:rep];
    if(rep[@"trackURL"] && ![rep[@"trackURL"] isEqual:_trackURL]) {
        _trackURL = rep[@"trackURL"];
        [self loadTrack];
    }
    return self;
}
-(NSDictionary*)rep;
{
    NSMutableDictionary *rep = $mdict(
        @"trackURL", _trackURL
    );
    [rep addEntriesFromDictionary:[super rep]];
    return rep;
}
+ (NSArray*)fieldDescriptors
{
    return [[super fieldDescriptors] arrayByAddingObjectsFromArray:@[
        DTFIELD(@"trackURL", String)
    ]];
}


@end
