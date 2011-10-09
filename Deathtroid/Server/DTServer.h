#import <Foundation/Foundation.h>

@class DTPhysics;
@class DTWorld, DTRoom, DTEntity, DTMap, DTLevelRepository;
@class DTTraceResult;
@class Vector2;

@interface DTServer : NSObject 

-(id)init;
-(id)initListeningOnPort:(NSUInteger)port;

-(void)loadLevel:(NSString*)levelName;

-(void)tick:(double)delta;

-(void)entityDamaged:(DTEntity*)entity damage:(int)damage location:(Vector2*)where;

-(void)teleportPlayerForEntity:(DTEntity*)playerE toPosition:(Vector2*)pos inRoomNamed:(NSString*)roomName;


@property (nonatomic,strong) DTPhysics *physics;

@property (nonatomic,strong) NSMutableDictionary *rooms;

@property (nonatomic,strong) DTLevelRepository *levelRepo;

@end
