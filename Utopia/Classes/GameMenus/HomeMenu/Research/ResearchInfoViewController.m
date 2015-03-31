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
#import "GenericPopupController.h"

#import "Globals.h"
#import "GameState.h"
#import "GameViewController.h"

#define RESEARCHING_DESCRIPTION @"This research is currently in progress"
#define RESEARCHING_TITLE @"Currently Researching"

#define DEFAULT_TITLE @"Ready to Research!"
#define DEFAULT_DESCRIPTION @"You have met all the requirements to Research."

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

- (void) updateWithResearch:(UserResearch *)userResearch {
  self.bottomBarDescription.text = DEFAULT_DESCRIPTION;
  self.bottomBarTitle.text = DEFAULT_TITLE;
  
  ResearchProto *research = userResearch.research;
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  ResearchController *rc = [ResearchController researchControllerWithProto:research];
  
  //for now we assume only a single property for each research
  self.improvementLabel.text = [rc longImprovementString];
  CGSize size = [self.improvementLabel.text getSizeWithFont:self.improvementLabel.font];
  int offsetFromBar = 5;
  self.detailView.center = CGPointMake(self.improvementLabel.frame.origin.x+size.width+(self.detailView.frame.size.width/2) + offsetFromBar, self.improvementLabel.center.y);
  
  [Globals imageNamed:research.iconImgName withView:self.researchImage greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  self.researchName.text = research.name;
  self.researchTimeLabel.text = [[Globals convertTimeToMediumString:research.durationMin*60] uppercaseString];
  
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
  
  float curPercent = [rc curPercent];
  float nextPercent = [rc nextPercent];
  
  [self.topPercentBar setPercentage:curPercent];
  [self.botPercentBar setPercentage:nextPercent];
  
  self.oilButtonLabel.text = [NSString stringWithFormat:@"%d", research.costAmt];
  self.oilButtonView.hidden = research.costType != ResourceTypeOil;
  self.oilButtonLabel.superview.hidden = NO;
  self.oilButton.userInteractionEnabled = YES;
  self.cashButtonLabel.text = [NSString stringWithFormat:@"%d", research.costAmt];
  self.cashButtonView.hidden = research.costType != ResourceTypeCash;
  self.cashButtonLabel.superview.hidden = NO;
  self.cashButton.userInteractionEnabled = YES;
  
  [Globals adjustViewForCentering:self.researchOilLabel.superview withLabel:self.researchOilLabel];
  [Globals adjustViewForCentering:self.researchCashLabel.superview withLabel:self.researchCashLabel];
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
  self.bottomBarDescription.text = [NSString stringWithFormat:@"You are missing %d requirement%@ to Research.", missingRequirements, missingRequirements == 1 ? @"" : @"s"];
  
  self.bottomBarIcon.highlighted = YES;
  self.bottomBarImage.highlighted = YES;
  self.bottomBarTitle.highlighted = YES;
  self.bottomBarDescription.highlighted = YES;
}



@end

@implementation ResearchInfoViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserResearch) name:RESEARCH_CHANGED_NOTIFICATION object:nil];
  
  [self.view updateWithResearch:_userResearch];
}

- (void) updateUserResearch {
  if(_userResearch) {
    GameState *gs = [GameState sharedGameState];
    _userResearch = [gs.researchUtil currentRankForResearch:_userResearch.research];
    [self.view updateWithResearch:_userResearch];
    self.title = [NSString stringWithFormat:@"Research to Rank %d",_userResearch.research.level];
  }
}

- (id) initWithResearch:(UserResearch *)userResearch {
  if ((self = [super init])) {
    _userResearch = userResearch;
    self.title = [NSString stringWithFormat:@"Research to Rank %d",_userResearch.research.level];
  }
  
  return self;
}

- (IBAction) detailsClicked:(id)sender {
  ResearchDetailViewController *rdvc = [[ResearchDetailViewController alloc] initWithUserResearch:_userResearch];
  [self.parentViewController pushViewController:rdvc animated:YES];
}

