#import <Foundation/Foundation.h>

@class DTClient, DTWorld, DTLevel, DTEntity, DTMap;
@class DTCollisionInfo;
@class Vector2;

@interface DTServer : NSObject
-(id)init;
-(id)initListeningOnPort:(NSUInteger)port;

-(void)tick:(double)delta;

-(void)collideEntityWithWorld:(DTEntity*)entity delta:(double)delta;

@property (nonatomic,strong) NSMutableArray *entities;

@property (nonatomic,strong) DTWorld *world;
@property (nonatomic,strong) DTLevel *level;

@property (nonatomic,strong) DTClient *client;

@end
