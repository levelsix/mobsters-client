//
//  TopBarQuestProgressView.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/31/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "UserData.h"
#import "NibUtils.h"

@interface TopBarQuestProgressView : UIView {
  void (^_completionBlock)(void);
}

@property (nonatomic, retain) IBOutlet MiniMonsterView *monsterView;
@property (nonatomic, retain) IBOutlet UILabel *questLabel;
@property (nonatomic, retain) IBOutlet UILabel *progressLabel;

- (void) displayForQuest:(FullQuestProto *)quest userQuest:(UserQuest *)userQuest jobId:(int)jobId completion:(void (^)(void))completion;

@end
