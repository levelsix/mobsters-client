//
//  FullQuestProto+JobAccess.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/23/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "Quest.pb.h"

@interface FullQuestProto (JobAccess)

- (QuestJobProto *) jobForId:(int)jobId;

@end
