//
//  EchoNestFetcher.h
//  Mutroid
//
//  Created by Amanda Rösler on 1/19/13.
//
//

#import <Foundation/Foundation.h>
#import "ARURLConnection.h"

@protocol EchoNestFetcherDelegate <NSObject>

- (void) foundSongData:(NSDictionary*)data;

@end

@interface EchoNestFetcher: NSObject<ARURLConnectionDelegate> 

- (void) findSong:(NSString*)song byArtist:(NSString*)artist delegate:(id<EchoNestFetcherDelegate>)delegate;
- (void) requestFinishedWithTag:(NSString*)tag data:(NSData*)data;

@end
