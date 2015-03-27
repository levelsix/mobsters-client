//
//  GameTypeProtocol.h
//  Utopia
//
//  Created by Kenneth Cox on 3/25/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "Protocols.pb.h"

@protocol GameTypeProto <NSObject>

- (int) numBars;
- (NSString *) statNameForIndex:(int)index;
- (NSString *) statSuffixForIndex:(int)index;
- (NSString *) statChangeForIndex:(int)index;

- (float) curBarPercentForIndex:(int)index;
- (float) nextBarPercentForIndex:(int)index;

- (int) strength;
- (int) numPrereqs;
- (BOOL) prereqCompleteForIndex:(int)index;
- (PrereqProto *) prereqForIndex:(int)index;

@end
