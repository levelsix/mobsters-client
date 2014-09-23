//
//  SkillBattleIndicatorView.h
//  Utopia
//
//  Created by Mikhail Larionov on 8/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <cocos2d.h>
#import <cocos2d-ui/CCButton.h>
#import "SkillController.h"

@interface SkillBattleIndicatorView : CCNode
{
  //CCSprite    *_bgImage;
  CCSprite    *_skillIcon;
  CCDrawNode  *_stencilNode;
  //CCSprite    *_orbIcon;
  //CCSprite    *_checkIcon;
  
  CCSprite    *_skillLabel;
  
  CCButton    *_skillButton;
  
  CCLabelTTF  *_orbsCountLabel;
  CCLabelTTF  *_passiveOnLabel;
  
  CCParticleSystem* _chargedEffect;
  
  BOOL        _enemy;
}

//@property (nonatomic) NSInteger orbsCount;  // Change it to update the counter

@property (nonatomic) float percentage;  // Change it to update the indicator

- (instancetype) initWithSkillController:(SkillController*)skillController enemy:(BOOL)enemy;

- (void) update;

- (void) appear:(BOOL)instantly;
- (void) disappear;

- (void) enableSkillButton:(BOOL)active;

@end
