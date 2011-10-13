#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

@class TCAsyncHashProtocol;

typedef void(^TCAsyncHashProtocolResponseCallback)(NSDictionary *response);
typedef void(^TCAsyncHashProtocolRequestCanceller)();

/// If you have set autoReadHash to NO, call readHash some time after receiving any of these
/// callbacks in order to continue receiving hashes.
@protocol TCAsyncHashProtocolDelegate <NSObject, AsyncSocketDelegate>
-(void)protocol:(TCAsyncHashProtocol*)proto receivedHash:(NSDictionary*)hash payload:(NSData*)payload;
-(void)protocol:(TCAsyncHashProtocol*)proto receivedRequest:(NSDictionary*)hash payload:(NSData*)payload responder:(TCAsyncHashProtocolResponseCallback)responder;
@end

@interface TCAsyncHashProtocol : NSObject <AsyncSocketDelegate>
@property(nonatomic,strong,readonly) AsyncSocket *socket;
@property(nonatomic,weak,readwrite) id<TCAsyncHashProtocolDelegate> delegate;
-(id)initWithSocket:(AsyncSocket*)sock delegate:(id<TCAsyncHashProtocolDelegate>)delegate;

/// Send any dictionary containing plist-safe types
-(void)sendHash:(NSDictionary*)hash;
/// Like above, but also attach an arbitrary payload.
-(void)sendHash:(NSDictionary*)hash payload:(NSData*)payload;
/// like above, but you can define a callback for when the other side responds.
-(TCAsyncHashProtocolRequestCanceller)requestHash:(NSDictionary*)hash response:(TCAsyncHashProtocolResponseCallback)response;

/// Ask this TCAHP to ask its AsyncSocket to listen for another hash.
-(void)readHash;
/// default YES; calls readHash after each message. Un-set this to interleave TCAHP
/// messages with your own custom protocol over the AsyncSocket.
@property(nonatomic) BOOL autoReadHash;
@end
