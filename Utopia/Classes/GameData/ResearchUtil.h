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
#import "GameTypeProtocol.h"

@interface UserResearch : NSObject

@property (nonatomic, retain) NSString *userResearchUuid;
@property (nonatomic, assign) int researchId;
@property (nonatomic, assign) BOOL complete;
@property (nonatomic, retain) MSDate *timeStarted;

// Used for the zero level research if using it
@property (nonatomic, retain) ResearchProto *fakeResearch;

+ (id) userResearchWithProto:(UserResearchProto *)proto;
- (MSDate *)tentativeCompletionDate;

- (ResearchProto *) staticResearch;
- (ResearchProto *) staticResearchForNextLevel;
- (ResearchProto *) staticResearchForBenefitLevel;

@end

@interface ResearchUtil : NSObject

@property (nonatomic, retain) NSMutableArray *userResearches;

- (id) initWithResearches:(NSArray *)researches;

- (UserResearch *) currentResearch;
- (UserResearch *) userResearchForProto:(ResearchProto *)research;
- (BOOL) prerequisiteFullfilledForResearch:(ResearchProto *)research;
- (UserResearch *) currentRankForResearch:(ResearchProto *) research;
- (void) cancelCurrentResearch;

- (BOOL) isResearchApplicable:(ResearchProto *)rp element:(Element)element evoTier:(int)evoTier resType:(ResourceType)resType;
- (float) percentageBenefitForType:(ResearchType)type;
- (float) percentageBenefitForType:(ResearchType)type element:(Element)element evoTier:(int)evoTier;
- (float) percentageBenefitForType:(ResearchType)type resType:(ResourceType)resType;
- (int) amountBenefitForType:(ResearchType)type element:(Element)element evoTier:(int)evoTier;
- (int) amountBenefitForType:(ResearchType)type;

- (NSArray *) allUserResearchesForElement:(Element)element evoTier:(int)evoTier;
- (NSArray *) allResearchProtosForElement:(Element)element evoTier:(int)evoTier;

@end

@interface ResearchProto (PrereqObject) <GameTypeProtocol>

- (ResearchProto *)successorResearch;
- (ResearchProto *)predecessorResearch;
- (ResearchProto *)maxLevelResearch;
- (ResearchProto *)minLevelResearch;
- (ResearchProto *) fakeRankZeroResearch;
- (NSArray *)fullResearchFamily;

- (BOOL)prereqsComplete;
- (int) numIncompletePrereqs;

- (Element) element;
- (int) evoTier;
- (ResourceType) resourceType;
- (float) percentage;
- (int) amountIncrease;
- (int) staticDataId;
- (BOOL) hasElement;
- (BOOL) hasEvoTier;
- (BOOL) hasResourceType;
- (BOOL) hasPercentage;
- (BOOL) hasAmountIncrease;
- (BOOL) hasStaticDataId;

@end