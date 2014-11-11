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
  CCSprite    *_skillIcon;
  CCDrawNode  *_stencilNode;
  CCSprite    *_skillLabel;
  CCButton    *_skillButton;
  CCParticleSystem* _chargedEffect;
  
  BOOL        _enemy;
  
  BOOL        _skillButtonEnabled;
  
  CCSprite*   _orbCounter;
}

@property (nonatomic, readonly) float percentage;

- (instancetype) initWithSkillController:(SkillController*)skillController enemy:(BOOL)enemy;
- (void) appear:(BOOL)instantly;
- (void) update;
- (void) enableSkillButton:(BOOL)active;

@end
