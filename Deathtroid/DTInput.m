//
//  QSTInputSystem.m
//  Quest
//
//  Created by Per Borgman on 28/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DTInput.h"

@implementation QSTInputMapping {
	
}

@end


@implementation QSTInputMapper

-(id)init {
	[super init];
		
	mappings = [[NSMutableArray array] retain];
	
	return self;
}

-(void)registerActionWithName:(NSString*)name action:(SEL)action target:(id)target {
	[self registerStateActionWithName:name beginAction:action endAction:nil target:target];
}

-(void)registerStateActionWithName:(NSString*)name beginAction:(SEL)begin endAction:(SEL)end target:(id)target {
	//InputMapping newMap;
	//newMap.name = name;
	//newMap.key = 0;
	//newMap.isSet = NO;
	//newMap.target = target;
	//newMap.beginAction = begin;
	//newMap.endAction = end;
	//[mappings addObject:[NSValue value:&newMap withObjCType:@encode(InputMapping)]];
	
	QSTInputMapping *newMap = [[QSTInputMapping alloc] init];
	newMap->name = name;
	newMap->key = 0;
	newMap->isSet = NO;
	newMap->target = target;
	newMap->beginAction = begin;
	newMap->endAction = end;
	[mappings addObject:newMap];
	[newMap release];
}

-(void)mapKey:(int)key toAction:(NSString*)actionName {
	for(QSTInputMapping *mapping in mappings) {
		//for(NSValue *mappingWrap in mappings) {
		//InputMapping mapping;
		//[mappingWrap getValue:&mapping];
		
		if([actionName isEqualToString:mapping->name]) {
			mapping->key = key;
			mapping->isSet = YES;
			return;
		}
	}
}

-(void)doInput:(int)key pressed:(BOOL)pressed {
	// Should probably add some quick test here to see
	// if key is in the array. Optimization!
	
	for(QSTInputMapping *mapping in mappings) {
		//for(NSValue *mappingWrap in mappings) {
		//InputMapping mapping;
		//[mappingWrap getValue:&mapping];
		
		if(mapping->key == key) {			
			if(pressed && mapping->beginAction != nil)
				[mapping->target performSelector:mapping->beginAction];
			else if (!pressed && mapping->endAction != nil)
				[mapping->target performSelector:mapping->endAction];
		}
	}
}

@end

@implementation DTInput

@synthesize mapper;

-(id)init {
	if(![super init]) return nil;
	return self;
}

-(void)pressedKey:(int)key repeated:(BOOL)repeated {
	[mapper doInput:key pressed:YES];
}

-(void)releasedKey:(int)key {
	[mapper doInput:key pressed:NO];
}

@end