#import "DTRenderState.h"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"


@interface DTRenderState ()
@property(nonatomic,readwrite,weak) DTRenderStateStack *stack;
@end

@implementation DTRenderStateStack {
    NSMutableArray *_stack;
}
- (id)init
{
    if (!(self = [super init]))
        return nil;
    _stack = [NSMutableArray new];
    return self;
}

- (void)draw:(NSTimeInterval)delta
{
    [[_stack lastObject] draw:delta];
}

- (NSArray*)states
{
    return _stack;
}
- (void)setStates:(NSArray *)states
{
    while(_stack.count)
        [self popState];
    for(DTRenderState *state in states)
        [self pushState:state];
}

- (void)pushState:(DTRenderState*)state
{
    state.stack = self;
    [_stack addObject:state];
}
- (void)popState
{
    [[_stack lastObject] setStack:nil];
    [_stack removeLastObject];
}
@end


@implementation DTRenderState {
    void(^_block)(NSTimeInterval delta);
}

- (id)initWithTarget:(id)target action:(SEL)action
{
    __weak id weakTarget = target;
    return [self initWithBlock:^(NSTimeInterval delta) {
        [weakTarget performSelector:action withObject:@(delta)];
    }];
}
- (id)initWithBlock:(void(^)(NSTimeInterval delta))block
{
    if (!(self = [super init]))
        return nil;
    _block = block;
    return self;
}
- (void)draw:(NSTimeInterval)delta
{
    _block(delta);
}
@end

@implementation DTRenderStateAnimation {
    NSTimeInterval _duration;
    id _timingFunction;
}
- (id)initWithTarget:(id)target action:(SEL)action duration:(NSTimeInterval)duration timingFunction:(id)timingFunction
{
    __weak id weakTarget = target;
    return [self initWithBlock:^(NSTimeInterval delta) {
        [weakTarget performSelector:action withObject:@(delta)];
    } duration:duration timingFunction:timingFunction];
}
- (id)initWithBlock:(void(^)(NSTimeInterval delta))block duration:(NSTimeInterval)duration timingFunction:(id)timingFunction
{
    if(!(self = [super initWithBlock:block]))
        return nil;
    _duration = duration;
    _timingFunction = timingFunction;
    return self;
}
- (void)draw:(NSTimeInterval)delta
{
    _duration -= delta;
    if(_duration <= 0) {
        DTRenderStateStack *stack = self.stack;
        [super draw:0];
        [self.stack popState];
        [stack draw:delta];
        return;
    }
    [super draw:delta];
}
@end