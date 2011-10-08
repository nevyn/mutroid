#import <Foundation/Foundation.h>

@class DTClient, DTLevel, DTEntity, DTMap;

@interface DTServer : NSObject
-(id)init;
-(id)initListeningOnPort:(NSUInteger)port;

-(void)tick:(double)delta;

-(void)collideEntityWithWorld:(DTEntity*)entity delta:(double)delta;
-(void)collideEntityWithWorldStep:(DTEntity*)entity vx:(float)vx vy:(float)vy map:(DTMap*)map;

@property (nonatomic,strong) NSMutableArray *entities;

@property (nonatomic,strong) DTLevel *level;

@property (nonatomic,strong) DTClient *client;

@end
