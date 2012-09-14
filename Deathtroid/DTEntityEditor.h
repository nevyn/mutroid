#import <Cocoa/Cocoa.h>
#import "DTEntityTemplate.h"

@interface DTEntityEditor : NSWindowController
- (id)initEditingTemplate:(DTEntityTemplate*)entity;
@property(readonly) DTEntityTemplate *entity;
@property NSUndoManager *undo;
@end
