//
//  DTEntityMutroidRoomLogic.h
//  Mutroid
//
//  Created by Amanda Rösler on 1/19/13.
//
//

#import "DTEntity.h"
#import "EchoNestFetcher.h"

@interface DTEntityMutroidRoomLogic : DTEntity<EchoNestFetcherDelegate>
@property(nonatomic,strong) NSString *trackURL;
@property (nonatomic, retain) NSMutableArray *beats;
@property (nonatomic, retain) NSMutableArray *bars;

- (float)timeSpeed;

@end
