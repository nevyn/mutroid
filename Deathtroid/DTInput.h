//
//  QSTInputSystem.h
//  Quest
//
//  Created by Per Borgman on 28/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void(^DTInputCallback)();

@interface DTInputMapping : NSObject {
@public
	//typedef struct {
	NSString	*name;		// Is shown in configmanager
	// And also used when loading config
	int			key;		// OS key
	BOOL		isSet;
	    
    DTInputCallback begin;
    DTInputCallback end;
	//} InputMapping;
}

@end

@interface DTInputMapper : NSObject {
	// Hm, could probably be a dictionary,
	// where key is the string.
	NSMutableArray	*mappings;
}

-(id)init;

// Called by engine, binds an action to a real selector
-(void)registerActionWithName:(NSString*)name action:(DTInputCallback)action;

// Used for actions that keep going until key is released
-(void)registerStateActionWithName:(NSString*)name beginAction:(DTInputCallback)begin endAction:(DTInputCallback)end;

// Called by Configuration Manager
-(void)mapKey:(int)key toAction:(NSString*)actionName;

// User presses a key
-(void)doInput:(int)key pressed:(BOOL)pressed;

@end

@interface DTInput : NSObject {
	DTInputMapper *mapper;
}

@property (nonatomic,retain) DTInputMapper *mapper;

-(void)pressedKey:(int)key repeated:(BOOL)repeated;
-(void)releasedKey:(int)key;

@end