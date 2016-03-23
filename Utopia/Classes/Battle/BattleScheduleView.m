//
//  BattleScheduleView.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/7/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "BattleScheduleView.h"
#import "BattleSchedule.h"
#import "Globals.h"
#import "CAKeyFrameAnimation+Jumping.h"

@implementation SideEffectActiveTurns

- (instancetype) init
{
  if (self = [super init])
  {
    _displaySymbol = nil;
    _playerTurns = 0;
    _enemyTurns = 0;
  }
  return self;
}

@end

@implementation BattleScheduleView

- (void) awakeFromNib {
  [self setSlotCount];
  
  _battleSchedule = nil;
  _upcomingSideEffectTurns = [NSMutableDictionary dictionary];
  
  UIImage *dark = [Globals maskImage:[Globals snapShotView:self.bgdView] withColor:[UIColor colorWithWhite:0.f alpha:1.f]];
  UIImageView *img = [[UIImageView alloc] initWithImage:dark];
  [self.bgdView.superview addSubview:img];
  img.frame = self.bgdView.frame;
  self.overlayView = img;
  img.alpha = 0.f;
  _reorderingInProgress = NO;
}

- (void) setSlotCount {
  if (![Globals isSmallestiPhone]) {
    if ([Globals isiPhone6] || [Globals isiPhone6Plus])
      self.numSlots = 6;
    else
      self.numSlots = 5;
  } else {
    self.numSlots = 3;
  }
}

- (void) setFrame:(CGRect)frame {
  [super setFrame:frame];
  
  //self.numSlots = roundf(self.width/(self.currentBorder.width+VIEW_SPACING));
  
  // We know currentBorder width is 1 more than miniMonsterViews
  self.currentBorder.center = [self.currentBorder.superview convertPoint:[self centerForIndex:0 width:self.currentBorder.width-1] fromView:self.containerView];
}

- (void) setBattleSchedule:(__weak BattleSchedule*)battleSchedule
{
  _battleSchedule = battleSchedule;
}

- (void) displayOverlayView {
  [UIView animateWithDuration:0.3f animations:^{
    self.overlayView.alpha = 1.f;
  }];
}

- (void) removeOverlayView {
  [UIView animateWithDuration:0.3f animations:^{
    self.overlayView.alpha = 0.f;
  }];
}

- (void) setOrdering:(NSArray *)ordering showEnemyBands:(NSArray *)showEnemyBands playerTurns:(NSArray*)playerTurns{
  NSMutableArray *oldArr = self.monsterViews;
  
  // Account for how many turns currently display side effects before
  // throwing away the old schedule, so that the new schedule can
  // properly display side effects on newly-created turn indicators
  for (MiniMonsterView* mmv in self.monsterViews)
    for (NSString* key in mmv.sideEffectSymbols)
    {
      SideEffectActiveTurns* at = [_upcomingSideEffectTurns objectForKey:key];
      if (mmv.belongsToPlayer) ++at.playerTurns; else ++at.enemyTurns;
    }
  
  // If it was hidden just remove all the old monster views
  if (self.hidden) {
    for (UIView *v in oldArr) {
      [v removeFromSuperview];
    }
    oldArr = nil;
  }
  
  self.monsterViews = [NSMutableArray array];
  for (int i = 0; i < ordering.count; i++) {
    NSNumber *num = ordering[i];
    NSNumber *enemyBand = showEnemyBands[i];
    NSNumber *playersTurn = playerTurns[i];
    
    int monsterId = num.intValue;
    BOOL showEnemyBand = enemyBand.boolValue;
    BOOL isPlayersTurn = playersTurn.boolValue;
    UIView *mmv = [self monsterViewForMonsterId:monsterId showEnemyBand:showEnemyBand player:isPlayersTurn];
    [self.monsterViews addObject:mmv];
    
    if (i < oldArr.count) {
      UIView *ommv = oldArr[i];
      
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (self.numSlots-i-1)*0.05f*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (i == 0)
          _reorderingInProgress = YES;
        [UIView transitionFromView:ommv toView:mmv duration:0.3 options:UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL finished) {
          
          if (i == ordering.count-1 || i == oldArr.count-1) // last element
            _reorderingInProgress = NO;
        }];
      });
    } else {
      // We have to put them into a superview because otherwise the whole container view flips when we transition
      UIView *v = [[UIView alloc] initWithFrame:mmv.frame];
      v.center = [self centerForIndex:i width:mmv.frame.size.width];
      [v addSubview:mmv];
      [self.containerView addSubview:v];
      
      //[self performSelector:@selector(bounceView:) withObject:self.monsterViews[0] afterDelay:0.3f];
    }
  }
}

