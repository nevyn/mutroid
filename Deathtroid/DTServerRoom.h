//
//  DTServerRoom.h
//  Deathtroid
//
//  Created by Joachim Bengtsson on 2011-10-09.
//  Copyright (c) 2011 Third Cog Software. All rights reserved.
//

#import "DTWorldRoom.h"

@class DTEntity;
@class DTServerRoom;

@protocol DTServerRoomDelegate <NSObject>
-(void)room:(DTServerRoom*)room createdEntity:(DTEntity*)ent;
-(void)room:(DTServerRoom*)room destroyedEntity:(DTEntity*)ent;
-(void)room:(DTServerRoom*)room sendsHash:(NSDictionary*)hash toCounterpartsOf:(DTEntity*)ent;
@end


typedef void(^EntCtor)(DTEntity*);

@interface DTServerRoom : DTWorldRoom
@property(nonatomic,weak) id<DTServerRoomDelegate> delegate;
-(id)initWithRoom:(DTRoom*)room;
-(id)createEntity:(Class)class setup:(EntCtor)setItUp;
-(void)addEntityToRoom:(DTEntity*)ent;
-(void)destroyEntityKeyed:(NSString*)key;

-(NSDictionary*)diffFromState:(NSDictionary*)old toState:(NSDictionary*)new;
-(NSDictionary*)optimizeDelta:(NSDictionary*)new;
@end
