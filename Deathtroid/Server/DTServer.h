#import <Foundation/Foundation.h>

@class DTWorld, DTLevel, DTEntity, DTMap;
@class DTTraceResult;
@class Vector2;

@interface DTServer : NSObject
-(id)init;
-(id)initListeningOnPort:(NSUInteger)port;

-(void)tick:(double)delta;

-(void)collideEntityWithWorld:(DTEntity*)entity delta:(double)delta;

@property (nonatomic,strong) NSMutableDictionary *entities;

@property (nonatomic,strong) DTWorld *world;
@property (nonatomic,strong) DTLevel *level;

@end
