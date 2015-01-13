//
//  NewGachaViews.m
//  Utopia
//
//  Created by Behrouz N. on 12/18/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "NewGachaViews.h"
#import "GameState.h"
#import "Globals.h"
#import "IAPHelper.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import "SkillController.h"

@implementation NewGachaPrizeView

- (void) animateWithMonsterId:(int)monsterId {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *proto = [gs monsterWithId:monsterId];
  
  self.nameLabel.text = proto.displayName;
  self.nameLabel.textColor = [Globals colorForElementOnDarkBackground:proto.monsterElement];
  self.descriptionLabel.text = proto.description;
  
  self.rarityIcon.image = [Globals imageNamed:[@"gacha" stringByAppendingString:[Globals imageNameForRarity:proto.quality suffix:@"tag.png"]]];
  
  NSString *fileName = [proto.imagePrefix stringByAppendingString:@"Character.png"];
  [Globals imageNamedWithiPhone6Prefix:fileName withView:self.monsterIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.pieceLabel.hidden = YES;
  self.rarityIcon.hidden = NO;
  
  [self doAnimation];
}

- (void) animateWithMonsterId:(int)monsterId numPuzzlePieces:(NSInteger)numPuzzlePieces {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *proto = [gs monsterWithId:monsterId];
  
  [self animateWithMonsterId:monsterId];
  self.pieceLabel.hidden = NO;
  self.pieceLabel.text = [NSString stringWithFormat:@"PIECES: %d/%d", (int)numPuzzlePieces, proto.numPuzzlePieces];
}

- (void) animateWithGems:(int)numGems {
  Globals *gl = [Globals sharedGlobals];
  IAPHelper *iap = [IAPHelper sharedIAPHelper];
  InAppPurchasePackageProto *pkg = nil;
  
  for (InAppPurchasePackageProto *p in gl.iapPackages) {
    if (p.currencyAmount <= numGems && p.currencyAmount > pkg.currencyAmount) {
      pkg = p;
    }
  }
  
  self.pieceLabel.hidden = YES;
  self.rarityIcon.hidden = YES;
  
  SKProduct *prod = iap.products[pkg.iapPackageId];
  self.nameLabel.text = prod.localizedTitle;
  
  [Globals imageNamed:pkg.imageName withView:self.monsterIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  self.monsterIcon.contentMode = UIViewContentModeCenter;
  
  self.descriptionLabel.text = [NSString stringWithFormat:@"%@ gems", [Globals commafyNumber:numGems]];
  
  [self doAnimation];
}

- (void) doAnimation {
  CAKeyframeAnimation *kf = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale" function:BackEaseOut fromValue:0 toValue:1];
  kf.duration = 0.5f;
  kf.delegate = self;
  [self.monsterIcon.layer addAnimation:kf forKey:@"bounce"];
}

- (void) doOldAnimation {
  self.infoView.center = ccp(self.frame.size.width+self.infoView.frame.size.width/2, self.frame.size.height/2);
  self.monsterSpinner.alpha = 0.f;
  self.pieceLabel.alpha = 0.f;
  
  [self rotateSpinner];
  
  CGPoint curPoint = self.monsterIcon.center;
  self.monsterIcon.center = ccp(self.frame.size.width/2, self.frame.size.height/2);
  float baseDelay = 1.f;
  [UIView animateWithDuration:0.3f delay:baseDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.monsterIcon.center = curPoint;
    self.infoView.center = ccp(self.frame.size.width-self.infoView.frame.size.width/2, self.frame.size.height/2);
    self.pieceLabel.alpha = 1.f;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.3f animations:^{
      self.monsterSpinner.alpha = 0.2f;
    }];
  }];
  
  for (int i = 0; i < self.animateViews.count; i++) {
    UIView *v = self.animateViews[i];
    v.alpha = 0.f;
    CGPoint center = v.center;
    v.center = ccpAdd(center, ccp(100, 0));
    [UIView animateWithDuration:0.3f delay:baseDelay+i*0.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
      v.alpha = 1.f;
      v.center = center;
    } completion:nil];
  }
}

- (void) rotateSpinner {
  CABasicAnimation *fullRotation;
  fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
  fullRotation.fromValue = [NSNumber numberWithFloat:0];
  fullRotation.toValue = [NSNumber numberWithFloat:M_PI * 2];
  fullRotation.duration = 6.f;
  fullRotation.repeatCount = 50000;
  [self.monsterSpinner.layer addAnimation:fullRotation forKey:@"360"];
}

