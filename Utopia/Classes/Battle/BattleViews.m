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
#import <cocos2d-ui/CCControlSubclass.h>

#define REWARDSVIEW_OFFSET 0

@implementation CancellableTextField

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  if (self.isFirstResponder) {
    if (![super pointInside:point withEvent:event]) {
      [self resignFirstResponder];
    }
    return YES;
  }
  return [super pointInside:point withEvent:event];
}

@end

@implementation BattleEndView

- (void) didLoadFromCCB {
  self.spinner.blendMode = [CCBlendMode blendModeWithOptions:@{CCBlendFuncSrcColor: @(GL_SRC_ALPHA), CCBlendFuncDstColor: @(GL_ONE)}];
  
  self.continueButton.label.position = ccp(0.5, 0.52);
  
  self.tipLabel.fontName = @"Whitney-Semibold";
  self.tipLabel.string = [@"Tip: " stringByAppendingString:[Globals getRandomTipFromFile:@"tips"]];
  
  // Move the bgd node to the main hierarchy
  self.mainNode = self.bgdNode.parent;
  [self.bgdNode removeFromParent];
  [self addChild:self.bgdNode z:-1];
}

- (void) setupContinueLayout:(int)gems {
  
  CCSpriteFrame *frame = [self.continueButton backgroundSpriteFrameForState:CCControlStateNormal];
  self.continueButton.preferredSize = frame.originalSize;
  self.continueButton.maxSize = frame.originalSize;
  self.continueButton.position = ccp(0,0);
  self.continueButton.label.fontSize += 2.f;
  NSString *buttonStr = [NSString stringWithFormat:@"CONTINUE          %d", gems];
  [self.continueButton setTitle:buttonStr];
  
  CCSprite *sprite = [CCSprite spriteWithImageNamed:@"diamond.png"];
  [self.continueButton addChild:sprite];
  sprite.scale = 0.6;
  
  NSString *str = @"CONTINUE     ";
  UIFont *font = [UIFont fontWithName:self.continueButton.label.fontName size:self.continueButton.label.fontSize];
  CGSize s1 = [str getSizeWithFont:font];
  CGSize s2 = [buttonStr getSizeWithFont:font];
  sprite.position = ccp(s1.width-s2.width/2+self.continueButton.contentSize.width/2, self.continueButton.contentSize.height/2);
  
  self.continueButton.label.position = ccpAdd(self.continueButton.label.position, ccp(0, 5));
  
  self.doneButton.position = ccp(0.5, self.tipLabel.position.y+0.03f);
  self.doneButton.positionType = CCPositionTypeNormalized;
  [self.doneButton removeFromParent];
  [self.tipLabel.parent addChild:self.doneButton];
  
  self.headerView.position = ccpAdd(self.headerView.position, ccp(0, 0.05f));
  self.spinner.position = ccpAdd(self.spinner.position, ccp(0, 0.05f));
  self.rewardsBgd.parent.parent.position = ccpAdd(self.rewardsBgd.parent.parent.position, ccp(0, 0.05f));
  self.continueButton.parent.position = ccpAdd(self.continueButton.parent.position, ccp(0, 0.06f));
  
  [self.tipLabel removeFromParent];
}

