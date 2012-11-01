//
//  DTClient.m
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTClient.h"
#import "TCAsyncHashProtocol.h"
#import <OpenGL/gl.h>

#import "DTRoom.h"
#import "DTLayer.h"
#import "DTMap.h"
#import "DTEntity.h"
#import "Vector2.h"
#import "DTCamera.h"
#import "DTPhysics.h"
#import "DTWorld.h"
#import "DTEntity.h"
#import "DTEntityPlayer.h"
#import "DTWorldRoom.h"
#import "DTCore.h"

#import "DTResourceManager.h"
#import "DTTexture.h"
#import "DTProgram.h"
#import "DTSpriteMap.h"
#import "DTRenderEntities.h"
#import "DTRenderTilemap.h"

#import "FISoundEngine.h"
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

static const float kRoomTransitionTime = 1;

@interface DTClient () <TCAsyncHashProtocolDelegate, DTRoomDelegate>
@property (nonatomic, strong) DTResourceManager *resources;
@end

@implementation DTClient {
	TCAsyncHashProtocol *_proto;
    __weak DTEntity *followThis;
	uint64_t frameCount;
	
	DTRenderEntities *entityRenderer;
	DTRenderTilemap *tilemapRenderer;
    FISoundEngine *finch;
    NSMutableDictionary *_visibleLayers;
    
    // If set, we're currently transitioning to the new room
    DTWorldRoom *_oldRoom;
    DTCamera *_oldCamera;
    float _oldRoomTransitionTimer;
    EntityDirection _transitionDirection;
    void(^_transitionDone)();
}
@synthesize physics;
@synthesize rooms, playerEntity;
@synthesize camera;
@synthesize resources, healthCallback, scoresCallback, messageCallback;

-(id)init;
{
    return [self initConnectingTo:@"localhost" port:kDTServerDefaultPort];
}
-(id)initConnectingTo:(NSString *)host port:(NSUInteger)port;
{
    if(!(self = [super init])) return nil;
    
    finch = [FISoundEngine new];
    [finch openAudioDevice];
	
	self.resources = [DTResourceManager sharedManager];
	
    entityRenderer = [DTRenderEntities new];
	tilemapRenderer = [DTRenderTilemap new];
	
	AsyncSocket *socket = [[AsyncSocket alloc] initWithDelegate:self];
	socket.delegate = _proto = [[TCAsyncHashProtocol alloc] initWithSocket:socket delegate:self];
	NSError *err = nil;
	if(![socket connectToHost:host onPort:port error:&err]) {
		[NSApp presentError:err];
		return nil;
	}
    
    rooms = [NSMutableDictionary dictionary];
    
    
    glDisable(GL_DEPTH_TEST);
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
    
    glDisable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    
    glActiveTexture(GL_TEXTURE0);
    
    glPointSize(5.0f);
    
    glLineWidth(1);
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    
    // Build shader programs
    //[resources resourceNamed:@"main.program"];
    
    camera = [[DTCamera alloc] init];
    
#if DUMB_CLIENT
    physics = nil;
#else
    physics = [[DTPhysics alloc] init];
#endif
    
    _visibleLayers = [NSMutableDictionary dictionaryWithCapacity:10];
    
    return self;
}

-(void)tick:(double)delta;
{
    // Ticka de som ska tickas?
    
    if(followThis)
        [camera setPositionFromEntity:followThis.position];
    [camera clampToRoom:_currentRoom.room];
    
    finch.listenerPosition = [FIVector vectorWithX:camera.position.x+8 Y:camera.position.y+7 Z:1];
    
    [_currentRoom tick:delta];
    
    for(DTEntity *entity in _currentRoom.entities.allValues)
        [entity tick:delta];
    
    if(_currentRoom.world)
        [physics runWithEntities:_currentRoom.entities.allValues world:_currentRoom.world delta:delta];
        
    if(self.healthCallback) self.healthCallback(followThis.maxHealth, followThis.health);
    
    for(DTEntity *entity in _currentRoom.entities.allValues)
        [entityRenderer tick:delta forEntity:entity];
}

