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

@implementation QuestUtil

+ (void) checkAllDonateQuests {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *changedQuests = [NSMutableArray array];
  
  for (FullQuestProto *quest in gs.inProgressIncompleteQuests.allValues) {
    if (quest.questType == FullQuestProto_QuestTypeDonateMonster) {
      int quantity = 0;
      for (UserMonster *um in gs.myMonsters) {
        if (um.monsterId == quest.staticDataId) {
          quantity = MIN(quantity+1, quest.quantity);
        }
      }
      
      UserQuest *uq = [gs myQuestWithId:quest.questId];
      if (quantity != uq.progress) {
        uq.progress = quantity;
        [changedQuests addObject:quest];
      }
    }
  }
  
  for (FullQuestProto *fqp  in changedQuests) {
    [[OutgoingEventController sharedOutgoingEventController] questProgress:fqp.questId];
  }
}

+ (void) checkQuestsForDungeon:(BeginDungeonResponseProto *)dungeonInfo {
  // Check kill quests
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *changedQuests = [NSMutableArray array];
  NSMutableArray *potentialQuests = [NSMutableArray array];
  
  for (FullQuestProto *quest in gs.inProgressIncompleteQuests.allValues) {
    if (quest.questType == FullQuestProto_QuestTypeKillMonster) {
      [potentialQuests addObject:quest];
    }
  }
  
  if (potentialQuests.count == 0) {
    return;
  }
  
  for (TaskStageProto *tsp in dungeonInfo.tspList) {
    for (TaskStageMonsterProto *tsm in tsp.stageMonstersList) {
      
      // Check the potential quests
      for (FullQuestProto *quest in potentialQuests) {
        UserQuest *uq = [gs myQuestWithId:quest.questId];
        if (quest.staticDataId == tsm.monsterId) {
          uq.progress = MIN(uq.progress+1, quest.quantity);
          uq.isComplete = (uq.progress >= quest.quantity);
          [changedQuests addObject:quest];
        }
      }
    }
  }
  
  for (FullQuestProto *fqp  in changedQuests) {
    [[OutgoingEventController sharedOutgoingEventController] questProgress:fqp.questId];
  }
  
  [self checkAllDonateQuests];
}

@end
