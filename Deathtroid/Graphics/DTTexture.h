//
//  DTTexture.h
//  Deathtroid
//
//  Created by Patrik Sjöberg on 2011-10-09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTResource.h"

@interface DTTexture : DTResource
@property (nonatomic, readonly) CGSize pixelSize;

-(void)use;
@end


@interface DTResourceManager (DTTexture)
-(DTTexture *)textureNamed:(NSString *)name;
@end