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
#import "MiniEventManager.h"

#import "DetailViewController.h"

#import "Globals.h"
#import "GameState.h"
#import "GameViewController.h"

#define RESEARCHING_DESCRIPTION @"This research is currently in progress"
#define RESEARCHING_TITLE @"Currently Researching"

#define DEFAULT_TITLE @"Ready to Research!"
#define DEFAULT_DESCRIPTION @"You have met all the requirements to Research."

@implementation ResearchPrereqView

- (void) updateForPrereq:(PrereqProto *)pre isComplete:(BOOL)isComplete {
  
  if (pre.gameType == GameTypeStructure) {
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
  self.bottomDescLabel.text = DEFAULT_DESCRIPTION;
  self.bottomNameLabel.text = DEFAULT_TITLE;
  
  ResearchProto *curResearch = userResearch.staticResearchForBenefitLevel;
  ResearchProto *nextResearch = userResearch.staticResearchForNextLevel;
  
  Globals *gl = [Globals sharedGlobals];
  
  [self.embeddedScrollView updateForGameTypeProto:curResearch];
  
  [Globals imageNamed:curResearch.iconImgName withView:self.researchIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  self.researchTimeLabel.text = nextResearch ? [[Globals convertTimeToMediumString:[gl calculateSecondsToResearch:nextResearch]] uppercaseString] : @"N/A";
  
  {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:curResearch.name attributes:@{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : self.researchNameLabel.font}];
    self.researchNameLabel.attributedText = attr;
    
    CGRect rect = [attr boundingRectWithSize:CGSizeMake(self.researchNameLabel.width, 9999) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    self.researchNameLabel.originY = floorf(CGRectGetMaxY(self.researchNameLabel.frame) - rect.size.height);
    self.researchNameLabel.height = ceilf(rect.size.height);
  }
  
  int numIncomplete = [curResearch numIncompletePrereqs];
  if (numIncomplete > 0) {
    [self setDisplayForNumMissingRequirements:numIncomplete];
  } else if (!userResearch.complete) {
    self.bottomDescLabel.text = RESEARCHING_DESCRIPTION;
    self.bottomNameLabel.text = RESEARCHING_TITLE;
  }
  
  if (userResearch.complete && nextResearch) {
    self.oilButtonLabel.text = [Globals commafyNumber:nextResearch.costAmt];
    self.oilButtonView.hidden = nextResearch.costType != ResourceTypeOil;
    self.cashButtonLabel.text = [Globals commafyNumber:nextResearch.costAmt];
    self.cashButtonView.hidden = nextResearch.costType != ResourceTypeCash;
    
    self.oilButton.userInteractionEnabled = YES;
    self.cashButton.userInteractionEnabled = YES;
  } else {
    self.oilButtonView.hidden = YES;
    self.cashButtonView.hidden = YES;
    
    if (!nextResearch) {
      self.bottomDescLabel.text = @"This research has already been completed";
      self.bottomNameLabel.text = @"Research Complete!";
    }
  }
  
  [Globals adjustViewForCentering:self.researchOilLabel.superview withLabel:self.researchOilLabel];
  [Globals adjustViewForCentering:self.researchCashLabel.superview withLabel:self.researchCashLabel];
}

- (void) setDisplayForNumMissingRequirements:(int)missingRequirements {
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
  
  self.bottomNameLabel.text = @"Woops!";
  self.bottomDescLabel.text = [NSString stringWithFormat:@"You are missing %d requirement%@ to Research.", missingRequirements, missingRequirements == 1 ? @"" : @"s"];
  
  self.bottomBarIcon.highlighted = YES;
  self.bottomBarBgd.highlighted = YES;
  self.bottomNameLabel.highlighted = YES;
  self.bottomDescLabel.highlighted = YES;
}

@end

@implementation ResearchInfoViewController

- (id) initWithResearch:(UserResearch *)userResearch {
  if ((self = [super init])) {
    _userResearch = userResearch;
  }
  
  return self;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self waitTimeComplete];
}

- (void) updateLabels {
  if (_waitingForServer) {
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  UserResearch *ur = _userResearch;
  
  if (!ur.complete) {
    int timeLeft = ur.tentativeCompletionDate.timeIntervalSinceNow;
    int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
    BOOL canHelp = [gs canAskForClanHelp] && [gs.clanHelpUtil getNumClanHelpsForType:GameActionTypePerformingResearch userDataUuid:ur.userResearchUuid] < 0;
    
    self.view.timeLeftLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    self.view.timeLeftLabel.superview.hidden = NO;
    
    self.view.finishButtonView.hidden = NO;
    
    if (speedupCost > 0) {
      self.view.speedupIcon.hidden = NO;
      self.view.freeLabel.hidden = YES;
      
      self.view.helpButtonView.hidden = !canHelp;
    } else {
      self.view.speedupIcon.hidden = YES;
      self.view.freeLabel.hidden = NO;
      self.view.helpButtonView.hidden = YES;
    }
  } else {
    self.view.finishButtonView.hidden = YES;
    self.view.helpButtonView.hidden = YES;
    self.view.timeLeftLabel.superview.hidden = YES;
    
    if (self.speedupItemsFiller) {
      [self.itemSelectViewController closeClicked:nil];
    }
  }
}

- (void) waitTimeComplete {
  ResearchProto *next = _userResearch.staticResearchForNextLevel;
  self.title = next ? [NSString stringWithFormat:@"Research to Rank %d", next.level] : [NSString stringWithFormat:@"%@ is at Max", _userResearch.staticResearch.name];
  
  [self.view updateWithResearch:_userResearch];
  [self updateLabels];
}

#pragma mark - Bottom View

- (IBAction) detailsClicked:(int)index {
  ResearchProto *rp = _userResearch.staticResearchForBenefitLevel;
  DetailViewController *rdvc = [[DetailViewController alloc] initWithGameTypeProto:rp index:index imageNamed:rp.iconImgName];
  
  [self.parentViewController pushViewController:rdvc animated:YES];
}

- (void) goClicked:(int)prereqId {
  NSArray *prereqs = [_userResearch.staticResearchForBenefitLevel prereqs];
  
  PrereqProto *pp;
  for (PrereqProto *nextPp in prereqs) {
    if(nextPp.prereqId == prereqId) {
      pp = nextPp;
    }
  }
  
  GameViewController *gvc = [GameViewController baseController];
  if (pp.prereqGameType == GameTypeStructure) {
    BOOL success = [gvc pointArrowToUpgradeForStructId:pp.prereqGameEntityId quantity:pp.quantity];
    
    if (success) {
      [self.parentViewController close];
    }
  }
}

- (IBAction) clickResearchStart:(id)sender {
  if (_waitingForServer) {
    return;
  }
  
  if (![_userResearch.staticResearch prereqsComplete]) {
    [Globals addAlertNotification:@"You have not yet met the requirements to research."];
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  UserResearch *curRes = [gs.researchUtil currentResearch];
  if (curRes) {
    int timeLeft = curRes.tentativeCompletionDate.timeIntervalSinceNow;
    int gemCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
    
    if (gemCost) {
      NSString *desc = [NSString stringWithFormat:@"You are currently researching %@! Speed it up for %@ gem%@ and start this research?", curRes.staticResearchForBenefitLevel.name, [Globals commafyNumber:gemCost], gemCost == 1 ? @"" : @"s"];
      [GenericPopupController displayGemConfirmViewWithDescription:desc title:@"Research In Progress" gemCost:gemCost target:self selector:@selector(speedupAndBeginResearch)];
    } else {
      [self speedupAndBeginResearch];
    }
    return;
  }
  
  ResearchProto *research = _userResearch.staticResearchForNextLevel;
  
  if ((research.costType == ResourceTypeCash && gs.cash < research.costAmt) ||
      (research.costType == ResourceTypeOil && gs.oil < research.costAmt)) {
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
    [self sendResearchWithItemsDict:nil allowGems:NO];
  }
}

- (void) speedupAndBeginResearch {
  GameState *gs = [GameState sharedGameState];
  
  UserResearch *ur = [gs.researchUtil currentResearch];
  if (ur) {
    [self speedupResearch:ur];
  }
  
  [self clickResearchStart:nil];
}

- (void) researchWithItemsDict:(NSDictionary *)itemIdsToQuantity {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  ResearchProto *rp = _userResearch.staticResearchForNextLevel;
  
  BOOL allowGems = [itemIdsToQuantity[@0] boolValue];
  
  int cost = rp.costAmt;
  ResourceType resType = rp.costType;
  
  int curAmount = [gl calculateTotalResourcesForResourceType:resType itemIdsToQuantity:itemIdsToQuantity];
  int gemCost = [gl calculateGemConversionForResourceType:resType amount:cost-curAmount];
  
  if (allowGems && gemCost > gs.gems) {
    [GenericPopupController displayNotEnoughGemsView];
  } else if (allowGems || cost <= curAmount) {
    [self sendResearchWithItemsDict:itemIdsToQuantity allowGems:allowGems];
  }
}


- (void) sendResearchWithItemsDict:(NSDictionary *)itemIdsToQuantity allowGems:(BOOL)allowGems {
  if (!_waitingForServer) {
    [[OutgoingEventController sharedOutgoingEventController] tradeItemIdsForResources:itemIdsToQuantity];
    BOOL success = [[OutgoingEventController sharedOutgoingEventController] beginResearch:_userResearch allowGems:allowGems delegate:self];
    
    if (success) {
      self.view.oilButtonLabel.superview.hidden = YES;
      self.view.cashButtonLabel.superview.hidden = YES;
      self.view.activityIndicator.hidden = NO;
      self.view.oilButton.userInteractionEnabled = NO;
      self.view.cashButton.userInteractionEnabled = NO;
      
      _waitingForServer = YES;
      
      [[NSNotificationCenter defaultCenter] postNotificationName:RESEARCH_CHANGED_NOTIFICATION object:self];
    }
  }
}

- (void) handlePerformResearchResponseProto:(FullEvent *)fe {
  _waitingForServer = NO;
  
  self.view.oilButtonLabel.superview.hidden = NO;
  self.view.cashButtonLabel.superview.hidden = NO;
  self.view.activityIndicator.hidden = YES;
  self.view.oilButton.userInteractionEnabled = YES;
  self.view.cashButton.userInteractionEnabled = YES;
  
  [self waitTimeComplete];
}

#pragma mark Completion

- (IBAction) helpButtonClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] solicitResearchHelp:_userResearch];
  [self updateLabels];
}