- (void) bounceLastView
{
  if (_reorderingInProgress)
    return;
  
  if (self.monsterViews && self.monsterViews.count > 0)
    [self bounceView:self.monsterViews[0]];
}

- (void) addMonster:(int)monsterId showEnemyBand:(BOOL)showEnemyBand player:(BOOL)player{
  UIView *first = [self.monsterViews firstObject];
  UIView *new = [self monsterViewForMonsterId:monsterId showEnemyBand:showEnemyBand player:player];
  
  [self.monsterViews removeObject:first];
  [self.monsterViews addObject:new];
  
  UIView *v = [[UIView alloc] initWithFrame:new.frame];
  if ([Globals isiPad]) {
    v.center = ccp(self.containerView.frame.size.width + new.frame.size.width/2, self.containerView.frame.size.height/2);
  } else {
    v.center = ccp(-new.frame.size.width/2, self.containerView.frame.size.height/2);
  }
  [v addSubview:new];
  [self.containerView addSubview:v];
  
  [UIView animateWithDuration:0.3f animations:^{
    for (int i = 0; i < self.monsterViews.count; i++) {
      UIView *mmv = self.monsterViews[i];
      mmv.superview.center = [self centerForIndex:i width:mmv.frame.size.width];
    }
    
    first.superview.center = ccp(first.superview.center.x, -first.superview.frame.size.height/2);
    first.superview.alpha = 0.f;
  } completion:^(BOOL finished) {
    //[self bounceLastView];  // Now we're calling bounce from the NewBattleLayer
    
    [first.superview removeFromSuperview];
  }];
}

- (void) bounceView:(UIView *)view {
  float iconHeight = view.frame.size.height/3;
  float duration = 0.8f;
  
  CAKeyframeAnimation *anim = [CAKeyframeAnimation dockBounceAnimationWithIconHeight:iconHeight];
  anim.duration = duration;
  [view.layer addAnimation:anim forKey:@"bounce"];
  
  CAKeyframeAnimation *anim2 = [CAKeyframeAnimation dockBounceAnimationWithIconHeight:iconHeight];
  anim2.duration = duration;
  [self.currentBorder.layer addAnimation:anim2 forKey:@"bounce"];
}

- (CGPoint) centerForIndex:(int)i width:(float)width {
  CGFloat viewSpacing = (self.containerView.width-width*self.numSlots)/(self.numSlots+1);
  return ccp(self.containerView.width-viewSpacing*(i+1)-width*(i+0.5),
             self.containerView.height/2);
}

- (MiniMonsterView *) monsterViewForMonsterId:(int)monsterId showEnemyBand:(BOOL)showEnemyBand player:(BOOL)player {
  MiniMonsterView *mmv = [[NSBundle mainBundle] loadNibNamed:([Globals isiPad] ? @"MiniMonsterViewiPadSchedule" : @"MiniMonsterView") owner:self options:nil][0];
  [mmv updateForMonsterId:monsterId];
  mmv.evoBadge.hidden = YES;
  mmv.belongsToPlayer = player;
  
  if (showEnemyBand) {
    UIImageView *iv = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"enemystripes.png"]];
    [mmv insertSubview:iv aboveSubview:mmv.bgdIcon];
    iv.alpha = 0.6;
    iv.size = mmv.size;
    
    THLabel *label = [[THLabel alloc] initWithFrame:CGRectMake(1, mmv.frame.size.height-18, mmv.frame.size.width, 17)];
    label.font = [UIFont fontWithName:@"GothamNarrow-Ultra" size:[Globals isiPad] ? 12 : 8];
    label.textAlignment = NSTextAlignmentCenter;
    label.gradientStartColor = [UIColor colorWithRed:255/255.f green:182/255.f blue:0.f alpha:1.f];
    label.gradientEndColor = [UIColor colorWithRed:255/255.f green:53/255.f blue:0.f alpha:1.f];
    label.strokeColor = [UIColor whiteColor];
    label.strokeSize = 1.f;
    label.shadowColor = [UIColor colorWithWhite:0.f alpha:0.7f];
    label.shadowBlur = 0.9;
    label.shadowOffset = CGSizeMake(0, 1);
    label.text = @"ENEMY";
    [mmv addSubview:label];
  }
  
  // If there are any outstanding side effects, display them on this turn indicator
  for (NSString* key in _upcomingSideEffectTurns)
  {
    SideEffectActiveTurns* at = [_upcomingSideEffectTurns objectForKey:key];
    if ((player && at.playerTurns != 0) || (!player && at.enemyTurns != 0))
      [self display:YES sideEffectIcon:at.displaySymbol withKey:key onView:mmv forPlayer:player];
  }
  
  // Button to activate mobster window
  if (self.delegate)
  {
    MaskedButton *button = [[MaskedButton alloc] initWithFrame:mmv.bgdIcon.frame];
    button.baseImage = mmv.bgdIcon;
    button.tag = player;
    [button remakeImage];
    [button addTarget:self.delegate action:@selector(mobsterViewTapped:) forControlEvents:UIControlEventTouchUpInside];
    [mmv addSubview:button];
  }
  
  return mmv;
}

