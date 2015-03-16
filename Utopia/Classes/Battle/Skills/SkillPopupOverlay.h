//
//  SkillPopupOverlay.h
//  Utopia
//
//  Created by Mikhail Larionov on 9/4/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Skill.pb.h"
#import "BattleOrb.h"

typedef void(^SkillPopupBlock)();

@class THLabel;

@interface SkillPopupOverlay : UIView
{
  __weak IBOutlet UIView *_avatarPlayer;
  __weak IBOutlet UIView *_avatarEnemy;
  
  __weak IBOutlet UIImageView *_imagePlayer;
  __weak IBOutlet UIImageView *_imageEnemy;
  
  __weak IBOutlet UIImageView *_rocksImagePlayer;
  __weak IBOutlet UIImageView *_rocksImageEnemy;
  
  __weak IBOutlet UIImageView *_leavesImagePlayer;
  __weak IBOutlet UIImageView *_leavesImageEnemy;
  
  __weak IBOutlet UIView *_skillPlayer;
  __weak IBOutlet UIView *_skillEnemy;
  
  __weak IBOutlet THLabel *_skillNameLabelPlayer;
  __weak IBOutlet THLabel *_skillNameLabelEnemy;
  
  __weak IBOutlet THLabel *_skillTopLabelPlayer;
  __weak IBOutlet THLabel *_skillTopLabelEnemy;
  
  __weak IBOutlet THLabel *_skillBottomLabelPlayer;
  __weak IBOutlet THLabel *_skillBottomLabelEnemy;
}

- (void) animate:(BOOL)player withImage:(UIImage*)characterImage topText:(NSString*)topText bottomText:(NSString*)bottomtext
       miniPopup:(BOOL)mini withCompletion:(SkillPopupBlock)completion;
- (void) hideWithCompletion:(SkillPopupBlock)completion forPlayer:(BOOL)player;

@end

