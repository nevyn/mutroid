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
#import "DTEntityPlayer.h"
#import "DTLayer.h"
#import <CocoaLibSpotify/CocoaLibSpotify.h>
#import "DTAppDelegate.h"
#import "DTWorldRoom.h"

@interface DTEntityMutroidRoomLogic ()

@property (nonatomic, assign) double timePassed;
@property (nonatomic, retain) DTMap *map;

@end

@implementation DTEntityMutroidRoomLogic
{
    EchoNestFetcher *_fetcher;
    SPTrack *_track;
    NSDictionary *_songData;
    BOOL _dead;
    BOOL _levelBuilt;
}

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    [self loadTrack];

    self.timePassed = 0.0;
    self.map = ((DTLayer*)[self.world.room.layers objectAtIndex:2]).map;
    
    DTMap *coll = self.world.room.collisionLayer;
    for(int i = 0, c = coll.width; i < c; i++) {
        [coll setTile:1 atX:i y:coll.height-1];
        [_map setTile:21 atX:i y:coll.height-1];
    }

    return self;
}

-(void)tick:(double)delta {
    [super tick:delta];
    
    self.timePassed = [DTAppDelegate sharedAppDelegate].audioOut.progress;
        
    DTEntityPlayer *player = nil;
    for(DTEntity *e in self.world.wroom.entities.allValues)
        if([e isKindOfClass:[DTEntityPlayer class]])
            player = (id)e;
    
    if(!([NSEvent modifierFlags] & NSShiftKeyMask))
        player.position.x = _timePassed * kMutroidTimeSpeedConstant;
    
    if(!self.world.server) {
        if(!player && !_dead && [SPSession sharedSession].playing) {
            [[SPSession sharedSession] setPlaying:NO];
            [DTAppDelegate sharedAppDelegate].audioOut.progress = 0;
            _dead = YES;
            [(NSSound*)[NSSound soundNamed:@"winddown.aif"] play];
        }
        
        if(![SPSession sharedSession].playing && player && _dead) {
            _dead = NO;
            [self playTrack];
        }
    }
}

- (void) foundSongData:(NSDictionary*)data
{
    _songData = data;
    if (!data)
        return;
    NSLog(@"Received song analysis");
    
    [self playTrack];
}

- (void)loadTrack
{
    if(!self.trackURL || self.world.sroom)
        return;
    
    _songData = NO;
    
    NSString *urlString = [[NSUserDefaults standardUserDefaults] objectForKey:@"trackLink"] ?: self.trackURL;
    
    [SPTrack trackForTrackURL:[NSURL URLWithString:urlString] inSession:[SPSession sharedSession] callback:^(SPTrack *track) {
        NSAssert(track, @"Expected track for link");
        _track = track;
        [SPAsyncLoading waitUntilLoaded:_track timeout:30 then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
            NSAssert(loadedItems.count == 1, @"Expected track to load");
                        
            _fetcher = [[EchoNestFetcher alloc] init];
            [_fetcher findSong:_track.name byArtist:[_track.artists[0] name] delegate:self];
        }];
    }];
}

- (void)playTrack
{
    [[SPSession sharedSession] playTrack:_track callback:^(NSError *error) {
        [self startLevel];
    }];
}
- (void)startLevel
{
    NSLog(@"Beats: %@", _songData[@"beats"][0]);
    self.beats = [NSMutableArray arrayWithArray:_songData[@"beats"]];
    self.bars = [NSMutableArray arrayWithArray:[_songData objectForKey:@"bars"]];
    
    [self buildLevel];
    
    self.timePassed = 0.0;
    [[SPSession sharedSession] setPlaying:YES];
}

- (void)buildLevel
{
    if(_levelBuilt)
        return;
    
    int i = 0;
    for(NSDictionary *beat in self.beats) {
        float start = [beat[@"start"] floatValue] * kMutroidTimeSpeedConstant;

        i++;
        
        if(start < 4)
            continue;
        
        enum {
            Jump,
            Duck,
            
            ActionCount
        } nextAction = arc4random_uniform(ActionCount);
        
        if(i % 2 != 0)
            continue;
            
        if(nextAction == Jump) {
            DTMap *coll = self.world.room.collisionLayer;
            [_map setTile:39 atX:start+1 y:coll.height-2];
            [_map setTile:40 atX:start+2 y:coll.height-2];
            [_map setTile:47 atX:start+1 y:coll.height-1];
            [_map setTile:48 atX:start+2 y:coll.height-1];
            
            [coll setTile:23 atX:start+1 y:coll.height-2];
            [coll setTile:23 atX:start+2 y:coll.height-2];
            [coll setTile:23 atX:start+1 y:coll.height-1];
            [coll setTile:23 atX:start+2 y:coll.height-1];
        } else if(nextAction == Duck) {
            DTMap *coll = self.world.room.collisionLayer;
            
            [_map setTile:47 atX:start+1 y:coll.height-4];
            [_map setTile:48 atX:start+2 y:coll.height-4];
            [_map setTile:39 atX:start+1 y:coll.height-3];
            [_map setTile:40 atX:start+2 y:coll.height-3];
            
            [_map setAttr:1 << 1 atX:start+1 y:coll.height-4];
            [_map setAttr:1 << 1 atX:start+2 y:coll.height-4];
            [_map setAttr:1 << 1 atX:start+1 y:coll.height-3];
            [_map setAttr:1 << 1 atX:start+2 y:coll.height-3];


            [coll setTile:23 atX:start+1 y:coll.height-4];
            [coll setTile:23 atX:start+2 y:coll.height-4];
            [coll setTile:23 atX:start+1 y:coll.height-3];
            [coll setTile:23 atX:start+2 y:coll.height-3];
        }
    }
    
    _levelBuilt = YES;
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