-(void)draw;
{
	frameCount++;
	
    glClear(GL_COLOR_BUFFER_BIT);
    glLoadIdentity();
    
    glTranslatef(0, 2, 0);
    
    if(_oldRoomTransitionTimer > 0) {
        Vector2 *roomDisplacement = [EntityDirectionToUnitVector(_transitionDirection) vectorByMultiplyingWithScalar:kScreenWidthInTiles];
        Vector2 *offset = [[roomDisplacement invertedVector] vectorByMultiplyingWithScalar:_oldRoomTransitionTimer/kRoomTransitionTime];
        glTranslatef(offset.x, offset.y, 0);
        
        // Old room
        glPushMatrix();
        glTranslatef(roomDisplacement.x, roomDisplacement.y, 0);
        for(DTLayer *layer in _oldRoom.room.layers) {
            [tilemapRenderer drawLayer:layer camera:_oldCamera fromWorldRoom:_oldRoom];
        }
        glPopMatrix();
        
        // New room
        for(DTLayer *layer in _currentRoom.room.layers) {
            [tilemapRenderer drawLayer:layer camera:camera fromWorldRoom:_currentRoom];
        }
    }

	// Background layers
    int i = 0;
	for(DTLayer *layer in _currentRoom.room.layers) {
        if(layer.foreground)
            break;
        if([self layerVisible:i++])
            [tilemapRenderer drawLayer:layer camera:camera fromWorldRoom:_currentRoom];
    }
    
    // Entities
    glPushMatrix();
    glTranslatef(-camera.position.x, -camera.position.y, 0);
    for(DTEntity *entity in _currentRoom.entities.allValues)
        [entityRenderer drawEntity:entity camera:camera frameCount:frameCount];
    glPopMatrix();
    
    // Foreground layers
	for(DTLayer *layer in [_currentRoom.room.layers subarrayWithRange:NSMakeRange(i, _currentRoom.room.layers.count-i)]) {
        if([self layerVisible:i++])
            [tilemapRenderer drawLayer:layer camera:camera fromWorldRoom:_currentRoom];
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"debug"])
        [tilemapRenderer drawCollision:_currentRoom.room.collisionLayer camera:camera];
        
    glLoadIdentity();
    
    DTProgram *p = [resources resourceNamed:@"main.program"];
    [p unuse];
    
    glBegin(GL_QUADS);
    glColor3f(0.3, 0.0, 0.0);
    glVertex2f(0.0, 0.0);
    glVertex2f(16., 0.);
    glVertex2f(16., 2.);
    glVertex2f(0., 2.);
    glEnd();
    
    [p use];
    
    if(_oldRoomTransitionTimer > 0) {
        _oldRoomTransitionTimer -= 1/60.;
        if(_oldRoomTransitionTimer <= 0) {
            _oldRoom = nil;
            _oldCamera = nil;
            if(_transitionDone)
                _transitionDone();
            _transitionDone = nil;
        }
    }
}

- (BOOL)layerVisible:(int)index
{
    return [[_visibleLayers objectForKey:@(index)] ?: @YES boolValue];
}
- (void)setLayer:(int)index visible:(BOOL)visible
{
    [_visibleLayers setObject:@(visible) forKey:@(index)];
}


#pragma mark -
#pragma mark Network
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port;
{
	NSLog(@"Connected to server: %@", sock);
	[_proto sendHash:$dict(
		@"command", @"hello",
		@"playerName", [[NSUserDefaults standardUserDefaults] objectForKey:@"playerName"],
        @"appId", [DTCore appInstanceIdentifier]
	)];
}
-(void)onSocketDidDisconnect:(AsyncSocket *)sock;
{
	NSLog(@"Lost connection to server: %@", sock);
}






#pragma mark -
#pragma mark Server commands

-(void)protocol:(TCAsyncHashProtocol*)proto receivedHash:(NSDictionary*)hash payload:(NSData*)payload;
{
    NSString *command = [hash objectForKey:@"command"];
    
    NSString *selNs = $sprintf(@"command:%@:", command);
    SEL sel = NSSelectorFromString(selNs);
    if([self respondsToSelector:sel])
        ((void(*)(id, SEL, id, id))[self methodForSelector:sel])(self, sel, proto, hash);
    else
        NSLog(@"Unknown command: %@", hash);
}

-(void)protocol:(TCAsyncHashProtocol*)proto receivedRequest:(NSDictionary*)hash payload:(NSData*)payload responder:(TCAsyncHashProtocolResponseCallback)responder;
{
    SEL sel = NSSelectorFromString($sprintf(@"request:%@:responder:", [hash objectForKey:@"question"]));
    if([self respondsToSelector:sel])
        ((void(*)(id, SEL, id, id, TCAsyncHashProtocolResponseCallback))[self methodForSelector:sel])(self, sel, proto, hash, responder);
    else {
        responder($dict(@"error", @"Unknown request"));
        NSLog(@"Unknown request %@", hash);
    }

}

