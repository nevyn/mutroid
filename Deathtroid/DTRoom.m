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
#import "DTEntityTemplate.h"

@interface DTRoom () <DTMapDelegate>
@property (nonatomic,strong,readwrite) NSString *name;
@end

@implementation DTRoom {
    NSMutableArray *_layerArray;
}

@synthesize collisionLayer;
@synthesize name = _name;
@synthesize uuid;

- (id)initWithResourceId:(NSString *)rid
{
    if(!(self = [super initWithResourceId:rid])) return nil;
    
    _layerArray = [[NSMutableArray alloc] init];
    _entityTemplates = [NSMutableDictionary dictionary];
    self.collisionLayer = [DTMap new];
    self.collisionLayer.delegate = self;
    
    return self;
}

- (id)rep
{
    return @{
        @"collision": [self.collisionLayer rep],
        @"layers": [self.layers valueForKeyPath:@"rep"],
        @"entities": [self.entityTemplates.allValues valueForKeyPath:@"rep"],
    };
}

-(NSString*)description;
{
    return $sprintf(@"<%@ %@/0x%x '%@'>", NSStringFromClass([self class]), self.uuid, (int)self, self.name);
}

#pragma mark Layers KVOable
@dynamic layers;
-(void)forwardInvocation:(NSInvocation *)invocation {
  if ([invocation selector] == @selector(layers)) {
    id value = [self mutableArrayValueForKey:@"layers"];
    [invocation setReturnValue:&value];
  }
}
-(NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
  if (sel == @selector(layers)) {
    return [super methodSignatureForSelector:@selector(valueForKey:)];
  } else {
    return [super methodSignatureForSelector:sel];
  }
}
- (NSUInteger)countOfLayers
{
    return [_layerArray count];
}
- (DTLayer*)objectInLayersAtIndex:(NSUInteger)index
{
    return _layerArray[index];
}
- (void)insertObject:(DTLayer *)layer inLayersAtIndex:(NSUInteger)index
{
    [_layerArray insertObject:layer atIndex:index];
    layer.map.delegate = self;
}
- (void)removeObjectFromLayersAtIndex:(NSUInteger)index
{
    [_layerArray[index] map].delegate = nil;
    [_layerArray removeObjectAtIndex:index];
}
- (void)attrOrTileChangedInMap:(DTMap *)map
{
    [_delegate roomChanged:self];
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
    NSArray *layerReps = $notNull([self.definition objectForKey:@"layers"]);
    int i = 0;
	for(NSDictionary *layerRep in layerReps) {
        if(room.layers.count <= i)
            [room.layers addObject:[DTLayer new]];
        [room.layers[i] updateFromRep:layerRep];
        i++;
    }
    
    room.name = self.path.dt_resourceName;
    NSDictionary *collisionRep = $notNull([self.definition objectForKey:@"collision"]);
    [room.collisionLayer updateFromRep:collisionRep];
    
    NSMutableSet *encounteredTemplateUuids = [NSMutableSet set];
    for(NSDictionary *templateRep in $notNull([self.definition objectForKey:@"entities"])) {
        DTEntityTemplate *template = [room.entityTemplates objectForKey:templateRep[@"uuid"]];
        if(!template) {
            template = [[DTEntityTemplate alloc] initWithRep:templateRep];
            [room.entityTemplates setObject:template forKey:template.uuid];
        } else {
            [template updateFromRep:templateRep];
        }
        [encounteredTemplateUuids addObject:template.uuid];
    }
    NSMutableSet *toRemove = [NSMutableSet setWithArray:room.entityTemplates.allKeys];
    [toRemove minusSet:encounteredTemplateUuids];
    for(NSString *uuid in toRemove)
        [room.entityTemplates removeObjectForKey:uuid];
    
    return YES;
}

- (void)saveResource:(DTRoom*)room
{
    [self writeDefinition:room.rep];
}

@end
