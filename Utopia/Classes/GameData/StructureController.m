//
//  StructureController.m
//  Utopia
//
//  Created by Kenneth Cox on 3/25/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "StructureController.h"

@implementation StructureController

+ (id) StructureControllerWithUserStruct:(UserStruct *)userStruct {
  id<StaticStructure> ss = [userStruct staticStructForCurrentConstructionLevel];
  switch ([ss structInfo].structType) {
    case StructureInfoProto_StructTypeBattleItemFactory: return self;
    case StructureInfoProto_StructTypeClan: return self;
    case StructureInfoProto_StructTypeEvo: return self;
    case StructureInfoProto_StructTypeHospital: return self;
    case StructureInfoProto_StructTypeLab: return self;
    case StructureInfoProto_StructTypeMiniJob: return self;
    case StructureInfoProto_StructTypeMoneyTree: return self;
    case StructureInfoProto_StructTypePvpBoard: return self;
    case StructureInfoProto_StructTypeResearchHouse: return self;
    case StructureInfoProto_StructTypeResidence: return self;
    case StructureInfoProto_StructTypeResourceGenerator: return self;
    case StructureInfoProto_StructTypeResourceStorage: return self;
    case StructureInfoProto_StructTypeTeamCenter: return self;
    case StructureInfoProto_StructTypeTownHall: return self;
    default: return self;
  }
}

@end
