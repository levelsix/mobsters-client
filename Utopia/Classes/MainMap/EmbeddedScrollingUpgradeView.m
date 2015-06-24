//
//  EmbeddedScrollingUpgradeView.m
//  Utopia
//
//  Created by Kenneth Cox on 3/24/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "EmbeddedScrollingUpgradeView.h"

#import "GameState.h"
#import "Globals.h"

#define REQUIREMENTS_TITLE @"REQUIREMENTS"
#define IMPROVEMENTS_TITLE @"IMPROVEMENTS"
#define STRENGTH_TITLE @"STRENGTH"
#define UNLOCKS_TITLE @"UNLOCKS"

#define VIEW_BUFFER 10
#define START_BUFFER 27


@implementation DetailsPrereqView

- (void) updateForPrereq:(PrereqProto *)prereq isComplete:(BOOL)isComplete allowGo:(BOOL)allowGo {
  self.prereqLabel.text = [prereq prereqString];
  
  self.checkIcon.highlighted = !isComplete;
  self.prereqLabel.highlighted = !isComplete;
  self.goButton.superview.hidden = isComplete || !allowGo;
  
  self.goButton.tag = prereq.prereqId;
  
  // Extend the prereqLabel if there is no go button
  if (prereq.gameType == GameTypeResearch) {
    self.requiresLabel.hidden = YES;
    self.prereqLabel.originX = self.requiresLabel.originX;
    self.prereqLabel.width = CGRectGetMaxX(self.goButton.superview.frame)-self.prereqLabel.originX;
  }
}

- (IBAction)goClicked:(id)sender {
  UIButton *clickedButton = (UIButton *)sender;
  [self.delegate goClicked:(int)clickedButton.tag];
}

@end

@implementation DetailsProgressBarView

- (void) updateWithDetailName:(NSString *) name description:(NSString *)description curAmount:(float)curAmount nextAmount:(float)nextAmount {
  self.detailName.text = [NSString stringWithFormat:@"%@:",name];
  self.increaseDescription.text = description;
  self.backBar.percentage = nextAmount;
  self.frontBar.percentage = curAmount;
  
  CGSize textSize = [self.increaseDescription.text getSizeWithFont:self.increaseDescription.font constrainedToSize:self.increaseDescription.size];
  self.buttonView.origin =  CGPointMake(self.increaseDescription.origin.x + textSize.width + 3, self.buttonView.origin.y);
}

- (IBAction)detailsClicked:(id)sender {
  DetailsProgressBarView *dpbv = [self getAncestorInViewHierarchyOfType:[DetailsProgressBarView class]];
  [self.delegate detailsClicked:(int)dpbv.tag];
}

@end

@implementation DetailsTitleBarView

- (void) updateWithTitle:(NSString *) title{
  self.title.text = [NSString stringWithFormat:@"  %@  ", title];
  
  CGSize textSize = [self.title.text getSizeWithFont:self.title.font];
  self.title.size = CGSizeMake(textSize.width, self.title.size.height);
}

@end

@implementation DetailsStrengthView

- (void) updateWithStrenght:(int)strength showPlus:(BOOL)showPlus{
  self.strengthLabel.text = [NSString stringWithFormat:@"%@%@",showPlus ? @"+":@"", [Globals commafyNumber:strength]];
}

@end

@implementation EmbeddedScrollingUpgradeView

- (void) addToScrollViewWithView:(UIView *)newView {
  [self.contentView addSubview:newView];
  newView.origin = CGPointMake(0.f, _curY);
  _curY += newView.height + VIEW_BUFFER;
}

- (void) updateForTownHall:(id<GameTypeProtocol>)gameProto {
  [self updateForGameTypeProto:gameProto showTownHallUnlocksView:YES];
}

- (void) updateForGameTypeProto:(id<GameTypeProtocol>)gameProto {
  [self updateForGameTypeProto:gameProto showTownHallUnlocksView:NO];
}

