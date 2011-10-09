//
//  DTSprite.h
//  Deathtroid
//
//  Created by Patrik Sjöberg on 2011-10-09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTResource.h"

/**
 * A
 */

@interface DTSprite : DTResource

@end


@interface DTResourceManager (DTSprite)
-(DTSprite *)spriteNamed:(NSString *)name;
@end