#pragma mark Entities
-(void)command:(id)proto updateEntityDeltas:(NSDictionary*)hash;
{
    NSDictionary *reps = $notNull([hash objectForKey:@"reps"]);
    NSString *roomName = $notNull([hash objectForKey:@"room"]);
    DTWorldRoom *room = $notNull([rooms objectForKey:roomName]);
    
    for(NSString *key in reps) {
        DTEntity *ent = $notNull([room.entities objectForKey:key]);
        [ent updateFromRep:[reps objectForKey:key]];
    }
}
-(void)command:(id)proto addEntity:(NSDictionary*)hash;
{
    NSString *roomName = $notNull([hash objectForKey:@"room"]);
    DTWorldRoom *room = $notNull([rooms objectForKey:roomName]);
    
    NSString *key = $notNull([hash objectForKey:@"uuid"]);
    NSDictionary *rep = $notNull([hash objectForKey:@"rep"]);
    
    DTEntity *ent = [[DTEntity alloc] initWithRep:rep world:room.world uuid:key];
    
    [room.entities setObject:ent forKey:key];
}
-(void)command:(id)proto removeEntity:(NSDictionary*)hash;
{
    NSString *key = $notNull([hash objectForKey:@"uuid"]);
    NSString *roomName = $notNull([hash objectForKey:@"room"]);
    DTWorldRoom *room = [rooms objectForKey:roomName];
    if(!room) return;
    
    DTEntity *entity = [room.entities objectForKey:key];
    if (entity) {
        [entityRenderer deleteGfxStateForEntity:entity];
        [room.entities removeObjectForKey:key];
    }
}

#pragma mark about this player
-(void)command:(id)proto playerEntity:(NSDictionary*)hash;
{
    NSString *key = $notNull([hash objectForKey:@"uuid"]);
    NSString *roomName = $notNull([hash objectForKey:@"room"]);
    DTWorldRoom *room = $notNull([rooms objectForKey:roomName]);
    
    playerEntity = [room.entities objectForKey:key];
}

-(void)command:(id)proto cameraFollow:(NSDictionary*)hash;
{
    NSString *roomName = $notNull([hash objectForKey:@"room"]);
    DTWorldRoom *room = $notNull([rooms objectForKey:roomName]);
    
    DTEntity *f = $notNull([room.entities objectForKey:[hash objectForKey:@"uuid"]]);
    followThis = f; // silence stupid warning :/
}

#pragma mark rooms
-(void)request:(id)proto joinRoom:(NSDictionary*)hash responder:(TCAsyncHashProtocolResponseCallback)responder;
{
    NSString *name = $notNull([hash objectForKey:@"name"]);
    NSString *uuid = $notNull([hash objectForKey:@"uuid"]);
    
    _oldRoom = self.currentRoom;
    _transitionDirection = [[hash objectForKey:@"transitionDirection"] intValue];
    if(_oldRoom && _transitionDirection != EntityDirectionNone) {
        _oldRoomTransitionTimer = kRoomTransitionTime;
        _oldCamera = [camera copy];
    } else {
        _oldRoomTransitionTimer = 0;
    }
    
    Vector2 *destination = [[Vector2 alloc] initWithRep:hash[@"destinationPosition"]];
    [camera setPositionFromEntity:destination];
    
    self.currentRoom = nil;
    [entityRenderer emptyGfxState];
    followThis = nil;
    
    __block DTWorldRoom *room = [rooms objectForKey:uuid];
    void(^then)() = ^ {
        self.currentRoom = room;
        
        [proto requestHash:$dict(@"question", @"getRoom", @"uuid", uuid) response:^(NSDictionary *hash2) {
            NSDictionary *reps = $notNull([hash2 objectForKey:@"entities"]);
            
            for(NSString *key in reps) {
                NSDictionary *rep = [reps objectForKey:key];
                DTEntity *existing = [room.entities objectForKey:key];
                if(existing)
                    [existing updateFromRep:rep];
                else {
                    DTEntity *ent = [[DTEntity alloc] initWithRep:rep world:room.world uuid:key];
                    [room.entities setObject:ent forKey:key];
                }
            }
        
            NSMutableSet *toDelete = [NSMutableSet setWithArray:[room.entities allKeys]];
            [toDelete minusSet:[NSSet setWithArray:reps.allKeys]];
            for(NSArray *key in toDelete) [room.entities removeObjectForKey:key];
            
            _transitionDone = ^{
                responder($dict(@"status", @"done"));
            };
            if(_oldRoomTransitionTimer <= 0) {
                _transitionDone();
                _transitionDone = nil;
            }
        }];
    };
    
    if(!room) {
		[resources resourceNamed:$sprintf(@"%@.room",name) loaded:(void(^)(id<DTResource>))^(DTRoom* newRoom) {
            if(!newRoom) {
				// todo<nevyn>: reintroduce errors into resource loader
                return;
            }
            room = [[DTWorldRoom alloc] initWithRoom:newRoom];
            room.room.uuid = uuid;
            room.world.resources = resources;
            newRoom.delegate = self;

            [rooms setObject:room forKey:uuid];
            then();
        }];
    } else then();
}
-(void)command:(id)proto entityDamaged:(NSDictionary*)hash;
{
    NSString *roomName = $notNull([hash objectForKey:@"room"]);
    DTWorldRoom *room = $notNull([rooms objectForKey:roomName]);
    
    DTEntity *e = $notNull([room.entities objectForKey:[hash objectForKey:@"uuid"]]);
    DTEntity *other = [room.entities objectForKey:[hash objectForKey:@"killer"]];
    
    int d = [$notNull([hash objectForKey:@"damage"]) intValue];
    Vector2 *location = [[Vector2 alloc] initWithRep:$notNull([hash objectForKey:@"location"])];
    [e damage:d from:location killer:other];
}

