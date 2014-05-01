//
//  QuestUtil.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/23/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "QuestUtil.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "Globals.h"
#import "FullQuestProto+JobAccess.h"

@implementation QuestUtil

+ (QuestUtil *) sharedQuestUtil
{
  static QuestUtil *sharedSingleton;
  
  @synchronized(self)
  {
    if (!sharedSingleton)
      sharedSingleton = [[QuestUtil alloc] init];
    
    return sharedSingleton;
  }
}

+ (void) setDelegate:(id)delegate {
  QuestUtil *qu = [QuestUtil sharedQuestUtil];
  qu.delegate = delegate;
}

+ (void) addJob:(QuestJobProto *)job toDict:(NSMutableDictionary *)dict {
  NSMutableSet *set = dict[@(job.questId)];
  
  if (!set) {
    set = [NSMutableSet set];
    [dict setObject:set forKey:@(job.questId)];
  }
  
  [set addObject:@(job.questJobId)];
}

+ (void) sendQuestProgressForQuests:(NSDictionary *)questIdToJobIds {
  GameState *gs = [GameState sharedGameState];
  for (NSNumber *questId in questIdToJobIds) {
    UserQuest *uq = [gs myQuestWithId:questId.intValue];
    FullQuestProto *fqp = [gs questForId:questId.intValue];
    NSArray *jobIds = questIdToJobIds[questId];
    
    // Check if all the jobs are complete
    BOOL questIsComplete = YES;
    for (QuestJobProto *qj in fqp.jobsList) {
      UserQuestJob *uqj = [uq jobForId:qj.questJobId];
      if (!uqj.isComplete) {
        questIsComplete = NO;
      }
    }
    uq.isComplete = questIsComplete;
    
    for (NSNumber *jobId in jobIds) {
      [[OutgoingEventController sharedOutgoingEventController] questProgress:fqp.questId jobId:jobId.intValue];
      
      if (!uq.isComplete) {
        [[[QuestUtil sharedQuestUtil] delegate] jobProgress:[fqp jobForId:jobId.intValue]];
      }
    }
    
    if (uq.isComplete) {
      [[[QuestUtil sharedQuestUtil] delegate] questComplete:fqp];
    }
  }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:QUESTS_CHANGED_NOTIFICATION object:nil];
}

+ (int) checkQuantityForDonateQuestJob:(QuestJobProto *)job {
  GameState *gs = [GameState sharedGameState];
  int quantity = 0;
  if (job.questJobType == QuestJobProto_QuestJobTypeDonateMonster) {
    for (UserMonster *um in gs.myMonsters) {
      // Make sure it is complete and not in any queue
      if (um.monsterId == job.staticDataId && um.isDonatable) {
        quantity = MIN(quantity+1, job.quantity);
      }
    }
  }
  return quantity;
}

+ (void) checkAllDonateQuests {
  GameState *gs = [GameState sharedGameState];
  NSMutableDictionary *questIdToJobIds = [NSMutableDictionary dictionary];
  
  for (FullQuestProto *quest in gs.inProgressIncompleteQuests.allValues) {
    for (QuestJobProto *job in quest.jobsList) {
      if (job.questJobType == QuestJobProto_QuestJobTypeDonateMonster) {
        int quantity = [self checkQuantityForDonateQuestJob:job];
        
        UserQuest *uq = [gs myQuestWithId:quest.questId];
        UserQuestJob *uqj = [uq jobForId:job.questJobId];
        if (!uq.isComplete && !uqj.isComplete && quantity != uqj.progress) {
          uqj.progress = quantity;
          [self addJob:job toDict:questIdToJobIds];
        }
      }
    }
  }
  
  if (questIdToJobIds.count > 0) {
    [self sendQuestProgressForQuests:questIdToJobIds];
  }
}

+ (void) checkQuestsForDungeon:(BeginDungeonResponseProto *)dungeonInfo {
  // Check kill quests
  GameState *gs = [GameState sharedGameState];
  NSMutableDictionary *questIdToJobIds = [NSMutableDictionary dictionary];
  NSMutableSet *potentialJobs = [NSMutableSet set];
  
  for (FullQuestProto *quest in gs.inProgressIncompleteQuests.allValues) {
    for (QuestJobProto *job in quest.jobsList) {
      if (job.questJobType == QuestJobProto_QuestJobTypeKillSpecificMonster ||
          job.questJobType == QuestJobProto_QuestJobTypeCollectSpecialItem ||
          job.questJobType == QuestJobProto_QuestJobTypeCompleteTask) {
        UserQuest *uq = [gs myQuestWithId:job.questId];
        UserQuestJob *uqj = [uq jobForId:job.questJobId];
        if (!uq.isComplete && !uqj.isComplete) {
          [potentialJobs addObject:job];
        }
      }
    }
  }
  
  if (potentialJobs.count == 0) {
    return;
  }
  
  // Check for complete_task quests
  for (QuestJobProto *job in potentialJobs) {
    if (job.questJobType == QuestJobProto_QuestJobTypeCompleteTask) {
      UserQuest *uq = [gs myQuestWithId:job.questId];
      UserQuestJob *uqj = [uq jobForId:job.questJobId];
      if (job.staticDataId == dungeonInfo.taskId) {
        uqj.progress = MIN(uqj.progress+1, job.quantity);
        uqj.isComplete = (uqj.progress >= job.quantity);
        [self addJob:job toDict:questIdToJobIds];
      }
    }
  }
  
  for (TaskStageProto *tsp in dungeonInfo.tspList) {
    for (TaskStageMonsterProto *tsm in tsp.stageMonstersList) {
      // Check the potential quests
      for (QuestJobProto *job in potentialJobs) {
        UserQuest *uq = [gs myQuestWithId:job.questId];
        UserQuestJob *uqj = [uq jobForId:job.questJobId];
        if (job.questJobType == QuestJobProto_QuestJobTypeKillSpecificMonster) {
          if (!job.staticDataId || job.staticDataId == tsm.monsterId) {
            uqj.progress = MIN(uqj.progress+1, job.quantity);
            uqj.isComplete = (uqj.progress >= job.quantity);
            [self addJob:job toDict:questIdToJobIds];
          }
        } else if (job.questJobType == QuestJobProto_QuestJobTypeCollectSpecialItem) {
          if (job.staticDataId == tsm.itemId) {
            uqj.progress = MIN(uqj.progress+1, job.quantity);
            uqj.isComplete = (uqj.progress >= job.quantity);
            [self addJob:job toDict:questIdToJobIds];
          }
        }
      }
    }
  }
  
  if (questIdToJobIds.count > 0) {
    [self sendQuestProgressForQuests:questIdToJobIds];
  }
  
  [self checkAllDonateQuests];
}

+ (void) checkNewlyAcceptedQuest:(FullQuestProto *)quest {
  GameState *gs = [GameState sharedGameState];
  NSMutableDictionary *questIdToJobIds = [NSMutableDictionary dictionary];
  for (QuestJobProto *job in quest.jobsList) {
    if (job.questJobType == QuestJobProto_QuestJobTypeDonateMonster) {
      int quantity = [self checkQuantityForDonateQuestJob:job];
      
      UserQuest *uq = [gs myQuestWithId:quest.questId];
      UserQuestJob *uqj = [uq jobForId:job.questJobId];
      if (quantity != uqj.progress) {
        uqj.progress = quantity;
        [self addJob:job toDict:questIdToJobIds];
      }
    }
  }
  
  if (questIdToJobIds.count > 0) {
    [self sendQuestProgressForQuests:questIdToJobIds];
  }
}

@end
