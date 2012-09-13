#import "DTEntityTemplate.h"
#import "DTEntity.h"
#import "Vector2.h"
#import "DTEntityDummy.h"

@implementation DTEntityTemplate
- (id)init
{
    return [self initWithRep:nil];
}
- (id)initWithRep:(NSDictionary*)rep
{
    if(!(self = [super init]))
        return nil;
    
    self.klass = [DTEntityDummy class];
    self.position = [MutableVector2 new];
    self.uuid = [NSString dt_uuid];
    self.additionalAttributes = [NSMutableDictionary new];
    
    if(rep)
        [self updateFromRep:rep];
    
    return self;
}
- (void)updateFromRep:(NSDictionary*)rep
{
    NSMutableDictionary *mrep = [rep mutableCopy];
    self.klass = NSClassFromString(mrep[@"class"]); [mrep removeObjectForKey:@"class"];
    NSAssert(self.klass != Nil, @"Missing entity class, or unknown class");
    NSAssert([self.klass isSubclassOfClass:[DTEntity class]], @"Must be Entity subclass");
    
    self.uuid = mrep[@"uuid"]; [mrep removeObjectForKey:@"uuid"];
    NSAssert(self.uuid, @"Template must have 'uuid'");
    
    self.position = [[MutableVector2 alloc] initWithRep:mrep[@"position"]]; [mrep removeObjectForKey:@"position"];
    self.rotation = [mrep[@"rotation"] floatValue]; [mrep removeObjectForKey:@"rotation"];
    
    self.additionalAttributes = mrep.copy;
}
- (NSDictionary*)rep
{
    NSMutableDictionary *mrep = [self.additionalAttributes mutableCopy];
    mrep[@"class"] = NSStringFromClass(self.klass);
    mrep[@"uuid"] = self.uuid;
    mrep[@"position"] = self.position.rep;
    mrep[@"rotation"] = @(self.rotation);
    return mrep;
}

- (NSUInteger)count;
{
    return self.additionalAttributes.count + 4;
}
- (id)objectForKey:(id)aKey;
{
    if ([aKey isEqual:@"self"])
        return self;
    if ([aKey isEqual:@"rep"])
        return self.rep;
    return self.rep[aKey];
}
- (NSEnumerator *)keyEnumerator
{
    return self.rep.keyEnumerator;
}

- (void)removeObjectForKey:(id)aKey
{
    [_additionalAttributes removeObjectForKey:aKey];
}
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey
{
    if([(id)aKey isEqual:@"class"])
        self.klass = NSClassFromString(anObject);
    else if([(id)aKey isEqual:@"position"])
        NSBeep();
    else if([@[@"uuid", @"rotation"] containsObject:aKey])
        [self setValue:anObject forKey:(id)aKey];
    else
        [_additionalAttributes setObject:anObject forKey:aKey];
}
- (void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
}


@end
