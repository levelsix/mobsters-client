//
//  SkillPopupOverlayController.m
//  Utopia
//
//  Created by Rob Giusti on 5/11/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "SkillPopupOverlayController.h"
#import "Globals.h"

@implementation SkillPopupOverlayController

- (id)initWithBelongsToPlayer:(BOOL)belongsToPlayer
{
  if (self = [super init])
  {
    _belongsToPlayer = belongsToPlayer;
  }
  return self;
}

- (void)showCurrentSkillPopup
{
  if (!_currentSkillPopup) return;
  if (_popupOverlay) return;
  
  // Create overlay
  UIView *parentView = self.battleLayer.hudView;
  _popupOverlay = [[[NSBundle mainBundle] loadNibNamed:_currentSkillPopup.miniPopup ? @"SkillPopupMiniOverlay" : @"SkillPopupOverlay" owner:self options:nil] objectAtIndex:0];
  [_popupOverlay setBounds:parentView.bounds];
  [_popupOverlay setOrigin:CGPointMake((parentView.width - _popupOverlay.width)/2, (parentView.height - _popupOverlay.height)/2)];
  [parentView addSubview:_popupOverlay];
  
  SkillPopupOverlay *tempPopup = _popupOverlay;
  
  [_popupOverlay animate:_currentSkillPopup.player withImage:_currentSkillPopup.characterImage.image topText:_currentSkillPopup.topText
              bottomText:_currentSkillPopup.bottomText miniPopup:_currentSkillPopup.miniPopup item:_currentSkillPopup.item stacks:_currentSkillPopup.stacks withCompletion:
   ^{
     // Hide popup and call block, if it hasn't been hidden yet
     if (_popupOverlay == tempPopup)
     {
       [self hideSkillPopupOverlayInternal];
     }
   }];
  
  // Hide pieces of battle hud
  if (_belongsToPlayer)
  {
    [UIView animateWithDuration:0.1 animations:^{
      self.battleLayer.hudView.bottomView.alpha = 0.0;
    } completion:^(BOOL finished) {
      self.battleLayer.hudView.bottomView.hidden = YES;
    }];
  }
}

- (void)enqueueSkillPopup:(SkillPopupData *)data
{
  if (_currentSkillPopup)
  {
    if (data.priority > _currentSkillPopup.priority)
    {
      [self quickHide];
      data.next = _currentSkillPopup;
      _currentSkillPopup = data;
    }
    else
    {
      [_currentSkillPopup enqueue:data];
    }
  }
  else
  {
    _currentSkillPopup = data;
  }
}

- (void)enqueueItemPopup:(BattleItemProto *)bip bottomText:(NSString*)bottomText
{
  UIImageView *itemImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
  [Globals imageNamed:bip.imgName withView:itemImageView greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  SkillPopupData *data = [SkillPopupData initWithData:_belongsToPlayer characterImage:itemImageView topText:bip.name bottomText:bottomText mini:YES stacks:0 completion:^{}];
  
  data.item = YES;
  data.priority = 2;
  
  [self enqueueSkillPopup:data];
  [self showCurrentSkillPopup];
}

- (void) hideSkillPopupOverlayInternal
{
  // Restore pieces of the battle hud in a block
  SkillPopupBlock newCompletion = ^(){
    
    if (_belongsToPlayer)
    {
      self.battleLayer.hudView.bottomView.hidden = NO;
      self.battleLayer.hudView.bottomView.alpha = 0.0;
      [UIView animateWithDuration:0.1 animations:^{
        self.battleLayer.hudView.bottomView.alpha = 1.0;
      }];
    }
    
    SkillPopupData* lastData = _currentSkillPopup;
    _currentSkillPopup = _currentSkillPopup.next;
    
    _popupOverlay = nil;
    
    if (!_currentSkillPopup){
      [lastData completion];
    }
    else
      [self showCurrentSkillPopup];
    
  };
  
  // Hide overlay
  [_popupOverlay hideWithCompletion:newCompletion forPlayer:_currentSkillPopup.player];
}

- (void) quickHide
{
  [_popupOverlay quickHide:_belongsToPlayer];
}

@end