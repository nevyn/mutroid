//
//  DTServerRoom.m
//  Deathtroid
//
//  Created by Joachim Bengtsson on 2011-10-09.
//  Copyright (c) 2011 Third Cog Software. All rights reserved.
//

#import "DTServerRoom.h"
#import "DTEntity.h"

@implementation DTServerRoom {
    NSDictionary *previousDelta;
}
@synthesize delegate;
-(id)initWithPath:(NSURL *)path;
{
    if(!(self = [super initWithPath:path])) return nil;
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    self.uuid = (__bridge_transfer NSString*)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    
    return self;
}
-(id)createEntity:(Class)class setup:(EntCtor)setItUp;
{
    DTEntity *ent = [[class alloc] init];
    ent.world = self.world;
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidS = (__bridge_transfer NSString*)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    ent.uuid = uuidS;
    
    [self.entities setObject:ent forKey:uuidS];
    
    if(setItUp) setItUp(ent);
    
    [self.delegate room:self createdEntity:ent];

    return ent;
}
-(void)destroyEntityKeyed:(NSString*)key;
{
    DTEntity *ent = [self.entities objectForKey:key];
    [self.entities removeObjectForKey:key];
    [self.delegate room:self destroyedEntity:ent];
}

-(NSDictionary*)optimizeDelta:(NSDictionary*)new;
{
    // todo: Save old delta, remove any attrs that haven't changed
    NSDictionary *old = previousDelta;
    previousDelta = new;
    
    if(!old) return new;
    
    NSMutableDictionary *slimmed = [NSMutableDictionary dictionaryWithCapacity:new.count];
    
    for(NSString *uuid in new.allKeys) {
        NSDictionary *oldRep = [old objectForKey:uuid];
        NSDictionary *newRep = [new objectForKey:uuid];
        if(!oldRep) { [slimmed setObject:newRep forKey:uuid]; break; }
        
        NSMutableDictionary *onlyChangedKeys = [NSMutableDictionary dictionaryWithCapacity:newRep.count];
        for(NSString *attr in newRep.allKeys)
            if(![[oldRep objectForKey:attr] isEqual:[newRep objectForKey:attr]])
                [onlyChangedKeys setObject:[newRep objectForKey:attr] forKey:attr];
        
        if(onlyChangedKeys.count > 0)
            [slimmed setObject:onlyChangedKeys forKey:uuid];
    }
    
    return slimmed;
}
@end
