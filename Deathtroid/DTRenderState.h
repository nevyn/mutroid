//
//  DTRenderState.h
//  Deathtroid
//
//  Created by Joachim Bengtsson on 2012-11-01.
//
//

#import <Foundation/Foundation.h>
@class DTRenderState;

@interface DTRenderStateStack : NSObject
- (void)draw:(NSTimeInterval)delta;

@property(nonatomic,copy) NSArray *states;
- (void)pushState:(DTRenderState*)state;
- (void)popState;
@end

@interface DTRenderState : NSObject
@property(nonatomic,readonly,weak) DTRenderStateStack *stack;
- (id)initWithTarget:(id)target action:(SEL)action;
- (id)initWithBlock:(void(^)(NSTimeInterval delta))block;
- (void)draw:(NSTimeInterval)delta;
@end

@interface DTRenderStateAnimation : DTRenderState
// called with delta 0 when animation finishes
- (id)initWithTarget:(id)target action:(SEL)action duration:(NSTimeInterval)duration timingFunction:(id)notyet;
- (id)initWithBlock:(void(^)(NSTimeInterval delta))block duration:(NSTimeInterval)duration timingFunction:(id)notyet;
@end