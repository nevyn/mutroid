//
//  DTProgram.h
//  Deathtroid
//
//  Created by Per Borgman on 10/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DTResource.h"

@interface DTProgram : DTResource

-(void)use;
-(void)unuse;

@property (nonatomic) GLuint programName;

@end
