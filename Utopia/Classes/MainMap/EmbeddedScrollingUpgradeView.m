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

#define VIEW_BUFFER 10



@implementation DetailsPrereqView

- (void) updateForPrereq:(PrereqProto *)prereq isComplete:(BOOL)isComplete allowGo:(BOOL)allowGo{
  self.prereqLabel.text = [prereq prereqString];
  
  self.checkIcon.highlighted = !isComplete;
  self.prereqLabel.highlighted = !isComplete;
  self.goButtonView.hidden = isComplete && !allowGo;
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

@implementation DetailsTitleBarView

- (void) updateWithTitle:(NSString *) title{
  self.title.text = title;
}

@end

@implementation DetailsStrengthView

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
      newestView = [self makePrereqViewWithPrereq:pp allowGo:NO];
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
      newestView = [self makePrereqViewWithPrereq:[staticStruct prereqForIndex:i] allowGo:YES];
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
  
  newestView = [self makeStrengthDetailsViewWithStrength:[staticStruct structInfo].strength];
}

- (DetailsPrereqView *) makePrereqViewWithPrereq:(PrereqProto *)prereq allowGo:(BOOL)allowGo{
  DetailsPrereqView *epv = [[NSBundle mainBundle] loadNibNamed:@"DetailsPrereqView" owner:nil options:nil][0];
  BOOL isComplete = [[Globals sharedGlobals] isPrerequisiteComplete:prereq];
  [epv updateForPrereq:prereq isComplete:isComplete allowGo:allowGo];
  return epv;
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

@end