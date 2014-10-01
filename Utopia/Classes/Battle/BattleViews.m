//
//  BattleContinueView.m
//  Utopia
//
//  Created by Ashwin Kamath on 9/18/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "BattleViews.h"
#import "Globals.h"
#import "GameState.h"
#import "CAKeyframeAnimation+AHEasing.h"

#define REWARDSVIEW_OFFSET 50

@implementation BattleLostView

- (void) didLoadFromCCB {
  //self.spinner.blendFunc = (ccBlendFunc){GL_SRC_ALPHA, GL_ONE};
  self.spinner.blendMode = [CCBlendMode blendModeWithOptions:@{CCBlendFuncSrcColor: @(GL_SRC_ALPHA), CCBlendFuncDstColor: @(GL_ONE)}];
  
  self.continueButton.label.position = ccp(0.5, 0.52);
  
  self.tipLabel.fontName = @"Whitney-Semibold";
  self.tipLabel.string = [@"Tip: " stringByAppendingString:[Globals getRandomTipFromFile:@"tips"]];
}

- (void) onExitTransitionDidStart {
  [self.rewardsScrollView removeFromSuperview];
  [self.loadingSpinner removeFromSuperview];
  
  CCClippingNode *clip = (CCClippingNode *)self.rewardsView.parent;
  clip.stencil = nil;
  
  [super onExitTransitionDidStart];
}

- (void) onEnterTransitionDidFinish {
  [super onEnterTransitionDidFinish];
  float firstDur = 0.4f;
  float secondDur = 0.6f;
  float thirdDur = 0.2f;
  float fourthDur = 0.5f;
  float fifthDur = 0.3f;
  float sixthDur = 0.3f;
  float seventhDur = 0.3f;
  
  self.bgdNode.opacity = 0.f;
  self.bgdNode.scale = MAX(self.parent.contentSize.height/self.bgdNode.contentSize.height,
                           self.parent.contentSize.width/self.bgdNode.contentSize.width);
  self.rewardsBgd.scale = 1/self.bgdNode.scale;
  [self.bgdNode runAction:[RecursiveFadeTo actionWithDuration:firstDur opacity:1.f]];
  
  CGPoint orig = self.headerView.position;
  self.headerView.position = ccpAdd(orig, ccp(0, 150));
  [self.headerView runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:firstDur],
    [CCActionEaseBounceOut actionWithAction:[CCActionMoveTo actionWithDuration:secondDur position:orig]], nil]];
  
  if (self.stickerHead.visible) {
    self.stickerHead.scale = 0.f;
    [self.stickerHead runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:firstDur+secondDur-0.1],
                                 [CCActionEaseElastic actionWithAction:[CCActionScaleTo actionWithDuration:thirdDur scale:1.f]], nil]];
    self.stickerHead.rotation = -12.5;
    CCActionRotateBy *rotate = [CCActionRotateBy actionWithDuration:fourthDur angle:-self.stickerHead.rotation*2];
    [self.stickerHead runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:rotate, rotate.reverse, nil]]];
  } else {
    self.lostLabel.opacity = 0.f;
    [self.lostLabel runAction:
     [CCActionSequence actions:
      [CCActionDelay actionWithDuration:firstDur+secondDur],
      [CCActionFadeTo actionWithDuration:thirdDur opacity:1.f], nil]];
    
    for (int i = 0; i < self.rewardsView.children.count; i++) {
      CCNode *n = self.rewardsView.children[i];
      CGPoint pt = n.position;
      n.position = ccpAdd(pt, ccp(400, 0));
      [n recursivelyApplyOpacity:0.f];
      [n runAction:
       [CCActionSequence actions:
        [CCActionDelay actionWithDuration:firstDur+secondDur+i*thirdDur],
        [CCActionSpawn actions: [RecursiveFadeTo actionWithDuration:0.3f opacity:1.f],
         [CCActionEaseOut actionWithAction:[CCActionMoveTo actionWithDuration:fourthDur position:pt] rate:10], nil],
        nil]];
    }
    
    if (self.rewardsView.contentSize.width+REWARDSVIEW_OFFSET*2 > self.rewardsView.parent.contentSize.width) {
      // Scroll the rewards view with the children
      float maxSpot = self.rewardsView.parent.contentSize.width-self.rewardsView.contentSize.width-REWARDSVIEW_OFFSET;
      [self.rewardsView runAction:
       [CCActionSequence actions:
        [CCActionDelay actionWithDuration:firstDur+secondDur+thirdDur*1],
        [CCActionEaseInOut actionWithAction:
         [CCActionMoveTo actionWithDuration:(self.rewardsView.children.count-1)*thirdDur position:ccp(maxSpot, self.rewardsView.position.y)] rate:1.5f],
        [CCActionCallBlock actionWithBlock:
         ^{
           self.rewardsScrollView.contentOffset = ccp(self.rewardsScrollView.contentSize.width-self.rewardsScrollView.frame.size.width, 0);
           self.rewardsScrollView.userInteractionEnabled = YES;
         }], nil]];
      self.rewardsScrollView.userInteractionEnabled = NO;
    }
  }
  
  float time = firstDur+secondDur+thirdDur-0.1;
  CCActionSequence *seq = [CCActionSequence actions:
                           [CCActionDelay actionWithDuration:time],
                           [CCActionEaseBackOut actionWithAction:[CCActionScaleTo actionWithDuration:fifthDur scale:1.f]], nil];
  self.shareButton.scale = 0.f;
  [self.shareButton runAction:seq.copy];
  self.continueButton.scale = 0.f;
  [self.continueButton runAction:seq.copy];
  
  time += fifthDur-0.1;
  self.doneButton.scale = 0.f;
  [self.doneButton runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:time],
    [CCActionEaseBackOut actionWithAction:[CCActionScaleTo actionWithDuration:sixthDur scale:1.f]], nil]];
  
  time += sixthDur-0.1;
  CGPoint pt = self.tipLabel.position;
  self.tipLabel.position = ccpAdd(pt, ccp(0, -50));
  [self.tipLabel runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:time],
    [CCActionMoveTo actionWithDuration:seventhDur position:pt], nil]];
  
  time += seventhDur;
  self.spinner.visible = NO;
  [self.spinner runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:time],
                           [CCActionCallBlock actionWithBlock:
                            ^{
                              self.spinner.visible = YES;
                              self.spinner.opacity = 0.f;
                            }],
                           [CCActionFadeTo actionWithDuration:0.2f opacity:1.f], nil]];
  [self.spinner runAction:[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:6.f angle:180]]];
  
  [self.youLostHeader runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:time],
    [CCActionCallBlock actionWithBlock:
     ^{
       CCActionScaleBy *scale = [CCActionScaleBy actionWithDuration:0.5 scale:1.1];
       [self.youLostHeader runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:scale, scale.reverse, nil]]];
     }], nil]];
}

