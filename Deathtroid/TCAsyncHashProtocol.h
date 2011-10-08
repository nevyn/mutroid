#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

@class TCAsyncHashProtocol;

@protocol TCAsyncHashProtocolDelegate <NSObject, AsyncSocketDelegate>
-(void)protocol:(TCAsyncHashProtocol*)proto receivedHash:(NSDictionary*)hash;
@end

@interface TCAsyncHashProtocol : NSObject <AsyncSocketDelegate>
@property(nonatomic,strong,readonly) AsyncSocket *socket;
@property(nonatomic,weak,readwrite) id<TCAsyncHashProtocolDelegate> delegate;
-(id)initWithSocket:(AsyncSocket*)sock delegate:(id<TCAsyncHashProtocolDelegate>)delegate;

-(void)sendHash:(NSDictionary*)hash;

-(void)readHash; // call after connection is established, and after each received hash
@end
