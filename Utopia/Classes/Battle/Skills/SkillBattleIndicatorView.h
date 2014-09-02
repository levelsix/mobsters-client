//
//  SkillBattleIndicatorView.h
//  Utopia
//
//  Created by Mikhail Larionov on 8/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <cocos2d.h>
#import "SkillControllerActive.h"

@interface SkillBattleIndicatorView : CCNode
{
  CCSprite    *_bgImage;
  CCSprite    *_skillIcon;
  CCSprite    *_orbIcon;
  CCSprite    *_checkIcon;
  
  CCLabelTTF  *_orbsCountLabel;
}

@property (nonatomic) NSInteger orbsCount;  // Change it to update the counter

- (instancetype) initWithSkillController:(SkillController*)skillController;

- (void) update;

@end
