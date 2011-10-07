#import "DTServer.h"
#import "AsyncSocket.h"

@implementation DTServer {
    AsyncSocket *_sock;
}

-(id)init;
{
    return [self initListeningOnPort:kDTServerDefaultPort];
}
-(id)initListeningOnPort:(NSUInteger)port;
{
    if(!(self = [super init])) return nil;
    
    _sock = [[AsyncSocket alloc] initWithDelegate:self];
    
    return self;
}
@end
