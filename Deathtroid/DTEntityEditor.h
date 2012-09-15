#import <Cocoa/Cocoa.h>
#import "DTEntityTemplate.h"
#import "DTClient.h"

@interface DTEntityEditor : NSWindowController
- (id)initEditingTemplate:(DTEntityTemplate*)entity;
@property(readonly) DTEntityTemplate *entity;
@property NSUndoManager *undo;
@property DTClient *client;
@end
