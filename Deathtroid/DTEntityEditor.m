//
//  DTEntityEditor.m
//  Deathtroid
//
//  Created by Joachim Bengtsson on 2012-09-13.
//
//

#import "DTEntityEditor.h"
#import <MAObjCRuntime/MARTNSObject.h>
#import "DTEntity.h"
#import "Vector2.h"

@interface DTEntityEditor ()

@end

@implementation DTEntityEditor {
    NSMutableArray *_keys;
    IBOutlet NSTableView *_tableView;
    IBOutlet __weak NSTableColumn *_keyColumn;
    IBOutlet __weak NSTableColumn *_valueColumn;
}
- (id)initEditingTemplate:(DTEntityTemplate*)entity
{
    if(!(self = [super initWithWindowNibName:NSStringFromClass([self class])]))
        return nil;
    _entity = entity;
    _keys = @[@"klass", @"uuid", @"position", @"rotation"].mutableCopy;
    [_keys addObjectsFromArray:_entity.additionalAttributes.allKeys];
    return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _entity.additionalAttributes.count + 4;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *key = [_keys objectAtIndex:row];
    if(tableColumn == _keyColumn)
        return key;
    if(tableColumn == _valueColumn)
        return [_entity valueForKey:key];
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *key = [_keys objectAtIndex:row];
    DTEntityFieldDescriptor *descriptor = [self descriptorForRow:row];
    
    if(tableColumn == _keyColumn) {
        if(row < 4)
            return;
        
        [self renameKey:key to:object onEntity:_entity];
        
    } else if(tableColumn == _valueColumn) {
        if(descriptor.type == EntityFieldClass)
            object = NSClassFromString(object);
        else if(descriptor.type == EntityFieldVector2) {
            NSArray *comps = [[[object stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""] componentsSeparatedByString:@", "];
            object = [MutableVector2 vectorWithX:[comps[0] floatValue] y:[comps[1] floatValue]];
        }
    
        [self setProperty:object forKey:key onEntity:_entity];
    }
}

- (DTEntityFieldDescriptor*)descriptorForRow:(NSInteger)row
{
    return [_entity.klass descriptorForKey:_keys[row]];
}

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if(tableColumn == _valueColumn) {
        switch ([self descriptorForRow:row].type) {
            case EntityFieldClass: {
                NSComboBoxCell *cell = [[NSComboBoxCell alloc] initTextCell:@""];
                [cell setButtonBordered:NO];
                cell.bordered = NO;
                for(Class klass in [DTEntity rt_subclasses])
                    [cell addItemWithObjectValue:NSStringFromClass(klass)];
                
                return cell;
            }
            case EntityFieldFloat:
            case EntityFieldInteger:
            case EntityFieldDirection: {
                NSTextFieldCell *cell = [tableColumn dataCellForRow:row];
                cell.objectValue = [self tableView:tableView objectValueForTableColumn:tableColumn row:row];
                cell.formatter = [[NSNumberFormatter alloc] init];
                //[(id)cell.formatter setGeneratesDecimalNumbers:YES];
                return cell;
            }
            default: { // normal text cell
                id cell = [tableColumn dataCellForRow:row];
                if([cell respondsToSelector:@selector(setFormatter:)])
                    [cell setFormatter:nil];
                return cell;
            }
        }
    }
    
    return nil;
}

- (void)setProperty:(id)property forKey:(NSString*)key onEntity:(DTEntityTemplate*)entity
{
    //[[_undo prepareWithInvocationTarget:self] setProperty:[_entity valueForKey:key] forKey:key onEntity:entity];
    [entity setValue:property forKey:key];
    if(![_keys containsObject:key])
        [_keys addObject:key];
    [_tableView reloadData];
}

- (void)renameKey:(NSString*)key to:(NSString*)newKey onEntity:(DTEntityTemplate*)entity
{
    //[[_undo prepareWithInvocationTarget:self] renameKeynewKey to:key onEntity:entity];
    if([_keys containsObject:newKey]) {
        NSBeep();
        return;
    }
    NSMutableDictionary *d = [_entity additionalAttributes];
    d[newKey] = d[key];
    [d removeObjectForKey:key];
    [_keys replaceObjectAtIndex:[_keys indexOfObject:key] withObject:newKey];
    
    [_tableView reloadData];
}
- (void)addNewKey:(NSString*)key
{
    //[[_undo prepareWithInvocationTarget:self] removeKey:key];
    [_entity additionalAttributes][key] = @(0);
    [_keys addObject:key];
    [_tableView reloadData];
}
- (void)removeKey:(NSString*)key
{
    //id oldValue = [_entity valueForKey:key];
    //[[_undo prepareWithInvocationTarget:self] setProperty:oldValue forKey:key onEntity:_entity];
    [[_entity additionalAttributes] removeObjectForKey:key];
    [_keys removeObject:key];
    [_tableView reloadData];
}

- (IBAction)add:(id)sender
{
    NSString *suggestedName; int i = 0;
    do {
        suggestedName = $sprintf(@"undefined_%d", i++);
    } while([[_entity additionalAttributes] objectForKey:suggestedName] != nil);
    [self addNewKey:suggestedName];
}
- (IBAction)remove:(id)sender
{
    [self removeKey:_keys[[_tableView selectedRow]]];
}
- (IBAction)reload:(id)sender
{
    [_client reloadEntityForTemplateUUID:_entity.uuid];
}
- (IBAction)undo:(id)sender
{
    [_undo undo];
}
- (IBAction)redo:(id)sender
{
    [_undo redo];
}

@end
