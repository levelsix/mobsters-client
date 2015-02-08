//
//  FullQuestProto+JobAccess.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/23/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "FullQuestProto+JobAccess.h"

@implementation FullQuestProto (JobAccess)

- (QuestJobProto *) jobForId:(int)jobId {
  for (QuestJobProto *qj in self.jobsList) {
    if (qj.questJobId == jobId) {
      return qj;
    }
  }
  return nil;
}

@end
