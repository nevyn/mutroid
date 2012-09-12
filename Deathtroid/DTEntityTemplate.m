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
    self.attributes = [NSMutableDictionary new];
    
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
    
    self.attributes = mrep.copy;
}
- (NSDictionary*)rep
{
    NSMutableDictionary *mrep = [self.attributes mutableCopy];
    mrep[@"class"] = NSStringFromClass(self.klass);
    mrep[@"uuid"] = self.uuid;
    mrep[@"position"] = self.position.rep;
    mrep[@"rotation"] = @(self.rotation);
    return mrep.copy;
}
@end
