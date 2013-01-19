//
//  EchoNestFetcher.m
//  Mutroid
//
//  Created by Amanda Rösler on 1/19/13.
//
//

#import "EchoNestFetcher.h"

#define API_KEY @"FHDI5OKWZWJMB2M7B"
#define FIND_SONG @"Find song"
#define GET_SONG_DATA @"Get song data"
#define GET_SONG_ANALYSIS @"Get song analysis"

@interface EchoNestFetcher ()
@end

@implementation EchoNestFetcher


- (void) findSong:(NSString*)song byArtist:(NSString*)artist {

    song = [song stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    artist = [artist stringByReplacingOccurrencesOfString:@" " withString:@"%20"];

    NSString *url = [NSString stringWithFormat:@"http://developer.echonest.com/api/v4/song/search?api_key=%@&format=json&results=1&artist=%@&title=%@&bucket=id:7digital-US&bucket=tracks", API_KEY, artist, song];
    
    [ARURLConnection connectionWithURL:url delegate:self tag:FIND_SONG];
    
}

- (void) requestFinishedWithTag:(NSString*)tag data:(NSData*)data {
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    if (tag == FIND_SONG) {
        
        NSLog(@"Found song: %@", json);
        
        NSString *trackID = [[[[[[json objectForKey:@"response"] objectForKey:@"songs"] objectAtIndex:0] objectForKey:@"tracks"] objectAtIndex:0] objectForKey:@"id"];
        
        NSString *url = [NSString stringWithFormat:@"http://developer.echonest.com/api/v4/track/profile?api_key=%@&format=json&id=%@&bucket=audio_summary", API_KEY, trackID];
        
        [ARURLConnection connectionWithURL:url delegate:self tag:GET_SONG_DATA];
    }
    else if (tag == GET_SONG_DATA) {
        
        NSLog(@"Song data: %@", json);
        
        NSString *analysisURL = [[[[json objectForKey:@"response"] objectForKey:@"track"] objectForKey:@"audio_summary"] objectForKey:@"analysis_url"];
        
        [ARURLConnection connectionWithURL:analysisURL delegate:self tag:GET_SONG_ANALYSIS];

    }
    else if (tag == GET_SONG_ANALYSIS) {
        
        NSLog(@"Song analysis: %@", json);

    }
}

@end