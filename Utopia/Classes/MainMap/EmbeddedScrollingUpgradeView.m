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

#define VIEW_BUFFER 5



@implementation DetailsPrereqView

- (void) updateForPrereq:(PrereqProto *)prereq isComplete:(BOOL)isComplete allowGo:(BOOL)allowGo{
  self.prereqLabel.text = [prereq prereqString];
  
  self.checkIcon.highlighted = !isComplete;
  self.prereqLabel.highlighted = !isComplete;
  self.goButton.superview.hidden = isComplete && allowGo;
  
  self.goButton.tag = prereq.prereqId;
}

- (IBAction)goClicked:(id)sender {
  UIButton *clickedButton = (UIButton *)sender;
  [self.delegate goClicked:(int)clickedButton.tag];
}

@end

@implementation DetailsProgressBarView

- (void) updateWithDetailName:(NSString *) name description:(NSString *)description curAmount:(float)curAmount nextAmount:(float)nextAmount {
  self.detailName.text = name;
  self.increaseDescription.text = description;
  self.backBar.percentage = nextAmount;
  self.frontBar.percentage = curAmount;
  
  CGSize textSize = [self.increaseDescription.text getSizeWithFont:self.increaseDescription.font];
  self.buttonView.origin =  CGPointMake(self.increaseDescription.origin.x + textSize.width + 3, self.buttonView.origin.y);
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

- (void) updateWithStrenght:(int)strength {
  self.strengthLabel.text = [NSString stringWithFormat:@"+%d",strength];
}

@end

@implementation EmbeddedScrollingUpgradeView

- (void) addToScrollViewWithView:(UIView *)newView {
  [self.contentView addSubview:newView];
  newView.origin = CGPointMake(0.f, _curY);
  _curY += newView.height + VIEW_BUFFER;
}

- (void) updateForGameTypeProto:(id<GameTypeProto>)gameProto {
//  id<StaticStructure> staticStruct = userStruct.staticStruct;
  
  _curY = VIEW_BUFFER*3;
  for (UIView *subview in self.contentView.subviews) {
    [subview removeFromSuperview];
  }
  
  UIView *newestView;
  
  if (gameProto.numPrereqs > 0) {
    newestView = [self makeTitleWithTitle:REQUIREMENTS_TITLE];
    [self addToScrollViewWithView:newestView];
    
    for(int i = 0; i < gameProto.numPrereqs; i++) {
      newestView = [self makePrereqViewWithPrereq:[gameProto prereqForIndex:i]];
      [self addToScrollViewWithView:newestView];
    }
  }
  
  if ([gameProto numBars] > 0) {
    newestView = [self makeTitleWithTitle:IMPROVEMENTS_TITLE];
    [self addToScrollViewWithView:newestView];
    for (int i = 0; i < [gameProto numBars]; i++) {
      newestView = [self makeDetailsProgressBarViewWithDetailName:[gameProto statNameForIndex:i]
                                                      description:[gameProto statChangeForIndex:i]
                                                        curAmount:[gameProto curBarPercentForIndex:i]
                                                       nextAmount:[gameProto nextBarPercentForIndex:i]];
      [self addToScrollViewWithView:newestView];
    }
  }
  
  newestView = [self makeTitleWithTitle:STRENGTH_TITLE];
  [self addToScrollViewWithView:newestView];
  
  newestView = [self makeStrengthDetailsViewWithStrength:[gameProto strength]];
  [self addToScrollViewWithView:newestView];
  
  _curY += VIEW_BUFFER * 2;
  
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
  return dpbv;
}

- (DetailsStrengthView *) makeStrengthDetailsViewWithStrength:(int)strength {
  DetailsStrengthView *sdv = [[NSBundle mainBundle] loadNibNamed:@"DetailsStrengthView" owner:nil options:nil][0];
  [sdv updateWithStrenght:strength];
  return sdv;
}

- (void) goClicked:(int)prereqId {
  [self.delegate goClicked:prereqId];
}

@end