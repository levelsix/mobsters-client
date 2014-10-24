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
  }
  return nil;
}

@end
