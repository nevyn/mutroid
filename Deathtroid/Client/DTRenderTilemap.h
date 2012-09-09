#import <Foundation/Foundation.h>

@class DTLayer, DTMap, DTCamera, DTWorldRoom;
@interface DTRenderTilemap : NSObject
-(void)drawLayer:(DTLayer*)layer camera:(DTCamera*)camera fromWorldRoom:(DTWorldRoom*)worldRoom;
-(void)drawCollision:(DTMap*)map camera:(DTCamera*)camera;
-(void)drawMap:(DTMap*)map textureScale:(float)scale;
@end
