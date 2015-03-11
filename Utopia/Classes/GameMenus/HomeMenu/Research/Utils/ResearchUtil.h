//
//  ResearchUtil.h
//  Utopia
//
//  Created by Kenneth Cox on 3/4/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Research.pb.h"
#import "UserData.h"

@interface ResearchUtil : NSObject {
  UserResearch *_curResearch;
}

@property (nonatomic, retain) NSMutableArray *userResearches;
- (id) initWithResearches:(NSArray *)researches;

- (void)startResearch:(UserResearch *)userResearch;
- (UserResearch *) currentResearch;
- (UserResearch *) userResearchForProto:(ResearchProto *)research;
- (BOOL)prerequisiteFullfilledForResearch:(ResearchProto *)research;

@end

@interface ResearchProto (prereqObject)

- (ResearchProto *)successorResearch;
- (ResearchProto *)predecessorResearch;
- (ResearchProto *)maxLevelResearch;
- (ResearchProto *)minLevelResearch;
- (ResearchPropertyProto *)firstProperty;
- (float)researchBenefit;
- (NSArray *)fullResearchFamily;
- (NSString *)simpleValue;
- (BOOL)prereqsComplete;

@end