- (IBAction)closeClicked:(id)sender {
  [UIView animateWithDuration:0.2f animations:^{
    self.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self removeFromSuperview];
    self.alpha = 1.f;
  }];
}

@end

@implementation NewGachaFeaturedView

- (void) awakeFromNib {
  self.coverGradient.alpha = 0.f;
  
  /*
  UIView *container = self.monsterIcon.superview;
  container.centerX = self.hpLabel.superview.originX/2+10;
  
  if ([Globals isiPhone6Plus]) {
    container.transform = CGAffineTransformMakeScale(1.2, 1.2);
    container.centerY -= 20.f;
  }
   */
  
  self.offensiveSkill = nil;
  self.defensiveSkill = nil;
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  
  self.offensiveSkillView.origin = CGPointMake(self.nameLabel.originX, self.attackLabel.originY + self.attackLabel.height + 5);
  self.defensiveSkillView.origin = self.offensiveSkillView.origin;
  
  _leftSkillViewOrigin = self.offensiveSkillView.origin;
  _rightSkillViewOrigin = self.defensiveSkillView.origin;
}

-(void)offensiveSkillTapped:(id)sender
{
  if (self.delegate && self.offensiveSkill)
  {
    UIView* parent = [self.delegate isKindOfClass:[UIViewController class]]
      ? ((UIViewController*)self.delegate).view
      : [UIApplication sharedApplication].keyWindow.rootViewController.view;
    [self.delegate skillTapped:self.offensiveSkill
                       element:_curMonsterElement
                      position:[self.offensiveSkillView.superview convertPoint:CGPointMake(self.offensiveSkillView.centerX, self.offensiveSkillView.originY) toView:parent]];
  }
}

-(void)defensiveSkillTapped:(id)sender
{
  if (self.delegate && self.defensiveSkill)
  {
    UIView* parent = [self.delegate isKindOfClass:[UIViewController class]]
      ? ((UIViewController*)self.delegate).view
      : [UIApplication sharedApplication].keyWindow.rootViewController.view;
    [self.delegate skillTapped:self.defensiveSkill
                       element:_curMonsterElement
                      position:[self.defensiveSkillView.superview convertPoint:CGPointMake(self.defensiveSkillView.centerX, self.defensiveSkillView.originY) toView:parent]];
  }
}

