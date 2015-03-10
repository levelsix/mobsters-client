//
//  ResearchController.h
//  Utopia
//
//  Created by Kenneth Cox on 3/5/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Research.pb.h"

@protocol ResearchProtocol <NSObject>
-(NSString *)longImprovementString;
-(NSString *)shortImprovementString;
@end

@interface ResearchController : NSObject <ResearchProtocol> {
  ResearchProto *_research;
}
+(id)researchControllerWithProto:(ResearchProto *)proto;
-(id)initWithProto:(ResearchProto *)proto;
@end

@interface ResearchPercentController : ResearchController
@end
@interface ResearchUnitController : ResearchController
@end