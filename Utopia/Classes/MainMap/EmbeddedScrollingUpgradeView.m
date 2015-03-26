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

#define NIB_TITLE_BAR 1
#define NIB_STRENGTH_DETAILS 2
#define NIB_DETAILS 3
#define NIB_PREREQ 4

#define REQUIREMENTS_TITLE @"REQUIREMENTS"
#define IMPROVEMENTS_TITLE @"IMPROVEMENTS"
#define STRENGTH_TITLE @"STRENGTH"

#define VIEW_BUFFER 10

@implementation ResearchPrereqView

- (void) updateForPrereq:(PrereqProto *)pre isComplete:(BOOL)isComplete {
  
  if(pre.gameType == GameTypeStructure) {
//    [super updateForPrereq:pre isComplete:isComplete];
    return;
  }
  
  self.prereqLabel.text = [pre prereqString];
  
  self.checkIcon.highlighted = !isComplete;
  self.prereqLabel.highlighted = !isComplete;
  self.goButtonView.hidden = YES;
}

@end

@implementation EmbeddedPrereqView

- (void) updateForPrereq:(PrereqProto *)prereq isComplete:(BOOL)isComplete {
  [self.prereqView loadNib];
  [self.prereqView updateForPrereq:prereq isComplete:isComplete];
}

@end

@implementation DetailsProgressBarView

- (void) updateWithDetailName:(NSString *) name description:(NSString *)description curAmount:(float)curAmount nextAmount:(float)nextAmount {
  self.detailName.text = name;
  self.increaseDescription.text = description;
  self.backBar.percentage = curAmount;
  self.frontBar.percentage = nextAmount;
}

@end

@implementation UpgradeTitleBarView

- (void) updateWithTitle:(NSString *) title{
  self.title.text = title;
}

@end

@implementation StrengthDetailsView

- (void) updateWithStrenght:(int)strength {
  self.strengthLabel.text = [NSString stringWithFormat:@"+%d",strength];
}

@end

@implementation EmbeddedScrollingUpgradeView

- (void) updateForResearch:(UserResearchProto *)userResearch {
  GameState *gs = [GameState sharedGameState];
  
  _curY = 0.f;
  for (UIView *subview in self.subviews) {
    [subview removeFromSuperview];
  }
  UIView *newestView;
  NSArray *prereqs = [gs prerequisitesForGameType:GameTypeResearch gameEntityId:userResearch.researchId];
  
  if (prereqs.count > 0) {
    newestView = [self makeTitleWithTitle:REQUIREMENTS_TITLE];
    [self addToScrollViewWithView:newestView];
    
    for(PrereqProto *pp in prereqs) {
      newestView = [self makePrereqViewWithPrereq:pp];
      [self addToScrollViewWithView:newestView];
    }
    
    
  }
  
}

- (void) addToScrollViewWithView:(UIView *)newView {
  [self.scrollView addSubview:newView];
  newView.origin = CGPointMake(0.f, _curY);
  _curY += newView.height + VIEW_BUFFER;
}

- (void) updateForBuildingUpgrade:(UserStruct *)userStruct {
  GameState *gs = [GameState sharedGameState];
  id<StaticStructure> staticStruct = userStruct.staticStruct;
  
  _curY = 0.f;
  for (UIView *subview in self.subviews) {
    [subview removeFromSuperview];
  }
  UIView *newestView;
  
  if (staticStruct.numPrereqs > 0) {
    newestView = [self makeTitleWithTitle:REQUIREMENTS_TITLE];
    [self addToScrollViewWithView:newestView];
    
    for(int i = 0; i < staticStruct.numPrereqs; i++) {
      newestView = [self makePrereqViewWithPrereq:[staticStruct prereqForIndex:i]];
      [self addToScrollViewWithView:newestView];
    }
  }
  
  if ([staticStruct numBars] > 0) {
    for (int i = 0; i < [staticStruct numBars]; i++) {
      newestView = [self makeDetailsProgressBarViewWithDetailName:[staticStruct statNameForIndex:i]
                                                      description:[staticStruct statSuffixForIndex:i]
                                                        curAmount:[staticStruct curBarPercentForIndex:i]
                                                       nextAmount:[staticStruct nextBarPercentForIndex:i]];
      [self addToScrollViewWithView:newestView];
    }
  }
  
  newestView = [self makeTitleWithTitle:STRENGTH_TITLE];
  [self addToScrollViewWithView:newestView];
  
  newestView = [self makeStrengthDetailsViewWithStrength:strength];
}

- (EmbeddedPrereqView *) makePrereqViewWithPrereq:(PrereqProto *)prereq {
  EmbeddedPrereqView *epv = [[NSBundle mainBundle] loadNibNamed:@"EmbeddedScrollingUpgradeView" owner:nil options:nil][NIB_PREREQ];
  BOOL isComplete = [[Globals sharedGlobals] isPrerequisiteComplete:prereq];
  [epv updateForPrereq:prereq isComplete:isComplete];
  return epv;
}

- (UpgradeTitleBarView *) makeTitleWithTitle:(NSString *)title {
  UpgradeTitleBarView *utbv = [[NSBundle mainBundle] loadNibNamed:@"EmbeddedScrollingUpgradeView" owner:nil options:nil][NIB_TITLE_BAR];
  [utbv updateWithTitle:title];
  return utbv;
}

- (DetailsProgressBarView *) makeDetailsProgressBarViewWithDetailName:(NSString *) name description:(NSString *)description curAmount:(float)curAmount nextAmount:(float)nextAmount {
  DetailsProgressBarView *dpbv = [[NSBundle mainBundle] loadNibNamed:@"EmbeddedScrollingUpgradeView" owner:nil options:nil][NIB_DETAILS];
  [dpbv updateWithDetailName:name description:description curAmount:curAmount nextAmount:nextAmount];
  return dpbv;
}

- (StrengthDetailsView *) makeStrengthDetailsViewWithStrength:(int)strength {
  StrengthDetailsView *sdv = [[NSBundle mainBundle] loadNibNamed:@"EmbeddedScrollingUpgradeView" owner:nil options:nil][NIB_STRENGTH_DETAILS];
  [sdv updateWithStrenght:strength];
  return sdv;
}

@end