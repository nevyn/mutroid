//
//  Level.m
//  SuperJetpack
//
//  Created by Per Borgman on 1/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DTRoom.h"
#import "DTLayer.h"
#import "DTMap.h"
#import "DTWorld.h"

@interface DTRoom ()
@property (nonatomic,strong,readwrite) NSString *name;
@end

@implementation DTRoom

@synthesize layers = _layers;
@synthesize collisionLayer;
@synthesize name = _name;
@synthesize initialEntityReps;
@synthesize uuid;

- (id)initWithResourceId:(NSString *)rid
{
    if(!(self = [super initWithResourceId:rid])) return nil;
    
    _layers = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)saveToDisk
{
    id rep = @{
        @"collision": [self.collisionLayer rep],
        @"layers": [self.layers valueForKeyPath:@"rep"],
        @"entities": self.initialEntityReps,
    };
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:rep options:0 error:&err];
    NSAssert(data != nil, @"Failed serialization: %@", err);
    
    [data writeToURL:[[DTResourceManager sharedManager] pathForResourceNamed:self.resourceId] atomically:YES];
}

-(NSString*)description;
{
    return $sprintf(@"<%@ %@/0x%x '%@'>", NSStringFromClass([self class]), self.uuid, (int)self, self.name);
}
@end

@interface DTRoomLoader : DTResourceLoader
@end

@implementation DTRoomLoader

+(void)load{
	[DTResourceManager registerResourceLoader:self withTypeName:@"room"];
}

- (id<DTResource>)createResourceWithManager:(DTResourceManager *)manager
{	
	return [[DTRoom alloc] initWithResourceId:self.path.dt_resourceId];
}

- (BOOL)loadResource:(DTRoom *)room usingManager:(DTResourceManager *)manager error:(NSError *__autoreleasing *)error
{
    [room.layers removeAllObjects];
    NSArray *layerReps = $notNull([self.definition objectForKey:@"layers"]);
	for(NSDictionary *layerRep in layerReps)
        [room.layers addObject:[[DTLayer alloc] initWithRep:layerRep]];
    
    room.name = self.path.dt_resourceName;
    NSDictionary *collisionRep = $notNull([self.definition objectForKey:@"collision"]);
    room.collisionLayer = [[DTMap alloc] initWithRep:collisionRep];
    room.initialEntityReps = $notNull([self.definition objectForKey:@"entities"]);
    
    return YES;
}

@end
