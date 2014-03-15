//
//  QuestUtil.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/23/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.pb.h"

@protocol QuestUtilDelegate <NSObject>

- (void) questComplete:(FullQuestProto *)fqp;

@end

@interface QuestUtil : NSObject

@property (nonatomic, assign) id<QuestUtilDelegate> delegate;

+ (void) setDelegate:(id)delegate;

+ (int) checkQuantityForDonateQuest:(FullQuestProto *)quest;
+ (void) checkAllDonateQuests;
+ (void) checkQuestsForDungeon:(BeginDungeonResponseProto *)dungeonInfo;
+ (void) checkNewlyAcceptedQuest:(FullQuestProto *)quest;

@end
