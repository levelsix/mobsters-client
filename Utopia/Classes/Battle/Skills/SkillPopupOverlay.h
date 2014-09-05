//
//  SkillPopupOverlay.h
//  Utopia
//
//  Created by Mikhail Larionov on 9/4/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Skill.pb.h"

typedef void(^SkillControllerBlock)();

@interface SkillPopupOverlay : UIView
{
  __weak IBOutlet UIImageView *_skillImage;
  __weak IBOutlet UIImageView *_ownerImage;
  __weak IBOutlet UIImageView *_usedImage;
}

- (void) animateForSkill:(SkillType)skill forPlayer:(BOOL)player withBlock:(SkillControllerBlock)block;

@end
