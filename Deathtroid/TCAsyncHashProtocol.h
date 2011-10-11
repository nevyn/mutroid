#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

@class TCAsyncHashProtocol;

typedef void(^TCAsyncHashProtocolResponseCallback)(NSDictionary *response);
typedef void(^TCAsyncHashProtocolRequestCanceller)();

/// You must call readHash after these CBs to keep reading from the socket
@protocol TCAsyncHashProtocolDelegate <NSObject, AsyncSocketDelegate>
-(void)protocol:(TCAsyncHashProtocol*)proto receivedHash:(NSDictionary*)hash;
-(void)protocol:(TCAsyncHashProtocol*)proto receivedRequest:(NSDictionary*)hash responder:(TCAsyncHashProtocolResponseCallback)responder;
@end

@interface TCAsyncHashProtocol : NSObject <AsyncSocketDelegate>
@property(nonatomic,strong,readonly) AsyncSocket *socket;
@property(nonatomic,weak,readwrite) id<TCAsyncHashProtocolDelegate> delegate;
-(id)initWithSocket:(AsyncSocket*)sock delegate:(id<TCAsyncHashProtocolDelegate>)delegate;

/// Send any dictionary containing plist-safe types
-(void)sendHash:(NSDictionary*)hash; 
/// like above, but you can define a callback for when the other side responds
-(TCAsyncHashProtocolRequestCanceller)requestHash:(NSDictionary*)hash response:(TCAsyncHashProtocolResponseCallback)response;

/// call after connection is established, and after each received hash
-(void)readHash;
@end