- (void) updateForRewards:(NSArray *)rewards {
  if (!rewards.count) {
    return;
  }
  
  CCLabelTTF *label = [CCLabelTTF labelWithString:@"You will miss out on:" fontName:@"Gotham-Ultra" fontSize:10.f];
  label.color = [CCColor whiteColor];
  [self addChild:label];
  label.position = ccpAdd(self.rewardsBgd.position, ccp(0, self.rewardsBgd.contentSize.height/2-10));
  self.lostLabel = label;
  
  CCNode *node = [CCNode node];
  
  for (int i = 0; i < rewards.count; i++) {
    BattleRewardNode *brn = [[BattleRewardNode alloc] initWithReward:rewards[i] isForLoss:YES];
    [node addChild:brn];
    brn.position = ccp((8+brn.contentSize.width)*(i+0.5)+4, 44);
    
    node.contentSize = CGSizeMake(brn.position.x+brn.contentSize.width/2+8, 86.f);
  }
  node.anchorPoint = ccp(0, 0.5);
  node.position = ccp(self.rewardsView.contentSize.width, self.rewardsBgd.contentSize.height/2);
  self.rewardsView = node;
  
  [self.rewardsScrollView removeFromSuperview];
  self.rewardsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(110, 180, 349, 76)];
  self.rewardsScrollView.delegate = self;
  self.rewardsScrollView.backgroundColor = [UIColor clearColor];
  self.rewardsScrollView.showsHorizontalScrollIndicator = NO;
  
  [Globals displayUIView:self.rewardsScrollView];
  self.rewardsScrollView.center = ccp(self.contentSize.width/2, 175);
  
  CCClippingNode *clip = [CCClippingNode clippingNode];
  clip.contentSize = self.rewardsScrollView.frame.size;
  clip.anchorPoint = ccp(0.5, 0.5);
  [self.rewardsBgd addChild:clip];
  clip.position = ccp(self.rewardsBgd.contentSize.width/2, self.rewardsBgd.contentSize.height/2-5);
  CCDrawNode *stencil = [CCDrawNode node];
  CGPoint rectangle[] = {{0, 0}, {clip.contentSize.width, 0}, {clip.contentSize.width, clip.contentSize.height}, {0, clip.contentSize.height}};
  [stencil drawPolyWithVerts:rectangle count:4 fillColor:[CCColor whiteColor] borderWidth:1 borderColor:[CCColor whiteColor]];
  clip.stencil = stencil;
  
  [clip addChild:node];
  
  // Leave a distance on each side
  self.rewardsScrollView.contentSize = CGSizeMake(self.rewardsView.contentSize.width+REWARDSVIEW_OFFSET*2, self.rewardsScrollView.frame.size.height);
  
  self.stickerHead.visible = NO;
  
  [self scrollViewDidScroll:self.rewardsScrollView];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
  if (self.rewardsView.contentSize.width+REWARDSVIEW_OFFSET*2 < self.rewardsScrollView.frame.size.width) {
    // Smaller
    self.rewardsView.position = ccp(-self.rewardsScrollView.contentOffset.x+self.rewardsView.parent.contentSize.width/2-self.rewardsView.contentSize.width/2, self.rewardsView.position.y);
  } else {
    self.rewardsView.position = ccp(-self.rewardsScrollView.contentOffset.x+REWARDSVIEW_OFFSET, self.rewardsView.position.y);
  }
}

