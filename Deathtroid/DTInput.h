//
//  QSTInputSystem.h
//  Quest
//
//  Created by Per Borgman on 28/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface QSTInputMapping : NSObject {
@public
	//typedef struct {
	NSString	*name;		// Is shown in configmanager
	// And also used when loading config
	int			key;		// OS key
	BOOL		isSet;
	
	id			target;
	SEL			beginAction;
	SEL			endAction;
	//} InputMapping;
}

@end

@interface QSTInputMapper : NSObject {
	// Hm, could probably be a dictionary,
	// where key is the string.
	NSMutableArray	*mappings;
}

-(id)init;

// Called by engine, binds an action to a real selector
-(void)registerActionWithName:(NSString*)name action:(SEL)action target:(id)target;

// Used for actions that keep going until key is released
-(void)registerStateActionWithName:(NSString*)name beginAction:(SEL)begin endAction:(SEL)end target:(id)target;

// Called by Configuration Manager
-(void)mapKey:(int)key toAction:(NSString*)actionName;

// User presses a key
-(void)doInput:(int)key pressed:(BOOL)pressed;

@end

@interface DTInput : NSObject {
	QSTInputMapper *mapper;
}

@property (nonatomic,retain) QSTInputMapper *mapper;

-(void)pressedKey:(int)key repeated:(BOOL)repeated;
-(void)releasedKey:(int)key;

@end