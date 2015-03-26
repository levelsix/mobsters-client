//
//  ResearchViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 2/27/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ResearchViewController.h"
#import "ResearchTreeViewController.h"
#import "OutgoingEventController.h"
#import "GenericPopupController.h"

#import "GameState.h"
#import "GameViewController.h"

@implementation ResearchViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.titleImageName = @"researchcentermenuheader.png";
  self.title = @"RESEARCH";
}

- (IBAction)helpButtonClicked:(id)sender {
  if(!_curResearch) {
    _curResearch = [[GameState sharedGameState].researchUtil currentResearch];
  }
  
  [[OutgoingEventController sharedOutgoingEventController] solicitResearchHelp:_curResearch];
  [self updateLabels];
}

#pragma mark - BarUpkeep

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  GameState *gs = [GameState sharedGameState];
  UserResearch *curResearch = [gs.researchUtil currentResearch];
  _curResearch = curResearch;
  
  if (curResearch && !_curResearchUp) {
    [Globals imageNamed:curResearch.research.iconImgName withView:self.researchIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
    
    CGPoint position = self.selectFieldView.center;
    [self.selectFieldView removeFromSuperview];
    [self.view addSubview:self.curReseaerchBar];
    self.curReseaerchBar.center = position;
    
    _curResearchUp = YES;
    
    [self updateLabels];
    
  } else if (!curResearch && _curResearchUp) {
    CGPoint position = self.curReseaerchBar.center;
    
    [self.curReseaerchBar removeFromSuperview];
    [self.view addSubview:self.selectFieldView];
    self.selectFieldView.center = position;
    
    _curResearchUp = NO;
    
    [self updateLabels];
  }
}

- (void) updateLabels {
  int timeLeft = _curResearch.tentativeCompletionDate.timeIntervalSinceNow;
  if (_waitingForServer) {
    self.curTimeRemaining.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    return;
  }
  
  if (!_curResearchUp) {return;}
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  BOOL canHelp = [gs canAskForClanHelp];
  
  if (canHelp) {
    canHelp = NO;
    if ([_curResearch isResearching]) {
      if ([gs.clanHelpUtil getNumClanHelpsForType:GameActionTypePerformingResearch userDataUuid:_curResearch.userResearchUuid] < 0) {
        canHelp = YES;
      }
    }
  }
  if (timeLeft > 0) {
    self.activityIndicator.hidden = YES;
    self.finishButton.superview.hidden = NO;
    
    self.curTimeRemaining.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    self.curTimeRemaining.superview.hidden = NO;
    if (speedupCost > 0) {
      self.helpButton.superview.hidden = !canHelp;
      self.finishIcon.hidden = NO;
      self.finishFreeLabel.hidden = YES;
    } else {
      self.helpButton.superview.hidden = YES;
      self.finishIcon.hidden = YES;
      self.finishFreeLabel.hidden = NO;
    }
  } else {
    self.finishButton.superview.hidden = YES;
    self.helpButton.superview.hidden = YES;
    self.curTimeRemaining.superview.hidden = YES;
  }
  self.curResearchTitle.text = _curResearch.research.name;
}

-(void)waitTimeComplete {
  if(_curResearchUp) {
    CGPoint position = self.curReseaerchBar.center;
    [self.curReseaerchBar removeFromSuperview];
    [self.view addSubview:self.selectFieldView];
    self.selectFieldView.center = position;
    _curResearchUp = NO;
  }
}

#pragma mark - handleResponses

- (void) handleFinishPerformingResearchResponseProto:(FullEvent *)fe {
  CGPoint position = self.curReseaerchBar.center;
  [self.curReseaerchBar removeFromSuperview];
  [self.view addSubview:self.selectFieldView];
  self.selectFieldView.center = position;
  _curResearchUp = NO;
}

#pragma mark - TableView Delegates

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ResearchCategoryCell *cell;
  cell = [tableView dequeueReusableCellWithIdentifier:@"ResearchCategoryCell"];
  if (!cell) {
    cell = [[NSBundle mainBundle] loadNibNamed:@"ResearchCategoryCell" owner:self options:nil][0];
  }
  
  ResearchDomain domain = (ResearchDomain)indexPath.row+2; //add 2 to avoid 0 and NO_DOMAIN
  [cell updateForDomain:domain];
  
  return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // Put the last domain here and subtract 2 to discount 0 and NoDomain
  return ResearchDomainTrapsAndObstacles - 2;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  ResearchTreeViewController *rtvc = [[ResearchTreeViewController alloc] initWithDomain:(ResearchDomain)indexPath.row+2];
  [self.parentViewController pushViewController:rtvc animated:YES];
}

