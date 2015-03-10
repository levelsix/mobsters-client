//
//  ResearchController.m
//  Utopia
//
//  Created by Kenneth Cox on 3/5/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ResearchController.h"
#import "ResearchUtil.h"

@implementation ResearchController

+(id)researchControllerWithProto:(ResearchProto *)proto {
  switch (proto.researchType) {
    case ResearchTypeIncreaseCashProduction: return [[ResearchPercentController alloc] initWithProto:proto];
      
    default: return [[ResearchUnitController alloc] initWithProto:proto];
//    default: CustomAssert(NO, @"Trying to create a researchControl with a type that is not recognized."); return nil;
  }
}

-(id)initWithProto:(ResearchProto *)proto {
  if((self = [super init])) {
    _research = proto;
  }
  return self;
}
-(NSString *)longImprovementString{return @"";}
-(NSString *)shortImprovementString{return @"";}

@end

@implementation ResearchPercentController
-(NSString *)longImprovementString { return [NSString stringWithFormat:@"%@%% Increase",[_research simpleValue]]; }
-(NSString *)shortImprovementString { return [NSString stringWithFormat:@"+%@%%",[_research simpleValue]]; }
@end

@implementation ResearchUnitController
-(NSString *)longImprovementString { return [NSString stringWithFormat:@"%@ Increase",[_research simpleValue]]; }
-(NSString *)shortImprovementString { return [NSString stringWithFormat:@"+%@",[_research simpleValue]]; }
@end