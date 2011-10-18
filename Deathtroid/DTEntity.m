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

@implementation DTEntity

@synthesize world, uuid;
@synthesize position, velocity, size, moveDirection, lookDirection, collisionType, gravity, moving, onGround, health, destructible;
@synthesize damageFlashTimer, maxHealth;
@synthesize animation, rotation, currentState;

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    health = 1;
    maxHealth = 1;
    destructible = NO;
        
    position = [MutableVector2 vectorWithX:5 y:1];
    velocity = [MutableVector2 vectorWithX:0 y:0];
    size = [MutableVector2 vectorWithX:0.8 y:1.75];
    
    collisionType = EntityCollisionTypeStop;
    gravity = true;
    moving = false;
    onGround = false;
    
    moveDirection = EntityDirectionRight;
    lookDirection = EntityDirectionRight;
    
    DTResourceManager *resourceManager = [[DTResourceManager alloc] initWithBaseURL:[[NSBundle mainBundle] URLForResource:@"resources" withExtension:nil]];

    self.animation = [resourceManager animationNamed:@"sten.animation"];
    self.rotation = 0.0;
    self.currentState = @"walking-right"; // This is used to specify what animation to use
    
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
    $doif(@"position", position = [[MutableVector2 alloc] initWithRep:o]);
    $doif(@"velocity", velocity = [[MutableVector2 alloc] initWithRep:o]);
    $doif(@"size", size = [[MutableVector2 alloc] initWithRep:o]);
    
    $doif(@"gravity", gravity = [o boolValue]);
    $doif(@"moving", moving = [o boolValue]);
    $doif(@"onGround", onGround = [o boolValue]);
    $doif(@"maxHealth", maxHealth = [o intValue]);
    
    $doif(@"moveDirection", moveDirection = [o intValue]);
    $doif(@"lookDirection", lookDirection = [o intValue]);
    $doif(@"collisionType", collisionType = [o intValue]);
    
    return self;
}
-(NSDictionary*)rep;
{
    NSMutableDictionary *rep = $mdict(
        @"class", NSStringFromClass([self class]),
        
        @"position", [position rep],
        @"velocity", [velocity rep],
        @"size", [size rep],
        
        @"gravity", $num(gravity),
        @"moving", $num(moving),
        @"onGround", $num(onGround),
        
        @"maxHealth", $num(maxHealth),
        
        @"moveDirection", $num(moveDirection),
        @"lookDirection", $num(lookDirection),
        @"collisionType", $num(collisionType)
    );
    
    return rep;
}

-(void)tick:(double)delta;
{    
    if(damageFlashTimer > 0)
        damageFlashTimer -= delta;
}

-(void)didCollideWithWorld:(DTTraceResult*)info; {}

-(BOOL)damage:(int)damage from:(Vector2*)damagerLocation killer:(DTEntity *)killer;
{
    if(!destructible) return NO;
    health -= damage;
    damageFlashTimer = 0.2;
    [world.server entityDamaged:self damage:damage location:damagerLocation killer:killer];
	if(health < 0)
		[world.server entityWasKilled:self by:killer];
	return YES;
}

-(void)remove;
{
	NSAssert(self.world.server, @"May only be called on a server entity");
	[$cast(DTServerRoom, self.world.room) destroyEntityKeyed:self.uuid];
}

-(void)sendToCounterpart:(NSDictionary*)hash;
{
	NSAssert(self.world.server, @"May only be called on a server entity");
	DTServerRoom *serverRoom = $cast(DTServerRoom, self.world.room);
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
    return $sprintf(@"<%@ %@/0x%x in %@>", NSStringFromClass([self class]), self.uuid, self, self.world.room);
}
-(NSString*)typeName;
{
	return [[[NSStringFromClass([self class]) componentsSeparatedByString:@"DTEntity"] objectAtIndex:1] lowercaseString];
}
@end
