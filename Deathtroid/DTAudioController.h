#import <Foundation/Foundation.h>
#import <CocoaLibSpotify/CocoaLibSpotify.h>
#import <AudioToolbox/AudioToolbox.h>

@interface DTAudioController : NSObject <SPSessionAudioDeliveryDelegate>
-(void)clearAudioBuffers;
-(BOOL)connectOutputBus:(UInt32)sourceOutputBusNumber ofNode:(AUNode)sourceNode toInputBus:(UInt32)destinationInputBusNumber ofNode:(AUNode)destinationNode inGraph:(AUGraph)graph error:(NSError **)error;
-(void)disposeOfCustomNodesInGraph:(AUGraph)graph;
@property (readwrite, nonatomic) double volume;
@property (readwrite, nonatomic) BOOL audioOutputEnabled;
@property CGFloat progress;
@end
