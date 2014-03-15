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

+ (void) sendQuestProgressForQuests:(NSArray *)quests {
  GameState *gs = [GameState sharedGameState];
  for (FullQuestProto *fqp in quests) {
    [[OutgoingEventController sharedOutgoingEventController] questProgress:fqp.questId];
    UserQuest *uq = [gs myQuestWithId:fqp.questId];
    if (uq.isComplete) {
      [[[QuestUtil sharedQuestUtil] delegate] questComplete:fqp];
    }
  }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:QUESTS_CHANGED_NOTIFICATION object:nil];
}

+ (int) checkQuantityForDonateQuest:(FullQuestProto *)quest {
  GameState *gs = [GameState sharedGameState];
  int quantity = 0;
  if (quest.questType == FullQuestProto_QuestTypeDonateMonster) {
    for (UserMonster *um in gs.myMonsters) {
      // Make sure it is complete and not in any queue
      if (um.monsterId == quest.staticDataId && um.isDonatable) {
        quantity = MIN(quantity+1, quest.quantity);
      }
    }
  }
  return quantity;
}

+ (void) checkAllDonateQuests {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *changedQuests = [NSMutableArray array];
  
  for (FullQuestProto *quest in gs.inProgressIncompleteQuests.allValues) {
    if (quest.questType == FullQuestProto_QuestTypeDonateMonster) {
      int quantity = [self checkQuantityForDonateQuest:quest];
      
      UserQuest *uq = [gs myQuestWithId:quest.questId];
      if (uq && quantity != uq.progress) {
        uq.progress = quantity;
        [changedQuests addObject:quest];
      }
    }
  }
  
  if (changedQuests.count > 0) {
    [self sendQuestProgressForQuests:changedQuests];
  }
}

+ (void) checkQuestsForDungeon:(BeginDungeonResponseProto *)dungeonInfo {
  // Check kill quests
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *changedQuests = [NSMutableArray array];
  NSMutableArray *potentialQuests = [NSMutableArray array];
  
  for (FullQuestProto *quest in gs.inProgressIncompleteQuests.allValues) {
    if (quest.questType == FullQuestProto_QuestTypeKillMonster ||
        quest.questType == FullQuestProto_QuestTypeCollectSpecialItem ||
        quest.questType == FullQuestProto_QuestTypeCompleteTask) {
      [potentialQuests addObject:quest];
    }
  }
  
  if (potentialQuests.count == 0) {
    return;
  }
  
  // Check for complete_task quests
  for (FullQuestProto *quest in potentialQuests) {
    if (quest.questType == FullQuestProto_QuestTypeCompleteTask) {
      UserQuest *uq = [gs myQuestWithId:quest.questId];
      if (quest.staticDataId == dungeonInfo.taskId) {
        uq.progress = MIN(uq.progress+1, quest.quantity);
        uq.isComplete = (uq.progress >= quest.quantity);
        [changedQuests addObject:quest];
      }
    }
  }
  
  for (TaskStageProto *tsp in dungeonInfo.tspList) {
    for (TaskStageMonsterProto *tsm in tsp.stageMonstersList) {
      // Check the potential quests
      for (FullQuestProto *quest in potentialQuests) {
        if (quest.questType == FullQuestProto_QuestTypeKillMonster) {
          UserQuest *uq = [gs myQuestWithId:quest.questId];
          if (quest.staticDataId == tsm.monsterId) {
            uq.progress = MIN(uq.progress+1, quest.quantity);
            uq.isComplete = (uq.progress >= quest.quantity);
            [changedQuests addObject:quest];
          }
        } else if (quest.questType == FullQuestProto_QuestTypeCollectSpecialItem) {
          UserQuest *uq = [gs myQuestWithId:quest.questId];
          if (quest.staticDataId == tsm.itemId) {
            uq.progress = MIN(uq.progress+1, quest.quantity);
            uq.isComplete = (uq.progress >= quest.quantity);
            [changedQuests addObject:quest];
          }
        }
      }
    }
  }
  
  if (changedQuests.count > 0) {
    [self sendQuestProgressForQuests:changedQuests];
  }
  
  [self checkAllDonateQuests];
}

+ (void) checkNewlyAcceptedQuest:(FullQuestProto *)quest {
  GameState *gs = [GameState sharedGameState];
  if (quest.questType == FullQuestProto_QuestTypeDonateMonster) {
    int quantity = [self checkQuantityForDonateQuest:quest];
    
    UserQuest *uq = [gs myQuestWithId:quest.questId];
    if (quantity != uq.progress) {
      uq.progress = quantity;
      [self sendQuestProgressForQuests:[NSArray arrayWithObject:quest]];
    }
  }
}

@end
