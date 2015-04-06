//
//  StaticStructure.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "Protocols.pb.h"
#import "GameTypeProtocol.h"

@protocol StaticStructure <NSObject>

- (StructureInfoProto *) structInfo;

- (int) numBars;
- (NSString *) statNameForIndex:(int)index;
- (NSString *) statSuffixForIndex:(int)index;

- (float) statValueForIndex:(int)index;

@optional
- (BOOL) usePowForIndex:(int)index;
- (BOOL) useSqrtForIndex:(int)index;

@end

@interface ResourceGeneratorProto (StaticStructureImpl) <StaticStructure>

@end

@interface ResourceStorageProto (StaticStructureImpl) <StaticStructure>

@end

@interface HospitalProto (StaticStructureImpl) <StaticStructure>

@end

@interface ResidenceProto (StaticStructureImpl) <StaticStructure>

@end

@interface TownHallProto (StaticStructureImpl) <StaticStructure>

@end

@interface LabProto (StaticStructureImpl) <StaticStructure>

@end

@interface EvoChamberProto (StaticsStructureImpl) <StaticStructure>

@end

@interface MiniJobCenterProto (StaticStructureImpl) <StaticStructure>

@end

@interface MoneyTreeProto (StaticStructureImpl) <StaticStructure>

@end

@interface PvpBoardHouseProto (StaticStructureImpl) <StaticStructure>

@end

@interface BattleItemFactoryProto (StaticStructureImpl) <StaticStructure>

@end

@interface ClanHouseProto (StaticStructureImpl) <StaticStructure>

@end

@interface TeamCenterProto (StaticStructureImpl) <StaticStructure>

@end

@interface ResearchHouseProto (StaticStructureImpl) <StaticStructure>

@end

@interface StructureInfoProto (StaticStructure) <GameTypeProtocol>

- (id<StaticStructure>) staticStruct;
- (StructureInfoProto *) predecessor;
- (StructureInfoProto *) successor;
- (StructureInfoProto *) maxStructInfo;

- (float) barPercentWithNumerator:(float)num denominator:(float)denom useSqrt:(BOOL)useSqrt usePow:(BOOL)usePow;
- (NSArray *) prereqs;
- (NSString *) statChangeWith:(float)curStat prevStat:(float)prevStat suffix:(NSString *)suffix;
- (NSString *) statChangeStringWith:(float)curStat nextStat:(float)nextStat suffix:(NSString *)suffix;
  
@end


@interface PrereqProto (Stringify)

- (NSString *) prereqString;

@end
