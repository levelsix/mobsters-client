//
//  QuestUtil.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/23/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.pb.h"
#import "FullQuestProto+JobAccess.h"

@protocol QuestUtilDelegate <NSObject>

- (void) questComplete:(FullQuestProto *)fqp;
- (void) jobProgress:(QuestJobProto *)qjp;

@end

@interface QuestUtil : NSObject

@property (nonatomic, weak) id<QuestUtilDelegate> delegate;

+ (void) setDelegate:(id)delegate;

+ (QuestUtil *) sharedQuestUtil;
+ (int) checkQuantityForDonateQuestJob:(QuestJobProto *)job;
+ (void) checkAllDonateQuests;
+ (void) checkAllStructQuests;
+ (void) checkQuestsForDungeon:(BeginDungeonResponseProto *)dungeonInfo;
+ (void) checkNewlyAcceptedQuest:(FullQuestProto *)quest;

@end
