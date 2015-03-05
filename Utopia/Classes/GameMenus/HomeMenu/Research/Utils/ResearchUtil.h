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

@property (nonatomic, assign) NSMutableArray *userResearches;
-(id) initWithResearches:(NSArray *)researches;

-(ResearchProto *) currentResearch;
-(BOOL) isResearched:(ResearchProto *)research;

@end
