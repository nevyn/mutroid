#import <Cocoa/Cocoa.h>
@class DTRoom, DTClient;

@interface DTRoomEditor : NSWindowController
- (id)initEditingRoom:(DTRoom*)room;
@property DTRoom *room;
@property DTClient *client;
@property NSUndoManager *undo;
@property (strong) IBOutlet NSArrayController *layersController;
@property (weak) IBOutlet NSTableView *layersTable;
@end
