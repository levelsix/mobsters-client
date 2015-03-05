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

@property (nonatomic, assign) NSArray *userResearched;

-(ResearchProto *) currentResearch;
-(void) initResearchListWithResearches:(NSArray *)researches;
-(BOOL) isResearched:(ResearchProto *)research;

@end