- (IBAction) clickResearchStart:(id)sender {
  if (!self.view.activityIndicator.hidden) {return;}
  
  GameState *gs = [GameState sharedGameState];
  
  if ([gs.researchUtil currentResearch]) {
    [Globals popupMessage:@"Research already in progress"];
    return;
  }
  
  ResearchProto *research = _userResearch.research;
  
  if ( (research.costType == ResourceTypeCash && gs.cash <= research.costAmt) || (research.costType == ResourceTypeOil && gs.oil <= research.costAmt)) {
    ItemSelectViewController *svc = [[ItemSelectViewController alloc] init];
    if (svc) {
      ResourceItemsFiller *rif = [[ResourceItemsFiller alloc] initWithResourceType:research.costType requiredAmount:research.costAmt shouldAccumulate:YES];
      rif.delegate = self;
      svc.delegate = rif;
      self.itemSelectViewController = svc;
      self.resourceItemsFiller = rif;
      
      GameViewController *gvc = [GameViewController baseController];
      svc.view.frame = gvc.view.bounds;
      [gvc addChildViewController:svc];
      [gvc.view addSubview:svc.view];
      
      UIButton* invokingButton = (UIButton*)sender;
      [svc showAnchoredToInvokingView:invokingButton withDirection:ViewAnchoringPreferLeftPlacement inkovingViewImage:invokingButton.currentImage];
    }
  } else {
    UserResearch *startedResearch = [[OutgoingEventController sharedOutgoingEventController] beginResearch:_userResearch gemsSpent:0 resourceType:research.costType resourceCost:research.costAmt delegate:self];
    _waitingForServer = YES;
    if(!startedResearch) {
      [Globals popupMessage:@"An error occured contacting the server."];
    } else {
      self.view.oilButtonLabel.superview.hidden = YES;
      self.view.cashButtonLabel.superview.hidden = YES;
      self.view.activityIndicator.hidden = NO;
      self.view.cashButton.userInteractionEnabled = NO;
      _userResearch = startedResearch;
    }
  }
}

- (void) beginResearchWithItemsDict:(NSDictionary *)itemIdsToQuantity useGems:(BOOL)useGems {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  UserResearch *startedResearch;
  int gems = 0;
  [[OutgoingEventController sharedOutgoingEventController] tradeItemIdsForResources:itemIdsToQuantity];
  if(useGems) {
    int remainingCost = _userResearch.research.costType == ResourceTypeCash ? _userResearch.research.costAmt - gs.cash : _userResearch.research.costAmt - gs.oil;
    gems = [gl calculateGemConversionForResourceType:_userResearch.research.costType amount:remainingCost];
    
    int playerResource = _userResearch.research.costType == ResourceTypeCash ? gs.cash : gs.oil;
    startedResearch = [[OutgoingEventController sharedOutgoingEventController] beginResearch:_userResearch gemsSpent:gems resourceType:_userResearch.research.costType resourceCost:playerResource delegate:self];
  } else {
    startedResearch = [[OutgoingEventController sharedOutgoingEventController] beginResearch:_userResearch gemsSpent:0 resourceType:_userResearch.research.costType resourceCost:_userResearch.research.costAmt delegate:self];
  }
  _waitingForServer = YES;
  if (startedResearch) {
    self.view.oilButtonLabel.superview.hidden = YES;
    self.view.cashButtonLabel.superview.hidden = YES;
    self.view.activityIndicator.hidden = NO;
    self.view.cashButton.userInteractionEnabled = NO;
    _userResearch = startedResearch;
  }
}

- (void) handlePerformResearchResponseProto:(FullEvent *)fe {
  _waitingForServer = NO;
  PerformResearchResponseProto *proto = (PerformResearchResponseProto *)fe.event;
  if(proto.status != PerformResearchResponseProto_PerformResearchStatusSuccess) {
    
  }
  self.view.bottomBarTitle.text = RESEARCHING_TITLE;
  self.view.bottomBarDescription.text = RESEARCHING_DESCRIPTION;
}

