#import <Foundation/Foundation.h>

@class DTPhysics;
@class DTWorld, DTLevel, DTEntity, DTMap;
@class DTTraceResult;
@class Vector2;

@interface DTServer : NSObject 

-(void)destroyEntityKeyed:(NSString*)key;

-(id)init;
-(id)initListeningOnPort:(NSUInteger)port;

-(void)tick:(double)delta;

@property (nonatomic,strong) DTPhysics *physics;

@property (nonatomic,strong) NSMutableDictionary *entities;

@property (nonatomic,strong) DTWorld *world;
@property (nonatomic,strong) DTLevel *level;

@end
