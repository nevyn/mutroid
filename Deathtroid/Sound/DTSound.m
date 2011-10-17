//
//  DTSound.m
//  Deathtroid
//
//  Created by Joachim Bengtsson on 2011-10-17.
//  Copyright (c) 2011 Third Cog Software. All rights reserved.
//

#import "DTSound.h"
#import "FIFactory.h"
#import "../Decoder/FISoundDecoder.h"

@interface DTSound ()
@property(nonatomic,strong) FISoundSample *sample;
@end

@implementation DTSound
@synthesize sample;
-(FISound*)newVoice;
{
    NSError *err = nil;
    FISound *voice = [[FISound alloc] initWithSample:sample error:&err];
    if(!voice)
        NSLog(@"Couldn't create voice: %@", err);
    return voice;
}
@end

@interface DTSoundLoader : DTResourceLoader
@property(nonatomic, strong) FIFactory *factory;
@end

@implementation DTSoundLoader
@synthesize factory;
+(void)load{
	[DTResourceManager registerResourceLoader:self withTypeName:@"sound"];
}
-(id)init;
{
    if(!(self = [super init])) return nil;
    
    self.factory = [FIFactory new];
    return self;
}
-(id<DTResource>)loadResourceAtURL:(NSURL *)url usingManager:(DTResourceManager *)manager;
{
	[super loadResourceAtURL:url usingManager:manager];
	NSString *soundPath = [self.definition objectForKey:@"file"];
	NSURL *soundUrl = [NSURL URLWithString:soundPath relativeToURL:url];
	
	DTSound *sound = [[DTSound alloc] initWithResourceId:url.dt_resourceId];
    
    NSError *err = nil;
    id<FISoundDecoder> dec = [factory decoderForFileAtPath:soundUrl.path];
    sound.sample = [dec decodeFileAtPath:soundUrl.path error:&err];
    if(!sound.sample) {
        // TODO<nevyn>: Pass NSError to caller instead; this is not a programmer error.
        [NSException raise:NSInvalidArgumentException format:@"Decoding error: %@", err];
        return nil;
    }
    
    return sound;
    
}
@end