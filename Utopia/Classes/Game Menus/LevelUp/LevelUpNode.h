//
//  LevelUpNode.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/25/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <cocos2d-ui.h>

#import "HudNotificationController.h"

@interface LevelUpNode : CCNode <TopBarNotification, CCBAnimationManagerDelegate> {
  dispatch_block_t _completion;
}

@property (nonatomic, retain) CCLabelTTF *levelLabel;
@property (nonatomic, retain) CCSprite *spinner;

@end