- (void) loadSpinnerAtCenter:(CGPoint)center {
  self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  [self.loadingSpinner startAnimating];
  [Globals displayUIView:self.loadingSpinner];
  self.loadingSpinner.center = [[CCDirector sharedDirector] convertToUI:center];
}

- (void) spinnerOnDone {
  self.doneButton.title = @"";
  [self loadSpinnerAtCenter:[self.doneButton.parent convertToWorldSpace:self.doneButton.position]];
}

- (void) spinnerOnManage {
  self.manageButton.title = @"";
  [self loadSpinnerAtCenter:[self.manageButton.parent convertToWorldSpace:self.manageButton.position]];
}

@end

@implementation BattleWonView

- (void) didLoadFromCCB {
  //self.spinner.blendFunc = (ccBlendFunc){GL_SRC_ALPHA, GL_ONE};
  self.spinner.blendMode = [CCBlendMode blendModeWithOptions:@{CCBlendFuncSrcColor: @(GL_SRC_ALPHA), CCBlendFuncDstColor: @(GL_ONE)}];
  
  self.tipLabel.fontName = @"Whitney-Semibold";
  self.tipLabel.string = [@"Tip: " stringByAppendingString:[Globals getRandomTipFromFile:@"tips"]];
}

- (void) onExitTransitionDidStart {
  [self.rewardsScrollView removeFromSuperview];
  [self.loadingSpinner removeFromSuperview];
  
  CCClippingNode *clip = (CCClippingNode *)self.rewardsView.parent;
  clip.stencil = nil;
  
  [super onExitTransitionDidStart];
}

