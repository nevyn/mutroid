//
//  QSTInputSystem.m
//  Quest
//
//  Created by Per Borgman on 28/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DTInput.h"

@implementation DTInputMapping {
	
}

@end


@implementation DTInputMapper

-(id)init {
	if(!(self = [super init])) return nil;
		
	mappings = [NSMutableArray array];
	
	return self;
}

-(void)registerActionWithName:(NSString*)name action:(DTInputCallback)action;
{
	[self registerStateActionWithName:name beginAction:action endAction:nil];
}

-(void)registerStateActionWithName:(NSString*)name beginAction:(DTInputCallback)begin endAction:(DTInputCallback)end;
{	
	DTInputMapping *newMap = [[DTInputMapping alloc] init];
	newMap->name = name;
	newMap->key = 0;
	newMap->isSet = NO;
    
    newMap->begin = begin;
    newMap->end = end;
    
	[mappings addObject:newMap];
}

-(void)mapKey:(int)key toAction:(NSString*)actionName {
	for(DTInputMapping *mapping in mappings) {
		if([actionName isEqualToString:mapping->name]) {
			mapping->key = key;
			mapping->isSet = YES;
			return;
		}
	}
}

-(void)doInput:(int)key pressed:(BOOL)pressed {
	for(DTInputMapping *mapping in mappings) {
		if(mapping->key == key) {			
			if(pressed && mapping->begin != nil)
                mapping->begin();
			else if (!pressed && mapping->end != nil)
                mapping->end();
		}
	}
}

@end

@implementation DTInput

@synthesize mapper;

-(id)init {
	if(!(self = [super init])) return nil;
    
    mapper = [[DTInputMapper alloc] init];
    
	return self;
}

-(void)pressedKey:(int)key repeated:(BOOL)repeated {
    if(repeated) return;
	[mapper doInput:key pressed:YES];
}

-(void)releasedKey:(int)key {
	[mapper doInput:key pressed:NO];
}

@end