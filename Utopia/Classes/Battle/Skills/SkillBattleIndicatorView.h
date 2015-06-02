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
  @protected  CCSprite    *_skillIcon;
  @protected  CCDrawNode  *_stencilNode;
  @protected  CCSprite    *_skillLabel;
  @protected  CCSprite    *_skillCounterBg;
  @protected  CCSprite    *_skillOrbIcon;
  @protected  CCLabelTTF  *_skillCounterLabel;
  @protected  CCLabelTTF  *_skillOwnerLabel;
  @protected  CCLabelTTF  *_skillNameLabel;
  @protected  CCSprite    *_skillActiveIcon;
  @protected  CCButton    *_skillButton;
  @protected  CCParticleSystem* _chargedEffect;
  
  BOOL        _enemy;
  
  BOOL        _skillButtonEnabled;
  
  BOOL        _skillActive;
  
  BOOL        _cursed;
  
  CCSprite*   _orbCounter;
  
  SkillProto* _skillProto;
}

@property (nonatomic) float percentage;
@property (nonatomic, weak) id<SkillBattleIndicatorViewDelegate> delegate;

- (instancetype) initWithSkillController:(SkillController*)skillController enemy:(BOOL)enemy;
- (void) appear:(BOOL)instantly;
- (void) setCurse:(BOOL)curse;
- (void) update;
- (void) enableSkillButton:(BOOL)active;
- (void) popupOrbCounter;

@end

@interface SkillBattleIndicatoriPadView : SkillBattleIndicatorView {
  CCSprite    *_skillCounterBgMiddle;
  CCSprite    *_skillBarLeftCap;
  CCSprite    *_skillBarRightCap;
  CCSprite    *_skillBarMiddle;
}
@end
