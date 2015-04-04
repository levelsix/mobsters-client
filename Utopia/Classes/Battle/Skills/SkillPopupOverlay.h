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

@interface SkillPopupData : NSObject

@property (nonatomic, assign) BOOL player;
@property (nonatomic, retain) UIImageView *characterImage;
@property (nonatomic, retain) NSString *topText;
@property (nonatomic, retain) NSString *bottomText;
@property (nonatomic, assign) BOOL miniPopup;
@property (nonatomic, assign) BOOL item;
@property (nonatomic, retain) SkillPopupData *next;
@property (nonatomic, assign) float priority;
@property (nonatomic, assign) SkillPopupBlock skillCompletion;
@property (nonatomic, assign) int stacks;

+ (instancetype) initWithData:(BOOL)player characterImage:(UIImageView*)characterImage topText:(NSString*)topText bottomText:(NSString*)bottomText
                         mini:(BOOL)mini stacks:(int)stacks completion:(SkillPopupBlock)completion;

- (void) enqueue:(SkillPopupData*)other;
@end

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
  
  __weak IBOutlet UIImageView *_itemImagePlayer;
  __weak IBOutlet UIImageView *_itemImageEnemy;
  
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
       miniPopup:(BOOL)mini item:(BOOL)item stacks:(int)stacks withCompletion:(SkillPopupBlock)completion;
- (void) quickHide:(BOOL)player;
- (void) hideWithCompletion:(SkillPopupBlock)completion forPlayer:(BOOL)player;

@end

