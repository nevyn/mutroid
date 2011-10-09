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
#import "DTLevelRepository.h"
#import <Carbon/Carbon.h>

@implementation DTCore

@synthesize input;

-(id)init;
{
    input = [[DTInput alloc] init];
    
    [input.mapper registerStateActionWithName:@"WalkLeft" beginAction:^{ [client walkLeft]; } endAction:^{ [client stopWalk]; }];
    [input.mapper registerStateActionWithName:@"WalkRight" beginAction:^{ [client walkRight]; } endAction:^{ [client stopWalk]; }];
    [input.mapper registerActionWithName:@"Jump" action:^{ [client jump]; }];
    [input.mapper registerActionWithName:@"Shoot" action:^{ [client shoot]; }];
    
    [input.mapper mapKey:kVK_ANSI_A toAction:@"WalkLeft"];
    [input.mapper mapKey:kVK_ANSI_D toAction:@"WalkRight"];
    [input.mapper mapKey:kVK_Space toAction:@"Jump"];
    [input.mapper mapKey:kVK_ANSI_K toAction:@"Shoot"];
	
     	
	NSString *host = [[NSUserDefaults standardUserDefaults] objectForKey:@"host"];

	if(host)
		client = [[DTClient alloc] initConnectingTo:host port:kDTServerDefaultPort];
	else {
        server = [[DTServer alloc] init];
		client = [[DTClient alloc] init];
    }
    
    
    DTDiskLevelRepository *local = nil;
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
    
    
    [server loadLevel:@"test"];
	    
    return self;
}

-(void)draw;
{
    [client draw];
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
@end
