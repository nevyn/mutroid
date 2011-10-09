//
//  BlackBackgroundView.m
//  Deathtroid
//
//  Created by Joachim Bengtsson on 2011-10-09.
//  Copyright (c) 2011 Third Cog Software. All rights reserved.
//

#import "BlackBackgroundView.h"

@implementation BlackBackgroundView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor blackColor] set];
    NSRectFill(dirtyRect);
}

@end
