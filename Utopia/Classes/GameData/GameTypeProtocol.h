//
//  GameTypeProtocol.h
//  Utopia
//
//  Created by Kenneth Cox on 3/25/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "Protocols.pb.h"

@protocol GameTypeProtocol <NSObject>

- (int) numBars;
- (NSString *) statNameForIndex:(int)index;
- (NSString *) statSuffixForIndex:(int)index;
- (NSString *) shortStatChangeForIndex:(int)index;
- (NSString *) longStatChangeForIndex:(int)index;

- (float) barPercentForIndex:(int)index;

- (int) strengthGain;
- (NSArray *) prereqs;

- (int) rank;
- (int) totalRanks;
- (NSString *) name;
- (id<GameTypeProtocol>) predecessor;
- (id<GameTypeProtocol>) successor;
- (NSArray *) fullFamilyList;

@end
