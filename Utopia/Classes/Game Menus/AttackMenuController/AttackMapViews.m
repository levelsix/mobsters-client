//
//  AttackMapViews.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/3/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "AttackMapViews.h"
#import "GameState.h"
#import "Globals.h"
#import "PersistentEventProto+Time.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import "OutgoingEventController.h"

@implementation AttackMapIconView

- (void) awakeFromNib {
  self.layer.anchorPoint = ccp(0.5, 1-18/70.f);
  [self removeLabelAndGlow];
  
  self.spinner.hidden = YES;
}

- (void) setIsLocked:(BOOL)isLocked bossImage:(NSString *)bossImage element:(Element)element {
  BOOL isBoss = bossImage != nil;
  
  _isLocked = isLocked;
  if (isLocked) {
    NSString *str = [NSString stringWithFormat:@"locked%@.png", isBoss ? @"boss" : @"city"];
    [self.cityButton setImage:[Globals imageNamed:str] forState:UIControlStateNormal];
  } else {
    NSString *str = [@"open" stringByAppendingString:[Globals imageNameForElement:element suffix:@".png"]];
    [self.cityButton setImage:[Globals imageNamed:str] forState:UIControlStateNormal];
  }
  
  if (isBoss) {
    [Globals imageNamed:bossImage withView:self.bossIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
    self.cityNumLabel.hidden = YES;
    self.bossIcon.hidden = NO;
    self.shadowIcon.hidden = NO;
  } else {
    self.cityNumLabel.hidden = isLocked;
    self.bossIcon.hidden = YES;
    self.shadowIcon.hidden = YES;
  }
}

- (void) doShake {
  [Globals shakeView:self.cityNameIcon duration:0.5f offset:5.f];
}

- (void) updateForTaskMapElement:(TaskMapElementProto *)elem task:(FullTaskProto *)task isLocked:(BOOL)isLocked {
  [self setIsLocked:isLocked bossImage:(elem.boss ? elem.bossImgName : nil) element:elem.element];
  self.tag = elem.mapElementId;
  self.cityNumLabel.text = [NSString stringWithFormat:@"%d", elem.mapElementId];
  _name = task.name;
  
  [self removeLabelAndGlow];
}

- (void) displayLabelAndGlow {
  // Optimized so all strokes don't get rewritten immediately
  self.nameLabel.strokeSize = 1.2f;
  self.nameLabel.text = [NSString stringWithFormat:@"%@ »", _name];
  
  self.nameLabel.hidden = NO;
  
  if (!self.isLocked) {
    self.glowIcon.hidden = NO;
    
    self.nameLabel.gradientStartColor = [UIColor colorWithRed:240/255.f green:253/255.f blue:152/255.f alpha:1.f];
    self.nameLabel.gradientEndColor = [UIColor colorWithRed:222/255.f green:251/255.f blue:72/255.f alpha:1.f];
    
    self.glowIcon.transform = CGAffineTransformMakeScale(0.7, 0.7);
    self.glowIcon.alpha = 1.f;
    [UIView animateWithDuration:1.5f delay:0.f options:UIViewAnimationOptionRepeat animations:^{
      self.glowIcon.transform = CGAffineTransformMakeScale(1.15, 1.15);
      self.glowIcon.alpha = 0.f;
    } completion:nil];
    
    [Globals bounceView:self fromScale:0.85f toScale:1.f duration:0.35f];
    self.layer.transform = CATransform3DIdentity;
  }
}

- (void) removeLabelAndGlow {
  self.nameLabel.hidden = YES;
  self.glowIcon.hidden = YES;
  
  [UIView animateWithDuration:0.15f animations:^{
    self.transform = CGAffineTransformMakeScale(0.85, 0.85);
  }];
}

@end

@implementation AttackMapStatusView

- (void) awakeFromNib {
  
  if ([Globals isiPhone5orSmaller])
  {
    [self hideCharacterIcon];
    if ([Globals isSmallestiPhone])
    {
      self.dropScrollView.originX = self.availableLabel.superview.originX;
      self.availableLabel.superview.hidden = YES;
    }
  }
  
}

- (void) hideCharacterIcon {
  [self.characterIcon removeFromSuperview];
  self.characterIcon = nil;
}

- (void) updateForTaskId:(int)taskId element:(Element)elem level:(int)level isLocked:(BOOL)isLocked isCompleted:(BOOL)isCompleted oilAmount:(int)oil cashAmount:(int)cash charImgName:(NSString *)charImgName {
  GameState *gs = [GameState sharedGameState];
  FullTaskProto *task = [gs taskWithId:taskId];
  
  NSString *file = !isLocked ? [Globals imageNameForElement:elem suffix:@"dailylab.png"] : @"lockeddailylab.png";
  self.bgdImage.image = [Globals imageNamed:file];
  
  self.topLabel.text = task.name;
  self.taskNameScrollView.contentSize = [self.topLabel.text sizeWithFont:self.topLabel.font];
  
  self.sideLabel.text = [NSString stringWithFormat:@"LEVEL %d", level];
  
  [self.greyscaleView removeFromSuperview];
  if (isLocked) {
    UIImage *grey = [Globals greyScaleImageWithBaseImage:[Globals snapShotView:self.enterButtonView]];
    self.greyscaleView = [[UIImageView alloc] initWithImage:grey];
    self.greyscaleView.userInteractionEnabled = YES;
    [self.enterButtonView addSubview:self.greyscaleView];
  }

  //Clear previous available rewards
  [[self.dropScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
  
  //Reset X value
  int nextX = 0;
  
  //Set check
  self.doneCheckImage.hidden = !isCompleted;
  
  //Determine scroll view width
  self.dropScrollView.width = (self.characterIcon ? self.characterIcon.originX + 28 : self.enterButtonView.originX) - self.dropScrollView.originX - 5;
  self.taskNameScrollView.width = self.dropScrollView.width + (self.availableLabel.superview.hidden ? -25 : 35);
  
  
  
  NSLog(@"Drop scroll width: %f, task name width: %f, Self origin: %f, view width: %f", self.dropScrollView.width, self.taskNameScrollView.width, self.dropScrollView.originX, self.width);
  
  //Add money rewards
  if (!isCompleted) {
    
    nextX = [self addReward:@"moneystack.png" labelText:[Globals commafyNumber:cash] xPos:nextX];
    nextX = [self addReward:@"oilicon.png" labelText:[Globals commafyNumber:oil] xPos:nextX];
    
  } else {
    //Remainder resources
    UserTaskCompletedProto *taskCompleteData = [gs.completedTaskData objectForKey:@(taskId)];
    
    if (taskCompleteData.unclaimedCash){
      nextX = [self addReward:@"moneystack.png" labelText:[Globals commafyNumber:taskCompleteData.unclaimedCash] xPos:nextX];
    }
    if (taskCompleteData.unclaimedOil){
      nextX = [self addReward:@"oilicon.png" labelText:[Globals commafyNumber:taskCompleteData.unclaimedOil] xPos:nextX];
    }
    
  }
  
  Quality qual;
  for (int i = 0; i < task.raritiesList.count; i++) {
    qual = [[task.raritiesList objectAtIndexedSubscript:i] intValue];
    NSString *qualName = [@"gacha" stringByAppendingString:[Globals imageNameForRarity:qual suffix:(qual == QualityCommon ? @"ball.png" : @"piece.png")]];
    nextX = [self addReward:qualName labelText:[Globals shortenedStringForRarity:qual] xPos:nextX];
  }
  
  self.dropScrollView.contentSize = CGSizeMake(nextX, self.dropScrollView.height);
  
  //If we have more content than we can fit, set up the timer to auto-scroll
  if (self.dropScrollView.contentSize.width > self.dropScrollView.width){
    [[NSRunLoop currentRunLoop] addTimer:[NSTimer timerWithTimeInterval:SCROLL_DISPLAY_TIME target:self selector:@selector(scrollRewardsForward:) userInfo:nil repeats:NO] forMode:NSDefaultRunLoopMode];
  }
  
  UIImage *gradientImage = [Globals imageNamed:(!isLocked ? [@"gradient" stringByAppendingString:[Globals imageNameForElement:elem suffix:@"dailylab.png"]] : @"gradientlockeddailylab.png")];
  [self.rightGradient setImage:gradientImage];
  self.rightGradient.originX = self.dropScrollView.originX + self.dropScrollView.width - 17;
  
  if (self.characterIcon) {
    [Globals imageNamedWithiPhone6Prefix:charImgName withView:self.characterIcon greyscale:isLocked indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  }
  
  self.taskId = taskId;
}

- (void) scrollRewardsForward:(NSTimer *)timer{
  //Destermine destination and duration
  float distance = self.dropScrollView.contentSize.width - self.dropScrollView.width;
  CGPoint destination = CGPointMake(distance, 0);
  float duration = distance / SCROLL_SPEED_PX_PER_SEC;
  
  //Run the animation
  [UIView animateWithDuration:duration animations:^ {
    [self.dropScrollView setContentOffset:destination animated:NO];
  }];
  
  //Start the timer to scroll us back
  [[NSRunLoop currentRunLoop] addTimer:[NSTimer timerWithTimeInterval:(duration+SCROLL_DISPLAY_TIME) target:self selector:@selector(scrollRewardsBack:) userInfo:nil repeats:NO] forMode:NSDefaultRunLoopMode];
}

- (void) scrollRewardsBack:(NSTimer *)timer{
  //Determine destination and duration
  float distance = self.dropScrollView.contentOffset.x;
  CGPoint destination = CGPointMake(0, 0);
  float duration = distance / SCROLL_SPEED_PX_PER_SEC;

  //Run the animation
  [UIView animateWithDuration:(distance/SCROLL_SPEED_PX_PER_SEC) animations:^ {
    [self.dropScrollView setContentOffset:destination animated:NO];
  }];
  
  //Restart the timer to scroll forwards again
  [[NSRunLoop currentRunLoop] addTimer:[NSTimer timerWithTimeInterval:(duration+SCROLL_DISPLAY_TIME) target:self selector:@selector(scrollRewardsForward:) userInfo:nil repeats:NO] forMode:NSDefaultRunLoopMode];
}

- (int) addReward:(NSString *)imageName labelText:(NSString *)labelText xPos:(int)xPos {
  UINib *nib = [UINib nibWithNibName:@"PossibleDropView" bundle:nil];
  PossibleDropView *drop = [nib instantiateWithOwner:self options:nil][0];
  [drop updateForReward:imageName labelText:labelText];
  
  [self.dropScrollView addSubview:drop];
  
  CGRect r = drop.frame;
  r.origin.x = xPos;
  drop.frame = r;
  
  return drop.frame.origin.x + drop.label.frame.origin.x + [drop.label.text getSizeWithFont:drop.label.font].width + 5;
}

@end

@implementation PossibleDropView

- (void) updateForReward:(NSString *)imageName labelText:(NSString *)labelText{
  self.label.text = labelText;
  [self.iconImage setImage:[Globals imageNamed:imageName]];
}

- (void) updateForToon:(int)toonId{
  
}

@end

@implementation AttackEventView

- (void) awakeFromNib {
  self.cooldownView.frame = self.enterView.frame;
  [self.enterView.superview addSubview:self.cooldownView];
}

- (void) updateForEvo {
  GameState *gs = [GameState sharedGameState];
  if (gs.myEvoChamber) {
    _eventType = PersistentEventProto_EventTypeEvolution;
    PersistentEventProto *pe = [gs currentPersistentEventWithType:PersistentEventProto_EventTypeEvolution];
    [self updateForPersistentEvent:pe];
  } else {
    self.hidden = YES;
  }
}

- (void) updateForEnhance {
  GameState *gs = [GameState sharedGameState];
  if ([Globals shouldShowFatKidDungeon]) {
    _eventType = PersistentEventProto_EventTypeEnhance;
    PersistentEventProto *pe = [gs currentPersistentEventWithType:PersistentEventProto_EventTypeEnhance];
    [self updateForPersistentEvent:pe];
  } else {
    self.hidden = YES;
  }
}

- (void) updateForPersistentEvent:(PersistentEventProto *)pe {
  GameState *gs = [GameState sharedGameState];
  
  NSMutableArray *imgs = [NSMutableArray array];
  float speed = 0.1;
  if (pe.type == PersistentEventProto_EventTypeEvolution) {
    for (int i = 0; i <= 12; i++) {
      NSString *str = [NSString stringWithFormat:@"Scientist%dBreath%02d.png", (int)pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
    for (int i = 0; i <= 12; i++) {
      // Repeat breath
      [imgs addObject:imgs[i]];
    }
    for (int i = 0; i <= 12; i++) {
      NSString *str = [NSString stringWithFormat:@"Scientist%dBlink%02d.png", (int)pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
    for (int i = 0; i <= 12; i++) {
      // Repeat breath
      [imgs addObject:imgs[i]];
    }
    for (int i = 0; i <= 12; i++) {
      // Repeat breath
      [imgs addObject:imgs[i]];
    }
    for (int i = 0; i <= 16; i++) {
      NSString *str = [NSString stringWithFormat:@"Scientist%dTurn%02d.png", (int)pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
    speed = 0.08;
  } else if (pe.type == PersistentEventProto_EventTypeEnhance) {
    for (int i = 0; i <= 12; i++) {
      NSString *str = [NSString stringWithFormat:@"FatBoy%dMove%02d.png", (int)pe.monsterElement, i];
      UIImage *img = [Globals imageNamed:str];
      [imgs addObject:img];
    }
  }
  
  self.monsterImage.animationImages = imgs;
  if (imgs.count > 0) self.monsterImage.image = imgs[0];
  
  self.monsterImage.animationDuration = imgs.count*speed;
  
  if (pe) {
    FullTaskProto *task = [gs taskWithId:pe.taskId];
    
    NSString *file = [Globals imageNameForElement:pe.monsterElement suffix:@"dailylab.png"];
    self.bgdImage.image = [Globals imageNamed:file];
    
    self.topLabel.text = task.name;
    
    _persistentEventId = pe.eventId;
    self.taskId = pe.taskId;
    
    if (self.enhanceBubbleImage) {
      file = [Globals imageNameForElement:pe.monsterElement suffix:@"feederevent.png"];
      self.enhanceBubbleImage.image = [Globals imageNamed:file];
    }
    self.hidden = NO;
  } else {
    self.hidden = YES;
  }
  [self updateLabels];
}

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  PersistentEventProto *pe = [gs currentPersistentEventWithType:_eventType];
  
  if (_persistentEventId != pe.eventId) {
    [self updateForPersistentEvent:pe];
  } else {
    int timeLeft = [pe.endTime timeIntervalSinceNow];
    self.bottomLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
    
    MSDate *cdTime = pe.cooldownEndTime;
    timeLeft = [cdTime timeIntervalSinceNow];
    if (timeLeft <= 0) {
      self.enterView.hidden = NO;
      self.cooldownView.hidden = YES;
    } else {
      self.cooldownLabel.text = [[Globals convertTimeToShortString:timeLeft] uppercaseString];
      int speedupCost = [gl calculateGemSpeedupCostForTimeLeft:timeLeft allowFreeSpeedup:YES];
      
      if (speedupCost > 0) {
        self.speedupGemsLabel.text = [Globals commafyNumber:speedupCost];
        [Globals adjustViewForCentering:self.speedupGemsLabel.superview withLabel:self.speedupGemsLabel];
        
        self.speedupGemsLabel.superview.hidden = NO;
        self.freeLabel.hidden = YES;
      } else {
        self.speedupGemsLabel.superview.hidden = YES;
        self.freeLabel.hidden = NO;
      }
      
      self.enterView.hidden = YES;
      self.cooldownView.hidden = NO;
    }
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.delegate eventViewSelected:self];
}

@end

@implementation LeagueListView

static NSString* const leagueColors[] = {@"b37858", @"808586", @"e39633", @"675f6f", @"3a94bc", @"b7271a"};
static int numLeagues = 6;

- (void) awakeFromNib
{
  [super awakeFromNib];
  [self.leagueTable registerNib:[UINib nibWithNibName:@"LeagueListViewCell" bundle:nil] forCellReuseIdentifier:@"leagueCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return numLeagues;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  LeagueListViewCell* cell = [self.leagueTable dequeueReusableCellWithIdentifier:@"leagueCell"];
  
  GameState* gs = [GameState sharedGameState];
  NSInteger leagueNumber = numLeagues - indexPath.row - 1;
  PvpLeagueProto* league = gs.staticLeagues[leagueNumber];
  
  BOOL thisLeagueIsPlayers = FALSE;
  if ( gs.pvpLeague && gs.pvpLeague.leagueId == league.leagueId )
    thisLeagueIsPlayers = TRUE;
  
  // League image
  NSString* imageName = league.imgPrefix;
  if ( imageName )
    cell.leagueImage.image = [Globals imageNamed:[NSString stringWithFormat:@"%@icon.png", imageName]];
  
  // League text and background color
  NSString* leagueText = league.leagueName;
  if (thisLeagueIsPlayers)
  {
    leagueText = [leagueText stringByAppendingString:[NSString stringWithFormat:@" - %d%@ Place", gs.pvpLeague.rank, [Globals qualifierStringForNumber:gs.pvpLeague.rank]]];
    cell.backgroundColor = [UIColor colorWithHexString:@"fff7dc"];
  }
  else
  {
    cell.backgroundColor = [UIColor whiteColor];
  }
  cell.leagueLabel.text = leagueText;
  
  // Label color
  UIColor* textColor = [UIColor blackColor];
  if ( indexPath.row < numLeagues)
    textColor = [UIColor colorWithHexString:leagueColors[leagueNumber]];
  cell.leagueLabel.textColor = textColor;
  
  // Hide separator for some cases (last row, selected row and row previous to selected)
  if ( indexPath.row == gs.staticLeagues.count - 1 || thisLeagueIsPlayers || (gs.pvpLeague && leagueNumber == gs.pvpLeague.leagueId ) )
    cell.separatorView.hidden = TRUE;
  else
    cell.separatorView.hidden = FALSE;
  cell.separatorView.height = 0.5;
  
  return cell;
}

@end

@implementation LeagueListViewCell
@end

@implementation MultiplayerView

- (void) awakeFromNib {
  Globals *gl = [Globals sharedGlobals];
  self.multiplayerUnlockLabel.text = [NSString stringWithFormat:@"Multiplayer play\n unlocks at level %d", gl.pvpRequiredMinLvl];
  
  GameState *gs = [GameState sharedGameState];
  TownHallProto *thp = (TownHallProto *)gs.myTownHall.staticStruct;
  self.cashCostLabel.text = [NSString stringWithFormat:@"Match Cost: %@", [Globals cashStringForNumber:thp.pvpQueueCashCost]];
  
  self.backButton.alpha = 0.f;
  self.titleLabel.text = @"Multiplayer";
  
  self.defendingStatusTextView.textContainer.maximumNumberOfLines = 3;
  
  if ([Globals screenSize].height > 321) {
    self.pvpGuysIcon.image = [Globals imageNamed:@"pvpguys.png"];
  }
  
  //  for (LeagueDescriptionView *dv in self.leagueDescriptionViews) {
  //    PvpLeagueProto *pvp = [gs leagueForId:(int)dv.tag];
  //    [dv updateForLeague:pvp];
  //  }
}

- (void) updateForLeague {
  GameState *gs = [GameState sharedGameState];
  [self.leagueView updateForUserLeague:gs.pvpLeague ribbonSuffix:@"ribbon.png"];
  
  self.defendingStatusTextView.text = gs.pvpDefendingMessage;
  self.placeholderLabel.hidden = gs.pvpDefendingMessage.length > 0;
}

- (IBAction)leagueSelected:(id)sender {
  [UIView animateWithDuration:0.3f animations:^{
    self.containerView.center = ccp(0, self.containerView.center.y);
    self.backButton.alpha = 1.f;
  }];
  
  CATransition *animation = [CATransition animation];
  animation.duration = 0.3f;
  animation.type = kCATransitionFade;
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [self.titleLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
  self.titleLabel.text = @"Rank";
}

- (IBAction)backClicked:(id)sender {
  [UIView animateWithDuration:0.3f animations:^{
    self.containerView.center = ccp(self.containerView.frame.size.width/2, self.containerView.center.y);
    self.backButton.alpha = 0.f;
  }];
  
  CATransition *animation = [CATransition animation];
  animation.duration = 0.3f;
  animation.type = kCATransitionFade;
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [self.titleLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
  self.titleLabel.text = @"Multiplayer";
}

- (void) showHideLeagueList
{
  //self.userInteractionEnabled = NO;
  
  if ( self.leagueListView.hidden )
  {
    self.leagueListView.hidden = NO;
    self.leagueListView.originY = self.leagueView.originY + self.leagueView.height - self.leagueListView.height;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
      self.leagueView.originY -= self.multiplayerHeaderView.height;
      self.leagueListView.originY = self.leagueView.originY + self.leagueView.height;
      self.leagueListButton.height = self.leagueView.height + self.leagueListView.height;
      self.leagueListButton.originY = 0;
    } completion:^(BOOL finished) {
      //self.userInteractionEnabled = YES;
    }];
  }
  else
  {
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
      self.leagueView.originY += self.multiplayerHeaderView.height;
      self.leagueListView.originY = self.leagueView.originY + self.leagueView.height - self.leagueListView.height;
      self.leagueListButton.height = self.leagueView.height;
      self.leagueListButton.originY = 0;
    } completion:^(BOOL finished) {
      //self.userInteractionEnabled = YES;
      self.leagueListView.hidden = YES;
    }];
  }
}

#pragma mark - TextView methods

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  //  Globals *gl = [Globals sharedGlobals];
  //  NSString *str = [t.text stringByReplacingCharactersInRange:range withString:text];
  //
  //#warning change back
  //  gl.defendingMsgCharLimit = 100;
  //  if (str.length > gl.defendingMsgCharLimit && text.length > 0) {
  //    return NO;
  //  }
  //  return YES;
  int maxNumLines = 3;
  
  NSMutableString *t = [NSMutableString stringWithString:textView.text];
  [t replaceCharactersInRange:range withString:text];
  
  // First check for standard '\n' (newline) type characters.
  NSUInteger numberOfLines = 0;
  for (NSUInteger i = 0; i < t.length; i++) {
    if ([[NSCharacterSet newlineCharacterSet] characterIsMember: [t characterAtIndex: i]]) {
      numberOfLines++;
    }
  }
  
  if (numberOfLines >= maxNumLines)
    return NO;
  
  
  // Now check for word wrapping onto newline.
  NSAttributedString *t2 = [[NSAttributedString alloc]
                            initWithString:[NSMutableString stringWithString:t] attributes:@{NSFontAttributeName:textView.font}];
  
  __block NSInteger lineCount = 0;
  
  CGFloat maxWidth   = textView.frame.size.width;
  
  NSTextContainer *tc = [[NSTextContainer alloc] initWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)];
  NSLayoutManager *lm = [[NSLayoutManager alloc] init];
  NSTextStorage   *ts = [[NSTextStorage alloc] initWithAttributedString:t2];
  [ts addLayoutManager:lm];
  [lm addTextContainer:tc];
  [lm enumerateLineFragmentsForGlyphRange:NSMakeRange(0,lm.numberOfGlyphs)
                               usingBlock:^(CGRect rect,
                                            CGRect usedRect,
                                            NSTextContainer *textContainer,
                                            NSRange glyphRange,
                                            BOOL *stop)
   {
     lineCount++;
   }];
  
  //    NSLog(@"%d", lineCount);
  
  return (lineCount <= maxNumLines);
}

- (void) textViewDidBeginEditing:(UITextView *)textView {
  self.placeholderLabel.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
  if (![textView hasText]) {
    self.placeholderLabel.hidden = NO;
  }
  
  GameState *gs = [GameState sharedGameState];
  if (gs.connected) {
    [[OutgoingEventController sharedOutgoingEventController] setDefendingMessage:textView.text];
  }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  if (self.defendingStatusTextView.isFirstResponder) {
    if (![self.defendingStatusTextView pointInside:[self.defendingStatusTextView convertPoint:point fromView:self] withEvent:event]) {
      [self.defendingStatusTextView resignFirstResponder];
    }
    return self.defendingStatusTextView;
  }
  return [super hitTest:point withEvent:event];
}

@end