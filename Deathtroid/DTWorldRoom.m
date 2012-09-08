#import "DTWorldRoom.h"
#import "DTLayer.h"
#import "DTWorld.h"

@implementation DTWorldRoom {
    NSMutableDictionary *_layerStates;
}
- (id)initWithRoom:(DTRoom*)room
{
    if(!(self = [super init]))
        return nil;
    self.room = room;
    self.world = [[DTWorld alloc] initWithRoom:room];

    _entities = [NSMutableDictionary new];
    _layerStates = [NSMutableDictionary new];
    
    return self;
}

-(void)tick:(float)delta
{
    for(DTLayer *layer in self.room.layers) {
        id key = [NSValue valueWithPointer:(__bridge const void *)(layer)];
        DTLayerState *state = [_layerStates objectForKey:key];
        if(!state) {
            state = [DTLayerState new];
            [_layerStates setObject:state forKey:key];
        }
        [layer tick:delta inState:state];
    }
}

- (DTColor*)cyclingColorForLayer:(DTLayer*)layer
{
    id key = [NSValue valueWithPointer:(__bridge const void *)(layer)];
    DTLayerState *state = [_layerStates objectForKey:key];
    return [layer.cycleColors objectAtIndex:state.cycleCurrent];
}
@end
