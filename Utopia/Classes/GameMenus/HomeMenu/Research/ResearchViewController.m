//
//  ResearchViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 2/27/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ResearchViewController.h"
#import "ResearchInfoViewController.h"
#import "ResearchTreeViewController.h"
#import "OutgoingEventController.h"
#import "GenericPopupController.h"
#import "MiniEventManager.h"

#import "GameState.h"
#import "GameViewController.h"

@implementation ResearchViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.titleImageName = @"researchcentermenuheader.png";
  self.title = @"RESEARCH";
  
  self.curResearchBar.frame = self.selectFieldView.frame;
  [self.selectFieldView.superview addSubview:self.curResearchBar];
}

- (UserResearch *) curResearch {
  GameState *gs = [GameState sharedGameState];
  return [gs.researchUtil currentResearch];
}

#pragma mark - BarUpkeep

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self updateBottomView];
}

- (void) updateBottomView {
  UserResearch *curResearch = [self curResearch];
  
  if (curResearch) {
    [Globals imageNamed:curResearch.staticResearch.iconImgName withView:self.researchIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
    
    self.curResearchBar.hidden = NO;
    self.selectFieldView.hidden = YES;
    
    [self updateLabels];
    
    self.researchNameLabel.text = self.curResearch.staticResearch.name;
  } else {
    self.curResearchBar.hidden = YES;
    self.selectFieldView.hidden = NO;
    
  }
}

- (void) updateLabels {
  if (_waitingForServer) {
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  UserResearch *ur = [self curResearch];
  
  int timeLeft = ur.tentativeCompletionDate.timeIntervalSinceNow;
  int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  BOOL canHelp = [gs canAskForClanHelp] && [gs.clanHelpUtil getNumClanHelpsForType:GameActionTypePerformingResearch userDataUuid:ur.userResearchUuid] < 0;
  
  self.timeLeftLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
  self.timeLeftLabel.superview.hidden = NO;
  
  if (speedupCost > 0) {
    self.speedupIcon.hidden = NO;
    self.freeLabel.hidden = YES;
    
    self.helpButtonView.hidden = !canHelp;
  } else {
    self.speedupIcon.hidden = YES;
    self.freeLabel.hidden = NO;
    self.helpButtonView.hidden = YES;
  }
}

- (void) waitTimeComplete {
  [self updateBottomView];
}

- (IBAction)curResearchBarClicked:(id)sender {
  ResearchInfoViewController *rivc = [[ResearchInfoViewController alloc] initWithResearch:self.curResearch];
  [self.parentViewController pushViewController:rivc animated:YES];
  
  ResearchTreeViewController *rtvc = [[ResearchTreeViewController alloc] initWithDomain:self.curResearch.staticResearch.researchDomain];
  [self.parentViewController.viewControllers insertObject:rtvc atIndex:self.parentViewController.viewControllers.count-1];
  [self.parentViewController addChildViewController:rtvc];
  [rtvc selectResearch:self.curResearch];
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
  // Put the last domain here and subtract 2 to discount 0 and NoDomain and add 1 since it needs to not be 0 aligned
  return ResearchDomainTrapsAndObstacles - 2 + 1;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  ResearchTreeViewController *rtvc = [[ResearchTreeViewController alloc] initWithDomain:(ResearchDomain)indexPath.row+2];
  [self.parentViewController pushViewController:rtvc animated:YES];
}

#pragma mark - ItemMenu

- (IBAction) helpButtonClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] solicitResearchHelp:self.curResearch];
  [self updateLabels];
}

- (IBAction) finishNowClicked:(id)sender {
  if (_waitingForServer) {
    return;
  }
  
  Globals *gl = [Globals sharedGlobals];
  int timeLeft = self.curResearch.tentativeCompletionDate.timeIntervalSinceNow;
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
    [self speedupResearch];
  }
}

- (void) speedupResearch {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (self.speedupItemsFiller) {
    [self.itemSelectViewController closeClicked:nil];
  }
  
  UserResearch *ur = [self curResearch];
  
  int timeLeft = ur.tentativeCompletionDate.timeIntervalSinceNow;
  int goldCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  
  if (gs.gems < goldCost) {
    [GenericPopupController displayNotEnoughGemsView];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] finishResearch:ur useGems:YES delegate:self];
    
    self.spinner.hidden = NO;
    self.finishLabelsView.hidden = YES;
    
    _waitingForServer = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RESEARCH_CHANGED_NOTIFICATION object:self];
    
    [[MiniEventManager sharedInstance] checkResearchStrength:ur.researchId];
  }
}

- (void) handleFinishPerformingResearchResponseProto:(FullEvent *)fe {
  self.spinner.hidden = YES;
  self.finishLabelsView.hidden = NO;
  
  [self updateBottomView];
  
  _waitingForServer = NO;
}

#pragma mark - Speedup Item Filler

- (void) speedupItemUsed:(id<ItemObject>)itemObject viewController:(ItemSelectViewController *)viewController {
  if ([itemObject isKindOfClass:[GemsItemObject class]]) {
    [self speedupResearch];
  } else if ([itemObject isKindOfClass:[UserItem class]]) {
    // Apply items
    GameState *gs = [GameState sharedGameState];
    UserItem *ui = (UserItem *)itemObject;
    ItemProto *ip = [gs itemForId:ui.itemId];
    
    UserResearch *ur = [self curResearch];
    
    if (ip.itemType == ItemTypeSpeedUp) {
      [[OutgoingEventController sharedOutgoingEventController] tradeItemForSpeedup:ui.itemId userResearch:ur];
      
      [self updateLabels];
    }
    
    int timeLeft = ur.tentativeCompletionDate.timeIntervalSinceNow;
    if (timeLeft > 0) {
      [viewController reloadDataAnimated:YES];
    }
  }
}

- (int) numGemsForTotalSpeedup {
  Globals *gl = [Globals sharedGlobals];
  int timeLeft = self.curResearch.tentativeCompletionDate.timeIntervalSinceNow;
  return [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
}

- (void) itemSelectClosed:(id)viewController {
  self.itemSelectViewController = nil;
  self.speedupItemsFiller = nil;
}

- (int) timeLeftForSpeedup {
  return self.curResearch.tentativeCompletionDate.timeIntervalSinceNow;
}

- (int) totalSecondsRequired {
  Globals *gl = [Globals sharedGlobals];
  return [gl calculateSecondsToResearch:self.curResearch.staticResearch];
}


@end

@implementation ResearchCategoryCell : UITableViewCell

- (void) updateForDomain:(ResearchDomain) domain {
  NSString *name = [Globals stringForResearchDomain:domain];
  self.categoryTitle.text = name;
  self.categoryIcon.image = [Globals imageNamed:[NSString stringWithFormat:@"%@researchgroup.png", [name lowercaseString]]];
}

@end