- (void) updateForMonsterId:(int)monsterId {
  if (!monsterId) {
    self.hidden = YES;
    return;
  } else {
    self.hidden = NO;
  }
  
  if (_curMonsterId == monsterId) {
    return;
  }
  
  _curMonsterId = monsterId;
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  MonsterProto *proto = [gs monsterWithId:monsterId];
  
  self.nameLabel.text = proto.displayName;
  self.rarityIcon.image = [Globals imageNamed:[@"battle" stringByAppendingString:[Globals imageNameForRarity:proto.quality suffix:@"tag.png"]]];
  
  _curMonsterElement = proto.monsterElement;
  
  NSString *fileName = [proto.imagePrefix stringByAppendingString:@"Character.png"];
  [Globals imageNamedWithiPhone6Prefix:fileName withView:self.monsterIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  UserMonster *um = [[UserMonster alloc] init];
  um.monsterId = monsterId;
  um.level = proto.maxLevel;
  um.offensiveSkillId = proto.baseOffensiveSkillId;
  um.defensiveSkillId = proto.baseDefensiveSkillId;
  self.attackLabel.text = [Globals commafyNumber:[gl calculateTotalDamageForMonster:um]];
  self.hpLabel.text = [Globals commafyNumber:[gl calculateMaxHealthForMonster:um]];
  self.speedLabel.text = [Globals commafyNumber:um.speed];
  
  [self updateSkillsForMonster:um];
}

- (void) updateSkillsForMonster:(UserMonster*)monster
{
  GameState *gs = [GameState sharedGameState];
  
  self.offensiveSkill = nil;
  self.defensiveSkill = nil;
  
  if (monster.offensiveSkillId == 0)
  {
    self.offensiveSkillView.hidden = YES;
    self.defensiveSkillView.origin = _leftSkillViewOrigin;
  }
  else
  {
    SkillProto* skillProto = [gs.staticSkills objectForKey:[NSNumber numberWithInteger:monster.offensiveSkillId]];
    if (skillProto)
    {
      [Globals imageNamed:[skillProto.imgNamePrefix stringByAppendingString:kSkillIconImageNameSuffix]
                 withView:self.offensiveSkillIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:NO];
      self.offensiveSkillView.hidden = NO;
      self.defensiveSkillView.origin = _rightSkillViewOrigin;
      self.offensiveSkill = skillProto;
    }
  }
  
  if (monster.defensiveSkillId == 0)
  {
    self.defensiveSkillView.hidden = YES;
  }
  else
  {
    SkillProto* skillProto = [gs.staticSkills objectForKey:[NSNumber numberWithInteger:monster.defensiveSkillId]];
    if (skillProto)
    {
      [Globals imageNamed:[skillProto.imgNamePrefix stringByAppendingString:kSkillIconImageNameSuffix]
                 withView:self.defensiveSkillIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:NO];
      self.defensiveSkillView.hidden = NO;
      self.defensiveSkill = skillProto;
    }
  }
}

@end

@implementation NewGachaItemCell

- (void) awakeFromNib {
  /*
  self.icon.layer.anchorPoint = ccp(0.5, 0.75);
  self.icon.center = ccpAdd(self.icon.center, ccp(0, self.icon.frame.size.height*(self.icon.layer.anchorPoint.y-0.5)));
   */
}

- (void) updateForGachaDisplayItem:(BoosterDisplayItemProto *)item {
  NSString *iconName = nil;
  if (item.isMonster) {
    //NSString *bgdImage = [@"gacha" stringByAppendingString:[Globals imageNameForRarity:item.quality suffix:@"bg.png"]];
    //[Globals imageNamed:bgdImage withView:self.bgdView greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    if (item.isComplete) {
      iconName = [@"gacha" stringByAppendingString:[Globals imageNameForRarity:item.quality suffix:@"ball.png"]];
      self.shadowIcon.hidden = NO;
    } else {
      iconName = [@"gacha" stringByAppendingString:[Globals imageNameForRarity:item.quality suffix:@"piece.png"]];
      self.shadowIcon.hidden = YES;
    }
    self.label.text = [[Globals stringForRarity:item.quality] uppercaseString];
    self.label.textColor = [Globals colorForRarity:item.quality];
    
    self.diamondIcon.hidden = YES;
    self.icon.hidden = NO;
  } else {
    //NSString *bgdImage = @"gachagemsbg.png";
    //[Globals imageNamed:bgdImage withView:self.bgdView greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    self.label.text = [Globals commafyNumber:item.gemReward];
    self.label.textColor = [Globals purplishPinkColor];
    
    self.diamondIcon.hidden = NO;
    self.shadowIcon.hidden = YES;
    self.icon.hidden = YES;
  }
  [Globals imageNamed:iconName withView:self.icon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
}

- (void) shakeIconNumTimes:(int)numTimes durationPerShake:(float)duration delay:(float)delay completion:(void (^)(void))comp {
  CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
  // Divide by 2 to account for autoreversing
  int repeatCt = numTimes;
  [animation setDuration:duration];
  [animation setRepeatCount:repeatCt];
  [animation setBeginTime:CACurrentMediaTime()+delay];
  animation.values = [NSArray arrayWithObjects:   	// i.e., Rotation values for the 3 keyframes, in RADIANS
                      [NSNumber numberWithFloat:0.0 * M_PI],
                      [NSNumber numberWithFloat:0.04 * M_PI],
                      [NSNumber numberWithFloat:-0.04 * M_PI],
                      [NSNumber numberWithFloat:0.0 * M_PI], nil];
  animation.keyTimes = [NSArray arrayWithObjects:
                        [NSNumber numberWithFloat:0],
                        [NSNumber numberWithFloat:.25],
                        [NSNumber numberWithFloat:.75],
                        [NSNumber numberWithFloat:1.0], nil];
  animation.timingFunctions = [NSArray arrayWithObjects:
                               [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                               [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                               [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], nil];
  animation.removedOnCompletion = YES;
  animation.delegate = self;
  _completion = comp;
  [self.icon.layer addAnimation:animation forKey:@"rotation"];
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  if (_completion) {
    _completion();
  }
}

@end
