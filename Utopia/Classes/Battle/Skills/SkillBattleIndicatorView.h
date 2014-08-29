//
//  SkillBattleIndicatorView.h
//  Utopia
//
//  Created by Mikhail Larionov on 8/29/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <cocos2d.h>
#import "SkillController.h"

@interface SkillBattleIndicatorView : CCSprite
{
  CCLabelTTF *_orbsLabel;
}

- (instancetype) initWithPlayerColor:(OrbColor)color activationType:(SkillActivationType)activationType skillType:(SkillType)skillType;

@property (nonatomic) NSInteger orbsCount;

@end
