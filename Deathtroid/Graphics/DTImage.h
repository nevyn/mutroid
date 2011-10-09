//
//  DTImageLoader.h
//  Deathtroid
//
//  Created by Patrik Sjöberg on 2011-10-09.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTResource.h"


@interface DTImage : DTResource
@property (nonatomic, readonly) NSImage *NSImage;
@property (nonatomic, readonly) NSBitmapImageRep *NSBitmapImageRep;
@end



@interface DTResourceManager (DTImage)
-(DTImage *)imageNamed:(NSString *)name;
@end