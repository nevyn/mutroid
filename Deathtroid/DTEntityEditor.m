//
//  DTEntityEditor.m
//  Deathtroid
//
//  Created by Joachim Bengtsson on 2012-09-13.
//
//

#import "DTEntityEditor.h"

@interface DTEntityEditor ()

@end

@implementation DTEntityEditor {
    NSMutableArray *_keys;
    IBOutlet NSTableView *_tableView;
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
    NSInteger col = [[tableView tableColumns] indexOfObject:tableColumn];

    NSString *key = [_keys objectAtIndex:row];
    if(col == 0)
        return key;
    if(col == 2)
        return [_entity valueForKey:key];
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSInteger col = [[tableView tableColumns] indexOfObject:tableColumn];
    NSString *key = [_keys objectAtIndex:row];
    
    if(col == 0) {
        if(row < 4)
            return;
        
        [self renameKey:key to:object onEntity:_entity];
        
    } else if(col == 2) {
        if([key isEqual:@"klass"])
            object = NSClassFromString(object);
    
        [self setProperty:object forKey:key onEntity:_entity];
    }
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

- (IBAction)undo:(id)sender
{
    [_undo undo];
}
- (IBAction)redo:(id)sender
{
    [_undo redo];
}

@end
