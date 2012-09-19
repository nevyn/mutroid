#import "DTRoomEditor.h"
#import "DTRoom.h"
#import "DTLayer.h"
#import "DTMap.h"

@interface DTRoomEditor ()
@property (weak) IBOutlet NSTableView *layersTable;
@property (weak) IBOutlet NSFormCell *widthCell;
@property (weak) IBOutlet NSFormCell *heightCell;
@property (weak) IBOutlet NSTableColumn *colIndex;
@property (weak) IBOutlet NSTableColumn *colFg;
@property (weak) IBOutlet NSTableColumn *colRepX;
@property (weak) IBOutlet NSTableColumn *colRepY;
@property (weak) IBOutlet NSTableColumn *colDepth;
@property (weak) IBOutlet NSTableColumn *colTileset;

@end

@implementation DTRoomEditor
- (id)initEditingRoom:(DTRoom*)room;
{
    if(!(self = [super initWithWindowNibName:@"DTRoomEditor"]))
        return nil;
    _room = room;
    return self;
}
- (DTLayer*)selectedLayer
{
    if(_layersTable.selectedRow == -1)
        return nil;
    return [[_room layers] objectAtIndex:_layersTable.selectedRow];
}
- (IBAction)newLayer:(id)sender {
}
- (IBAction)removeSelectedLayer:(id)sender {
}
- (IBAction)moveLayerUp:(id)sender {
}
- (IBAction)moveLayerDown:(id)sender {
}
- (IBAction)updateLayerSize:(id)sender
{
    DTMap *map = self.selectedLayer.map;
    [map setWidth:_widthCell.intValue height:_heightCell.intValue];
    if(map.width > _room.collisionLayer.width || map.height > _room.collisionLayer.height) {
        [_room.collisionLayer
            setWidth:MAX(map.width, _room.collisionLayer.width)
            height:MAX(map.height, _room.collisionLayer.height)];
    }
}

#pragma mark Table view
/*- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)col row:(NSInteger)row
{
    DTLayer *lay = [[_room layers] objectAtIndex:row];
    if(col == _colIndex) return @(row+1);
    if(col == _colFg) return @(lay.foreground);
    if(col == _colRepX) return @(lay.repeatX);
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{

}

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{

    
    return nil;
}*/


@end
