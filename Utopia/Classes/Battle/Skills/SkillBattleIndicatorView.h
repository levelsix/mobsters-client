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

@protocol SkillBattleIndicatorViewDelegate <NSObject>

@optional
- (void) onCloseSkillPopup;

@end

@interface SkillBattleIndicatorView : CCNode
{
  CCSprite    *_skillIcon;
  CCDrawNode  *_stencilNode;
  CCSprite    *_skillLabel;
  CCSprite    *_skillCounterBg;
  CCSprite    *_skillOrbIcon;
  CCLabelTTF  *_skillCounterLabel;
  CCSprite    *_skillActiveIcon;
  CCButton    *_skillButton;
  CCParticleSystem* _chargedEffect;
  
  BOOL        _enemy;
  
  BOOL        _skillButtonEnabled;
  
  BOOL        _skillActive;
  
  BOOL        _cursed;
  
  CCSprite*   _orbCounter;
  
  SkillProto* _skillProto;
}

@property (nonatomic, readonly) float percentage;
@property (nonatomic, assign) id<SkillBattleIndicatorViewDelegate> delegate;

- (instancetype) initWithSkillController:(SkillController*)skillController enemy:(BOOL)enemy;
- (void) appear:(BOOL)instantly;
- (void) setCurse:(BOOL)curse;
- (void) update;
- (void) enableSkillButton:(BOOL)active;
- (void) popupOrbCounter;

@end
