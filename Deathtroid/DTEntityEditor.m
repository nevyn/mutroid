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

@implementation DTEntityEditor
- (id)initEditingTemplate:(DTEntityTemplate*)entity
{
    if(!(self = [super initWithWindowNibName:NSStringFromClass([self class])]))
        return nil;
    _entity = entity;
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
