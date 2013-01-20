//
//  DTEntityMutroidRoomLogic.h
//  Mutroid
//
//  Created by Amanda Rösler on 1/19/13.
//
//

#import "DTEntity.h"
#import "EchoNestFetcher.h"

static const float kMutroidTimeSpeedConstant = 7;

@interface DTEntityMutroidRoomLogic : DTEntity<EchoNestFetcherDelegate>
@property(nonatomic,strong) NSString *trackURL;
@property (nonatomic, retain) NSMutableArray *beats;
@property (nonatomic, retain) NSMutableArray *bars;

@end
