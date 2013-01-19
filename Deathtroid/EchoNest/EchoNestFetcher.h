//
//  EchoNestFetcher.h
//  Mutroid
//
//  Created by Amanda Rösler on 1/19/13.
//
//

#import <Foundation/Foundation.h>
#import "ARURLConnection.h"

@interface EchoNestFetcher: NSObject<ARURLConnectionDelegate> 

- (void) findSong:(NSString*)song byArtist:(NSString*)artist;
- (void) requestFinishedWithTag:(NSString*)tag data:(NSData*)data;

@end
