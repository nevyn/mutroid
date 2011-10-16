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

-(id<DTResource>)loadResourceAtURL:(NSURL *)url usingManager:(DTResourceManager *)manager;
{
	[super loadResourceAtURL:url usingManager:manager];
            
    DTShader *shd = [[DTShader alloc] initWithResourceId:url.dt_resourceId];
    
    NSString *name = [self.definition objectForKey:@"file"];
        
    NSURL *sourceURL = [NSURL URLWithString:name relativeToURL:url];
    NSString *source = [NSString stringWithContentsOfURL:sourceURL encoding:NSUTF8StringEncoding error:NULL];
    
    DTShaderType t = [url.dt_resourceType isEqualToString:@"vertexshader"]?DTShaderTypeVertex:DTShaderTypeFragment;
    
    [shd loadWithSource:source type:t];
		
	return shd;
}
@end
