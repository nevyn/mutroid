//
//  DTProgram.m
//  Deathtroid
//
//  Created by Per Borgman on 10/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTProgram.h"
#import "DTShader.h"
#import "DTResourceManager.h"

@implementation DTProgram

@synthesize programName;

-(void)loadWithShaders:(NSArray*)shaders;
{
    programName = glCreateProgram();
    
    for(DTShader *sh in shaders) {
        glAttachShader(programName, sh.shaderName);
    }
    
    glLinkProgram(programName);
    [self use];
}

-(void)use;
{
    NSLog(@"USE ME!");
    glUseProgram(programName);
    GLint l = glGetUniformLocation(programName, "tex");
    glUniform1i(l, 0);
}

@end


@interface DTProgramLoader : DTResourceLoader

@end

@implementation DTProgramLoader

+(void)load{
	[DTResourceManager registerResourceLoader:self withTypeName:@"program"];
}

-(id<DTResource>)loadResourceAtURL:(NSURL *)url usingManager:(DTResourceManager *)manager;
{
	[super loadResourceAtURL:url usingManager:manager];
    
    DTProgram *prg = [[DTProgram alloc] initWithResourceId:url.dt_resourceId];
    
    NSArray *shaderNames = [self.definition objectForKey:@"shaders"];
    NSMutableArray *shaders = [NSMutableArray array];
    for(NSString *name in shaderNames) {
        [shaders addObject:[manager resourceNamed:name]];
    }
    
    [prg loadWithShaders:shaders];
    
	return prg;
}
@end
