#import <Foundation/Foundation.h>

@class DTLayer, DTMap, DTCamera;
@interface DTRenderTilemap : NSObject
-(void)drawLayer:(DTLayer*)layer camera:(DTCamera*)camera;
-(void)drawCollision:(DTMap*)map camera:(DTCamera*)camera;
-(void)drawMap:(DTMap*)map camera:(DTCamera*)camera;
@end
