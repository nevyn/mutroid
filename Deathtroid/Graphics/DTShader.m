//
//  DTShader.m
//  Deathtroid
//
//  Created by Per Borgman on 10/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTShader.h"

@implementation DTShader

@synthesize shaderName;

-(void)loadWithSource:(NSString*)source type:(DTShaderType)type;
{
    const GLchar *_source;  
    _source = (GLchar*)[source UTF8String];

    if(type == DTShaderTypeVertex) shaderName = glCreateShader(GL_VERTEX_SHADER);
    else if(type == DTShaderTypeFragment) shaderName = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(shaderName, 1, &_source, NULL);
    glCompileShader(shaderName);
    
    int length;
    char log[2048];
    
    glGetShaderInfoLog(shaderName, 2048, &length, log);
    
    printf("%s", log);
}

@end


@interface DTShaderLoader : DTResourceLoader

@end

@implementation DTShaderLoader

+(void)load{
	[DTResourceManager registerResourceLoader:self withTypeName:@"vertexshader"];
    [DTResourceManager registerResourceLoader:self withTypeName:@"fragmentshader"];
}

- (id<DTResource>)createResourceWithManager:(DTResourceManager *)manager
{
    return [[DTShader alloc] initWithResourceId:self.path.dt_resourceId];
}

- (BOOL)loadResource:(DTShader *)shader usingManager:(DTResourceManager *)manager error:(NSError *__autoreleasing *)error
{
    NSString *name = [self.definition objectForKey:@"file"];
    
    NSURL *sourceURL = [NSURL URLWithString:name relativeToURL:self.path];
    NSString *source = [NSString stringWithContentsOfURL:sourceURL encoding:NSUTF8StringEncoding error:error];
    if(!source) return NO;
    
    DTShaderType t = [self.path.dt_resourceType isEqualToString:@"vertexshader"] ? DTShaderTypeVertex : DTShaderTypeFragment;
    
    [shader loadWithSource:source type:t];
    
    return YES;
}

@end
