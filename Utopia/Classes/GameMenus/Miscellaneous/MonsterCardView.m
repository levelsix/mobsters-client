//
//  EquipCardView.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/29/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "MonsterCardView.h"
#import "Globals.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "NibUtils.h"

@implementation EvoBadge

- (void) updateForToonId:(int)toonId {
  [self updateForToon:[[GameState sharedGameState] monsterWithId:toonId]];
}

- (void) updateForToonId:(int)toonId greyscale:(BOOL)greyscale {
  [self updateForToon:[[GameState sharedGameState] monsterWithId:toonId] greyscale:greyscale];
}

- (void) updateForToon:(MonsterProto *)proto {
  [self updateForToon:proto greyscale:NO];
}

- (void) updateForToon:(MonsterProto *)proto greyscale:(BOOL)greyscale {
  [Globals imageNamed:@"evobadge2.png" withView:self.bg greyscale:greyscale indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  self.evoLevel.text = [NSString stringWithFormat:@"%i", proto.evolutionLevel];
  self.hidden = proto.evolutionLevel <= 1;
}

@end

@implementation MonsterCardView

static UIImage *img = nil;

- (void) awakeFromNib {
  [self addSubview:self.noMonsterView];
  
  self.qualityLabel.superview.transform = CGAffineTransformMakeRotation(-M_PI_4);
  
  self.overlayButton.hidden = YES;
  self.infoButton.hidden = YES;
}

- (void) setDelegate:(id<MonsterCardViewDelegate>)delegate {
  self.overlayButton.hidden = !delegate || ![delegate respondsToSelector:@selector(monsterCardSelected:)];
  self.infoButton.hidden = !delegate || ![delegate respondsToSelector:@selector(infoClicked:)];
  
  _delegate = delegate;
}

- (void) updateForMonster:(UserMonster *)um {
  [self updateForMonster:um backupString:@"Slot Empty" greyscale:NO];
}

- (void) updateForMonster:(UserMonster *)um backupString:(NSString *)str greyscale:(BOOL)greyscale {
  if (!um) {
    [self updateForNoMonsterWithLabel:str];
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:um.monsterId];
  
  NSString *fileName = [mp.imagePrefix stringByAppendingString:@"Card.png"];
  [Globals imageNamed:fileName withView:self.monsterIcon greyscale:greyscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  NSString *p1 = [NSString stringWithFormat:@"%@ ", mp.monsterName];
  NSString *p2 = [NSString stringWithFormat:@"L%d", um.level];
  NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[p1 stringByAppendingString:p2]];
  if (!greyscale) {
    [attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:48/255.f green:124/255.f blue:238/255.f alpha:1.f] range:NSMakeRange(p1.length, p2.length)];
  }
  self.nameLabel.attributedText = attr;
  
  self.qualityLabel.text = [[Globals shortenedStringForRarity:mp.quality] uppercaseString];
  
  
  NSString *bgdImgName = !greyscale ? [Globals imageNameForElement:mp.monsterElement suffix:@"square.png"] : @"greysquare.png";
  [Globals imageNamed:bgdImgName withView:self.cardBgdView greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  NSString *tagName = !greyscale ? [Globals imageNameForRarity:mp.quality suffix:@"band.png"] : @"greyband.png";
  [Globals imageNamed:tagName withView:self.qualityBgdView greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  [Globals imageNamed:@"infoi.png" withView:self.infoButton greyscale:greyscale indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  [self.evoBadge updateForToon:mp greyscale:greyscale];
  
  self.mainView.hidden = NO;
  self.noMonsterView.hidden = YES;
}

- (void) updateForNoMonsterWithLabel:(NSString *)str {
  self.nameLabel.text = str;
  
  self.mainView.hidden = YES;
  self.noMonsterView.hidden = NO;
}

- (IBAction)darkOverlayClicked:(id)sender {
  [self.delegate monsterCardSelected:self];
}

- (IBAction)infoClicked:(id)sender {
  [self.delegate infoClicked:self];
}

@end

@implementation MonsterCardContainerView

- (id) initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super initWithCoder:aDecoder])) {
    [[NSBundle mainBundle] loadNibNamed:@"MonsterCardView" owner:self options:nil];
    [self addSubview:self.monsterCardView];
    self.monsterCardView.frame = self.bounds;
  }
  return self;
}

- (void) awakeFromNib {
  NSMutableArray *oldSubviews = [self.subviews copy];
  self.backgroundColor = [UIColor clearColor];
  
  for (UIView *v in oldSubviews) {
    if (v != self.monsterCardView) {
      [self.monsterCardView.mainView insertSubview:v belowSubview:self.monsterCardView.overlayButton];
    }
  }
}

@end

@implementation MiniMonsterView

- (void) awakeFromNib {
  // Make sure side effect views are stored in the proper order
  NSMutableArray* sideEffectViews = [NSMutableArray array];
  if (self.sideEffectView1) [sideEffectViews addObject:self.sideEffectView1];
  if (self.sideEffectView2) [sideEffectViews addObject:self.sideEffectView2];
  if (self.sideEffectView3) [sideEffectViews addObject:self.sideEffectView3];
  if (self.sideEffectView4) [sideEffectViews addObject:self.sideEffectView4];
  
  _sideEffectViews = [NSArray arrayWithArray:sideEffectViews];
}

