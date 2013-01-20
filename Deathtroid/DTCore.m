//
//  DTCore.m
//  Deathtroid
//
//  Created by Per Borgman on 10/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTCore.h"

#import "DTClient.h"
#import "DTServer.h"
#import "DTInput.h"
#import "DTEditorTilemap.h"
#import "DTEditorEntities.h"
#import <Carbon/Carbon.h>

@implementation DTCore  {
    DTClient    *client;
    DTServer    *server;
}

-(id)init;
{
    if(!(self = [super init])) return nil;
    
    _input = [[DTInput alloc] init];
    
    [_input.mapper registerActionWithName:@"Up" action:^{ [client pressUp]; }];
    [_input.mapper registerActionWithName:@"Down" action:^{ [client pressDown]; }];
    [_input.mapper mapKey:kVK_ANSI_W toAction:@"Up"];
    [_input.mapper mapKey:kVK_ANSI_S toAction:@"Down"];


//    [_input.mapper registerStateActionWithName:@"WalkLeft" beginAction:^{ [client walkLeft]; } endAction:^{ [client stopWalkLeft]; }];
//    [_input.mapper registerStateActionWithName:@"WalkRight" beginAction:^{ [client walkRight]; } endAction:^{ [client stopWalkRight]; }];
//    [_input.mapper registerActionWithName:@"Jump" action:^{ [client jump]; }];
//    [_input.mapper registerActionWithName:@"Shoot" action:^{ [client shoot]; }];
//    
//    [_input.mapper mapKey:kVK_ANSI_A toAction:@"WalkLeft"];
//    [_input.mapper mapKey:kVK_ANSI_D toAction:@"WalkRight"];
//    [_input.mapper mapKey:kVK_Space toAction:@"Jump"];
//    [_input.mapper mapKey:kVK_ANSI_K toAction:@"Shoot"];
	
     	
	NSString *host = [[NSUserDefaults standardUserDefaults] objectForKey:@"host"];

	if(host)
		client = [[DTClient alloc] initConnectingTo:host port:kDTServerDefaultPort];
	else {
        server = [[DTServer alloc] init];
		client = [[DTClient alloc] init];
    }
    _tilemapEditor = [[DTEditorTilemap alloc] init];
    _tilemapEditor.client = client;
    _entitiesEditor = [[DTEditorEntities alloc] init];
    _entitiesEditor.client = client;
    
    
/*    DTDiskLevelRepository *local = nil;
    DTDiskLevelRepository *storage = nil;
    for(NSString *support in NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSAllDomainsMask, YES)) {
        DTDiskLevelRepository *parent = local;
        NSURL *u = [[NSURL fileURLWithPath:support] URLByAppendingPathComponent:@"Deathtroid" isDirectory:YES];
        local = [[DTDiskLevelRepository alloc] initWithRoot:u parent:parent];
        if(!storage) storage = local;
     }
    
    DTDiskLevelRepository *bundled = [[DTDiskLevelRepository alloc] initWithRoot:[[NSBundle mainBundle] URLForResource:@"rooms" withExtension:nil] parent:local];
    
    DTOnlineRepository *online = [[DTOnlineRepository alloc] initWithBaseURL:[NSURL URLWithString:@"http://nevyn.nu/whatev"] storingLevelsIn:storage parent:bundled];
    
    server.levelRepo = client.levelRepo = online;
    */
    
    _drawing = YES;
	    
    return self;
}

-(void)draw;
{
    [client draw];
    [_tilemapEditor draw];
    [_entitiesEditor draw];
}

-(void)tick:(double)delta;
{
    [server tick:delta];
    [client tick:delta];
}
-(DTClient*)client;
{
    return client;
}
-(DTServer*)server;
{
    return server;
}

+ (NSString*)appInstanceIdentifier
{
    static NSString *identifier = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        identifier = [NSString dt_uuid];
    });
    return identifier;
}
@end
