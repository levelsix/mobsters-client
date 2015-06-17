
//  AttackMapViewController.m
//  Utopia
//
//  Created by Danny on 10/8/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "AttackMapViewController.h"
#import "Globals.h"
#import "GameState.h"
#import "GameViewController.h"
#import "PersistentEventProto+Time.h"
#import "MenuNavigationController.h"
#import "GenericPopupController.h"
#import "AchievementUtil.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import "Downloader.h"
#import "DBFBProfilePictureView.h"
#import "SoundEngine.h"

#import "TangoDelegate.h"

#define NUM_CITIES 10

#define MAP_SECTION_NUM_KEY @"MapSectionNumKey"
#define LAST_ELEM_KEY @"LastMapElemKey"
#define PREV_ENTERED_ELEM_KEY @"PrevEnteredMapElemKey"

@implementation AttackMapViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Disabling attack event views in attack map
  //GameState *gs = [GameState sharedGameState];
  if (false) {//[Globals shouldShowFatKidDungeon] || gs.myEvoChamber) {
    NSString *nibFile = [Globals isSmallestiPhone] ? @"AttackEventViewSmall" : @"AttackEventView";
    [[NSBundle mainBundle] loadNibNamed:nibFile owner:self options:nil];
    
    [self.pveView addSubview:self.enhanceEventView];
    [self.pveView addSubview:self.evoEventView];
    
    self.enhanceEventView.center = ccp(self.enhanceEventView.frame.size.width/2, self.pveView.frame.size.height-self.enhanceEventView.frame.size.height/2);
    self.evoEventView.center = ccp(self.evoEventView.frame.size.width/2, self.pveView.frame.size.height-self.evoEventView.frame.size.height/2);
  }
  
  self.multiplayerView.center = ccp(-self.multiplayerView.frame.size.width*2/3, self.multiplayerView.center.y);
  self.pveView.center = ccp(self.view.frame.size.width+self.pveView.frame.size.width*2/3, self.pveView.center.y);
  [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
    self.multiplayerView.center = ccp(self.multiplayerView.frame.size.width/2, self.multiplayerView.center.y);
    self.pveView.center = ccp(self.view.frame.size.width-self.pveView.frame.size.width/2, self.pveView.center.y);
  } completion:nil];
  
  GameState *gs = [GameState sharedGameState];
  // On first open of 
  if (!gs.userHasEnteredBattleThisSession) {
    [self setPrevMapElement:0];
  }
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.enhanceEventView.width = self.pveView.width;
  self.evoEventView.width = self.pveView.width;
  
  [self.evoEventView updateForEvo];
  [self.enhanceEventView updateForEnhance];
  if (self.evoEventView && !self.evoEventView.hidden) {
    [self.evoEventView.monsterImage startAnimating];
    _curEventView = self.evoEventView;
  } else if (self.enhanceEventView && !self.enhanceEventView.hidden) {
    [self.enhanceEventView.monsterImage startAnimating];
    _curEventView = self.enhanceEventView;
  }
  
  [self.multiplayerView updateForLeague];
  
  GameState *gs = [GameState sharedGameState];
  if (![gs hasShownCurrentLeague]) {
    // Took out the animation..
    [gs currentLeagueWasShown];
  }
  
  [self loadInitialMapSegments];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  
  [[GameViewController baseController] clearTutorialArrows];
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabels) userInfo:Nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void) updateLabels {
  [self.evoEventView updateLabels];
  [self.enhanceEventView updateLabels];
  
  //  if (self.evoEventView.hidden && self.enhanceEventView.hidden) {
  //    self.mapScrollView.contentSize = CGSizeMake(self.mapScrollView.frame.size.width, self.mapView.frame.size.height);
  //  } else {
  //    self.mapScrollView.contentSize = CGSizeMake(self.mapScrollView.frame.size.width, self.mapView.frame.size.height+self.evoEventView.bgdImage.frame.size.height);
  //  }
}

- (void) viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self.timer invalidate];
  
  [self.itemSelectViewController closeClicked:nil];
  
  [self.view endEditing:YES];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
