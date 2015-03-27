//
//  StaticStructure.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "Protocols.pb.h"
#import "GameTypeProtocol.h"

@protocol StaticStructure <GameTypeProto>

- (StructureInfoProto *) structInfo;

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

@interface StructureInfoProto (StaticStructure)

- (id<StaticStructure>) maxStaticStruct;
- (float) barPercentWithNumerator:(float)num Denominator:(float)denom useSqrt:(BOOL)useSqrt usePow:(BOOL)usePow;
- (int) numPrereqs;
- (BOOL) prereqCompleteForIndex:(int)index;
- (PrereqProto *) prereqForIndex:(int)index;
- (NSString *) statChangeStringWith:(float)curStat nextStat:(float)nextStat suffix:(NSString *)suffix;
  
@end


@interface PrereqProto (Stringify)

- (NSString *) prereqString;

@end