-(void)command:(id)proto entityCounterpartMessage:(NSDictionary*)hash;
{
    NSString *roomName = $notNull([hash objectForKey:@"room"]);
    DTWorldRoom *room = $notNull([rooms objectForKey:roomName]);
	
	DTEntity *ent = $notNull([room.entities objectForKey:[hash objectForKey:@"uuid"]]);
	
	[ent receivedFromCounterpart:$notNull([hash objectForKey:@"message"])];
}

- (void)roomChanged:(DTRoom *)room
{
    [_proto sendHash:@{
        @"command": @"updateRoomFromRep",
        @"room": room.uuid,
        @"rep": room.rep
    }];
}
- (void)command:(id)proto updateRoomFromRep:(NSDictionary*)hash
{
    DTWorldRoom *room = [rooms objectForKey:$notNull([hash objectForKey:@"room"])];
    room.room.delegate = nil;
    NSDictionary *rep = $notNull(hash[@"rep"]);
    [[DTResourceManager sharedManager] reloadResoure:room.room usingDefinition:rep];
    room.room.delegate = self;
}

- (void)reloadEntityForTemplateUUID:(NSString*)uuid
{
    [_proto sendHash:@{
        @"command": @"respawnEntityFromTemplateUUID",
        @"templateUUID": uuid
    }];
}


#pragma mark meta
-(void)command:(id)proto updateScoreboard:(NSDictionary*)hash;
{
    if(self.scoresCallback) self.scoresCallback([hash objectForKey:@"scoreboard"]);
}
-(void)command:(id)proto displayMessage:(NSDictionary*)hash;
{
    if(self.messageCallback) self.messageCallback([hash objectForKey:@"message"]);
}






#pragma mark -
#pragma mark Player actions
-(void)walkLeft;
{
    playerEntity.moving = true;
    playerEntity.moveDirection = EntityDirectionLeft;
	[_proto sendHash:$dict(@"command", @"action", @"action", @"walk",   @"direction", @"left")];
}
-(void)stopWalk;
{
    playerEntity.moving = false;
	[_proto sendHash:$dict(@"command", @"action", @"action", @"walk",   @"direction", @"stop")];
}
-(void)walkRight;
{
    playerEntity.moving = true;
    playerEntity.moveDirection = EntityDirectionRight;
	[_proto sendHash:$dict(@"command", @"action", @"action", @"walk",   @"direction", @"right")];
}
-(void)jump;
{
    [(DTEntityPlayer*)playerEntity jump];
    [_proto sendHash:$dict(@"command", @"action", @"action", @"jump")];
}
-(void)shoot;
{
    [_proto sendHash:$dict(@"command", @"action", @"action",@"shoot")];
}


@end