- (void) updateForRewards:(NSArray *)rewards {
  if (!rewards.count) {
    return;
  }
  
  CCNode *node = [CCNode node];
  
  for (int i = 0; i < rewards.count; i++) {
    BattleRewardNode *brn = [[BattleRewardNode alloc] initWithReward:rewards[i] isForLoss:NO];
    [node addChild:brn];
    brn.position = ccp((8+brn.contentSize.width)*(i+0.5)+4, 50);
    
    node.contentSize = CGSizeMake(brn.position.x+brn.contentSize.width/2+8, 86.f);
  }
  node.anchorPoint = ccp(0, 0.5);
  node.position = ccp(self.rewardsView.contentSize.width, self.rewardsBgd.contentSize.height/2);
  self.rewardsView = node;
  
  [self.rewardsScrollView removeFromSuperview];
  self.rewardsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(110, 180, 349, 76)];
  self.rewardsScrollView.delegate = self;
  self.rewardsScrollView.backgroundColor = [UIColor clearColor];
  self.rewardsScrollView.showsHorizontalScrollIndicator = NO;
  
  [Globals displayUIView:self.rewardsScrollView];
  self.rewardsScrollView.center = ccp(self.contentSize.width/2, 175);
  
  CCClippingNode *clip = [CCClippingNode clippingNode];
  clip.contentSize = self.rewardsScrollView.frame.size;
  clip.anchorPoint = ccp(0.5, 0.5);
  [self.rewardsBgd addChild:clip];
  clip.position = ccp(self.rewardsBgd.contentSize.width/2, self.rewardsBgd.contentSize.height/2-5);
  CCDrawNode *stencil = [CCDrawNode node];
  CGPoint rectangle[] = {{0, 0}, {clip.contentSize.width, 0}, {clip.contentSize.width, clip.contentSize.height}, {0, clip.contentSize.height}};
  [stencil drawPolyWithVerts:rectangle count:4 fillColor:[CCColor whiteColor] borderWidth:1 borderColor:[CCColor whiteColor]];
  clip.stencil = stencil;
  
  [clip addChild:node];
  
  // Leave a distance on each side
  self.rewardsScrollView.contentSize = CGSizeMake(self.rewardsView.contentSize.width+REWARDSVIEW_OFFSET*2, self.rewardsScrollView.frame.size.height);
  
  self.stickerHead.visible = NO;
  
  [self scrollViewDidScroll:self.rewardsScrollView];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
  if (self.rewardsView.contentSize.width+REWARDSVIEW_OFFSET*2 < self.rewardsScrollView.frame.size.width) {
    // Smaller
    self.rewardsView.position = ccp(-self.rewardsScrollView.contentOffset.x+self.rewardsView.parent.contentSize.width/2-self.rewardsView.contentSize.width/2, self.rewardsView.position.y);
  } else {
    self.rewardsView.position = ccp(-self.rewardsScrollView.contentOffset.x+REWARDSVIEW_OFFSET, self.rewardsView.position.y);
  }
}

- (void) onEnterTransitionDidFinish {
  [super onEnterTransitionDidFinish];
  float firstDur = 0.4f;
  float secondDur = 0.6f;
  float thirdDur = 0.5f;
  float fourthDur = 0.5f;
  float fifthDur = 0.3f;
  float sixthDur = 0.3f;
  float seventhDur = 0.3f;
  
  self.bgdNode.opacity = 0.f;
  [self.bgdNode runAction:[RecursiveFadeTo actionWithDuration:firstDur opacity:1.f]];
  
  CGPoint orig = self.headerView.position;
  self.headerView.position = ccpAdd(orig, ccp(0, 150));
  [self.headerView runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:firstDur],
    [CCActionEaseBounceOut actionWithAction:[CCActionMoveTo actionWithDuration:secondDur position:orig]], nil]];
  
  for (int i = 0; i < self.rewardsView.children.count; i++) {
    CCNode *n = self.rewardsView.children[i];
    CGPoint pt = n.position;
    n.position = ccpAdd(pt, ccp(400, 0));
    [n recursivelyApplyOpacity:0.f];
    [n runAction:
     [CCActionSequence actions:
      [CCActionDelay actionWithDuration:firstDur+secondDur+i*thirdDur],
      [CCActionSpawn actions: [RecursiveFadeTo actionWithDuration:0.3f opacity:1.f],
       [CCActionEaseOut actionWithAction:[CCActionMoveTo actionWithDuration:fourthDur position:pt] rate:10], nil],
      nil]];
  }
  
  if (self.rewardsView.contentSize.width+REWARDSVIEW_OFFSET*2 > self.rewardsView.parent.contentSize.width) {
    // Scroll the rewards view with the children
    float maxSpot = self.rewardsView.parent.contentSize.width-self.rewardsView.contentSize.width-REWARDSVIEW_OFFSET;
    [self.rewardsView runAction:
     [CCActionSequence actions:
      [CCActionDelay actionWithDuration:firstDur+secondDur+thirdDur*1],
      [CCActionEaseInOut actionWithAction:
       [CCActionMoveTo actionWithDuration:(self.rewardsView.children.count-1)*thirdDur position:ccp(maxSpot, self.rewardsView.position.y)] rate:1.5f],
      [CCActionCallBlock actionWithBlock:
       ^{
         self.rewardsScrollView.contentOffset = ccp(self.rewardsScrollView.contentSize.width-self.rewardsScrollView.frame.size.width, 0);
         self.rewardsScrollView.userInteractionEnabled = YES;
       }], nil]];
    self.rewardsScrollView.userInteractionEnabled = NO;
  }
  
  if (self.stickerHead.visible) {
    self.stickerHead.scale = 0.f;
    [self.stickerHead runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:firstDur+secondDur-0.1],
                                 [CCActionEaseElastic actionWithAction:[CCActionScaleTo actionWithDuration:thirdDur scale:1.f]], nil]];
    self.stickerHead.rotation = -12.5;
    CCActionRotateBy *rotate = [CCActionRotateBy actionWithDuration:fourthDur angle:-self.stickerHead.rotation*2];
    [self.stickerHead runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:rotate, rotate.reverse, nil]]];
  }
  
  float time = firstDur+secondDur+self.rewardsView.children.count*thirdDur+fourthDur-0.2;
  self.shareButton.scale = 0.f;
  [self.shareButton runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:time],
    [CCActionEaseBackOut actionWithAction:[CCActionScaleTo actionWithDuration:fifthDur scale:1.f]], nil]];
  
  time += fifthDur-0.1;
  self.doneButton.scale = 0.f;
  [self.doneButton runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:time],
    [CCActionEaseBackOut actionWithAction:[CCActionScaleTo actionWithDuration:sixthDur scale:1.f]], nil]];
  
  time += sixthDur-0.1;
  CGPoint pt = self.tipLabel.position;
  self.tipLabel.position = ccpAdd(pt, ccp(0, -50));
  [self.tipLabel runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:time],
    [CCActionMoveTo actionWithDuration:seventhDur position:pt], nil]];
  
  time += seventhDur;
  self.spinner.visible = NO;
  [self.spinner runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:time],
                           [CCActionCallBlock actionWithBlock:
                            ^{
                              self.spinner.visible = YES;
                              self.spinner.opacity = 0.f;
                            }],
                           [CCActionFadeTo actionWithDuration:0.2f opacity:1.f], nil]];
  [self.spinner runAction:[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:6.f angle:180]]];
  
  [self.youWonHeader runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:time],
    [CCActionCallBlock actionWithBlock:
     ^{
       CCActionScaleBy *scale = [CCActionScaleBy actionWithDuration:0.5 scale:1.1];
       [self.youWonHeader runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:scale, scale.reverse, nil]]];
     }], nil]];
}

