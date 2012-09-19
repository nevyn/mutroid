#import <Cocoa/Cocoa.h>
@class DTRoom;

@interface DTRoomEditor : NSWindowController
- (id)initEditingRoom:(DTRoom*)room;
@property DTRoom *room;
@end