- (void) updateLabels {
  int timeLeft = _userResearch.tentativeCompletionDate.timeIntervalSinceNow;
  if(_waitingForServer) {
    self.view.timeLeftLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    return;
  }
  
  if(_userResearch.complete) {
    self.view.oilButtonView.hidden = YES;
    self.view.cashButtonView.hidden = YES;
    self.view.finishButtonView.hidden = YES;
    self.view.helpButtonView.hidden = YES;
    self.view.timeLeftLabel.superview.hidden = YES;
    self.view.bottomBarDescription.text = @"This research has already been completed";
    self.view.bottomBarTitle.text = @"Research Complete!";
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  
  BOOL canHelp = [gs canAskForClanHelp];
  if (canHelp) {
    canHelp = NO;
    if ([_userResearch isResearching]) {
      int helpsRequested = [gs.clanHelpUtil getNumClanHelpsForType:GameActionTypePerformingResearch userDataUuid:_userResearch.userResearchUuid];
      if (helpsRequested <= 0) {
        canHelp = YES;
      }
    }
  }
  
  if (timeLeft > 0) {
    self.view.oilButtonView.hidden = YES;
    self.view.cashButtonView.hidden = YES;
    self.view.activityIndicator.hidden = YES;
    self.view.finishButtonView.hidden = NO;
    
    self.view.timeLeftLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    self.view.timeLeftLabel.superview.hidden = NO;
    if (speedupCost > 0) {
      self.view.helpButtonView.hidden = !canHelp;
      self.view.finishSpeedupIcon.hidden = NO;
      self.view.finishFreeLabel.hidden = YES;
    } else {
      self.view.helpButtonView.hidden = YES;
      self.view.finishSpeedupIcon.hidden = YES;
      self.view.finishFreeLabel.hidden = NO;
    }
  } else {
    self.view.finishButtonView.hidden = YES;
    self.view.helpButtonView.hidden = YES;
    self.view.timeLeftLabel.superview.hidden = YES;
  }
}

-(void) waitTimeComplete {
  UserResearch *newUserResearch = [UserResearch userResearchWithResearch:_userResearch.research];
  newUserResearch.userResearchUuid = _userResearch.userResearchUuid;
  _userResearch = newUserResearch;
}

- (IBAction)helpButtonClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] solicitResearchHelp:_userResearch];
  [self updateLabels];
}

- (IBAction)finishNowClicked:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  int timeLeft = _userResearch.tentativeCompletionDate.timeIntervalSinceNow;
  int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  
  if(speedupCost > 0) {
    ItemSelectViewController *svc = [[ItemSelectViewController alloc] init];
    if (svc) {
      SpeedupItemsFiller *sif = [[SpeedupItemsFiller alloc] init];
      sif.delegate = self;
      svc.delegate = sif;
      self.speedupItemsFiller = sif;
      self.itemSelectViewController = svc;
      
      GameViewController *gvc = [GameViewController baseController];
      svc.view.frame = gvc.view.bounds;
      [gvc addChildViewController:svc];
      [gvc.view addSubview:svc.view];
      
      if (sender == nil)
      {
        [svc showCenteredOnScreen];
      }
      else
      {
        if ([sender isKindOfClass:[TimerCell class]])
        {
          UIButton* invokingButton = ((TimerCell*)sender).speedupButton;
          const CGPoint invokingViewAbsolutePosition = [Globals convertPointToWindowCoordinates:invokingButton.frame.origin fromViewCoordinates:invokingButton.superview];
          [svc showAnchoredToInvokingView:invokingButton
                            withDirection:invokingViewAbsolutePosition.y < [Globals screenSize].height * .25f ? ViewAnchoringPreferBottomPlacement : ViewAnchoringPreferLeftPlacement
                        inkovingViewImage:[invokingButton backgroundImageForState:invokingButton.state]];
        }
        else if ([sender isKindOfClass:[UIButton class]]) // Speed up healing mobster
        {
          UIButton* invokingButton = (UIButton*)sender;
          [svc showAnchoredToInvokingView:invokingButton
                            withDirection:ViewAnchoringPreferLeftPlacement
                        inkovingViewImage:[invokingButton backgroundImageForState:invokingButton.state]];
        }
      }
    }
  } else {
    self.view.activityIndicator.hidden = NO;
    self.view.finishFreeLabel.hidden = YES;
    _userResearch = [[OutgoingEventController sharedOutgoingEventController] finishResearch:_userResearch gemsSpent:0 delegate:self];
    _waitingForServer = YES;
  }
}