- (void) updateForRewards:(NSArray *)rewards isWin:(BOOL)isWin showsReplay:(BOOL)showsReplay allowsContinue:(BOOL)allowsContinue continueCost:(int)continueCost {
  _isWin = isWin;
  
  if (!isWin) {
    self.topLabelHeader.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"youlostyou.png"];
    self.botLabelHeader.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"youlostlost.png"];
    self.ribbon.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"youmissoutonribbon.png"];
    self.stickerHead.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"loststickerhead.png"];
  }
  
  
  // Add a clipping node for the rewards bg so that it can fall
  
  CCSprite *stencil = [CCSprite spriteWithSpriteFrame:self.rewardsBgd.spriteFrame];
  CCClippingNode *clip = [CCClippingNode clippingNodeWithStencil:stencil];
  clip.contentSize = stencil.contentSize;
  clip.anchorPoint = ccp(0.5, 0.5);
  clip.position = self.rewardsBgd.position;
  [self.rewardsBgd.parent addChild:clip z:-1];
  stencil.position = ccp(clip.contentSize.width/2, clip.contentSize.height/2);
  
  [self.rewardsBgd removeFromParentAndCleanup:NO];
  [clip addChild:self.rewardsBgd];
  self.rewardsBgd.position = ccp(clip.contentSize.width/2, clip.contentSize.height/2);
  
  
  if (allowsContinue) {
    [self setupContinueLayout:continueCost];
  }
  
  if (showsReplay) {
    self.shareButton.title = @"REPLAY";
  }
  
  
  if (!rewards.count) {
    self.ribbonLabel.string = isWin ? @"GOOD JOB!" : @"BETTER LUCK NEXT TIME!";
  } else {
    self.ribbonLabel.string = isWin ? @"YOU FOUND" : allowsContinue ? @"YOU WILL MISS OUT ON" : @"BETTER LUCK NEXT TIME!";
    
    // Add a clipping node for rewards and enforce it with a scroll view
    [self.rewardsScrollView removeFromSuperview];
    self.rewardsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(110, 180, 349, 76)];
    self.rewardsScrollView.delegate = self;
    self.rewardsScrollView.backgroundColor = [UIColor clearColor];
    self.rewardsScrollView.showsHorizontalScrollIndicator = NO;
    [Globals displayUIView:self.rewardsScrollView];
    
    //Rewards
    CCNode *node = [CCNode node];
    
    for (int i = 0; i < rewards.count; i++) {
      BattleRewardNode *brn = [[BattleRewardNode alloc] initWithReward:rewards[i] isForLoss:!isWin];
      [node addChild:brn];
      brn.position = ccp((8+brn.contentSize.width)*(i+0.5)+4, 45);
      
      if (brn.type == RewardTypePvpLeague)
        self.pvpLeagueNode = brn;
      
      node.contentSize = CGSizeMake(brn.position.x+brn.contentSize.width/2+8, 86.f);
    }
    node.anchorPoint = ccp(0, 0.5);
    node.position = ccp(self.rewardsView.contentSize.width, self.rewardsBgd.contentSize.height/2);
    self.rewardsView = node;
    
    
    clip = [CCClippingNode clippingNode];
    clip.contentSize = CGSizeMake(self.rewardsBgd.contentSize.width-4, self.rewardsBgd.contentSize.height);
    clip.anchorPoint = ccp(0.5, 0.5);
    [self.rewardsBgd addChild:clip];
    clip.position = ccp(self.rewardsBgd.contentSize.width/2, self.rewardsBgd.contentSize.height/2);
    CCDrawNode *stencil2 = [CCDrawNode node];
    CGPoint rectangle[] = {{0, 0}, {clip.contentSize.width, 0}, {clip.contentSize.width, clip.contentSize.height}, {0, clip.contentSize.height}};
    [stencil2 drawPolyWithVerts:rectangle count:4 fillColor:[CCColor whiteColor] borderWidth:1 borderColor:[CCColor whiteColor]];
    clip.stencil = stencil2;
    
    [clip addChild:self.rewardsView];
    
    self.rewardsScrollView.size = clip.contentSize;
    self.rewardsScrollView.center = [[CCDirector sharedDirector] convertToUI:[clip.parent convertToWorldSpace:clip.position]];
    
    // Leave a distance on each side
    self.rewardsScrollView.contentSize = CGSizeMake(self.rewardsView.contentSize.width+REWARDSVIEW_OFFSET*2, self.rewardsScrollView.frame.size.height);
    
    self.stickerHead.visible = NO;
    
    [self scrollViewDidScroll:self.rewardsScrollView];
  }
}