- (void) loadSpinnerAtCenter:(CGPoint)center {
  self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  [self.loadingSpinner startAnimating];
  [Globals displayUIView:self.loadingSpinner];
  self.loadingSpinner.center = [[CCDirector sharedDirector] convertToUI:center];
}

- (void) spinnerOnDone {
  self.doneButton.title = @"";
  [self loadSpinnerAtCenter:[self.doneButton.parent convertToWorldSpace:self.doneButton.position]];
}

- (void) spinnerOnManage {
  self.manageButton.title = @"";
  [self loadSpinnerAtCenter:[self.manageButton.parent convertToWorldSpace:self.manageButton.position]];
}

@end

@implementation BattleRewardNode

- (id) initWithReward:(Reward *)reward isForLoss:(BOOL)loss {
  GameState *gs = [GameState sharedGameState];
  NSString *imgName = nil;
  NSString *labelName = nil;
  NSString *labelImage = nil;
  NSString *bgdName = nil;
  NSString *borderName = nil;
  UIColor *color = nil;
  BOOL isPiece = NO;
  if (reward.type == RewardTypeMonster) {
    MonsterProto *mp = [gs monsterWithId:reward.monsterId];
    imgName = [mp.imagePrefix stringByAppendingString:@"Card.png"];
    bgdName = [Globals imageNameForRarity:mp.quality suffix:@"found.png"];
    labelImage = [@"battle" stringByAppendingString:[Globals imageNameForRarity:mp.quality suffix:@"tag.png"]];
    isPiece = mp.numPuzzlePieces > 1;
  } else if (reward.type == RewardTypeSilver) {
    imgName = @"moneystack.png";
    bgdName = @"cashfound.png";
    labelName = [Globals commafyNumber:reward.silverAmount];
    color = [Globals greenColor];
  } else if (reward.type == RewardTypeOil) {
    imgName = @"oilicon.png";
    bgdName = @"ultrafound.png";
    labelName = [Globals commafyNumber:reward.oilAmount];
    color = [Globals goldColor];
  } else if (reward.type == RewardTypeGold) {
    imgName = @"diamond.png";
    bgdName = @"commonfound.png";
    labelName = [Globals commafyNumber:reward.goldAmount];
    color = [Globals purplishPinkColor];
  } else if (reward.type == RewardTypeItem) {
    ItemProto *item = [gs itemForId:reward.itemId];
    imgName = item.imgName;
    labelName = item.name;
    bgdName = @"commonfound.png";
    color = [Globals creamColor];
  }
  
  if (loss) {
    bgdName = @"youlostitembg.png";
    borderName = @"youlostitemborder.png";
  } else {
    bgdName = @"youwonitembg.png";
    borderName = @"youwonitemborder.png";
  }
  
  if ((self = [super initWithImageNamed:bgdName])) {
    CCSprite *inside = [CCSprite spriteWithImageNamed:imgName];
    [self addChild:inside];
    inside.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    if (inside.contentSize.height > self.contentSize.height) {
      inside.scale = self.contentSize.height/inside.contentSize.height;
    }
    
    float labelPosition = loss ? -10.f : -13.f;
    if (labelName) {
      CCLabelTTF *label = [CCLabelTTF labelWithString:labelName fontName:@"Gotham-Ultra" fontSize:11.f dimensions:CGSizeMake(self.contentSize.width, 15)];
      label.horizontalAlignment = CCTextAlignmentCenter;
      label.color = [CCColor colorWithUIColor:color];
      [self addChild:label];
      label.position = ccp(self.contentSize.width/2, labelPosition-1);
    } else if (labelImage) {
      CCSprite *label = [CCSprite spriteWithImageNamed:labelImage];
      [self addChild:label];
      label.position = ccp(self.contentSize.width/2, labelPosition);
    }
    
    if (isPiece) {
      CCLabelTTF *label = [CCLabelTTF labelWithString:@"Piece" fontName:@"Gotham-Ultra" fontSize:8.f dimensions:CGSizeMake(self.contentSize.width, 15)];
      label.horizontalAlignment = CCTextAlignmentCenter;
      label.color = [CCColor whiteColor];
      label.shadowColor = [CCColor colorWithWhite:0.f alpha:0.76];
      label.shadowBlurRadius = 1.f;
      label.shadowOffset = ccp(0, -1);
      [self addChild:label];
      label.position = ccp(self.contentSize.width/2, label.contentSize.height/2);
    }
    
    CCSprite *border = [CCSprite spriteWithImageNamed:borderName];
    [self addChild:border];
    border.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
  }
  return self;
}

