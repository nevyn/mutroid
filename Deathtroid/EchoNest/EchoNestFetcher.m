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

@property (nonatomic, retain) id<EchoNestFetcherDelegate> delegate;
@property (nonatomic, retain) ARURLConnection *connection;

@end

@implementation EchoNestFetcher


- (void) findSong:(NSString*)song byArtist:(NSString*)artist delegate:(id<EchoNestFetcherDelegate>)delegate {

    self.delegate = delegate;
    
    if ([song isEqualToString:@"Nothing More"] && [artist isEqualToString:@"Expensive Looks"]) {
        
        NSLog(@"Use default song");
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"analysis" ofType:@"json"]];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

        if (json) [self.delegate foundSongData:json];
    }
    else {
    
        NSLog(@"Find song %@ by artist %@", song, artist);
        
        song = [song stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        artist = [artist stringByReplacingOccurrencesOfString:@" " withString:@"%20"];

        NSString *url = [NSString stringWithFormat:@"http://developer.echonest.com/api/v4/song/search?api_key=%@&format=json&results=1&artist=%@&title=%@&bucket=id:7digital-US&bucket=tracks", API_KEY, artist, song];
        
        self.connection = [ARURLConnection connectionWithURL:url delegate:self tag:FIND_SONG];
    }
    
}

- (void) requestFinishedWithTag:(NSString*)tag data:(NSData*)data {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if(!json) {
        NSString *errorString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Error! %@", errorString);
    }
    
    if ([tag isEqual:FIND_SONG]) {
        
        if (json) {
        
            if (![json objectForKey:@"response"] ||
                ![[json objectForKey:@"response"] objectForKey:@"songs"] ||
                [[[json objectForKey:@"response"] objectForKey:@"songs"] count] == 0 ||
                ![[[[json objectForKey:@"response"] objectForKey:@"songs"] objectAtIndex:0] objectForKey:@"tracks"] ||
                [[[[[json objectForKey:@"response"] objectForKey:@"songs"] objectAtIndex:0] objectForKey:@"tracks"] count] == 0 ||
                ![[[[[[json objectForKey:@"response"] objectForKey:@"songs"] objectAtIndex:0] objectForKey:@"tracks"] objectAtIndex:0] objectForKey:@"id"]) {
                    
                NSLog(@"Error! Couldn't find song id");
                return;
            }
                
            NSString *trackID = [[[[[[json objectForKey:@"response"] objectForKey:@"songs"] objectAtIndex:0] objectForKey:@"tracks"] objectAtIndex:0] objectForKey:@"id"];
        
            NSString *url = [NSString stringWithFormat:@"http://developer.echonest.com/api/v4/track/profile?api_key=%@&format=json&id=%@&bucket=audio_summary", API_KEY, trackID];
        
            [ARURLConnection connectionWithURL:url delegate:self tag:GET_SONG_DATA];
        }
        else {
            NSLog(@"Couldn't find song");
        }
    }
    else if ([tag isEqual:GET_SONG_DATA]) {
        
        if (json) {
            
            if (![json objectForKey:@"response"] ||
                ![[json objectForKey:@"response"] objectForKey:@"track"] ||
                ![[[json objectForKey:@"response"] objectForKey:@"track"] objectForKey:@"audio_summary"] ||
                ![[[[json objectForKey:@"response"] objectForKey:@"track"] objectForKey:@"audio_summary"] objectForKey:@"analysis_url"]) {
                
                NSLog(@"Error! Couldn't find analysis url");
                return;
            }
        
            NSString *analysisURL = [[[[json objectForKey:@"response"] objectForKey:@"track"] objectForKey:@"audio_summary"] objectForKey:@"analysis_url"];
        
            [ARURLConnection connectionWithURL:analysisURL delegate:self tag:GET_SONG_ANALYSIS];
        }
        else {
            NSLog(@"Couldn't find song data");
        }

    }
    else if ([tag isEqual:GET_SONG_ANALYSIS]) {
        
        if (json) {
            [self.delegate foundSongData:json];
        }
        else {
            NSLog(@"Couldn't find song analysis: %@", json);
        }
    }
    
    self.connection = nil;
}

@end
