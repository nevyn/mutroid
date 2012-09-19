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
    
    self.additionalAttributes = [mrep mutableCopy];
    
    for(NSString *key in self.additionalAttributes.copy) {
        DTEntityFieldDescriptor *desc = [self.klass descriptorForKey:key];
        if(desc.type == EntityFieldVector2)
            [self.additionalAttributes setObject:[[MutableVector2 alloc] initWithRep:self.additionalAttributes[key]] forKey:key];
    }
}
- (NSDictionary*)rep
{
    NSMutableDictionary *mrep = [self.additionalAttributes mutableCopy];    
    for(NSString *key in mrep.copy) {
        DTEntityFieldDescriptor *desc = [self.klass descriptorForKey:key];
        if(desc.type == EntityFieldVector2)
            mrep[key] = [mrep[key] rep];
    }
    
    mrep[@"class"] = NSStringFromClass(self.klass);
    mrep[@"uuid"] = self.uuid;
    mrep[@"position"] = self.position.rep;
    mrep[@"rotation"] = @(self.rotation);

    return mrep;
}

- (id)valueForUndefinedKey:(NSString *)key
{
    return _additionalAttributes[key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    _additionalAttributes[key] = value;
}

@end