- (void) updatePvpReward:(PvpLeagueProto *)league leagueChange:(BOOL)leagueChange change:(int)change  {
  [self.pvpLeagueNode updatePvpLeagueReward:league leagueChange:leagueChange change:change];
}

- (void) onExitTransitionDidStart {
  [self.rewardsScrollView removeFromSuperview];
  [self.loadingSpinner removeFromSuperview];
  [self.msgTextField removeFromSuperview];
  
  self.doneButton.title = @"GO HOME";
  
  //  CCClippingNode *clip = (CCClippingNode *)self.rewardsView.parent;
  //  clip.stencil = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  [super onExitTransitionDidStart];
}

- (void) onEnterTransitionDidFinish {
  [super onEnterTransitionDidFinish];
  float firstDur = 0.4f; // bgd node
  float secondDur = 0.4f; // combination of "You Won"
  float thirdDur = 0.2f; // each reward cell delay or sticker head
  float fourthDur = 0.5f; // reward cell fly in
  float fifthDur = 0.3f; // continue/share
  float sixthDur = 0.3f; // done
  float seventhDur = 0.3f; // tip
  
  float eighthDur = 0.15f; // ribbon fade
  float ninthDur = 0.3f; // rewards coming down
  float tenthDur = 0.2f; // chat view fading in
  
  self.bgdNode.opacity = 0.f;
  self.bgdNode.scale = MAX(self.parent.contentSize.height/self.bgdNode.contentSize.height,
                           self.parent.contentSize.width/self.bgdNode.contentSize.width);
  [self.bgdNode runAction:[RecursiveFadeTo actionWithDuration:firstDur opacity:1.f]];
  
  
  CGPoint delta = ccp(-60, -11);
  CGPoint origPos = self.topLabelHeader.position;
  self.topLabelHeader.position = ccpAdd(self.topLabelHeader.position, delta);
  self.topLabelHeader.scale = 0.f;
  self.topLabelHeader.opacity = 0.f;
  [self.topLabelHeader runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:firstDur],
    [CCActionSpawn actions:
     [CCActionFadeTo actionWithDuration:0.1f opacity:1.f],
     [CCActionEaseSineIn actionWithAction:[CCActionMoveTo actionWithDuration:secondDur*0.6f position:origPos]],
     [CCActionSequence actions:[CCActionDelay actionWithDuration:0.05f],
      [CCActionEaseBackOut actionWithAction:[CCActionScaleTo actionWithDuration:secondDur*0.6f scale:1.f]], nil], nil], nil]];
  
  origPos = self.botLabelHeader.position;
  self.botLabelHeader.position = ccpAdd(self.botLabelHeader.position, ccpMult(delta, -1));
  self.botLabelHeader.scale = 0.f;
  self.botLabelHeader.opacity = 0.f;
  [self.botLabelHeader runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:firstDur+secondDur*0.4f],
    [CCActionSpawn actions:
     [CCActionFadeTo actionWithDuration:0.1f opacity:1.f],
     [CCActionEaseSineIn actionWithAction:[CCActionMoveTo actionWithDuration:secondDur*0.6f position:origPos]],
     [CCActionSequence actions:[CCActionDelay actionWithDuration:0.05f],
      [CCActionEaseBackOut actionWithAction:[CCActionScaleTo actionWithDuration:secondDur*0.6f scale:1.f]], nil], nil], nil]];
  
  [self.ribbon recursivelyApplyOpacity:0.f];
  [self.ribbon runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:firstDur+secondDur],
    [RecursiveFadeTo actionWithDuration:eighthDur opacity:1.f], nil]];
  
  self.rewardsBgd.position = ccpAdd(self.rewardsBgd.position, ccp(0, self.rewardsBgd.contentSize.height));
  [self.rewardsBgd runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:firstDur+secondDur+eighthDur],
    [CCActionMoveBy actionWithDuration:ninthDur position:ccp(0, -self.rewardsBgd.contentSize.height)], nil]];
  
  if (self.stickerHead.visible) {
    self.stickerHead.scale = 0.f;
    [self.stickerHead runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:firstDur+secondDur+eighthDur+ninthDur],
                                 [CCActionEaseElastic actionWithAction:[CCActionScaleTo actionWithDuration:thirdDur scale:1.f]], nil]];
    self.stickerHead.rotation = -12.5;
    CCActionRotateBy *rotate = [CCActionRotateBy actionWithDuration:fourthDur angle:-self.stickerHead.rotation*2];
    [self.stickerHead runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:rotate, rotate.reverse, nil]]];
  } else {
    for (int i = 0; i < self.rewardsView.children.count; i++) {
      CCNode *n = self.rewardsView.children[i];
      CGPoint pt = n.position;
      n.position = ccpAdd(pt, ccp(400, 0));
      [n recursivelyApplyOpacity:0.f];
      [n runAction:
       [CCActionSequence actions:
        [CCActionDelay actionWithDuration:firstDur+secondDur+eighthDur+ninthDur+i*thirdDur],
        [CCActionSpawn actions: [RecursiveFadeTo actionWithDuration:0.3f opacity:1.f],
         [CCActionEaseOut actionWithAction:[CCActionMoveTo actionWithDuration:fourthDur position:pt] rate:10], nil],
        nil]];
    }
    
    if (self.rewardsView.contentSize.width+REWARDSVIEW_OFFSET*2 > self.rewardsView.parent.contentSize.width) {
      // Scroll the rewards view with the children
      float maxSpot = self.rewardsView.parent.contentSize.width-self.rewardsView.contentSize.width-REWARDSVIEW_OFFSET;
      [self.rewardsView runAction:
       [CCActionSequence actions:
        [CCActionDelay actionWithDuration:firstDur+secondDur+eighthDur+ninthDur+thirdDur*1],
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
  
  float time = firstDur+secondDur+eighthDur+ninthDur+thirdDur-0.1;
  
  if (self.sendButton) {
    [self.sendButton.parent recursivelyApplyOpacity:0.f];
    CCActionSequence *seq = [CCActionSequence actions:
                             [CCActionDelay actionWithDuration:time],
                             [CCActionCallBlock actionWithBlock:
                              ^{
                                [self createTextField];
                                self.msgTextField.alpha = 0.f;
                                [UIView animateWithDuration:tenthDur animations:^{
                                  self.msgTextField.alpha = 1.f;
                                }];
                              }],
                             [RecursiveFadeTo actionWithDuration:tenthDur opacity:1.f], nil];
    
    [self.sendButton.parent runAction:seq];
    
    time += tenthDur;
  }
  
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
  self.tipLabel.positionInPoints = ccpAdd(self.tipLabel.positionInPoints, ccp(0, -50));
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
  [self loadSpinnerAtCenter:[self.doneButton.parent convertToWorldSpace:self.doneButton.positionInPoints]];
}

#pragma mark - TextField delegate methods

- (void) showTextFieldWithTarget:(id)target selector:(SEL)selector {
  self.tipLabel.visible = NO;
  self.doneButton.parent.position = ccp(0.5f, 0.1f);
  self.rewardsBgd.parent.parent.position = ccpAdd(self.rewardsBgd.parent.parent.position, ccp(0, 0.03));
  self.headerView.position = ccpAdd(self.headerView.position, ccp(0, 0.03));
  self.spinner.position = ccpAdd(self.spinner.position, ccp(0, 0.03));
  
  CCNode *msgNode = [CCNode node];
  [self.mainNode addChild:msgNode];
  
  msgNode.position = ccp(0.5f, 0.24f);
  msgNode.positionType = CCPositionTypeNormalized;
  
  
  CCSprite *bgd = [CCSprite spriteWithImageNamed:@"battleinputmessage.png"];
  [msgNode addChild:bgd];
  bgd.position = ccp(bgd.contentSize.width/2-self.rewardsBgd.contentSize.width/2, 0);
  self.textBox = bgd;
  
  CCButton *sendButton = [CCButton buttonWithTitle:@"SEND" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"battlesendmessage.png"]];
  sendButton.label.fontName = @"Ziggurat-HTF-Black";
  sendButton.label.fontSize = 10.f;
  [sendButton setTarget:target selector:selector];
  
  CCColor *c = [CCColor colorWithRed:0/255.f green:85/255.f blue:141/255.f];
  [sendButton setLabelColor:c forState:CCControlStateNormal];
  [sendButton setLabelColor:c forState:CCControlStateHighlighted];
//  [sendButton.label setShadowColor:[CCColor colorWithRed:1.f green:1.f blue:1.f alpha:0.8f]];
//  [sendButton.label setShadowBlurRadius:2.f];
//  [sendButton.label setShadowOffset:ccp(0, -1)];
  [msgNode addChild:sendButton];
  sendButton.position = ccp(self.rewardsBgd.contentSize.width/2-sendButton.contentSize.width/2+2, 0);
  self.sendButton = sendButton;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) createTextField {
  CCNode *bgd = self.textBox;
  
  CancellableTextField *tf = [[CancellableTextField alloc] init];
  tf.font = [UIFont fontWithName:@"Whitney-SemiboldItalic" size:12.f];
  tf.placeholder = @"Send a message";
  tf.size = CGSizeMake(bgd.contentSize.width-18, bgd.contentSize.height);
  [Globals displayUIView:tf];
  tf.center = ccp(self.contentSizeInPoints.width/2+bgd.positionInPoints.x, tf.superview.height-bgd.parent.positionInPoints.y-1);
  tf.autocorrectionType = UITextAutocorrectionTypeNo;
  tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
  tf.delegate = self;
  self.msgTextField = tf;
  
  _initTextFieldPos = tf.center;
}

- (void) replaceTextFieldWithMessageSentLabel {
  CCLabelTTF *label = [[CCLabelTTF alloc] initWithString:@"Message Sent!" fontName:@"Whitney-Black" fontSize:14.f];
  label.position = self.sendButton.parent.position;
  label.positionType = self.sendButton.parent.positionType;
  label.shadowColor = [CCColor colorWithWhite:0.f alpha:0.75f];
  label.shadowBlurRadius = 1.6f;
  label.shadowOffset = ccp(0, -1);
  [self.mainNode addChild:label];
  
  [self.sendButton.parent removeFromParent];
  [self.msgTextField removeFromSuperview];
  
  float dur = 1.f;
  [self.sendButton.parent runAction:[CCActionSequence actions:[RecursiveFadeTo actionWithDuration:dur opacity:0.f], [CCActionRemove action], nil]];
  
  [UIView animateWithDuration:dur animations:^{
    self.msgTextField.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self.msgTextField removeFromSuperview];
  }];
  
  [label runAction:[CCActionFadeIn actionWithDuration:dur]];
}

- (void) update:(CCTime)delta {
  self.msgTextField.centerY = _initTextFieldPos.y-self.mainNode.positionInPoints.y;
}

- (void) keyboardWillShow:(NSNotification *)n {
  NSDictionary *userInfo = [n userInfo];
  CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
  NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
  
  CGRect relFrame = [self.msgTextField.superview convertRect:keyboardFrame fromView:nil];
  
  CCActionInterval *action = [CCActionMoveTo actionWithDuration:animationDuration position:ccp(0, relFrame.size.height)];
  
  switch (curve) {
    case UIViewAnimationCurveEaseInOut:
      action = [CCActionEaseSineInOut actionWithAction:action];
      break;
      
    case UIViewAnimationCurveEaseIn:
      action = [CCActionEaseSineIn actionWithAction:action];
      break;
      
    case UIViewAnimationCurveEaseOut:
      action = [CCActionEaseOut actionWithAction:action];
      break;
      
    default:
      break;
  }
  
  [self.mainNode stopAllActions];
  [self.mainNode runAction:action];
}

- (void) keyboardWillHide:(NSNotification *)n {
  NSDictionary *userInfo = [n userInfo];
  NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
  
  CCActionInterval *action = [CCActionMoveTo actionWithDuration:animationDuration position:ccp(0, 0)];
  
  switch (curve) {
    case UIViewAnimationCurveEaseInOut:
      action = [CCActionEaseSineInOut actionWithAction:action];
      break;
      
    case UIViewAnimationCurveEaseIn:
      action = [CCActionEaseSineIn actionWithAction:action];
      break;
      
    case UIViewAnimationCurveEaseOut:
      action = [CCActionEaseOut actionWithAction:action];
      break;
      
    default:
      break;
  }
  
  [self.mainNode stopAllActions];
  [self.mainNode runAction:action];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
  [self.sendButton triggerAction];
  return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  Globals *gl = [Globals sharedGlobals];
  NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
  if ([str length] > gl.maxLengthOfChatString) {
    return NO;
  }
  return YES;
}

@end

@implementation BattleRewardNode

- (id) initWithReward:(Reward *)reward isForLoss:(BOOL)loss {
  
  GameState *gs = [GameState sharedGameState];
  
  NSString *imgName = [reward imgName];
  NSString *labelName = [reward shorterName];
  NSString *bgdName = nil;
  
  NSString *labelImage = nil;
  NSString *borderName = nil;
  UIColor *color = nil;
  BOOL isPiece = NO;
  self.type = reward.type;
  
  
  if (reward.type == RewardTypeMonster) {
    MonsterProto *mp = [gs monsterWithId:reward.monsterId];
    bgdName = [Globals imageNameForRarity:mp.quality suffix:@"found.png"];
    labelImage = [@"battle" stringByAppendingString:[Globals imageNameForRarity:mp.quality suffix:@"tag.png"]];
    isPiece = reward.monsterLvl == 0 && mp.numPuzzlePieces > 1;
  } else if (reward.type == RewardTypeCash) {
    bgdName = @"cashfound.png";
    color = [Globals greenColor];
  } else if (reward.type == RewardTypeOil) {
    bgdName = @"ultrafound.png";
    color = [Globals goldColor];
  } else if (reward.type == RewardTypeGems) {
    bgdName = @"commonfound.png";
    color = [Globals purplishPinkColor];
  } else if (reward.type == RewardTypeGachaToken) {
    bgdName = @"commonfound.png";
    color = [UIColor colorWithHexString:@"EA5F25"];
  } else if (reward.type == RewardTypeItem) {
    bgdName = @"commonfound.png";
    color = [Globals creamColor];
  } else if (reward.type == RewardTypePvpLeague) {
    labelName = @"Loading";
    color = [UIColor whiteColor];
  }
  
  if (loss) {
    bgdName = @"youlostitembg.png";
    borderName = @"youlostitemborder.png";
  } else {
    bgdName = @"youwonitembg.png";
    borderName = @"youwonitemborder.png";
  }
  
  if ((self = [super initWithImageNamed:bgdName])) {
    _inside = [CCSprite node];
    [Globals imageNamed:imgName toReplaceSprite:_inside completion:^(BOOL success) {
      if (success)
      {
        if (reward.type == RewardTypePvpLeague)
        {
          _inside.scale = 30 / _inside.contentSize.height;
        }
        else if (_inside.contentSize.height > self.contentSize.height) {
          _inside.scale = self.contentSize.height/_inside.contentSize.height;
        }
      }
    }];
    [self addChild:_inside];  
    _inside.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    
    float labelPosition = loss ? -10.f : -13.f;
    if (labelImage) {
      CCSprite *label = [CCSprite spriteWithImageNamed:labelImage];
      [self addChild:label];
      label.position = ccp(self.contentSize.width/2, labelPosition);
    } else if (labelName) {
      _label = [CCLabelTTF labelWithString:labelName fontName:@"Gotham-Ultra" fontSize:11.f dimensions:CGSizeMake(self.contentSize.width+5, 15)];
      _label.horizontalAlignment = CCTextAlignmentCenter;
      _label.color = [CCColor colorWithUIColor:color];
      [self addChild:_label];
      _label.position = ccp(self.contentSize.width/2, labelPosition-1);
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

- (void) updatePvpLeagueReward:(PvpLeagueProto *)league leagueChange:(BOOL)leagueChange change:(int)change  {
  float labelPosition = change < 0 ? -10.f : -13.f;
  NSString *labelName;
  
  if (leagueChange) {
    labelName = league.leagueName;
  } else {
    labelName = [Globals commafyNumber:change];
    if (change > 0) {
      labelName = [@"+" stringByAppendingString:labelName];
    } else if (change == 0) {
      labelName = @"Same";
    }
  }
  
  if (league && league.hasImgPrefix) {
    NSString *imgName = [league.imgPrefix stringByAppendingString:@"icon.png"];
    [Globals imageNamed:imgName toReplaceSprite:_inside completion:^(BOOL success) {
      _inside.scale = 30 / _inside.contentSize.height;
      _inside.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    }];
  }
  
  [_label removeFromParentAndCleanup:YES];
  
  _label = [CCLabelTTF labelWithString:labelName fontName:@"Gotham-Ultra" fontSize:11.f dimensions:CGSizeMake(self.contentSize.width, 15)];
  _label.horizontalAlignment = CCTextAlignmentCenter;
  if (change != 0) {
    _label.color = [CCColor colorWithUIColor:(change > 0 ? [Globals greenColor] : [Globals redColor])];
  }
  [self addChild:_label];
  _label.position = ccp(self.contentSize.width/2, labelPosition-1);
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
  clip.alphaThreshold = 0.5f;
  clip.contentSize = self.monsterBgd.contentSize;
  self.monsterIcon = [CCSprite spriteWithImageNamed:@"Zark1T1Card.png"];
  self.monsterIcon.scale = clip.contentSize.height/self.monsterIcon.contentSize.height;
  self.monsterIcon.position = ccp(clip.contentSize.width/2, clip.contentSize.height/2);
  [clip addChild:self.monsterIcon];
  [self.monsterBgd addChild:clip];
  
  
  // Create fake main node and move everything in here except the gradient so we can move it up and down for dialogue
  self.mainNode = [CCNode node];
  self.mainNode.contentSize = CGSizeMake(1, 1);
  self.mainNode.contentSizeType = CCSizeTypeNormalized;
  
  for (CCNode *n in self.children.copy) {
    if (n != self.gradientNode) {
      [n removeFromParent];
      [self.mainNode addChild:n];
    }
  }
  
  [self addChild:self.mainNode];
  self.mainNode.anchorPoint = ccp(1, 0.5);
  self.mainNode.position = ccp(self.contentSize.width, self.contentSize.height/2);
  
  self.bubbleNode = [CCSprite spriteWithImageNamed:@"attackpvpbubble.png"];
  [self.mainNode addChild:self.bubbleNode];
  
  self.defendingMsgLabel = [CCLabelTTF labelWithString:@"Come at me, bruh..." fontName:@"Whitney-SemiboldItalic" fontSize:11.f dimensions:CGSizeMake(self.bubbleNode.contentSize.width-15.f, self.bubbleNode.contentSize.height-8.f)];
  self.defendingMsgLabel.color = [CCColor colorWithCcColor3b:ccc3(38, 38, 38)];
  self.defendingMsgLabel.horizontalAlignment = CCTextAlignmentCenter;
  self.defendingMsgLabel.verticalAlignment = CCVerticalTextAlignmentCenter;
  [self.bubbleNode addChild:self.defendingMsgLabel];
  self.defendingMsgLabel.position = ccp(self.bubbleNode.contentSize.width/2, self.bubbleNode.contentSize.height/2+4.f);
  
  [self.gradientNode removeFromParent];
}

- (void) updateForPvpProto:(PvpProto *)pvp {
  self.nameLabel.string = [Globals fullNameWithName:pvp.defender.name clanTag:pvp.defender.clan.tag];
  self.cashLabel.string = [Globals commafyNumber:pvp.cashWinnings];
  self.oilLabel.string = [Globals commafyNumber:pvp.oilWinnings];
  
  GameState *gs = [GameState sharedGameState];
  TownHallProto *thp = (TownHallProto *)gs.myTownHall.staticStruct;
  self.nextMatchCostLabel.string = [Globals cashStringForNumber:thp.pvpQueueCashCost];
  
  int avatarId = pvp.defender.avatarMonsterId;
  if (!avatarId) {
    PvpMonsterProto *ump = [pvp.defenderMonstersList firstObject];
    
    MonsterProto *mp = [gs monsterWithId:ump.defenderMonster.monsterId];
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
    [self.leagueIcon setSpriteFrame:[CCSpriteFrame frameWithImageNamed:[league stringByAppendingString:[Globals isiPad] ? @"big.png" : @"icon.png"]]];
    self.leagueLabel.string = pvpLeague.leagueName;
    self.rankLabel.string = [Globals commafyNumber:rank];
    self.rankQualifierLabel.string = [Globals qualifierStringForNumber:rank];
    
    float leftSide = self.rankLabel.position.x+self.rankLabel.contentSize.width;
    self.rankQualifierLabel.position = ccp(leftSide+5, self.rankQualifierLabel.position.y);
    self.placeLabel.position = ccp(leftSide+5, self.placeLabel.position.y);
  }
  
  NSString *defMsg = pvp.defenderMsg;
  if (defMsg.length > 0) {
    self.bubbleNode.position = ccpAdd(self.monsterBgd.parent.position, ccp(0, self.monsterBgd.contentSize.height/2+self.bubbleNode.contentSize.height/2+8));
    self.defendingMsgLabel.string = defMsg;
    
    if (self.parent.contentSize.height < 321 && ![Globals isiPad]) {
      self.mainNode.scale = 0.95f;
    }
    
    self.mainNode.position = ccp(self.contentSize.width, self.contentSize.height/2-(self.bubbleNode.contentSize.height/2+5.f)*self.mainNode.scale);
  } else {
    // move the bubble node off screen
    self.bubbleNode.position = ccp(self.contentSize.width*2, 0);
    self.mainNode.position = ccp(self.contentSize.width, self.contentSize.height/2);
    self.mainNode.scale = 1.f;
  }
  
//NSLog(@"Attack button scale: %g", self.attackButtonNode.scale);
}

- (void) fadeInAnimationForIsRevenge:(BOOL)isRevenge {
  float dur = 0.2f;
  
  if (isRevenge) {
    float left = self.nextButtonNode.position.x-self.nextButtonNode.contentSize.width/2;
    float right = self.attackButtonNode.position.x+self.attackButtonNode.contentSize.width/2;
    [self.nextButtonNode removeFromParent];
    self.attackButtonNode.position = ccp(lroundf(left+(right-left)/2), self.attackButtonNode.position.y);
  }
  
  NSArray *nodes = @[self.bubbleNode, self.monsterBgd.parent, self.nameLabel, self.cashNode, self.oilNode, self.leagueNode, self.nextButtonNode, self.attackButtonNode];
  
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
  
  NSArray *nodes = @[self.bubbleNode, self.monsterBgd.parent, self.nameLabel, self.cashNode, self.oilNode, self.leagueNode, self.nextButtonNode, self.attackButtonNode];
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
