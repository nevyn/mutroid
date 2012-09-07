//
//  Level.m
//  SuperJetpack
//
//  Created by Per Borgman on 1/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DTRoom.h"
#import "DTLayer.h"
#import "DTWorld.h"

@interface DTRoom ()
@property (nonatomic,strong,readwrite) NSString *name;
@end

@implementation DTRoom

@synthesize layers = _layers;
@synthesize entityLayerIndex;
@synthesize name = _name;
@synthesize initialEntityReps;
@synthesize uuid;
@synthesize world;
@synthesize entities;

-(id)initWithPath:(NSURL*)path resourceId:(NSString*)rid;
{
	if(!(self = [super initWithResourceId:rid])) return nil;
	
    _name = [path dt_resourceName];
	_layers = [NSMutableArray array];
    entities = [NSMutableDictionary dictionary];
    
    NSData *d = [NSData dataWithContentsOfURL:path];
    if(!d)
        return self = nil;

    NSError *err = nil;
    NSDictionary *rep = [NSJSONSerialization JSONObjectWithData:d options:0 error:&err];
    if(!rep) {
        [NSApp presentError:err];
        return self = nil;
    }
    
    NSArray *layerReps = $notNull([rep objectForKey:@"layers"]);
	for(NSDictionary *layerRep in layerReps)
        [_layers addObject:[[DTLayer alloc] initWithRep:layerRep]];
    
    entityLayerIndex = _layers.count-1;
    
    initialEntityReps = [rep objectForKey:@"entities"];
    
    world = [[DTWorld alloc] initWithRoom:self];
	
	return self;
}

-(void)tick:(float)delta {
	for(DTLayer *lay in _layers)
		[lay tick:delta];
}

/*
-(void)moveEntity:(MovingEntity*)anEntity toLayer:(int)layerNum {
	for(int l=0;l < [layers count];l++) {
		Layer *layer = [layers objectAtIndex:l];
		if(l==layerNum)
			[layer addEntity:anEntity];
		else
			[layer removeEntity:anEntity];
	}
}
*/
-(NSString*)description;
{
    return $sprintf(@"<%@ %@/0x%x '%@'>", NSStringFromClass([self class]), self.uuid, self, self.name);
}
@end

@interface DTRoomLoader : DTResourceLoader
@end

@implementation DTRoomLoader

+(void)load{
	[DTResourceManager registerResourceLoader:self withTypeName:@"room"];
}

-(id<DTResource>)loadResourceAtURL:(NSURL *)url usingManager:(DTResourceManager *)manager;
{
	[super loadResourceAtURL:url usingManager:manager];
	Class klass = manager.isServerSide ? NSClassFromString(@"DTServerRoom") : [DTRoom class];
	
	DTRoom *room = [[klass alloc] initWithPath:url resourceId:url.dt_resourceId];
	
	return room;
}

@end
