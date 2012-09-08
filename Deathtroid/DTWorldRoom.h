#import <Foundation/Foundation.h>
#import "DTRoom.h"
@class DTColor, DTLayer;

@interface DTWorldRoom : NSObject
- (id)initWithRoom:(DTRoom*)room;

@property DTRoom *room;
@property (nonatomic,strong) DTWorld *world; // room maths
@property NSMutableDictionary *entities;

-(void)tick:(float)delta;
- (DTColor*)cyclingColorForLayer:(DTLayer*)layer;
@end