//  [[GameViewController baseController] showEarlyGameTutorialArrow];
}

- (IBAction)close:(id)sender {
  if (!_buttonClicked) {
    [self close];
  }
}

- (void) close {
  [self.view endEditing:YES];
  [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
    self.multiplayerView.center = ccp(-self.multiplayerView.frame.size.width*2/3, self.multiplayerView.center.y);
    self.pveView.center = ccp(self.view.frame.size.width+self.pveView.frame.size.width*2/3, self.pveView.center.y);
  } completion:^(BOOL finished) {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

#pragma mark - PVE

- (void) loadInitialMapSegments {
  Globals *gl = [Globals sharedGlobals];
  TaskMapElementProto *nextElem = [self nextMapElement];
  float scaleFactor = self.mapScrollView.frame.size.width/gl.mapTotalWidth;
  [self loadMapInfoAroundPoint:ccp(nextElem.xPos, nextElem.yPos+self.mapScrollView.frame.size.height/3/scaleFactor)];
  [self centerOnAppropriateMapIcon];
}

#define MAP_SECTION_TAG_BASE 2834

- (void) loadMapInfoAroundPoint:(CGPoint)pt {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  float scaleFactor = self.mapScrollView.frame.size.width/gl.mapTotalWidth;
  
  // This if statement means this is the first time we're calling this method
  if (!self.mapSegmentContainer) {
    // If its a new set of map sections, delete the last one
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    int lastNum = (int)[def integerForKey:MAP_SECTION_NUM_KEY];
    if (lastNum != gl.mapNumberOfSections) {
      NSString *imgName = [NSString stringWithFormat:@"%@%d.jpg", gl.mapSectionImagePrefix, lastNum];
      imgName = [Globals getDoubleResolutionImage:imgName useiPhone6Prefix:YES];
      [[Downloader sharedDownloader] deleteFile:imgName];
      
      [def setInteger:gl.mapNumberOfSections forKey:MAP_SECTION_NUM_KEY];
    }
    
    self.mapSegmentContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mapScrollView.frame.size.width, gl.mapTotalHeight*scaleFactor)];
    [self.mapScrollView addSubview:self.mapSegmentContainer];
    self.mapScrollView.contentSize = self.mapSegmentContainer.frame.size;
  }
  
  // Check for map sections
  int section = floorf(pt.y/gl.mapSectionHeight)+1;
  for (int i = section-1; i <= section+1; i++) {
    // Make sure it doesn't already exist
    if (i > 0 && i <= gl.mapNumberOfSections && ![self.mapSegmentContainer viewWithTag:i+MAP_SECTION_TAG_BASE]) {
      NSString *imgName = [NSString stringWithFormat:@"%@%d.jpg", gl.mapSectionImagePrefix, i];
      
      CGRect frame = CGRectZero;
      frame.size.width = self.mapScrollView.frame.size.width;
      frame.size.height = scaleFactor*gl.mapSectionHeight;
      frame.origin.y = gl.mapTotalHeight*scaleFactor-frame.size.height*i;
      
      // The last section might be smaller than the section height
      if (frame.origin.y < 0) {
        frame.size.height = frame.origin.y+frame.size.height;
        frame.origin.y = 0;
      }
      
      UIImageView *iv = [[UIImageView alloc] initWithFrame:frame];
      iv.contentMode = UIViewContentModeScaleToFill;
      [self.mapSegmentContainer addSubview:iv];
      [Globals imageNamed:imgName withView:iv greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
      iv.tag = i+MAP_SECTION_TAG_BASE;
    }
  }
  
#ifdef APPSTORE
  BOOL showFake = NO;
#else
  BOOL showFake = YES;
#endif
  
  // Check map icons
  UINib *nib = nil;
  // Do it in reverse so that the lower ones are higher
  float scaledHeight = self.mapScrollView.frame.size.height/scaleFactor;
  
  NSArray *mapElements = [gs.staticMapElements sortedArrayUsingComparator:^(TaskMapElementProto *p1, TaskMapElementProto *p2) {
    return [@(p2.yPos) compare:@(p1.yPos)];
  }];
  
  for (TaskMapElementProto *elem in mapElements) {
    if ((!elem.isFake || showFake) && elem.yPos > pt.y-scaledHeight && elem.yPos < pt.y+scaledHeight && ![self.mapScrollView viewWithTag:elem.mapElementId]) {
      if (!nib) {
        nib = [UINib nibWithNibName:@"AttackMapIconView" bundle:nil];
      }
      
      FullTaskProto *task = [gs taskWithId:elem.taskId];
      
      AttackMapIconView *icon = [nib instantiateWithOwner:self options:nil][0];
      [icon updateForTaskMapElement:elem task:task isLocked:![gs isTaskUnlocked:elem.taskId]];
      
      [self.mapScrollView addSubview:icon];
      icon.center = ccpMult(ccp(elem.xPos, gl.mapTotalHeight-elem.yPos), scaleFactor);
      
      [icon.cityButton addTarget:self action:@selector(cityClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
  }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
  Globals *gl = [Globals sharedGlobals];
  float scaleFactor = self.mapScrollView.frame.size.width/gl.mapTotalWidth;
  CGPoint center = ccp(gl.mapTotalWidth/2, (self.mapScrollView.contentSize.height-self.mapScrollView.contentOffset.y-self.mapScrollView.frame.size.height/2)/scaleFactor);
  [self loadMapInfoAroundPoint:center];
}

- (TaskMapElementProto *) bestMapElement {
  GameState *gs = [GameState sharedGameState];
  TaskMapElementProto *bestElem = nil;
  for (TaskMapElementProto *elem in gs.staticMapElements) {
    if (!elem.isFake && [gs isTaskUnlocked:elem.taskId]) {
      if (!bestElem) {
        bestElem = elem;
      } else {
        BOOL bestCompleted = [gs isTaskCompleted:bestElem.taskId];
        BOOL curCompleted = [gs isTaskCompleted:elem.taskId];
        
        if (bestCompleted != curCompleted) {
          // Choose non-completed one
          bestElem = bestCompleted ? elem : bestElem;
        } else {
          // Choose higher map elem id
          bestElem = bestElem.mapElementId > elem.mapElementId ? bestElem : elem;
        }
      }
    }
  }
  return bestElem;
}

// The last dungeon they entered
- (TaskMapElementProto *) prevMapElement {
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  int lastKey = (int)[def integerForKey:PREV_ENTERED_ELEM_KEY];
  
  GameState *gs = [GameState sharedGameState];
  return [gs mapElementWithId:lastKey];
}

- (void) setPrevMapElement:(int)lastKey {
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  [def setInteger:lastKey forKey:PREV_ENTERED_ELEM_KEY];
}

- (TaskMapElementProto *) nextMapElement {
  return [self nextMapElementAndShouldAnimate:NULL];
}

- (TaskMapElementProto *) nextMapElementAndShouldAnimate:(BOOL *)shouldAnimate {
  TaskMapElementProto *prevElem = [self prevMapElement];
  TaskMapElementProto *bestElem = [self bestMapElement];
  TaskMapElementProto *nextElem = nil;
  
  // Since this is called by loadInitialSegments
  
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  int lastKey = (int)[def integerForKey:LAST_ELEM_KEY];
  if (shouldAnimate) {
    [def setInteger:bestElem.mapElementId forKey:LAST_ELEM_KEY];
  }
  
  // If we are progressing to a new map elem, set nextElem to that new one.
  // Otherwise, just use the last one entered
  if (bestElem.mapElementId-1 == prevElem.mapElementId && lastKey == bestElem.mapElementId-1) {
    nextElem = bestElem;
    
    if (shouldAnimate) {
      *shouldAnimate = YES;
    }
  } else {
    // In tutorial, there won't be a prevElem
    nextElem = prevElem && prevElem.mapElementId <= bestElem.mapElementId ? prevElem : bestElem;
  }
  
  return nextElem;
}

- (void) centerOnAppropriateMapIcon {
  BOOL shouldAnimate = NO;
  TaskMapElementProto *prevElem = [self prevMapElement];
  TaskMapElementProto *nextElem = [self nextMapElementAndShouldAnimate:&shouldAnimate];
  
  if (nextElem) {
    AttackMapIconView *icon = (AttackMapIconView *)[self.mapScrollView viewWithTag:nextElem.mapElementId];
    float center = icon.center.y-self.mapScrollView.frame.size.height/3;
    float max = self.mapScrollView.contentSize.height-self.mapScrollView.frame.size.height;
    float min = 0;
    self.mapScrollView.contentOffset = ccp(0, clampf(center, min, max));
    
    if (shouldAnimate) {
      AttackMapIconView *prevIcon = (AttackMapIconView *)[self.mapScrollView viewWithTag:prevElem.mapElementId];
      [self createMyPositionViewFromIcon:prevIcon toIcon:icon];
      
      [self setPrevMapElement:nextElem.mapElementId];
    } else {
      [self createMyPositionViewForIcon:icon];
      
      [self cityClicked:icon];
    }
  } else {
    self.mapScrollView.contentOffset = ccp(0, self.mapScrollView.contentSize.height-self.mapScrollView.frame.size.height);
  }
}

- (void) createMyPositionViewForIcon:(AttackMapIconView *)icon {
  GameState *gs = [GameState sharedGameState];
  UIImageView *iv = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"profilecircle.png"]];
  
  UIView *pos = [[UIView alloc] initWithFrame:iv.frame];
  
  CGRect frame = CGRectInset(pos.bounds, 2, 2);
  
#ifdef TOONSQUAD
  if ([TangoDelegate isTangoAvailable] && [TangoDelegate isTangoAuthenticated] && [TangoDelegate getMyId]) {
    UIImageView *img = [[UIImageView alloc] initWithFrame:frame];
    img.layer.cornerRadius = img.frame.size.width/2;
    img.clipsToBounds = YES;
    img.contentMode = UIViewContentModeScaleAspectFill;
    [pos addSubview:img];
    
    [TangoDelegate getProfilePicture:^(UIImage *i) {
      img.image = i;
    }];
  }
  
  else
#endif
    
    if (gs.facebookId) {
      DBFBProfilePictureView *pf = [[DBFBProfilePictureView alloc] initWithFrame:frame];
      pf.layer.cornerRadius = pf.frame.size.width/2;
      pf.clipsToBounds = YES;
      pf.profileID = gs.facebookId;
      [pos addSubview:pf];
    } else {
      CircleMonsterView *cmv = [[CircleMonsterView alloc] initWithFrame:frame];
      cmv.bgdIcon = [[UIImageView alloc] initWithFrame:cmv.bounds];
      cmv.monsterIcon = [[UIImageView alloc] initWithFrame:cmv.bounds];
      [cmv addSubview:cmv.bgdIcon];
      [cmv addSubview:cmv.monsterIcon];
      cmv.monsterIcon.clipsToBounds = YES;
      [cmv awakeFromNib];
      
      [cmv updateForMonsterId:gs.avatarMonsterId];
      [pos addSubview:cmv];
    }
  
  [self.mapScrollView addSubview:pos];
  
  [pos addSubview:iv];
  pos.center = ccpAdd(icon.center, ccp(-16, -14));
  
  _myPositionIcon = icon;
  
  self.myPositionView = pos;
}

- (void) createMyPositionViewFromIcon:(AttackMapIconView *)fIcon toIcon:(AttackMapIconView *)tIcon {
  GameState *gs = [GameState sharedGameState];
  TaskMapElementProto *elem = [gs mapElementWithId:(int)tIcon.tag];
  FullTaskProto *task = [gs taskWithId:elem.taskId];
  
  [self createMyPositionViewForIcon:fIcon];
  
  [tIcon updateForTaskMapElement:elem task:task isLocked:YES];
  
  [self moveMyPositionViewToIcon:tIcon completion:^{
    [self cityClicked:tIcon];
  }];
}

- (void) moveMyPositionViewToIcon:(AttackMapIconView *)tIcon completion:(dispatch_block_t)completion {
  GameState *gs = [GameState sharedGameState];
  TaskMapElementProto *elem = [gs mapElementWithId:(int)tIcon.tag];
  FullTaskProto *task = [gs taskWithId:elem.taskId];
  
  CGPoint diff = ccpSub(self.myPositionView.center, _myPositionIcon.center);
  float delay = tIcon.isLocked ? 0.61f : 0.f;
  float dur = tIcon.isLocked ? 1.05f : 0.7f;
  [UIView animateWithDuration:dur delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.myPositionView.center = ccpAdd(tIcon.center, diff);
  } completion:^(BOOL finished) {
    [tIcon updateForTaskMapElement:elem task:task isLocked:NO];
    
    if (completion) {
      completion();
    }
  }];
  
  [self performBlockAfterDelay:delay block:^(void) { [SoundEngine nextTask]; }];
  
  [self.myPositionView.superview bringSubviewToFront:self.myPositionView];
  
  _myPositionIcon = tIcon;
}

#pragma mark - IBActions

- (void) cityClicked:(id)sender {
  sender = [sender getAncestorInViewHierarchyOfType:[AttackMapIconView class]];
  
  AttackMapIconView *icon = (AttackMapIconView *)sender;
  [self showTaskStatusForMapElement:(int)icon.tag];
  
  if (_myPositionIcon != icon && !icon.isLocked) {
    [self moveMyPositionViewToIcon:icon completion:nil];
  }
  
  [_selectedIcon removeLabelAndGlow];
  _selectedIcon = icon;
  [_selectedIcon displayLabelAndGlow];
}

- (IBAction)enterDungeonClicked:(id)sender {
  if (!_buttonClicked && [Globals checkEnteringDungeon]) {
    GameState *gs = [GameState sharedGameState];
    int taskId = self.taskStatusView.taskId;
    TaskMapElementProto *elem = [gs mapElementWithTaskId:taskId];
    
    [self setPrevMapElement:elem.mapElementId];
    
    [self.delegate enterDungeon:self.taskStatusView.taskId isEvent:NO eventId:0 useGems:NO];
  }
}

- (IBAction)enterEventClicked:(UIView *)sender {
  if (!_buttonClicked && [Globals checkEnteringDungeon]) {
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    PersistentEventProto *pe = [gs persistentEventWithId:_curEventView.persistentEventId];
    FullTaskProto *ftp = [gs taskWithId:pe.taskId];
    
    BOOL asked = NO;
    if (sender.tag) {
      
      int timeLeft = [pe.cooldownEndTime timeIntervalSinceNow];
      int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
      
      if (speedupCost) {
        NSString *str = [NSString stringWithFormat:@"Would you like to enter %@ for %@ gems?", ftp.name, [Globals commafyNumber:speedupCost]];
        [GenericPopupController displayGemConfirmViewWithDescription:str title:[NSString stringWithFormat:@"Enter %@?", ftp.name] gemCost:speedupCost target:self selector:@selector(enterEventWithGems)];
        asked = YES;
      }
    }
    
    if (!asked) {
      NSString *str = [NSString stringWithFormat:@"Would you like to enter %@?", ftp.name];
      [GenericPopupController displayConfirmationWithDescription:str title:[NSString stringWithFormat:@"Enter %@?", ftp.name] okayButton:@"Enter" cancelButton:@"Cancel" target:self selector:@selector(enterEventWithoutGems)];
    }
  }
}

- (void) enterEventWithGems {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  PersistentEventProto *pe = [gs persistentEventWithId:_curEventView.persistentEventId];
  
  int timeLeft = [pe.cooldownEndTime timeIntervalSinceNow];
  int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
  
  if (gs.gems >= speedupCost) {
    [self enterEventConfirmed:_curEventView useGems:YES];
  } else {
    [GenericPopupController displayNotEnoughGemsView];
  }
}

- (void) enterEventWithoutGems {
  [self enterEventConfirmed:_curEventView useGems:NO];
}

- (void) enterEventConfirmed:(AttackEventView *)eventView useGems:(BOOL)useGems {
  [self.timer invalidate];
  [self.delegate enterDungeon:eventView.taskId isEvent:YES eventId:eventView.persistentEventId useGems:useGems];
  _buttonClicked = YES;
}

#pragma mark - PVP

- (IBAction)findMatchClicked:(id)sender {
  if (!_buttonClicked && [Globals checkEnteringDungeon]) {
    [self findMatch];
  }
}

- (void) findMatch {
  GameState *gs = [GameState sharedGameState];
  TownHallProto *thp = (TownHallProto *)gs.myTownHall.staticStruct;
  if (gs.cash < thp.pvpQueueCashCost) {
    ItemSelectViewController *svc = [[ItemSelectViewController alloc] init];
    if (svc) {
      ResourceItemsFiller *rif = [[ResourceItemsFiller alloc] initWithResourceType:ResourceTypeCash requiredAmount:thp.pvpQueueCashCost shouldAccumulate:YES];
      rif.delegate = self;
      svc.delegate = rif;
      self.itemSelectViewController = svc;
      self.resourceItemsFiller = rif;
      
      GameViewController *gvc = [GameViewController baseController];
      svc.view.frame = gvc.view.bounds;
      [gvc addChildViewController:svc];
      [gvc.view addSubview:svc.view];
      
      [svc showAnchoredToInvokingView:self.findMatchButton withDirection:ViewAnchoringPreferRightPlacement inkovingViewImage:self.findMatchButton.currentImage];
    }
  } else {
    [self nextMatchWithItemsDict:nil];
  }
}

- (void) nextMatchWithItemsDict:(NSDictionary *)itemIdsToQuantity {
  if (!_buttonClicked) {
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    TownHallProto *thp = (TownHallProto *)gs.myTownHall.staticStruct;
    
    BOOL allowGems = [itemIdsToQuantity[@0] boolValue];
    
    int cost = thp.pvpQueueCashCost;
    ResourceType resType = ResourceTypeCash;
    
    int curAmount = [gl calculateTotalResourcesForResourceType:resType itemIdsToQuantity:itemIdsToQuantity];
    int gemCost = [gl calculateGemConversionForResourceType:resType amount:cost-curAmount];
    
    if (allowGems && gemCost > gs.gems) {
      [GenericPopupController displayNotEnoughGemsView];
    } else if (allowGems || cost <= curAmount) {
      _buttonClicked = YES;
      [self.delegate findPvpMatchWithItemsDict:itemIdsToQuantity];
    }
  }
}

- (IBAction)openLeagueListClicked:(id)sender {
  [self.multiplayerView showHideLeagueList];
}

#pragma mark - EventView and TaskStatusView

- (void) showTaskStatusForMapElement:(int)mapElementId {
  GameState *gs = [GameState sharedGameState];
  TaskMapElementProto *elem = [gs mapElementWithId:mapElementId];
  
  if (self.taskStatusView.taskId != elem.taskId) {
    UIView *oldTaskStatusView = self.taskStatusView;
    [[NSBundle mainBundle] loadNibNamed:@"AttackMapTaskStatusView" owner:self options:nil];
    [self.pveView addSubview:self.taskStatusView];
    
    BOOL isCompleted = [gs isTaskCompleted:elem.taskId];
    int cash = isCompleted ? 0 : elem.cashReward;
    int oil = isCompleted ? 0 : elem.oilReward;
    self.taskStatusView.frame = CGRectMake(0, 0, self.pveView.frame.size.width, self.taskStatusView.frame.size.height);
    [self.taskStatusView updateForTaskId:elem.taskId element:elem.element level:elem.mapElementId isLocked:![gs isTaskUnlocked:elem.taskId] isCompleted:isCompleted oilAmount:oil cashAmount:cash charImgName:elem.characterImgName];
    self.taskStatusView.characterIcon.center = ccpAdd(self.taskStatusView.characterIcon.center, ccp(elem.charImgHorizPixelOffset, elem.charImgVertPixelOffset));
    self.taskStatusView.characterIcon.transform = CGAffineTransformMakeScale(elem.charImgScaleFactor, elem.charImgScaleFactor);
    
    self.taskStatusView.center = ccp(self.taskStatusView.frame.size.width/2, self.pveView.frame.size.height+self.taskStatusView.frame.size.height/2);
    [UIView animateWithDuration:0.3f animations:^{
      NSMutableArray *arr = [NSMutableArray array];
      if (oldTaskStatusView) [arr addObject:oldTaskStatusView];
      if (self.evoEventView) [arr addObject:self.evoEventView];
      if (self.enhanceEventView) [arr addObject:self.enhanceEventView];
      
      for (UIView *v in arr) {
        v.center = ccp(v.frame.size.width/2, self.pveView.frame.size.height+v.frame.size.height/2);
      }
      
      self.taskStatusView.center = ccp(self.taskStatusView.frame.size.width/2, self.pveView.frame.size.height-self.taskStatusView.frame.size.height/2);
    } completion:^(BOOL finished) {
      [oldTaskStatusView removeFromSuperview];
    }];
  }
}

- (IBAction) removeTaskStatusView {
  if (self.taskStatusView && ((self.evoEventView && !self.evoEventView.hidden) || (self.enhanceEventView && !self.enhanceEventView.hidden)) ) {
    [UIView animateWithDuration:0.3f animations:^{
      NSMutableArray *arr = [NSMutableArray array];
      if (self.evoEventView) [arr addObject:self.evoEventView];
      if (self.enhanceEventView) [arr addObject:self.enhanceEventView];
      
      for (UIView *v in arr) {
        v.center = ccp(v.frame.size.width/2, self.pveView.frame.size.height-v.frame.size.height/2);
      }
      
      self.taskStatusView.center = ccp(self.taskStatusView.frame.size.width/2, self.pveView.frame.size.height+self.taskStatusView.frame.size.height/2);
    } completion:^(BOOL finished) {
      [self.taskStatusView removeFromSuperview];
      self.taskStatusView = nil;
    }];
    
    [_selectedIcon removeLabelAndGlow];
    _selectedIcon = nil;
  }
}

- (void) eventViewSelected:(AttackEventView *)eventView {
  if (!_buttonClicked && _curEventView != eventView) {
    [eventView.superview bringSubviewToFront:eventView];
    [eventView.monsterImage startAnimating];
    
    [_curEventView.monsterImage stopAnimating];
    _curEventView = eventView;
  }
}

#pragma mark - Resource Items Filler

- (void) resourceItemsUsed:(NSDictionary *)itemUsages {
  [self nextMatchWithItemsDict:itemUsages];
}

- (void) itemSelectClosed:(id)viewController {
  self.itemSelectViewController = nil;
  self.resourceItemsFiller = nil;
}

#pragma mark - Keyboard Notifications

- (void) keyboardWillShow:(NSNotification *)n {
  NSDictionary *userInfo = [n userInfo];
  CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
  NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
  
  CGRect relFrame = [self.view convertRect:keyboardFrame fromView:nil];
  
  // Use the superview since that will be the darkened box around it
  UIView *textView = self.multiplayerView.defendingStatusTextView.superview;
  CGRect textViewFrame = [self.view convertRect:textView.frame fromView:textView.superview];
  
  if (CGRectGetMaxY(textViewFrame) > relFrame.origin.y) {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationDuration:animationDuration];
    
    self.view.centerY += relFrame.origin.y - CGRectGetMaxY(textViewFrame);
    
    [UIView commitAnimations];
  }
}

- (void) keyboardWillHide:(NSNotification *)n {
  NSDictionary *userInfo = [n userInfo];
  NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  UIViewAnimationCurve curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
  
  if (self.view.originY != 0) {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationDuration:animationDuration];
    
    self.view.originY = 0;
    
    [UIView commitAnimations];
  }
}

@end