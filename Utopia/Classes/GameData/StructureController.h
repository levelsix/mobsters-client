//
//  StructureController.h
//  Utopia
//
//  Created by Kenneth Cox on 3/25/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameState.h"

@interface StructureController : NSObject

+ (id) StructureControllerWithUserStruct:(UserStruct *)userStruct;

@end

@interface ItemFactoryStructureController : StructureController

@end

@interface ClanStructController : StructureController

@end

@interface EvoStructureController : StructureController

@end

@interface HospitalStructureController : StructureController

@end

@interface LabStructureController : StructureController

@end

@interface MiniJobStructureController : StructureController

@end

@interface MoneyTReeStructureController : StructureController

@end

@interface PvpBoardStructureController : StructureController

@end

@interface ResearchStructureController : StructureController

@end

@interface ResidenceStructureController : StructureController

@end

@interface ResourcestorageStructureController : StructureController

@end