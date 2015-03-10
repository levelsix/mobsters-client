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

-(void)updateWithResearch:(ResearchProto *)research {
  
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


@end

@implementation ResearchInfoViewController

- (void) viewDidLoad {
  self.title = @"info view";
}

- (id)initWithResearch:(ResearchProto *)research {
  if((self = [super init])) {
    [self.view updateWithResearch:research];
    self.title = [NSString stringWithFormat:@"Research to Rank %d",research.level];
    _researchId = research.researchId;
  }
  
  return self;
}

- (IBAction)DetailsClicked:(id)sender {
  ResearchDetailViewController *rdvc = [[ResearchDetailViewController alloc] initWithResearchId:_researchId];
  [self.parentViewController pushViewController:rdvc animated:YES];
}

- (IBAction)clickResearchStart:(id)sender {
  ResearchProto *research = [[GameState sharedGameState].staticResearch objectForKey:@(_researchId)];
  BOOL success = [[OutgoingEventController sharedOutgoingEventController] beginResearch:research gemsSpent:0 resourceType:research.costType resourceChange:-research.costAmt delegate:self];
  if(!success) {
    [Globals popupMessage:@"it didn't work weeeeee"];
  } else {
    ResearchInfoView *riv = self.view;
    riv.oilButtonLabel.superview.hidden = YES;
    riv.cashButtonLabel.superview.hidden = NO;
    riv.activityIndicator.hidden = NO;
  }
}

- (void) handlePerformResearchRequestProto:(FullEvent *)fe {
  PerformResearchResponseProto *proto = (PerformResearchResponseProto *)fe.event;
  if(proto.status == PerformResearchResponseProto_PerformResearchStatusSuccess) {
    ResearchInfoView *riv = self.view;
    riv.oilButtonLabel.superview.hidden = NO;
    riv.cashButtonLabel.superview.hidden = YES;
    riv.activityIndicator.hidden = YES;
  
    CGPoint barCenter = riv.inactiveResearchBar.center;
    [riv.inactiveResearchBar.superview addSubview:riv.activeResearchBar];
    [riv.inactiveResearchBar removeFromSuperview];
    riv.activeResearchBar.center = barCenter;
  }
}

@end