- (IBAction) finishNowClicked:(id)sender {
  if (_waitingForServer) {
    return;
  }
  
  Globals *gl = [Globals sharedGlobals];
  
  int timeLeft = _userResearch.tentativeCompletionDate.timeIntervalSinceNow;
  int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  
  if (speedupCost > 0) {
    ItemSelectViewController *svc = [[ItemSelectViewController alloc] init];
    if (svc) {
      SpeedupItemsFiller *sif = [[SpeedupItemsFiller alloc] initWithGameActionType:GameActionTypePerformingResearch];
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
    [self speedupResearch:_userResearch];
  }
}

- (void) speedupResearch:(UserResearch *)ur {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (self.speedupItemsFiller) {
    [self.itemSelectViewController closeClicked:nil];
  }
  
  int timeLeft = ur.tentativeCompletionDate.timeIntervalSinceNow;
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  
  if (gs.gems < goldCost) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    BOOL success = [[OutgoingEventController sharedOutgoingEventController] finishResearch:ur useGems:YES delegate:self];
    
    if (success) {
      self.view.activityIndicator.hidden = NO;
      self.view.finishLabelsView.hidden = YES;
      self.view.finishButtonView.userInteractionEnabled = NO;
      
      if (ur == _userResearch) {
        _waitingForServer = YES;
      }
      
      [[NSNotificationCenter defaultCenter] postNotificationName:RESEARCH_CHANGED_NOTIFICATION object:self];
      
      [[MiniEventManager sharedInstance] checkResearchStrength:ur.researchId];
    }
  }
}

