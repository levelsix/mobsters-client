//
//  ResearchInfoViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 3/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ResearchInfoViewController.h"
#import "ResearchController.h"
#import "OutgoingEventController.h"
#import "Globals.h"
#import "GameState.h"

#define RESEARCHING_DESCRIPTION @"This research is currently in progress"
#define RESEARCHING_TITLE @"Currently Researching"

@implementation ResearchPrereqView

- (void) updateForPrereq:(PrereqProto *)pre isComplete:(BOOL)isComplete {
  
  if(pre.gameType == GameTypeStructure) {
    [super updateForPrereq:pre isComplete:isComplete];
    return;
  }
  
  self.prereqLabel.text = [pre prereqString];
  
  self.checkIcon.highlighted = !isComplete;
  self.prereqLabel.highlighted = !isComplete;
  self.goButtonView.hidden = YES;
}

@end

@implementation ResearchInfoView

-(void)updateWithResearch:(UserResearch *)userResearch {
  ResearchProto *research = userResearch.research;
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  ResearchController *rc = [ResearchController researchControllerWithProto:research];
  
  self.oilButtonLabel.text = [NSString stringWithFormat:@"%d", research.costAmt];
  self.oilButtonView.hidden = research.costType != ResourceTypeOil;
  self.cashButtonLabel.text = [NSString stringWithFormat:@"%d", research.costAmt];
  self.cashButtonView.hidden = research.costType != ResourceTypeCash;
  
  [Globals adjustViewForCentering:self.researchOilLabel.superview withLabel:self.researchOilLabel];
  [Globals adjustViewForCentering:self.researchCashLabel.superview withLabel:self.researchCashLabel];
  
  //for now we assume only a single property for each research
  self.percentIncreseLabel.text = [rc longImprovementString];
  
  [Globals imageNamed:research.iconImgName withView:self.researchImage greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  self.researchName.text = research.name;
  self.researchTimeLabel.text = [Globals convertTimeToMediumString:research.durationMin*60];
  
  NSArray *prereqs = [gs prerequisitesForGameType:GameTypeResearch gameEntityId:research.researchId];
  
  self.prereqViewA.hidden = prereqs.count < 1;
  self.prereqViewB.hidden = prereqs.count < 2;
  self.prereqViewC.hidden = prereqs.count < 3;
  
  int unfulfilledRequirements = 0;
  if(!self.prereqViewA.hidden) {
    BOOL isComplete = [gl isPrerequisiteComplete:prereqs[0]];
    [self.prereqViewA updateForPrereq:prereqs[0] isComplete:isComplete];
    if (!isComplete) {
      unfulfilledRequirements++;
    }
  }
  if(!self.prereqViewB.hidden) {
    BOOL isComplete = [gl isPrerequisiteComplete:prereqs[0]];
    [self.prereqViewB updateForPrereq:prereqs[1] isComplete:isComplete];
    if (!isComplete) {
      unfulfilledRequirements++;
    }
  }
  if(!self.prereqViewC.hidden) {
    BOOL isComplete = [gl isPrerequisiteComplete:prereqs[0]];
    [self.prereqViewC updateForPrereq:prereqs[2] isComplete:isComplete];
    if (!isComplete) {
      unfulfilledRequirements++;
    }
  }
  
  if(unfulfilledRequirements > 0) {
    [self setDisplayForNumMissingRequirements:unfulfilledRequirements];
  } else if ([userResearch isResearching]) {
    self.bottomBarDescription.text = RESEARCHING_DESCRIPTION;
    self.bottomBarTitle.text = RESEARCHING_TITLE;
  }
  
  float maxPercent = (1.f + ([[research maxLevelResearch] firstProperty].researchValue / 100.f));
  float curPercent;
  if([research predecessorResearch]) {
    curPercent = (1.f + ([[research predecessorResearch] firstProperty].researchValue / 100.f)) / maxPercent;
  } else {
    curPercent = 1.f / maxPercent;
  }
  
  float nextPercent = (1.f + ([research firstProperty].researchValue / 100.f)) / maxPercent;
  
  [self.topPercentBar setPercentage:curPercent];
  [self.botPercentBar setPercentage:nextPercent];
}

-(void)setDisplayForNumMissingRequirements:(int)missingRequirements {
  UIImage *grey = [Globals imageNamed:@"greymenuoption.png"];
  self.oilButton.userInteractionEnabled = NO;
  self.cashButton.userInteractionEnabled = NO;
  
  [self.oilButton setImage:grey forState:UIControlStateNormal];
  [self.cashButton setImage:grey forState:UIControlStateNormal];
  
  self.oilIcon.image = [Globals greyScaleImageWithBaseImage:self.oilIcon.image];
  self.cashIcon.image = [Globals greyScaleImageWithBaseImage:self.cashIcon.image];
  
  self.researchCashLabel.textColor = [UIColor colorWithWhite:0.5f alpha:1.f];
  self.researchCashLabel.shadowColor = [UIColor colorWithWhite:1.f alpha:0.25];
  self.researchOilLabel.textColor = [UIColor colorWithWhite:0.5f alpha:1.f];
  self.researchOilLabel.shadowColor = [UIColor colorWithWhite:1.f alpha:0.25];
  
  self.bottomBarTitle.text = @"Woops!";
  self.bottomBarDescription.text = [NSString stringWithFormat:@"You are missing %d requirement%@ to upgrade.", missingRequirements, missingRequirements == 1 ? @"" : @"s"];
  
  self.bottomBarIcon.highlighted = YES;
  self.bottomBarImage.highlighted = YES;
  self.bottomBarTitle.highlighted = YES;
  self.bottomBarDescription.highlighted = YES;
}

-(void)updateLabels {
  UserResearch *curResearch = [[GameState sharedGameState].researchUtil currentResearch];
  self.timeLeftLabel.text = [Globals convertTimeToShortString:-[curResearch.endTime timeIntervalSinceNow]];
}

@end

@implementation ResearchInfoViewController

- (void) viewDidLoad {
  self.title = @"info view";
}

- (id)initWithResearch:(UserResearch *)userResearch {
  if((self = [super init])) {
    [self.view updateWithResearch:userResearch];
    self.title = [NSString stringWithFormat:@"Research to Rank %d",userResearch.research.level];
    _userResearch = userResearch;
  }
  
  return self;
}

- (IBAction)DetailsClicked:(id)sender {
  ResearchDetailViewController *rdvc = [[ResearchDetailViewController alloc] initWithResearchResearch:_userResearch];
  [self.parentViewController pushViewController:rdvc animated:YES];
}

- (IBAction)clickResearchStart:(id)sender {
  ResearchProto *research = _userResearch.research;
  UserResearch *startedResearch = [[OutgoingEventController sharedOutgoingEventController] beginResearch:_userResearch gemsSpent:0 resourceType:research.costType resourceCost:research.costAmt delegate:self];
  if(!startedResearch) {
    [Globals popupMessage:@"it didn't work weeeeee"];
  } else {
    self.view.oilButtonLabel.superview.hidden = YES;
    self.view.cashButtonLabel.superview.hidden = YES;
    self.view.activityIndicator.hidden = NO;
    self.view.cashButton.userInteractionEnabled = NO;
    [[GameState sharedGameState].researchUtil startResearch:startedResearch];
  }
}

- (void) handlePerformResearchResponseProto:(FullEvent *)fe {
  PerformResearchResponseProto *proto = (PerformResearchResponseProto *)fe.event;
  if(proto.status != PerformResearchResponseProto_PerformResearchStatusSuccess) {
    
  }
  self.view.oilButtonLabel.superview.hidden = NO;
  self.view.cashButtonLabel.superview.hidden = NO;
  self.view.activityIndicator.hidden = YES;
  self.view.cashButton.userInteractionEnabled = YES;
  
  self.view.oilButtonView.hidden = YES;
  self.view.cashButtonView.hidden = YES;
  self.view.helpButtonView.hidden = YES;
  self.view.finishButtonView.hidden = NO;
  
  self.view.timeLeftLabel.hidden = NO;
  self.view.bottomBarTitle.text = RESEARCHING_TITLE;
  self.view.bottomBarDescription.text = RESEARCHING_DESCRIPTION;
}

- (void) updateLabels {
  [self.view updateLabels];
}

@end


