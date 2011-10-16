//
//  DTShader.h
//  Deathtroid
//
//  Created by Per Borgman on 10/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTResource.h"
#import <OpenGL/gl.h>

typedef enum {
    DTShaderTypeVertex,
    DTShaderTypeFragment
} DTShaderType;

@interface DTShader : DTResource

@property (nonatomic) GLuint shaderName;

@end