@end

@implementation BattleQueueNode

- (void) didLoadFromCCB {
  self.cashLabel.fontName = @"Gotham-Ultra";
  self.oilLabel.fontName = @"Gotham-Ultra";
  self.leagueLabel.fontName = @"Ziggurat-HTF-Black-Italic";
  
  CCClippingNode *clip = [CCClippingNode clippingNode];
  CCNode *stencil = [CCNode node];
  CCSprite *spr = [CCSprite spriteWithImageNamed:@"nightbigavatar.png"];
  [stencil addChild:spr];
  spr.position = ccp(spr.contentSize.width/2, spr.contentSize.height/2);
  clip.stencil = stencil;
  clip.alphaThreshold = 0.f;
  clip.contentSize = self.monsterBgd.contentSize;
  self.monsterIcon = [CCSprite spriteWithImageNamed:@"Zark1T1Card.png"];
  self.monsterIcon.scale = clip.contentSize.height/self.monsterIcon.contentSize.height;
  self.monsterIcon.position = ccp(clip.contentSize.width/2, clip.contentSize.height/2);
  [clip addChild:self.monsterIcon];
  [self.monsterBgd addChild:clip];
  
}

- (void) updateForPvpProto:(PvpProto *)pvp {
  self.nameLabel.string = pvp.defender.minUserProto.name;
  self.cashLabel.string = [Globals cashStringForNumber:pvp.prospectiveCashWinnings];
  self.oilLabel.string = [Globals commafyNumber:pvp.prospectiveOilWinnings];
  
  GameState *gs = [GameState sharedGameState];
  TownHallProto *thp = (TownHallProto *)gs.myTownHall.staticStruct;
  self.nextMatchCostLabel.string = [Globals cashStringForNumber:thp.pvpQueueCashCost];
  
  int avatarId = pvp.defender.minUserProto.avatarMonsterId;
  while (!avatarId) {
    NSMutableArray *arr = gs.staticMonsters.allValues.mutableCopy;
    [arr shuffle];
    
    MonsterProto *mp = arr[0];
    if (mp.imagePrefix.length) {
      avatarId = mp.monsterId;
    }
  }
  MonsterProto *avMonster = [gs monsterWithId:avatarId];
  NSString *file = [Globals imageNameForElement:avMonster.monsterElement suffix:@"bigavatar.png"];
  [self.monsterBgd setSpriteFrame:[CCSpriteFrame frameWithImageNamed:file]];
  file = [avMonster.imagePrefix stringByAppendingString:@"Card.png"];
  self.monsterIcon.spriteFrame = nil;
  [Globals imageNamed:file toReplaceSprite:self.monsterIcon];
  
  if (pvp.pvpLeagueStats) {
    PvpLeagueProto *pvpLeague = [gs leagueForId:pvp.pvpLeagueStats.leagueId];
    NSString *league = pvpLeague.imgPrefix;
    int rank = pvp.pvpLeagueStats.rank;
    [self.leagueBgd setSpriteFrame:[CCSpriteFrame frameWithImageNamed:[@"pvp" stringByAppendingString:[league stringByAppendingString:@"ribbon.png"]]]];
    [self.leagueIcon setSpriteFrame:[CCSpriteFrame frameWithImageNamed:[league stringByAppendingString:@"icon.png"]]];
    self.leagueLabel.string = pvpLeague.leagueName;
    self.rankLabel.string = [Globals commafyNumber:rank];
    self.rankQualifierLabel.string = [Globals qualifierStringForNumber:rank];
    
    float leftSide = self.rankLabel.position.x+self.rankLabel.contentSize.width;
    self.rankQualifierLabel.position = ccp(leftSide+5, self.rankQualifierLabel.position.y);
    self.placeLabel.position = ccp(leftSide+5, self.placeLabel.position.y);
  }
}

