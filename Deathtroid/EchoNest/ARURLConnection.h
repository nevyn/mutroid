//
//  ARURLConnection.h
//  Mutroid
//
//  Created by Amanda Rösler on 1/19/13.
//
//

#import <Foundation/Foundation.h>

@protocol ARURLConnectionDelegate <NSObject>

- (void) requestFinishedWithTag:(NSString*)tag data:(NSData*)data;

@end

@interface ARURLConnection : NSObject

+ (id) connectionWithURL:(NSString*)url delegate:(id<ARURLConnectionDelegate>)delegate tag:(NSString*)tag;

@end
