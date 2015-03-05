//
//  StaticStructure.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "StaticStructure.h"
#import "Protocols.pb.h"
#import "GameState.h"

@implementation ResourceGeneratorProto (StaticStructureImpl)

@end

@implementation ResourceStorageProto (StaticStructureImpl)

@end

@implementation HospitalProto (StaticStructureImpl)

@end

@implementation ResidenceProto (StaticStructureImpl)

@end

@implementation TownHallProto (StaticStructureImpl)

@end

@implementation LabProto (StaticStructureImpl)

@end

@implementation MiniJobCenterProto (StaticStructureImpl)

@end

@implementation MoneyTreeProto (StaticStructureImpl)

@end

@implementation PvpBoardHouseProto (StaticStructureImpl)

@end

@implementation BattleItemFactoryProto (StaticStructureImpl)

@end

@implementation PrereqProto (Stringify)

- (NSString *) prereqString {
  GameState *gs = [GameState sharedGameState];
  if (self.prereqGameType == GameTypeStructure) {
    id<StaticStructure> ss = [gs structWithId:self.prereqGameEntityId];
    StructureInfoProto *sip = [ss structInfo];
    
    NSString *quant = self.quantity <= 1 ? @"" : [NSString stringWithFormat:@"%d ", self.quantity];
    NSString *lvl = [NSString stringWithFormat:@"LVL %d ", sip.level];
    NSString *name = [NSString stringWithFormat:@"%@%@", sip.name, self.quantity == 1 ? @"" : @"s"];
    
    return [NSString stringWithFormat:@"%@%@%@", quant, lvl, name];
  } else if (self.prereqGameType == GameTypeTask) {
    TaskMapElementProto *elem = [gs mapElementWithTaskId:self.prereqGameEntityId];
    return [NSString stringWithFormat:@"Defeat Level %d", elem.mapElementId];
  } else if (self.prereqGameType == GameTypeResearch) {
    ResearchProto *research = [gs.staticResearch objectForKey:@(self.prereqGameEntityId)];
    if (research.level > 1) {
      NSString *lvl = [NSString stringWithFormat:@"Rank %d", research.level];
      return [NSString stringWithFormat:@"%@ %@",lvl, research.name];
    } else {
      return [NSString stringWithFormat:@"%@",research.name];
    }
  }
  return nil;
}

@end
