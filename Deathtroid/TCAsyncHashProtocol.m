#import "TCAsyncHashProtocol.h"

enum {
	kTagLength,
	kTagData,
	
};

@interface TCAsyncHashProtocol ()
@property(nonatomic,strong,readwrite) AsyncSocket *socket;
@end

@implementation TCAsyncHashProtocol
@synthesize socket = _socket, delegate = _delegate;
-(id)initWithSocket:(AsyncSocket*)sock delegate:(id<TCAsyncHashProtocolDelegate>)delegate;
{
	if(!(self = [super init])) return nil;
	
	self.socket = sock;
	_socket.delegate = self;
	_delegate = delegate;
	
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
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)inData withTag:(long)tag;
{
	if(tag == kTagLength) {
		uint32_t readLength = 0;
		[inData getBytes:&readLength length:4];
		readLength = ntohl(readLength);
		
		[_socket readDataToLength:readLength withTimeout:-1 tag:kTagData];
	} else if(tag == kTagData) {
		id data = [self unserialize:inData];
		NSAssert(data, @"really should be unserializable");
		
		[_delegate protocol:self receivedHash:data];
		
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
-(void)readHash;
{
	[_socket readDataToLength:4 withTimeout:-1 tag:kTagLength];
}
@end
