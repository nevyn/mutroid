//
//  DTEntity.m
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTEntity.h"

#import "Vector2.h"
#import "DTWorld.h"
#import "DTServer.h"
#import "DTRoom.h"
#import "DTServerRoom.h"
#import "DTSpriteMap.h"
#import "DTResourceManager.h"
#import "DTAnimation.h"
#import "DTSound.h"

@implementation DTBBox
@synthesize min, max;
-(id)initWithMin:(MutableVector2*)_min max:(MutableVector2*)_max; {
    if(!(self = [super init])) return nil;
    min = _min;
    max = _max;
    return self;
}
-(id)initWithRep:(NSDictionary*)rep; {
    NSDictionary *minRep = [rep objectForKey:@"min"];
    NSDictionary *maxRep = [rep objectForKey:@"max"];
    MutableVector2 *_min = [MutableVector2 vectorWithX:[[minRep objectForKey:@"x"] floatValue] y:[[minRep objectForKey:@"y"] floatValue]];
    MutableVector2 *_max = [MutableVector2 vectorWithX:[[maxRep objectForKey:@"x"] floatValue] y:[[maxRep objectForKey:@"y"] floatValue]];
    return [self initWithMin:_min max:_max];
}
-(NSDictionary*)rep;
{
    return $dict(@"min", [min rep], @"max", [max rep]);
}
@end

@implementation DTEntity

@synthesize world, uuid;

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    _health = 1;
    _maxHealth = 1;
    _destructible = NO;
        
    _position = [MutableVector2 vectorWithX:5 y:1];
    _velocity = [MutableVector2 vectorWithX:0 y:0];
    _size = [[DTBBox alloc] initWithMin:[MutableVector2 vectorWithX:-0.4 y:-0.875] max:[MutableVector2 vectorWithX:0.4 y:0.875]];
    
    _collisionType = EntityCollisionTypeStop;
    _gravity = true;
    _moving = false;
    _onGround = false;

    _moveDirection = EntityDirectionRight;
    _lookDirection = EntityDirectionRight;
    
    self.rotation = 0.0;
    // currentState is used to specify what animation to use
    
    return self;
}
-(id)initWithRep:(NSDictionary*)rep world:(DTWorld*)world_ uuid:(NSString*)uuid_;
{
    Class klass = NSClassFromString([rep objectForKey:@"class"]);
    if(klass && ![klass isEqual:[self class]])
        self = [klass alloc];
    self.world = world_;
    self.uuid = uuid_;
    self = [self init];
    if(rep) [self updateFromRep:rep];
    return self;
}

-(id)updateFromRep:(NSDictionary*)rep;
{
    $doif(@"position", _position = [[MutableVector2 alloc] initWithRep:o]);
    $doif(@"velocity", _velocity = [[MutableVector2 alloc] initWithRep:o]);
    $doif(@"size", _size = [[DTBBox alloc] initWithRep:o]);
    
    $doif(@"gravity", _gravity = [o boolValue]);
    $doif(@"moving", _moving = [o boolValue]);
    $doif(@"onGround", _onGround = [o boolValue]);
    $doif(@"maxHealth", _maxHealth = [o intValue]);
    
    $doif(@"moveDirection", _moveDirection = [o intValue]);
    $doif(@"lookDirection", _lookDirection = [o intValue]);
    $doif(@"collisionType", _collisionType = [o intValue]);
    $doif(@"rotation", _rotation = [o floatValue]);
    
    $doif(@"templateUUID", _templateUUID = o);
    
    return self;
}
-(NSDictionary*)rep;
{
    NSMutableDictionary *rep = $mdict(
        @"class", NSStringFromClass([self class]),
        
        @"position", [_position rep],
        @"velocity", [_velocity rep],
        @"size", [_size rep],
        
        @"gravity", $num(_gravity),
        @"moving", $num(_moving),
        @"onGround", $num(_onGround),
        
        @"maxHealth", $num(_maxHealth),
        
        @"moveDirection", $num(_moveDirection),
        @"lookDirection", $num(_lookDirection),
        @"collisionType", $num(_collisionType),
        @"rotation", $num(_rotation)
    );
    if(_templateUUID)
        rep[@"templateUUID"] = _templateUUID;
    
    return rep;
}
+ (NSArray*)fieldDescriptors
{
    return @[
        DTFIELD(@"klass", Class),
        DTFIELD(@"position", Vector2),
        DTFIELD(@"velocity", Vector2),
        DTFIELD(@"maxHealth", Integer),
        DTFIELD(@"moveDirection", Direction),
        DTFIELD(@"lookDirection", Direction),
        DTFIELD(@"rotation", Float),
        DTFIELD(@"uuid", String)
    ];
}
+ (DTEntityFieldDescriptor*)descriptorForKey:(NSString*)key
{
    for(DTEntityFieldDescriptor *desc in self.fieldDescriptors) {
        if([desc.key isEqual:key])
            return desc;
    }
    return nil;
}

-(void)tick:(double)delta;
{    
    if(_damageFlashTimer > 0)
        _damageFlashTimer -= delta;
}

- (NSString*)currentState
{
    if(!_currentState)
        self.currentState = self.animation.animationNames[0];
    return _currentState;
}

-(void)didCollideWithWorld:(DTTraceResult*)info; {}

-(BOOL)damage:(int)damage from:(Vector2*)damagerLocation killer:(DTEntity *)killer;
{
    if(!_destructible) return NO;
    _health -= damage;
    _damageFlashTimer = 0.2;
    [world.server entityDamaged:self damage:damage location:damagerLocation killer:killer];
	if(_health < 0)
		[world.server entityWasKilled:self by:killer];
	return YES;
}

-(void)remove;
{
	NSAssert(self.world.server, @"May only be called on a server entity");
	[self.world.sroom destroyEntityKeyed:self.uuid];
}

-(void)sendToCounterpart:(NSDictionary*)hash;
{
	NSAssert(self.world.server, @"May only be called on a server entity");
	DTServerRoom *serverRoom = self.world.sroom;
	[serverRoom.delegate room:serverRoom sendsHash:hash toCounterpartsOf:self];
}
-(void)receivedFromCounterpart:(NSDictionary*)hash;
{
	NSLog(@"Unhandled counterpart message: %@", hash);
}

-(FISound*)makeVoice:(NSString*)soundName;
{
    DTSound *resource = [self.world.resources resourceNamed:$sprintf(@"%@.sound",soundName)];
    FISound *voice = [resource newVoice];
    voice.position = [FIVector vectorWithX:self.position.x Y:self.position.y Z:0];
    return voice;
}


-(NSString*)description;
{
    return $sprintf(@"<%@ %@/0x%p in %@>", NSStringFromClass([self class]), self.uuid, self, self.world.sroom.room);
}
-(NSString*)typeName;
{
	return [[[NSStringFromClass([self class]) componentsSeparatedByString:@"DTEntity"] objectAtIndex:1] lowercaseString];
}
@end

@implementation DTEntityFieldDescriptor
- (id)initKeyed:(NSString*)key type:(EntityFieldTypes)type
{
    if(!(self = [super init])) return nil;
    self.key = key;
    self.type = type;
    return self;
}
@end
