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

@implementation EmbeddedPrereqView

- (void) updateForPrereq:(PrereqProto *)prereq {
  [self.prereqView loadNib];
  self.prereqView 
}

@end

@implementation DetailsProgressBarView

- (void) updateWithDetailName:(NSString *) name description:(NSString *)description fullAmount(float)fullAmount curAmount:(float)curAmount nextAmount:(float)nextAmount {
  self.detailName.text = name;
  self.increaseDescription.text = description;
  self.backBar.percentage = nextAmount / fullAmount;
  self.frontBar.percentage = curAmount / fullAmount;
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
    [self.scrollView addSubview:newestView];
    newestView.origin = CGPointMake(0.f, _curY);
    _curY+= newestView.height + VIEW_BUFFER;
    for(PrereqProto *pp in prereqs) {
      
    }
    
  }
  
}

- (void) updateForBuildingUpgrade:(id)iDontKnow {
  
}

- (EmbeddedPrereqView *) makePrereqView {
  EmbeddedPrereqView *epv = [[NSBundle mainBundle] loadNibNamed:@"EmbeddedScrollingUpgradeView" owner:nil options:nil][NIB_PREREQ];
}

- (UpgradeTitleBarView *) makeTitleWithTitle:(NSString *)title {
  UpgradeTitleBarView *utbv = [[NSBundle mainBundle] loadNibNamed:@"EmbeddedScrollingUpgradeView" owner:nil options:nil][NIB_TITLE_BAR];
  [utbv updateWithTitle:title];
  return utbv;
}

@end