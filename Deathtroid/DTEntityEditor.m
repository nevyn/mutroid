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
    if(row < 4 && col == 0)
        return;
    
    NSString *key = [_keys objectAtIndex:row];
    
    if([key isEqual:@"klass"])
        object = NSClassFromString(object);
    
    [self setProperty:object forKey:key onEntity:_entity];
}

- (void)setProperty:(id)property forKey:(NSString*)key onEntity:(DTEntityTemplate*)entity
{
    //[[_undo prepareWithInvocationTarget:self] setProperty:[_entity valueForKey:key] forKey:key onEntity:entity];
    [entity setValue:property forKey:key];
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