- (void) handleFinishPerformingResearchResponseProto:(FullEvent *)fe {
  self.view.activityIndicator.hidden = YES;
  NSString *researchUserId = _userResearch.userResearchUuid;
  _userResearch = [UserResearch userResearchWithResearch:_userResearch.research];
  _userResearch.userResearchUuid = researchUserId;
  _waitingForServer = NO;
}

- (void) speedupResearchWithGems {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (self.speedupItemsFiller) {
    [self.itemSelectViewController closeClicked:nil];
  }
  
  int timeLeft = _userResearch.tentativeCompletionDate.timeIntervalSinceNow;
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  
  if (gs.gems < goldCost) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    self.view.activityIndicator.hidden = NO;
    self.view.finishFreeLabel.hidden = YES;
    _userResearch = [[OutgoingEventController sharedOutgoingEventController] finishResearch:_userResearch gemsSpent:goldCost delegate:self];
    _waitingForServer = YES;
      
      [[NSNotificationCenter defaultCenter] postNotificationName:RESEARCH_CHANGED_NOTIFICATION object:self];
  }
}

#pragma mark - SpeedUpItemFillerDelegate

- (void) speedupItemUsed:(id<ItemObject>)itemObject viewController:(ItemSelectViewController *)viewController {
  if ([itemObject isKindOfClass:[GemsItemObject class]]) {
    [self speedupResearchWithGems];
  } else if ([itemObject isKindOfClass:[UserItem class]]) {
    // Apply items
    GameState *gs = [GameState sharedGameState];
    UserItem *ui = (UserItem *)itemObject;
    ItemProto *ip = [gs itemForId:ui.itemId];
    
    if (ip.itemType == ItemTypeSpeedUp) {
      [[OutgoingEventController sharedOutgoingEventController] tradeItemForSpeedup:ui.itemId userResearch:_userResearch];
      
      [self updateLabels];
    }
    
    int timeLeft = _userResearch.tentativeCompletionDate.timeIntervalSinceNow;
    if (timeLeft > 0) {
      [viewController reloadDataAnimated:YES];
    }
  }
}

- (int) numGemsForTotalSpeedup {
  int timeLeft = _userResearch.tentativeCompletionDate.timeIntervalSinceNow;
  return [[Globals sharedGlobals] calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
}

- (void) itemSelectClosed:(id)viewController {
  self.itemSelectViewController = nil;
  self.speedupItemsFiller = nil;
  self.resourceItemsFiller = nil;
}

- (int) timeLeftForSpeedup {
  return _userResearch.tentativeCompletionDate.timeIntervalSinceNow;
}

- (int) totalSecondsRequired {
  return _userResearch.research.durationMin * 60;
}

- (NSString *)titleName {
  //not sure where this even goes
  return @"Item Menu";
}

- (void) resourceItemsUsed:(NSDictionary *)itemUsages {
  // itemUsages are Item Ids to Quantity
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  BOOL allowGems = [itemUsages[@0] boolValue];
  
  int cost = _userResearch.research.costAmt;
  ResourceType resType = _userResearch.research.costType;
  
  int curAmount = [gl calculateTotalResourcesForResourceType:resType itemIdsToQuantity:itemUsages];
  int gemCost = [gl calculateGemConversionForResourceType:resType amount:cost-curAmount];
  
  if (allowGems && gemCost > gs.gems) {
    [GenericPopupController displayNotEnoughGemsView];
  } else if (allowGems || cost <= curAmount) {
    [self beginResearchWithItemsDict:itemUsages useGems:allowGems];
  }
}

@end


