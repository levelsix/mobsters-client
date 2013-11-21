//
//  QuestUtil.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/23/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MobstersEventProtocol.pb.h"

@interface QuestUtil : NSObject

+ (void) checkAllDonateQuests;
+ (void) checkQuestsForDungeon:(BeginDungeonResponseProto *)dungeonInfo;

@end
