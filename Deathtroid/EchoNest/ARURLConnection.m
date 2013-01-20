//
//  ARURLConnection.m
//  Mutroid
//
//  Created by Amanda Rösler on 1/19/13.
//
//

#import "ARURLConnection.h"

@interface ARURLConnection ()

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSString* tag;
@property (nonatomic, retain) id<ARURLConnectionDelegate> delegate;

@end

@implementation ARURLConnection

+ (id) connectionWithURL:(NSString*)url delegate:(id<ARURLConnectionDelegate>)delegate tag:(NSString*)tag {
    
    return [[ARURLConnection alloc] initWithURL:url delegate:delegate tag:tag];
}

- (id) initWithURL:(NSString*)url delegate:(id<ARURLConnectionDelegate>)delegate tag:(NSString*)tag {
   
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.tag = tag;
        
        [self sendRequestWithURL:url];
    }
    return self;
}

- (void) sendRequestWithURL:(NSString*)url {
    
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        self.receivedData = [NSMutableData data];
    } else {
        NSLog(@"Connection failed");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
    
    self.receivedData = nil;
    
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
        
    [self.delegate requestFinishedWithTag:self.tag data:self.receivedData];
    
    self.receivedData = nil;
}


@end
