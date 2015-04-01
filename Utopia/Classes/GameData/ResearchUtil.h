//
//  ResearchUtil.h
//  Utopia
//
//  Created by Kenneth Cox on 3/4/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Research.pb.h"
#import "MSDate.h"

@interface UserResearch : NSObject

@property (nonatomic, retain) NSString *userResearchUuid;
@property (nonatomic, assign) int researchId;
@property (nonatomic, assign) BOOL complete;
@property (nonatomic, retain) MSDate *timeStarted;

+ (id) userResearchWithProto:(UserResearchProto *)proto;
+ (id) userResearchWithResearch:(ResearchProto *)proto;
- (id) initWithResearch:(ResearchProto *)proto;
- (void) updateForUserResearch:(UserResearch *)UserResearch;
- (BOOL) isResearching;
- (MSDate *)tentativeCompletionDate;

- (ResearchProto *) staticResearch;
- (ResearchProto *) staticResearchForBenefitLevel;

@end

@interface ResearchUtil : NSObject {
  UserResearch *_curResearch;
}

@property (nonatomic, retain) NSMutableArray *userResearches;
- (id) initWithResearches:(NSArray *)researches;

- (void)startResearch:(UserResearch *)userResearch;
- (UserResearch *) researchForTimer;
- (UserResearch *) currentResearch;
- (UserResearch *) userResearchForProto:(ResearchProto *)research;
- (BOOL)prerequisiteFullfilledForResearch:(ResearchProto *)research;
- (UserResearch *)currentRankForResearch:(ResearchProto *) research;
- (void)cancelCurrentResearch;

- (float) percentageBenefitForType:(ResearchType)type;
- (float) percentageBenefitForType:(ResearchType)type element:(Element)element rarity:(Quality)rarity;
- (float) percentageBenefitForType:(ResearchType)type resType:(ResourceType)resType;
- (int) amountBenefitForType:(ResearchType)type element:(Element)element rarity:(Quality)rarity;
- (int) amountBenefitForType:(ResearchType)type;

- (NSArray *) allUserResearchesForElement:(Element)element rarity:(Quality)rarity;
- (NSArray *) allResearchProtosForElement:(Element)element rarity:(Quality)rarity;

@end

@interface ResearchProto (prereqObject)

- (ResearchProto *)successorResearch;
- (ResearchProto *)predecessorResearch;
- (ResearchProto *)maxLevelResearch;
- (ResearchProto *)minLevelResearch;
- (NSArray *)fullResearchFamily;
- (BOOL)prereqsComplete;

- (Element) element;
- (Quality) rarity;
- (ResourceType) resourceType;
- (float) percentage;
- (int) amountIncrease;
- (int) staticDataId;
- (BOOL) hasElement;
- (BOOL) hasRarity;
- (BOOL) hasResourceType;
- (BOOL) hasPercentage;
- (BOOL) hasAmountIncrease;
- (BOOL) hasStaticDataId;

@end