- (void) handleFinishPerformingResearchResponseProto:(FullEvent *)fe {
  self.view.activityIndicator.hidden = YES;
  
  self.view.finishLabelsView.hidden = NO;
  self.view.finishButtonView.userInteractionEnabled = YES;
  
  _waitingForServer = NO;
  
  [self waitTimeComplete];
}

#pragma mark - SpeedUpItemFillerDelegate

- (void) speedupItemUsed:(id<ItemObject>)itemObject viewController:(ItemSelectViewController *)viewController {
  if ([itemObject isKindOfClass:[GemsItemObject class]]) {
    [self speedupResearch:_userResearch];
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
  Globals *gl = [Globals sharedGlobals];
  return [gl calculateSecondsToResearch:_userResearch.staticResearchForNextLevel];
}

- (void) resourceItemsUsed:(NSDictionary *)itemUsages {
  // itemUsages are Item Ids to Quantity
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  BOOL allowGems = [itemUsages[@0] boolValue];
  
  ResearchProto *rp = _userResearch.staticResearchForNextLevel;
  int cost = rp.costAmt;
  ResourceType resType = rp.costType;
  
  int curAmount = [gl calculateTotalResourcesForResourceType:resType itemIdsToQuantity:itemUsages];
  int gemCost = [gl calculateGemConversionForResourceType:resType amount:cost-curAmount];
  
  if (allowGems && gemCost > gs.gems) {
    [GenericPopupController displayNotEnoughGemsView];
  } else if (allowGems || cost <= curAmount) {
    [self sendResearchWithItemsDict:itemUsages allowGems:allowGems];
  }
}

@end