#pragma mark - ItemMenu

- (IBAction)finishNowClicked:(id)sender {
  if(!_curResearch) {
    _curResearch = [[GameState sharedGameState].researchUtil currentResearch];
  }
  Globals *gl = [Globals sharedGlobals];
  int timeLeft = _curResearch.tentativeCompletionDate.timeIntervalSinceNow;
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
        if ([sender isKindOfClass:[TimerCell class]]) // Invoked from TimerAction
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
    self.activityIndicator.hidden = NO;
    self.finishFreeLabel.hidden = YES;
    _curResearch = [[OutgoingEventController sharedOutgoingEventController] finishResearch:_curResearch gemsSpent:0 delegate:self];
    _waitingForServer = YES;
  }
}

- (void) speedupResearchWithGems {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (self.speedupItemsFiller) {
    [self.itemSelectViewController closeClicked:nil];
  }
  
  int timeLeft = _curResearch.tentativeCompletionDate.timeIntervalSinceNow;
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  
  if (gs.gems < goldCost) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    self.activityIndicator.hidden = NO;
    self.finishFreeLabel.hidden = YES;
    _curResearch = [[OutgoingEventController sharedOutgoingEventController] finishResearch:_curResearch gemsSpent:goldCost delegate:self];
    _waitingForServer = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RESEARCH_CHANGED_NOTIFICATION object:self];
  }
}

- (void) speedupItemUsed:(id<ItemObject>)itemObject viewController:(ItemSelectViewController *)viewController {
  if ([itemObject isKindOfClass:[GemsItemObject class]]) {
    [self speedupResearchWithGems];
  } else if ([itemObject isKindOfClass:[UserItem class]]) {
    // Apply items
    GameState *gs = [GameState sharedGameState];
    UserItem *ui = (UserItem *)itemObject;
    ItemProto *ip = [gs itemForId:ui.itemId];
    
    if (ip.itemType == ItemTypeSpeedUp) {
      [[OutgoingEventController sharedOutgoingEventController] tradeItemForSpeedup:ui.itemId userResearch:_curResearch];
      
      [self updateLabels];
    }
    int timeLeft = _curResearch.tentativeCompletionDate.timeIntervalSinceNow;
    if (timeLeft > 0) {
      [viewController reloadDataAnimated:YES];
    }
  }
}

- (int) numGemsForTotalSpeedup {
  int timeLeft = _curResearch.tentativeCompletionDate.timeIntervalSinceNow;
  return [[Globals sharedGlobals] calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
}

- (void) itemSelectClosed:(id)viewController {
  self.itemSelectViewController = nil;
  self.speedupItemsFiller = nil;
}

- (int) timeLeftForSpeedup {
  return _curResearch.tentativeCompletionDate.timeIntervalSinceNow;
}

- (int) totalSecondsRequired {
  return _curResearch.research.durationMin * 60;
}

- (NSString *)titleName {
  return @"ugghh";
}


@end

@implementation ResearchCategoryCell : UITableViewCell

- (void) updateForDomain:(ResearchDomain) domain {
  
  switch (domain) {
    case ResearchDomainRestorative:
      self.categoryTitle.text = @"Restorative";
      self.categoryIcon.image = [Globals imageNamed:@"researchtoons.png"];
      break;
    case ResearchDomainBattle:
      self.categoryTitle.text = @"Battle";
      self.categoryIcon.image =[Globals imageNamed:@"researchbattle.png"];
      break;
    case ResearchDomainLevelup:
      self.categoryTitle.text = @"Level Up";
      self.categoryIcon.image =[Globals imageNamed:@"researchresources.png"];
      break;
    case ResearchDomainResources:
      self.categoryTitle.text = @"Resources";
      self.categoryIcon.image =[Globals imageNamed:@"researchresources.png"];
      break;
    case ResearchDomainItems:
      self.categoryTitle.text = @"Items";
      self.categoryIcon.image =[Globals imageNamed:@"researchresources.png"];
      break;
    case ResearchDomainTrapsAndObstacles:
      self.categoryTitle.text = @"Obstacles";
      self.categoryIcon.image =[Globals imageNamed:@"researchresources.png"];
      
    default:
      self.categoryTitle.text = [NSString stringWithFormat:@"Had a problem loading domain type %d",domain];
      break;
  }
  
}

@end
