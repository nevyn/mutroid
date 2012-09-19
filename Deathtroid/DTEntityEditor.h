#import <Cocoa/Cocoa.h>
#import "DTEntityTemplate.h"
#import "DTClient.h"
@protocol DTEntityEditorDelegate;

@interface DTEntityEditor : NSWindowController
- (id)initEditingTemplate:(DTEntityTemplate*)entity;
@property(readonly) DTEntityTemplate *entity;
@property NSUndoManager *undo;
@property DTClient *client;
@property id<DTEntityEditorDelegate> delegate;
@end

@protocol DTEntityEditorDelegate <NSObject>
- (void)editorClosed:(DTEntityEditor*)editor;
@end