//
//  ResearchUtil.h
//  Utopia
//
//  Created by Kenneth Cox on 3/4/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Research.pb.h"

@interface ResearchUtil : NSObject

@property (nonatomic, retain) NSMutableArray *userResearches;
-(id) initWithResearches:(NSArray *)researches;

-(UserResearchProto *) currentResearch;
-(BOOL) isResearched:(ResearchProto *)research;
-(BOOL) isResearching:(ResearchProto *)research;
-(NSString *)uuidForResearch:(ResearchProto *)research;

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
- (BOOL)isComplete;
- (BOOL)isResearching;
- (BOOL)isAvailable;
- (BOOL)prereqsComplete;

@end