- (void) fadeInAnimationForIsRevenge:(BOOL)isRevenge {
  float dur = 0.2f;
  
  if (isRevenge) {
    float left = self.nextButtonNode.position.x-self.nextButtonNode.contentSize.width/2;
    float right = self.attackButtonNode.position.x+self.attackButtonNode.contentSize.width/2;
    [self.nextButtonNode removeFromParent];
    self.attackButtonNode.position = ccp(left+(right-left)/2, self.attackButtonNode.position.y);
  }
  
  NSArray *nodes = @[self.monsterBgd.parent, self.nameLabel, self.cashNode, self.oilNode, self.leagueNode, self.nextButtonNode, self.attackButtonNode];
  for (int i = 0; i < nodes.count; i++) {
    CCNode *node = nodes[i];
    
    node.visible = YES;
    [node recursivelyApplyOpacity:0.f];
    CGPoint oldPos = node.position;
    node.position = ccpAdd(oldPos, ccp(20, 0));
    
    [node runAction:
     [CCActionSequence actions:
      [CCActionDelay actionWithDuration:(dur-0.1)*i],
      [CCActionSpawn actions:
       [RecursiveFadeTo actionWithDuration:dur opacity:1.f],
       [CCActionMoveTo actionWithDuration:dur position:oldPos], nil],
      [CCActionCallBlock actionWithBlock:
       ^{
         if (i == nodes.count-1) {
           self.userInteractionEnabled = YES;
         }
       }],
      nil]];
  }
  
  self.gradientNode.opacity = 0.f;
  [self.gradientNode runAction:[CCActionFadeTo actionWithDuration:0.7f opacity:1.f]];
}

- (void) fadeOutAnimation {
  float dur = 0.2f;
  
  NSArray *nodes = @[self.monsterBgd.parent, self.nameLabel, self.cashNode, self.oilNode, self.leagueNode, self.nextButtonNode, self.attackButtonNode];
  for (int i = 0; i < nodes.count; i++) {
    CCNode *node = nodes[nodes.count-i-1];
    
    [node recursivelyApplyOpacity:1.f];
    CGPoint oldPos = node.position;
    
    [node runAction:
     [CCActionSequence actions:
      [CCActionDelay actionWithDuration:(dur-0.1)*i],
      [CCActionSpawn actions:
       [RecursiveFadeTo actionWithDuration:dur opacity:0.f],
       [CCActionMoveTo actionWithDuration:dur position:ccpAdd(oldPos, ccp(20, 0))], nil],
      [CCActionCallBlock actionWithBlock:
       ^{
         node.position = oldPos;
         node.visible = NO;
       }],
      nil]];
  }
  
  [self.gradientNode runAction:
   [CCActionFadeTo actionWithDuration:1.f opacity:0.f]];
  
  self.userInteractionEnabled = NO;
}

@end
