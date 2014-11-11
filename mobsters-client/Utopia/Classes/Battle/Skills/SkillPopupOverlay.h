//
//  SkillPopupOverlay.h
//  Utopia
//
//  Created by Mikhail Larionov on 9/4/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Skill.pb.h"

typedef void(^SkillPopupBlock)();

@interface SkillPopupOverlay : UIView
{
  __weak IBOutlet UIView *_avatarPlayer;
  __weak IBOutlet UIView *_avatarEnemy;
  
  __weak IBOutlet UIImageView *_imagePlayer;
  __weak IBOutlet UIImageView *_imageEnemy;
  
  __weak IBOutlet UIImageView *_skillImagePlayer;
  __weak IBOutlet UIImageView *_skillImageEnemy;
  
  __weak IBOutlet UIImageView *_enemyGradient;
}

- (void) animateForSkill:(NSInteger)skillId forPlayer:(BOOL)player withImage:(UIImageView*)imageView withCompletion:(SkillPopupBlock)completion;
- (void) hideWithCompletion:(SkillPopupBlock)completion;

@end