- (void) displaySideEffectIcon:(NSString*)icon withKey:(NSString*)key forUpcomingNumberOfTurns:(NSInteger)numTurns forPlayer:(BOOL)player
{
  SideEffectActiveTurns* at = [_upcomingSideEffectTurns objectForKey:key];
  if (!at) { at = [[SideEffectActiveTurns alloc] init]; [_upcomingSideEffectTurns setObject:at forKey:key]; }
  if (player) at.playerTurns = numTurns; else at.enemyTurns = numTurns;
  at.displaySymbol = icon;
  
  int turnCounter = 0;
  for (MiniMonsterView* mv in self.monsterViews)
    if (mv.belongsToPlayer == player)
      [self display:(numTurns < 0 || turnCounter++ < numTurns) sideEffectIcon:icon withKey:key onView:mv forPlayer:player];
}

- (void) displaySideEffectIcon:(NSString*)icon withKey:(NSString*)key forUpcomingNumberOfOpponentTurns:(NSInteger)numTurns forPlayer:(BOOL)player
{
  if (_battleSchedule && numTurns > 0)
  {
    int turn = -1;
    int upcomingAffectedTurns = 0;
    int opponentTurnsEncountered = 0;
    while (opponentTurnsEncountered < numTurns)
      if ([_battleSchedule getNthMove:turn++] == player) ++upcomingAffectedTurns;
      else ++opponentTurnsEncountered;
    
    [self displaySideEffectIcon:icon withKey:key forUpcomingNumberOfTurns:upcomingAffectedTurns forPlayer:player];
  }
}

- (void) removeSideEffectIconWithKey:(NSString*)key onAllUpcomingTurnsForPlayer:(BOOL)player
{
  for (MiniMonsterView* mv in self.monsterViews)
    if (mv.belongsToPlayer == player)
      [self display:NO sideEffectIcon:nil withKey:key onView:mv forPlayer:player];
  
  SideEffectActiveTurns* at = [_upcomingSideEffectTurns objectForKey:key];
  if (player) at.playerTurns = 0; else at.enemyTurns = 0;
}

- (void) display:(BOOL)display sideEffectIcon:(NSString*)icon withKey:(NSString*)key onView:(MiniMonsterView*)mv forPlayer:(BOOL)player
{
  if (display)
  {
    [mv displaySideEffectIcon:icon withKey:key];
    SideEffectActiveTurns* at = [_upcomingSideEffectTurns objectForKey:key];
    if (player) { if (at.playerTurns > 0) --at.playerTurns; } else { if (at.enemyTurns > 0) --at.enemyTurns; }
  }
  else
    [mv removeSideEffectIconWithKey:key];
}

@end

@implementation BattleScheduleiPadView

- (void)setSlotCount
{
  self.numSlots = 7;
}

- (CGPoint)centerForIndex:(int)i width:(float)width
{
  return ccp(13*(i+1)+width*(i+0.5), self.containerView.frame.size.height/2);
}


@end