- (void) updateForMonsterId:(int)monsterId {
  [self updateForMonsterId:monsterId greyscale:NO];
}

- (void) updateForMonsterId:(int)monsterId greyscale:(BOOL)greyscale {
  if (monsterId) {
    GameState *gs = [GameState sharedGameState];
    MonsterProto *mp = [gs monsterWithId:monsterId];
    [self updateForElement:mp.monsterElement imgPrefix:mp.imagePrefix greyscale:greyscale];
    [self.evoBadge updateForToon:mp];
    self.monsterIcon.hidden = NO;
  } else {
    self.bgdIcon.image = [Globals imageNamed:@"teamslotopen.png"];
    self.monsterIcon.hidden = YES;
    self.evoBadge.hidden = YES;
  }
  self.monsterId = monsterId;
  
  for (int i = 0; i < _sideEffectViews.count; ++i)
  {
    UIView* sideEffectView = _sideEffectViews[i];
    [[sideEffectView viewWithTag:7910] removeFromSuperview];
    [sideEffectView setHidden:YES];
  }
  [_sideEffectSymbols removeAllObjects];
}

- (void) updateForElement:(Element)element imgPrefix:(NSString *)imgPrefix greyscale:(BOOL)greyscale {
  NSString *file = [imgPrefix stringByAppendingString:@"Card.png"];
  [self updateForElement:element imgName:file greyscale:greyscale];
}

- (void) updateForElement:(Element)element imgName:(NSString *)file greyscale:(BOOL)greyscale {
  [Globals imageNamed:file withView:self.monsterIcon greyscale:greyscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  if (element != ElementNoElement) {
    NSString *suffix = self.bgdIcon.frame.size.width >= 74 ? @"square.png" : self.bgdIcon.frame.size.width > 45 ? @"mediumsquare.png" : @"smallsquare.png";
    file = !greyscale ? [Globals imageNameForElement:element suffix:suffix] : [@"grey" stringByAppendingString:suffix];
    [Globals imageNamed:file withView:self.bgdIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  }
}

- (void) displaySideEffectIcon:(NSString*)icon withKey:(NSString*)key
{
  if (!_sideEffectSymbols)
    _sideEffectSymbols = [NSMutableDictionary dictionary];
  if ([_sideEffectSymbols objectForKey:key])
    [self removeSideEffectIconWithKey:key];
  
  for (int i = 0; i < _sideEffectViews.count; ++i)
  {
    UIView* sideEffectView = _sideEffectViews[i];
    if ([sideEffectView viewWithTag:7910] == nil)
    {
      UIImageView* sideEffectSymbol = [[UIImageView alloc] initWithImage:[Globals imageNamed:icon]];
      [sideEffectSymbol setFrame:CGRectMake(1.f, 1.f, 13.f, 14.f)];
      [sideEffectSymbol setContentMode:UIViewContentModeScaleAspectFit];
      [sideEffectSymbol setTag:7910];
      [sideEffectView addSubview:sideEffectSymbol];
      [sideEffectView setHidden:NO];
      
      /*
      // Add spinning animation
      CABasicAnimation* spinAnimation;
      spinAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
      spinAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.f];
      spinAnimation.duration = 1.f;
      spinAnimation.cumulative = YES;
      spinAnimation.repeatCount = HUGE_VALF; // The stupid (and only) way to infinitely loop a CABasicAnimation
      [sideEffectSymbol.layer addAnimation:spinAnimation forKey:@"ConfusedSymbolSpinAnimation"];
       */
      
      [_sideEffectSymbols setObject:sideEffectSymbol forKey:key];
      
      break;
    }
  }
}

- (void) removeSideEffectIconWithKey:(NSString*)key
{
  UIImageView* sideEffectSymbol = [_sideEffectSymbols objectForKey:key];
  if (sideEffectSymbol)
  {
    [sideEffectSymbol.superview setHidden:YES];
    [sideEffectSymbol removeFromSuperview];
    [_sideEffectSymbols removeObjectForKey:key];
  }
}

- (void) removeAllSideEffectIcons
{
  for (UIImageView* sideEffect in [_sideEffectSymbols allValues]) {
    [sideEffect.superview setHidden:YES];
    [sideEffect removeFromSuperview];
  }
  [_sideEffectSymbols removeAllObjects];
}

@end

@implementation CircleMonsterView

- (void) awakeFromNib {
  self.monsterIcon.layer.cornerRadius = self.monsterIcon.frame.size.width/2;
}

- (void) updateForMonsterId:(int)monsterId {
  if (monsterId) {
    GameState *gs = [GameState sharedGameState];
    MonsterProto *mp = [gs monsterWithId:monsterId];
    [self updateForElement:mp.monsterElement imgPrefix:mp.imagePrefix greyscale:NO];
  } else {
    self.bgdIcon.image = nil;
    self.monsterIcon.image = nil;
  }
  self.monsterId = monsterId;
}

- (void) updateForElement:(Element)element imgPrefix:(NSString *)imgPrefix greyscale:(BOOL)greyscale {
  NSString *file = [imgPrefix stringByAppendingString:@"Card.png"];
  [Globals imageNamed:file withView:self.monsterIcon greyscale:greyscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  file = [Globals imageNameForElement:element suffix:@"avatar.png"];
  [Globals imageNamed:file withView:self.bgdIcon greyscale:greyscale indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
}

@end
