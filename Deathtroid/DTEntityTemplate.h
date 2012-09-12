#import <Foundation/Foundation.h>
@class MutableVector2;

/**
    @class DTEntityTemplate
    @abstract Template from which an entity can be instantiated.
    Used in the list of entities in a Room resource.
*/
@interface DTEntityTemplate : NSObject
- (id)init;
- (id)initWithRep:(NSDictionary*)rep;
- (void)updateFromRep:(NSDictionary*)rep;
- (NSDictionary*)rep;

@property Class klass;
@property NSString *uuid; // of the template, not the instance

@property MutableVector2 *position;
@property float rotation;
// all additional attributes
@property NSMutableDictionary *attributes;
@end