- (void) updateForGameTypeProto:(id<GameTypeProtocol>)gameProto showTownHallUnlocksView:(BOOL)showTownHallUnlocksView {
//  id<StaticStructure> staticStruct = userStruct.staticStruct;
  
  _curY = START_BUFFER;
  for (UIView *subview in self.contentView.subviews) {
    [subview removeFromSuperview];
  }
  
  UIView *newestView;
  
  NSArray *prereqs = [gameProto prereqs];
  
  if (prereqs.count > 0) {
    newestView = [self makeTitleWithTitle:REQUIREMENTS_TITLE];
    [self addToScrollViewWithView:newestView];
    
    for(int i = 0; i < prereqs.count; i++) {
      newestView = [self makePrereqViewWithPrereq:prereqs[i]];
      [self addToScrollViewWithView:newestView];
    }
  }
  
  if (showTownHallUnlocksView && self.townHallUnlocksView) {
    newestView = [self makeTitleWithTitle:UNLOCKS_TITLE];
    [self addToScrollViewWithView:newestView];
    
    [self addToScrollViewWithView:self.townHallUnlocksView];
    
    //special case, this view should be centered
    CGPoint center = self.townHallUnlocksView.center;
    center.x = self.scrollView.width /2.f;
    self.townHallUnlocksView.center = center;
  }
  
  if ([gameProto numBars] > 0) {
    newestView = [self makeTitleWithTitle:IMPROVEMENTS_TITLE];
    [self addToScrollViewWithView:newestView];
    
    for (int i = 0; i < [gameProto numBars]; i++) {
      
      float curPerc = [gameProto barPercentForIndex:i];
      float nextPerc = [gameProto.successor barPercentForIndex:i];
      
      newestView = [self makeDetailsProgressBarViewWithDetailName:[gameProto statNameForIndex:i]
                                                      description:[gameProto longStatChangeForIndex:i]
                                                        curAmount:curPerc
                                                       nextAmount:nextPerc];
      newestView.tag = i;
      [self addToScrollViewWithView:newestView];
    }
  }
  
  newestView = [self makeTitleWithTitle:STRENGTH_TITLE];
  [self addToScrollViewWithView:newestView];
  
  newestView = [self makeStrengthDetailsViewWithStrength:[gameProto strengthGainForNextLevel] showPlus:!!gameProto.successor];
  [self addToScrollViewWithView:newestView];
  
  _curY += 21;
  
  self.contentView.size = CGSizeMake(self.contentView.size.width, _curY);
  self.scrollView.contentSize = self.contentView.frame.size;
}

- (DetailsPrereqView *) makePrereqViewWithPrereq:(PrereqProto *)prereq{
  DetailsPrereqView *dpv = [[NSBundle mainBundle] loadNibNamed:@"DetailsPrereqView" owner:nil options:nil][0];
  BOOL isComplete = [[Globals sharedGlobals] isPrerequisiteComplete:prereq];
  [dpv updateForPrereq:prereq isComplete:isComplete allowGo:prereq.gameType == GameTypeStructure];
  dpv.delegate = self;
  return dpv;
}

- (DetailsTitleBarView *) makeTitleWithTitle:(NSString *)title {
  DetailsTitleBarView *utbv = [[NSBundle mainBundle] loadNibNamed:@"DetailsTitleBarView" owner:nil options:nil][0];
  [utbv updateWithTitle:title];
  return utbv;
}

- (DetailsProgressBarView *) makeDetailsProgressBarViewWithDetailName:(NSString *) name description:(NSString *)description curAmount:(float)curAmount nextAmount:(float)nextAmount {
  DetailsProgressBarView *dpbv = [[NSBundle mainBundle] loadNibNamed:@"DetailsProgressBarView" owner:nil options:nil][0];
  [dpbv updateWithDetailName:name description:description curAmount:curAmount nextAmount:nextAmount];
  dpbv.delegate = self;
  return dpbv;
}

- (DetailsStrengthView *) makeStrengthDetailsViewWithStrength:(int)strength showPlus:(BOOL)showPlus{
  DetailsStrengthView *sdv = [[NSBundle mainBundle] loadNibNamed:@"DetailsStrengthView" owner:nil options:nil][0];
  [sdv updateWithStrenght:strength showPlus:showPlus];
  return sdv;
}

- (void) goClicked:(int)prereqId {
  [self.delegate goClicked:prereqId];
}

- (void) detailsClicked:(int)index {
  [self.delegate detailsClicked:index];
}

@end