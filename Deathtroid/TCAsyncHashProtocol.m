#import "TCAsyncHashProtocol.h"

enum {
	kTagLength,
	kTagData,
};

static const NSString *kTCAsyncHashProtocolRequestKey = @"__tcahp-requestKey";
static const NSString *kTCAsyncHashProtocolResponseKey = @"__tcahp-responseKey";

@interface TCAsyncHashProtocol ()
@property(nonatomic,strong,readwrite) AsyncSocket *socket;
@end

@implementation TCAsyncHashProtocol {
	NSMutableDictionary *requests;
}
@synthesize socket = _socket, delegate = _delegate, autoReadHash = _autoReadHash;
-(id)initWithSocket:(AsyncSocket*)sock delegate:(id<TCAsyncHashProtocolDelegate>)delegate;
{
	if(!(self = [super init])) return nil;
	
	self.socket = sock;
	_autoReadHash = YES;
	_socket.delegate = self;
	_delegate = delegate;
	requests = [NSMutableDictionary dictionary];
	
	return self;
}
-(NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector;
{
	if([super respondsToSelector:aSelector]) return [super methodSignatureForSelector:aSelector];
	if([_delegate respondsToSelector:aSelector]) return [(id)_delegate methodSignatureForSelector:aSelector];
	return nil;
}
-(void)forwardInvocation:(NSInvocation *)anInvocation;
{
	if([_delegate respondsToSelector:anInvocation.selector]) {
		anInvocation.target = _delegate;
		return [anInvocation invoke];
	}
	return [super forwardInvocation:anInvocation];
}
-(BOOL)respondsToSelector:(SEL)aSelector;
{
	return [super respondsToSelector:aSelector] || [_delegate respondsToSelector:aSelector];
}

#pragma mark Serialization
-(NSData*)serialize:(id)thing;
{
	//return [NSKeyedArchiver archivedDataWithRootObject:thing];
	NSError *err = nil;
	return [NSJSONSerialization dataWithJSONObject:thing options:0 error:&err];
}
-(id)unserialize:(NSData*)unthing;
{
	//return [NSKeyedUnarchiver unarchiveObjectWithData:unthing];
	NSError *err = nil;
	return [NSJSONSerialization JSONObjectWithData:unthing options:0 error:&err];
}

#pragma mark AsyncSocket
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port;
{
	if([self.delegate respondsToSelector:_cmd]) [self.delegate onSocket:sock didConnectToHost:host port:port];
	
	if(self.autoReadHash) [self readHash];
}
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)inData withTag:(long)tag;
{
	if(tag == kTagLength) {
		uint32_t readLength = 0;
		[inData getBytes:&readLength length:4];
		readLength = ntohl(readLength);
		
		[_socket readDataToLength:readLength withTimeout:-1 tag:kTagData];
	} else if(tag == kTagData) {
		NSDictionary *hash = [self unserialize:inData];
		NSAssert(hash, @"really should be unserializable");
		
		NSString *reqKey = [hash objectForKey:kTCAsyncHashProtocolRequestKey];
		NSString *respKey = [hash objectForKey:kTCAsyncHashProtocolResponseKey];
		if(reqKey) {
			[_delegate protocol:self receivedRequest:hash responder:^(NSDictionary *response) {
				NSMutableDictionary *resp2 = [response mutableCopy];
				[resp2 setObject:reqKey forKey:kTCAsyncHashProtocolResponseKey];
				[self sendHash:resp2];
			}];
			if(self.autoReadHash) [self readHash];
		}
		if(respKey) {
			TCAsyncHashProtocolResponseCallback cb = [requests objectForKey:respKey];
			if(cb) cb(hash);
			else NSLog(@"Discarded response: %@", hash);
			[requests removeObjectForKey:respKey];
			[self readHash]; // we're not calling delegate at all, so MUST readHash here
		} 
		if(!reqKey && !respKey) {
			[_delegate protocol:self receivedHash:hash];
			if(self.autoReadHash) [self readHash];
		}
		
	} else if([_delegate respondsToSelector:@selector(_cmd)])
		[_delegate onSocket:sock didReadData:inData withTag:tag];
}
-(void)sendHash:(NSDictionary*)hash;
{
	NSData *unthing = [self serialize:hash];
	
	uint32_t writeLength = htonl(unthing.length);
	NSData *lengthD = [NSData dataWithBytes:&writeLength length:4];
	[_socket writeData:lengthD withTimeout:-1 tag:kTagLength];
	
	[_socket writeData:unthing withTimeout:-1 tag:kTagData];
}
-(TCAsyncHashProtocolRequestCanceller)requestHash:(NSDictionary*)hash response:(TCAsyncHashProtocolResponseCallback)response;
{
	NSString *uuid = [NSString dt_uuid];
	[requests setObject:[response copy] forKey:uuid];
	TCAsyncHashProtocolRequestCanceller canceller = ^{ [requests removeObjectForKey:uuid]; };
	
	NSMutableDictionary *hash2 = [hash mutableCopy];
	[hash2 setObject:uuid forKey:kTCAsyncHashProtocolRequestKey];
	
	[self sendHash:hash2];
	
	return canceller;
}
-(void)readHash;
{
	[_socket readDataToLength:4 withTimeout:-1 tag:kTagLength];
}
-(NSString*)description;
{
	return $sprintf(@"<TCAsyncHashProtocol@%p over %@>", self, _socket);
}
@end
