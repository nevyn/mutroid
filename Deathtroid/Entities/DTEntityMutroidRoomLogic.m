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

@interface DTEntityMutroidRoomLogic ()

@property (nonatomic, assign) double timePassed;
@property (nonatomic, retain) NSMutableArray *beats;
@property (nonatomic, retain) DTMap *map;

@end

@implementation DTEntityMutroidRoomLogic
{
    EchoNestFetcher *_fetcher;
    SPTrack *_track;
}

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    [self loadTrack];

    self.timePassed = 0.0;
    self.map = ((DTLayer*)[self.world.room.layers objectAtIndex:0]).map;

    return self;
}

-(void)tick:(double)delta {
    [super tick:delta];
    
    if(!self.world.sroom)
        return;
 
    self.timePassed += delta;
    
    if ([self.beats count] <= 0) return;
    
    float start = [[[self.beats objectAtIndex:0] objectForKey:@"start"] floatValue];
    float duration = [[[self.beats objectAtIndex:0] objectForKey:@"duration"] floatValue];
    float end = start + duration;
    
    int expected = (self.timePassed >= start && self.timePassed <= end) ? 2 : 0;
    if(expected != *[self.map tileAtX:10 y:20])
        [self.map setTile:expected atX:10 y:20];
    
    if (self.timePassed >= end) {
        [self.beats removeObjectAtIndex:0];
    }
}

- (void) foundSongData:(NSDictionary*)data {
    NSLog(@"Beats: %@", [data objectForKey:@"beats"]);
    self.beats = [NSMutableArray arrayWithArray:[data objectForKey:@"beats"]];
    
    self.timePassed = 0.0;
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
