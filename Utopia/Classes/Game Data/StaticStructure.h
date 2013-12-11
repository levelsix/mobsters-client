//
//  StaticStructure.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "Protocols.pb.h"

@protocol StaticStructure <NSObject>

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