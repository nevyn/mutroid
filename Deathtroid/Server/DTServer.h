#import <Foundation/Foundation.h>

@class DTPhysics;
@class DTWorld, DTRoom, DTEntity, DTMap;
@class DTTraceResult;
@class Vector2;
@class DTPlayer;

@interface DTServer : NSObject 

-(id)init;
-(id)initListeningOnPort:(NSUInteger)port;

-(void)loadLevel:(NSString*)levelName;

-(void)tick:(double)delta;

-(void)entityDamaged:(DTEntity*)entity damage:(int)damage location:(Vector2*)where killer:(DTEntity*)killer;

/// @param player: nil to send hoster's player
/// @param pos: nil to find a spawn location
-(void)teleportPlayer:(DTPlayer*)player toPosition:(Vector2*)pos inRoomNamed:(NSString*)roomName;
-(DTPlayer*)playerForEntity:(DTEntity*)playerE;

@property (nonatomic,strong) DTPhysics *physics;

@property (nonatomic,strong) NSMutableDictionary *rooms;

-(void)entityWasKilled:(DTEntity*)killed by:(DTEntity*)killer;

@end
