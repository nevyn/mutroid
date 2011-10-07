#import <Foundation/Foundation.h>

@interface DTServer : NSObject
-(id)init;
-(id)initListeningOnPort:(NSUInteger)port;
@end
