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

@implementation BattleLostView

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
  [self.bgdNode runAction:[RecursiveFadeTo actionWithDuration:firstDur opacity:1.f]];
  
  CGPoint orig = self.headerView.position;
  self.headerView.position = ccpAdd(orig, ccp(0, 150));
  [self.headerView runAction:
   [CCActionSequence actions:
    [CCActionDelay actionWithDuration:firstDur],
    [CCActionEaseBounceOut actionWithAction:[CCActionMoveTo actionWithDuration:secondDur position:orig]], nil]];
  
  self.stickerHead.scale = 0.f;
  [self.stickerHead runAction:[CCActionSequence actions:[CCActionDelay actionWithDuration:firstDur+secondDur-0.1],
                               [CCActionEaseElastic actionWithAction:[CCActionScaleTo actionWithDuration:thirdDur scale:1.f]], nil]];
  self.stickerHead.rotation = -12.5;
  CCActionRotateBy *rotate = [CCActionRotateBy actionWithDuration:fourthDur angle:-self.stickerHead.rotation*2];
  [self.stickerHead runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:rotate, rotate.reverse, nil]]];
  
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
  CGPoint pt = self.manageButton.position;
  self.manageButton.position = ccpAdd(pt, ccp(0, -50));
  [self.manageButton runAction:
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

@end

@implementation BattleWonView

#define REWARDSVIEW_OFFSET 50

- (void) onExitTransitionDidStart {
  [self.rewardsScrollView removeFromSuperview];
  
  CCClippingNode *clip = (CCClippingNode *)self.rewardsView.parent;
  clip.stencil = nil;
  [super onExitTransitionDidStart];
}

- (void) updateForRewards:(NSArray *)rewards {
  CCNode *node = [CCNode node];
  
  for (int i = 0; i < rewards.count; i++) {
    BattleRewardNode *brn = [[BattleRewardNode alloc] initWithReward:rewards[i]];
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
  CGPoint pt = self.manageButton.position;
  self.manageButton.position = ccpAdd(pt, ccp(0, -50));
  [self.manageButton runAction:
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

- (void) hideDoneLabel {
  self.doneButton.name = nil;
}

- (void) hideManageLabel {
  self.manageButton.name = nil;
}

@end

@implementation BattleRewardNode

- (id) initWithReward:(Reward *)reward {
  GameState *gs = [GameState sharedGameState];
  NSString *imgName = nil;
  NSString *labelName = nil;
  NSString *bgdName = nil;
  UIColor *color = nil;
  if (reward.type == RewardTypeMonster) {
    MonsterProto *mp = [gs monsterWithId:reward.monsterId];
    imgName = [Globals imageNameForRarity:mp.quality suffix:@"piece.png"];
    bgdName = [Globals imageNameForRarity:mp.quality suffix:@"found.png"];
    labelName = [Globals stringForRarity:mp.quality];
    color = [Globals colorForRarity:mp.quality];
  } else if (reward.type == RewardTypeSilver) {
    imgName = @"moneystack.png";
    bgdName = @"cashfound.png";
    labelName = [Globals cashStringForNumber:reward.silverAmount];
    color = [Globals greenColor];
  } else if (reward.type == RewardTypeOil) {
    imgName = @"oilicon.png";
    bgdName = @"ultrafound.png";
    labelName = [Globals commafyNumber:reward.oilAmount];
    color = [Globals goldColor];
  } else if (reward.type == RewardTypeGold) {
    imgName = @"diamond.png";
    labelName = [Globals commafyNumber:reward.goldAmount];
    color = [Globals purplishPinkColor];
  } else if (reward.type == RewardTypeItem) {
    ItemProto *item = [gs itemForId:reward.itemId];
    imgName = item.imgName;
    labelName = item.name;
    bgdName = @"commonfound.png";
    color = [Globals creamColor];
  }
  
  if ((self = [super initWithImageNamed:bgdName])) {
    CCSprite *inside = [CCSprite spriteWithImageNamed:imgName];
    [self addChild:inside];
    inside.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:labelName fontName:[Globals font] fontSize:13.f];
    label.color = [CCColor colorWithUIColor:color];
    [self addChild:label];
    label.position = ccp(self.contentSize.width/2, -11.f);
  }
  return self;
}

@end

@implementation BattleElementView

- (void) awakeFromNib {
  self.layer.anchorPoint = ccp(0, 0.5);
  self.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  BOOL inside = [super pointInside:point withEvent:event];
  if (!inside) {
    [self close];
  }
  return inside;
}

- (void) open {
  [UIView animateWithDuration:0.15f animations:^{
    self.transform = CGAffineTransformMakeScale(1.f, 1.f);
  }];
}

- (void) close {
  [UIView animateWithDuration:0.15f animations:^{
    self.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
  }];
}

@end

@implementation BattleDeployCardView

- (void) updateForBattlePlayer:(BattlePlayer *)bp {
  if (!bp) {
    self.emptyView.hidden = NO;
    self.mainView.hidden = YES;
  } else {
    self.healthbar.percentage = bp.curHealth/(float)bp.maxHealth;
    self.healthLabel.text = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:bp.curHealth], [Globals commafyNumber:bp.maxHealth]];
    
    BOOL grayscale = bp.curHealth == 0;
    NSString *mini = [Globals imageNameForElement:bp.element suffix:@"team.png"];
    [Globals imageNamed:mini withView:self.bgdIcon greyscale:grayscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    NSString *monster = [bp.spritePrefix stringByAppendingString:@"Thumbnail.png"];
    [Globals imageNamed:monster withView:self.monsterIcon greyscale:grayscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    self.emptyView.hidden = YES;
    self.mainView.hidden = NO;
  }
}

@end

@implementation BattleDeployView

- (void) updateWithBattlePlayers:(NSArray *)players {
  for (BattleDeployCardView *card in self.cardViews) {
    [card updateForBattlePlayer:nil];
    for (BattlePlayer *bp in players) {
      if (bp.slotNum == card.tag) {
        [card updateForBattlePlayer:bp];
      }
    }
  }
}

@end

@implementation BattleQueueNode

- (void) updateForPvpProto:(PvpProto *)pvp {
  self.nameLabel.string = pvp.defender.minUserProto.name;
  self.rankLabel.string = [NSString stringWithFormat:@"%d.  %@", 22, pvp.defender.minUserProto.name];
  self.cashLabel.string = [Globals cashStringForNumber:pvp.prospectiveCashWinnings];
  self.oilLabel.string = [Globals commafyNumber:pvp.prospectiveOilWinnings];
  
  GameState *gs = [GameState sharedGameState];
  TownHallProto *thp = (TownHallProto *)gs.myTownHall.staticStruct;
  self.nextMatchCostLabel.string = [Globals cashStringForNumber:thp.pvpQueueCashCost];
}

- (void) fadeInAnimation {
  float dur = 0.2f;
  
  NSArray *nodes = @[self.nameLabel, self.cashNode, self.oilNode, self.leagueNode, self.nextButtonNode, self.attackButtonNode];
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
  
  NSArray *nodes = @[self.nameLabel, self.cashNode, self.oilNode, self.leagueNode, self.nextButtonNode, self.attackButtonNode];
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
