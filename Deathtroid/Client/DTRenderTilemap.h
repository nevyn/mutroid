#import <Foundation/Foundation.h>

@class DTLayer, DTCamera;
@interface DTRenderTilemap : NSObject
-(void)drawLayer:(DTLayer*)layer camera:(DTCamera*)camera;
@end
