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
@property (strong) IBOutlet NSArrayController *layersController;
@end

@implementation DTRoomEditor
- (id)initEditingRoom:(DTRoom*)room;
{
    if(!(self = [super initWithWindowNibName:@"DTRoomEditor"]))
        return nil;
    _room = room;
    
    return self;
}
- (void)dealloc
{
    [_undo removeAllActionsWithTarget:self];
}
- (void)windowDidLoad
{
    self.window.title = [NSString stringWithFormat:@"Editing %@", _room.name];
    [self tableViewSelectionDidChange:nil];
}
- (DTLayer*)selectedLayer
{
    if(_layersTable.selectedRow == -1)
        return nil;
    return [[_room layers] objectAtIndex:_layersTable.selectedRow];
}

- (IBAction)newLayer:(id)sender
{
    [self addLayer:[DTLayer new] atIndex:_room.layers.count];
}
- (IBAction)removeSelectedLayer:(id)sender
{
    [self removeLayer:[self selectedLayer]];
}
- (void)addLayer:(DTLayer*)layer atIndex:(NSInteger)index
{
    if(!layer) return;
    [[_undo prepareWithInvocationTarget:self] removeLayer:layer];
    [_room.layers insertObject:layer atIndex:index];
}
- (void)removeLayer:(DTLayer*)layer
{
    if(!layer) return;
    [[_undo prepareWithInvocationTarget:self] addLayer:layer atIndex:[_room.layers indexOfObject:layer]];
    [_room.layers removeObject:layer];
}

- (IBAction)moveLayerUp:(id)sender
{
    [self moveLayerUpAction:[self selectedLayer]];
}
- (IBAction)moveLayerDown:(id)sender
{
    [self moveLayerDownAction:[self selectedLayer]];
}
- (void)moveLayerUpAction:(DTLayer*)layer
{
    if(!layer) return;
    
    NSInteger oldIndex = [_room.layers indexOfObject:layer];
    if(oldIndex == 0) return;
    
    [[_undo prepareWithInvocationTarget:self] moveLayerDownAction:layer];
    
    [_room.layers removeObject:layer];
    [_room.layers insertObject:layer atIndex:oldIndex-1];
    
    [_layersController setSelectionIndex:oldIndex-1];
}
- (void)moveLayerDownAction:(DTLayer*)layer
{
    if(!layer) return;
    
    NSInteger oldIndex = [_room.layers indexOfObject:layer];
    if(oldIndex == _room.layers.count-1) return;
    
    [[_undo prepareWithInvocationTarget:self] moveLayerUpAction:layer];
    
    [_room.layers removeObject:layer];
    [_room.layers insertObject:layer atIndex:oldIndex+1];
    
    [_layersController setSelectionIndex:oldIndex+1];
}

- (IBAction)updateLayerSize:(id)sender
{
    [self updateLayer:[self selectedLayer] width:_widthCell.intValue height:_heightCell.intValue];
}
- (void)updateLayer:(DTLayer*)layer width:(int)width height:(int)height
{
    if(!layer || width == 0 || height == 0) return;
    
    [[_undo prepareWithInvocationTarget:self] updateLayer:layer width:layer.map.width height:layer.map.height];
    DTMap *map = self.selectedLayer.map;
    [map setWidth:width height:height];
    
    if(map.width > _room.collisionLayer.width || map.height > _room.collisionLayer.height) {
        [_room.collisionLayer
            setWidth:MAX(map.width, _room.collisionLayer.width)
            height:MAX(map.height, _room.collisionLayer.height)];
    }

}

#pragma mark Table view
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)col row:(NSInteger)row
{
    if(col == _colIndex) return @(row+1);
    return nil;
}

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)col row:(NSInteger)row
{
    if(col == _colTileset) {
        NSComboBoxCell *cell = [col dataCellForRow:row];
        [cell setEditable:YES];
        [cell removeAllItems];
        for(NSString *setName in [[DTResourceManager sharedManager] namesOfLocalResourcesOfType:@"image"])
            [cell addItemWithObjectValue:[setName dt_resourceName]];
        return cell;
    }
    
    return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification;
{
    _widthCell.intValue = [self selectedLayer].map.width;
    _heightCell.intValue = [self selectedLayer].map.height;
}

@end
