//
//  NewGachaViews.m
//  Utopia
//
//  Created by Behrouz N. on 12/18/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "NewGachaViews.h"
#import "GameState.h"
#import "Globals.h"
#import "IAPHelper.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import "SkillController.h"
#import "UIEffectDesignerView.h"
#import "SoundEngine.h"

static const CGFloat kRevealAnimDuration = 1.f;         // Seconds
static const CGFloat kRevealAnimFrames = 20.f;          // Frames
static const CGFloat kRevealDelayInBetweenAnims = .2f;  // Seconds
static const CGFloat kSoundEffectAnimHeadStart = .8f;   // Seconds

static const CGFloat kStatsScaleAnimStartingScale = 8.f;
static const CGFloat kStatsScaleAnimDuration = .4f;   // Seconds
static const CGFloat kScreenShakeAnimDuration = .4f;  // Seconds
static const int kScreenShakeAnimOffsetRange = 15.f;  // Pixels

static const CGFloat kPFXFadeInAnimDuration = 1.f;          // Seconds
static const CGFloat kLightPulseAnimDuration = 1.f;         // Seconds
static const CGFloat kCloseButtonFadeInAnimDelay = .1f;     // Seconds
static const CGFloat kCloseButtonFadeInAnimDuration = .4f;  // Seconds
static const CGFloat kCloseButtonTargetOpacity = .6f;

#define REVEAL_KEYFRAME_ANIMATION(__anim__, __key__) \
  CAKeyframeAnimation *__anim__ = [CAKeyframeAnimation animationWithKeyPath:__key__]; { \
  [__anim__ setDuration:kRevealAnimDuration]; \
  [__anim__ setCalculationMode:kCAAnimationLinear]; \
  [__anim__ setDelegate:self]; \
}

typedef void (^RevealAnimCompletionBlock)(void);
#define REVEAL_ANIM_COMPLETION_BLOCK_KEY @"RevealAnimCompletionBlock"

@implementation NewGachaPrizeStatsView
// Stupid Objective-C...
@end

@implementation NewGachaPrizeView

- (void) awakeFromNib
{
  _firstTimeLoadingFromNib = YES;
  
  if ([Globals isiPhone6])
  {
    // We good
  }
  else if ([Globals isiPhone6Plus])
  {
    self.statsContainerView.originX += 50.f;
  }
  else if ([Globals isSmallestiPhone])
  {
    const CGFloat heightToWidth = ([Globals screenSize].height / 375.f) / ([Globals screenSize].width / 667.f);
    for (UIView* subview in self.animationContainerView.subviews)
      subview.frame = CGRectMake(subview.originX * heightToWidth, subview.originY, subview.width * heightToWidth, subview.height);
    
    self.statsContainerView.originX -= 100.f;
    self.statsContainerView.nameLabel.width -= 30.f;
  }
  else
    self.statsContainerView.originX -= 50.f;
  
  self.statsContainerView.layer.anchorPoint = CGPointMake(.25f, .5f);
  self.statsContainerView.originX -= self.statsContainerView.width * .25f;
  
  self.nextButton.layer.transform = CATransform3DMakeScale(-1, 1, 1);
  
  const CGFloat deviceScale = [Globals screenSize].width / 667.f;
  UIEffectDesignerView* effectView = [UIEffectDesignerView effectWithFile:@"NewGachaSmoke.ped"];
  [effectView setFrame:CGRectMake(140.f * deviceScale, 250.f * deviceScale, 100.f * deviceScale, 20.f * deviceScale)];
  [effectView.emitter setEmitterSize:CGSizeMake(effectView.width, effectView.height)];
  [effectView.emitter setEmitterPosition:CGPointMake(effectView.emitter.emitterPosition.x - effectView.width * .5f, effectView.emitter.emitterPosition.y)];
  [self insertSubview:effectView aboveSubview:self.contentScrollView];
  _particleEffectView = effectView;
  
  _backgroundDuplicate = nil;
  _lightCircleDuplicate = nil;
  _whiteLightCircleDuplicate = nil;
  _characterWhite = nil;
}

- (void) didMoveToSuperview
{
  _firstTimeLoadingFromNib = NO;
}

- (void) preloadWithMonsterIds:(NSArray*)monsterIds
{
  GameState *gs = [GameState sharedGameState];
  
  _characterImageViews = [NSMutableArray array];
  [_characterImageViews addObject:self.character];
  
  //
  // Load and display the first character
  //
  
  MonsterProto *proto = [gs monsterWithId:[monsterIds[0] intValue]];
  [Globals imageNamedWithiPhone6Prefix:[proto.imagePrefix stringByAppendingString:@"Character.png"]
                              withView:self.character
                           maskedColor:nil
                             indicator:UIActivityIndicatorViewStyleWhite
              clearImageDuringDownload:YES];
  
  const NSString* elementStr = [[Globals stringForElement:proto.monsterElement] lowercaseString];
  self.background.image = [Globals imageNamed:[elementStr stringByAppendingString:@"grbackground.jpg"]];

  _characterBackgrounds = [NSMutableArray array];
  [_characterBackgrounds addObject:self.background.image];
  
  //
  // Load the remaining characters (if any) as subviews of characterScrollView
  //
  
  self.characterScrollView.contentSize = CGSizeMake(self.width * monsterIds.count, self.height);
  self.characterScrollView.contentOffset = CGPointZero;
  
  const CGFloat wR = _firstTimeLoadingFromNib ? [Globals screenSize].width  / 667.f : 1.f;
  const CGFloat hR = _firstTimeLoadingFromNib ? [Globals screenSize].height / 375.f : 1.f;
  const CGRect adjustedFrame = CGRectMake(self.character.frame.origin.x * wR,
                                          self.character.frame.origin.y * hR,
                                          self.character.size.width  * wR,
                                          self.character.size.height * hR);
  
  for (int i = 1; i < monsterIds.count; ++i)
  {
    UIImageView* characterImageView = [[UIImageView alloc] initWithFrame:adjustedFrame];
    characterImageView.contentMode = self.character.contentMode;
    characterImageView.originX += (self.width * wR) * i;
    
    MonsterProto *proto = [gs monsterWithId:[monsterIds[i] intValue]];
    [Globals imageNamedWithiPhone6Prefix:[proto.imagePrefix stringByAppendingString:@"Character.png"]
                                withView:characterImageView
                             maskedColor:nil
                               indicator:UIActivityIndicatorViewStyleWhite
                clearImageDuringDownload:YES];
    
    const NSString* elementStr = [[Globals stringForElement:proto.monsterElement] lowercaseString];
    [_characterBackgrounds addObject:[Globals imageNamed:[elementStr stringByAppendingString:@"grbackground.jpg"]]];
    
    [self.characterScrollView addSubview:characterImageView];
    [_characterImageViews addObject:characterImageView];
  }
}

- (void) initializeWithMonsterDescriptors:(NSArray*)monsterDescriptors
{
  _characterStatsViews = [NSMutableArray array];
  [_characterStatsViews addObject:self.statsContainerView];
  
  //
  // Initialize the animation and load and display the first character's stats
  //
  
  _characterDescriptors = [monsterDescriptors copy];
  _currentCharacterIndex = 0;
  _skippingAnimations = NO;
  
  [self updateStatsForCurrentMonster];
  
  //
  // Load the remaining characters stats (if any) as subviews of contentScrollView
  //
  
  self.contentScrollView.contentSize = CGSizeMake(self.width * monsterDescriptors.count, self.height);
  self.contentScrollView.contentOffset = CGPointZero;
  self.contentScrollView.scrollEnabled = NO;
  
  self.contentPageControl.numberOfPages = monsterDescriptors.count;
  self.contentPageControl.hidden = YES;
  self.contentPageLabel.hidden = YES;
  
  self.prevButton.hidden = YES;
  self.nextButton.hidden = YES;

  self.skipAllButton.hidden = !(monsterDescriptors.count > 1);
  self.closeButton.hidden = YES;
  _particleEffectView.hidden = YES;
  
  for (int i = 1; i < monsterDescriptors.count; ++i)
  {
    NewGachaPrizeStatsView* characterStatsView = [[NewGachaPrizeStatsView alloc] init];
    characterStatsView.layer.anchorPoint = self.statsContainerView.layer.anchorPoint;
    characterStatsView.frame = self.statsContainerView.frame;
    characterStatsView.originX += self.width * i;
    characterStatsView.nameLabel.width = self.statsContainerView.nameLabel.width;
    
    [self.contentScrollView addSubview:characterStatsView];
    [_characterStatsViews addObject:characterStatsView];
    
    ++_currentCharacterIndex;
    [self updateStatsForCurrentMonster];
  }
  
  _currentCharacterIndex = 0;
  
  [self setInitialOpacity];
}

- (void) updateStatsForCurrentMonster
{
  const int monsterId = [[_characterDescriptors[_currentCharacterIndex] objectForKey:@"MonsterId"] intValue];
  const int numPuzzlePieces = [[_characterDescriptors[_currentCharacterIndex] objectForKey:@"NumPuzzlePieces"] intValue];
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  MonsterProto *proto = [gs monsterWithId:monsterId];

  NewGachaPrizeStatsView* characterStatsView = _characterStatsViews[_currentCharacterIndex];
  characterStatsView.hidden = YES;
  characterStatsView.nameLabel.text = proto.displayName;
  characterStatsView.rarityIcon.image = [Globals imageNamed:[@"battle" stringByAppendingString:[Globals imageNameForRarity:proto.quality suffix:@"tag.png"]]];
  
  THLabel* label = (THLabel*)characterStatsView.nameLabel;
  switch (proto.monsterElement)
  {
    case ElementFire:
      label.gradientStartColor = [UIColor colorWithHexString:@"ff8f00"];
      label.gradientEndColor = [UIColor colorWithHexString:@"ff4000"];
      break;
    case ElementEarth:
      label.gradientStartColor = [UIColor colorWithHexString:@"d7f828"];
      label.gradientEndColor = [UIColor colorWithHexString:@"63e40b"];
      break;
    case ElementWater:
      label.gradientStartColor = [UIColor colorWithHexString:@"00edff"];
      label.gradientEndColor = [UIColor colorWithHexString:@"00b9ff"];
      break;
    case ElementLight:
      label.gradientStartColor = [UIColor colorWithHexString:@"ffe700"];
      label.gradientEndColor = [UIColor colorWithHexString:@"ffb300"];
      break;
    case ElementDark:
      label.gradientStartColor = [UIColor colorWithHexString:@"e600ff"];
      label.gradientEndColor = [UIColor colorWithHexString:@"9600ff"];
      break;
      
    default:
      break;
  }
  
  CGFloat offset = characterStatsView.rarityIcon.width - characterStatsView.rarityIcon.image.size.width;
  characterStatsView.rarityIcon.width -= offset;
  characterStatsView.pieceSeparator.originX -= offset;
  characterStatsView.pieceIcon.originX -= offset;
  characterStatsView.pieceLabel.originX -= offset;
  
  UserMonster *um = [[UserMonster alloc] init];
  um.monsterId = monsterId;
  um.level = proto.maxLevel;
  um.offensiveSkillId = proto.baseOffensiveSkillId;
  um.defensiveSkillId = proto.baseDefensiveSkillId;
  characterStatsView.attackLabel.text = [Globals commafyNumber:[gl calculateTotalDamageForMonster:um]];
  characterStatsView.hpLabel.text = [Globals commafyNumber:[gl calculateMaxHealthForMonster:um]];
  characterStatsView.speedLabel.text = [Globals commafyNumber:um.speed];
  characterStatsView.powerLabel.text = [Globals commafyNumber:um.teamCost];
  
  [self updateSkillsForMonster:um];
  [Globals alignSubviewsToPixelsBoundaries:characterStatsView];

  if (numPuzzlePieces > 0)
  {
    [Globals imageNamed:[@"gacha" stringByAppendingString:[Globals imageNameForRarity:proto.quality suffix:@"piece.png"]]
               withView:characterStatsView.pieceIcon
            maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    characterStatsView.pieceLabel.text = [NSString stringWithFormat:@"1 PIECE (%d/%d)", numPuzzlePieces, proto.numPuzzlePieces];
  }
  
  characterStatsView.pieceSeparator.hidden = !(numPuzzlePieces > 0);
  characterStatsView.pieceIcon.hidden = !(numPuzzlePieces > 0);
  characterStatsView.pieceLabel.hidden = !(numPuzzlePieces > 0);
}

- (void) updateSkillsForMonster:(UserMonster*)monster
{
  GameState *gs = [GameState sharedGameState];
  
  NewGachaPrizeStatsView* characterStatsView = _characterStatsViews[_currentCharacterIndex];
  
  if (monster.offensiveSkillId == 0)
  {
    characterStatsView.offensiveSkillView.hidden = YES;
    characterStatsView.defensiveSkillView.originY = characterStatsView.offensiveSkillView.originY;
  }
  else
  {
    SkillProto* skillProto = [gs.staticSkills objectForKey:[NSNumber numberWithInteger:monster.offensiveSkillId]];
    if (skillProto)
    {
      [Globals imageNamed:[skillProto.imgNamePrefix stringByAppendingString:kSkillIconImageNameSuffix]
                 withView:characterStatsView.offensiveSkillIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:NO];
      characterStatsView.offensiveSkillName.text = skillProto.name;
      characterStatsView.offensiveSkillView.hidden = NO;
      characterStatsView.defensiveSkillView.originY = CGRectGetMaxY(characterStatsView.offensiveSkillView.frame) + 8.f;
    }
  }
  
  if (monster.defensiveSkillId == 0)
  {
    characterStatsView.defensiveSkillView.hidden = YES;
  }
  else
  {
    SkillProto* skillProto = [gs.staticSkills objectForKey:[NSNumber numberWithInteger:monster.defensiveSkillId]];
    if (skillProto)
    {
      [Globals imageNamed:[skillProto.imgNamePrefix stringByAppendingString:kSkillIconImageNameSuffix]
                 withView:characterStatsView.defensiveSkillIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:NO];
      characterStatsView.defensiveSkillName.text = skillProto.name;
      characterStatsView.defensiveSkillView.hidden = NO;
    }
  }
  
  if (characterStatsView.offensiveSkillView.hidden &&
      characterStatsView.defensiveSkillView.hidden)
  {
    characterStatsView.skillsSeparator.hidden = YES;
    characterStatsView.height = CGRectGetMaxY(characterStatsView.powerLabel.frame) + 8.f;
  }
  else
  {
    characterStatsView.skillsSeparator.hidden = NO;
    characterStatsView.height = CGRectGetMaxY(characterStatsView.defensiveSkillView.hidden ? characterStatsView.offensiveSkillView.frame : characterStatsView.defensiveSkillView.frame) + 8.f;
  }
  
  characterStatsView.centerY = self.height * .5f;
}

- (void) setInitialOpacity
{
  UIImageView* characterImageView = _characterImageViews[_currentCharacterIndex];
  
  [self.characterShadow.layer setOpacity:0.f];
  [characterImageView.layer setOpacity:0.f];
  [self.elementbigFlash.layer setOpacity:0.f];
  [self.lightCircle.layer setOpacity:0.f];
  [self.whiteLightCircle.layer setOpacity:0.f];
  [self.elementLightsFlash.layer setOpacity:0.f];
  [self.lights.layer setOpacity:0.f];
  [self.glow.layer setOpacity:0.f];
  [self.elementGlow.layer setOpacity:0.f];
  [self.crystalGlow.layer setOpacity:0.f];
  [self.lightningBolt7.layer setOpacity:0.f];
  [self.lightningBolt6.layer setOpacity:0.f];
  [self.lightningBolt5.layer setOpacity:0.f];
  [self.lightningBolt4.layer setOpacity:0.f];
  [self.lightningBolt3.layer setOpacity:0.f];
  [self.lightningBolt2.layer setOpacity:0.f];
  [self.lightningBolt1.layer setOpacity:0.f];
  [self.afterGlow.layer setOpacity:0.f];
  
  if (_lightCircleDuplicate) [_lightCircleDuplicate.layer setOpacity:0.f];
  if (_whiteLightCircleDuplicate) [_whiteLightCircleDuplicate.layer setOpacity:0.f];
  if (_characterWhite) [_characterWhite.layer setOpacity:0.f];
}

- (void) beginAnimation
{
  UIImageView* characterImageView = _characterImageViews[_currentCharacterIndex];
  NewGachaPrizeStatsView* characterStatsView = _characterStatsViews[_currentCharacterIndex];
  
  const int monsterId = [[_characterDescriptors[_currentCharacterIndex] objectForKey:@"MonsterId"] intValue];
  MonsterProto* proto = [[GameState sharedGameState] monsterWithId:monsterId];
  const NSString* elementStr = [[Globals stringForElement:proto.monsterElement] lowercaseString];
  {
    self.elementbigFlash.image = [Globals imageNamed:[elementStr stringByAppendingString:@"grbigflash1.png"]];
    self.elementGlow.image = [Globals imageNamed:[elementStr stringByAppendingString:@"grglow2glowblend.png"]];
    self.elementLightsFlash.image = [Globals imageNamed:[elementStr stringByAppendingString:@"lightsflashlow1.png"]];
  }
  self.background.image = _characterBackgrounds[_currentCharacterIndex];
  
  if (!_lightCircleDuplicate)
  {
     _lightCircleDuplicate = [[UIImageView alloc] initWithFrame:self.lightCircle.frame];
    [_lightCircleDuplicate setImage:self.lightCircle.image];
    [_lightCircleDuplicate setContentMode:self.lightCircle.contentMode];
    [self.animationContainerView insertSubview:_lightCircleDuplicate aboveSubview:self.whiteLightCircle];
  }
  
  if (!_whiteLightCircleDuplicate)
  {
     _whiteLightCircleDuplicate = [[UIImageView alloc] initWithFrame:self.whiteLightCircle.frame];
    [_whiteLightCircleDuplicate setImage:self.whiteLightCircle.image];
    [_whiteLightCircleDuplicate setContentMode:self.whiteLightCircle.contentMode];
    [self.animationContainerView insertSubview:_whiteLightCircleDuplicate aboveSubview:_lightCircleDuplicate];
  }
  
  if (_characterWhite) [_characterWhite removeFromSuperview];
   _characterWhite = [[UIImageView alloc] initWithFrame:self.character.frame];
  [_characterWhite setImage:[Globals maskImage:characterImageView.image withColor:[UIColor whiteColor]]];
  [_characterWhite setContentMode:self.character.contentMode];
  [self.animationContainerView insertSubview:_characterWhite aboveSubview:self.elementLightsFlash];
  
  REVEAL_KEYFRAME_ANIMATION(anim1, @"opacity")
    [anim1 setKeyTimes:@[ @0.f, @(6.f / kRevealAnimFrames), @(13.f / kRevealAnimFrames), @1.0f ]];
    [anim1 setValues:@[ @0.f, @0.f, @1.f, @1.f ]];
    [anim1 setValue:^(void) { [self.characterShadow.layer setOpacity:1.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [self.characterShadow.layer addAnimation:anim1 forKey:@"CharacterShadowFadeInAnimation"];
    [self.characterShadow.layer setOpacity:1.f];
  
  REVEAL_KEYFRAME_ANIMATION(anim2, @"opacity")
    [anim2 setKeyTimes:@[ @0.f, @(8.f / kRevealAnimFrames), @(9.f / kRevealAnimFrames), @1.0f ]];
    [anim2 setValues:@[ @0.f, @0.f, @1.f, @1.f ]];
    [anim2 setValue:^(void) { [characterImageView.layer setOpacity:1.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [characterImageView.layer addAnimation:anim2 forKey:@"CharacterFadeInAnimation"];
    [characterImageView.layer setOpacity:1.f];
  
  REVEAL_KEYFRAME_ANIMATION(anim3, @"opacity")
    [anim3 setKeyTimes:@[ @0.f, @(3.f / kRevealAnimFrames), @(8.f / kRevealAnimFrames), @(17.f / kRevealAnimFrames), @1.0f ]];
    [anim3 setValues:@[ @0.f, @0.f, @1.f, @0.f, @0.f ]];
    [anim3 setValue:^(void) { [self.elementbigFlash.layer setOpacity:0.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [self.elementbigFlash.layer addAnimation:anim3 forKey:@"BigFlashFadeInOutAnimation"];
    [self.elementbigFlash.layer setOpacity:0.f];
  
  REVEAL_KEYFRAME_ANIMATION(anim4, @"opacity")
    [anim4 setKeyTimes:@[ @0.f, @(3.f / kRevealAnimFrames), @(12.f / kRevealAnimFrames), @1.0f ]];
    [anim4 setValues:@[ @0.f, @0.f, @1.f, @1.f ]];
    [anim4 setValue:^(void) { [self.lightCircle.layer setOpacity:1.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [self.lightCircle.layer addAnimation:anim4 forKey:@"LightCircleFadeInAnimation"];
    [self.lightCircle.layer setOpacity:1.f];
  
  REVEAL_KEYFRAME_ANIMATION(anim5, @"opacity")
    [anim5 setKeyTimes:@[ @0.f, @(3.f / kRevealAnimFrames), @(12.f / kRevealAnimFrames), @1.0f ]];
    [anim5 setValues:@[ @0.f, @0.f, @1.f, @1.f ]];
    [anim5 setValue:^(void) { [self.whiteLightCircle.layer setOpacity:1.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [self.whiteLightCircle.layer addAnimation:anim5 forKey:@"WhiteLightCircleFadeInAnimation"];
    [self.whiteLightCircle.layer setOpacity:1.f];
  
  REVEAL_KEYFRAME_ANIMATION(anim6, @"opacity")
    [anim6 setKeyTimes:@[ @0.f, @(6.f / kRevealAnimFrames), @(16.f / kRevealAnimFrames), @1.0f ]];
    [anim6 setValues:@[ @0.f, @0.f, @1.f, @1.f ]];
    [anim6 setValue:^(void) { [_lightCircleDuplicate.layer setOpacity:1.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [_lightCircleDuplicate.layer addAnimation:anim6 forKey:@"LightCircleDuplicateFadeInAnimation"];
    [_lightCircleDuplicate.layer setOpacity:1.f];
  
  REVEAL_KEYFRAME_ANIMATION(anim7, @"opacity")
    [anim7 setKeyTimes:@[ @0.f, @(6.f / kRevealAnimFrames), @(16.f / kRevealAnimFrames), @1.0f ]];
    [anim7 setValues:@[ @0.f, @0.f, @1.f, @1.f ]];
    [anim7 setValue:^(void) { [_whiteLightCircleDuplicate.layer setOpacity:1.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [_whiteLightCircleDuplicate.layer addAnimation:anim7 forKey:@"WhiteLightCircleDuplicateFadeInAnimation"];
    [_whiteLightCircleDuplicate.layer setOpacity:1.f];
  
  REVEAL_KEYFRAME_ANIMATION(anim8, @"opacity")
    [anim8 setKeyTimes:@[ @0.f, @(2.f / kRevealAnimFrames), @(7.f / kRevealAnimFrames), @(20.f / kRevealAnimFrames), @1.0f ]];
    [anim8 setValues:@[ @0.f, @0.f, @1.f, @0.f, @0.f ]];
    [anim8 setValue:^(void) { [self.elementLightsFlash.layer setOpacity:0.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [self.elementLightsFlash.layer addAnimation:anim8 forKey:@"LighsFlashFadeInOutAnimation"];
    [self.elementLightsFlash.layer setOpacity:0.f];
  
  REVEAL_KEYFRAME_ANIMATION(anim9, @"opacity")
    [anim9 setKeyTimes:@[ @0.f, @(3.f / kRevealAnimFrames), @(7.f / kRevealAnimFrames), @(9.f / kRevealAnimFrames), @(15.f / kRevealAnimFrames), @1.0f ]];
    [anim9 setValues:@[ @0.f, @0.f, @1.f, @1.f, @0.f, @0.f ]];
    [anim9 setValue:^(void) { [_characterWhite.layer setOpacity:0.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [_characterWhite.layer addAnimation:anim9 forKey:@"CharacterWhiteFadeInOutAnimation"];
    [_characterWhite.layer setOpacity:0.f];
  
  REVEAL_KEYFRAME_ANIMATION(anim10, @"opacity")
    [anim10 setKeyTimes:@[ @0.f, @(3.f / kRevealAnimFrames), @(8.f / kRevealAnimFrames), @(14.f / kRevealAnimFrames), @1.0f ]];
    [anim10 setValues:@[ @0.f, @0.f, @1.f, @0.f, @0.f ]];
    [anim10 setValue:^(void) { [self.lights.layer setOpacity:0.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [self.lights.layer addAnimation:anim10 forKey:@"LighsFadeInOutAnimation"];
    [self.lights.layer setOpacity:0.f];
  
  REVEAL_KEYFRAME_ANIMATION(anim11, @"opacity")
    [anim11 setKeyTimes:@[ @0.f, @(1.f / kRevealAnimFrames), @(3.f / kRevealAnimFrames), @(6.f / kRevealAnimFrames), @(20.f / kRevealAnimFrames), @1.0f ]];
    [anim11 setValues:@[ @0.f, @0.f, @1.f, @1.f, @0.f, @.0f ]];
    [anim11 setValue:^(void) { [self.glow.layer setOpacity:0.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [self.glow.layer addAnimation:anim11 forKey:@"GlowFadeInOutAnimation"];
    [self.glow.layer setOpacity:0.f];
  
  REVEAL_KEYFRAME_ANIMATION(anim12, @"opacity")
    [anim12 setKeyTimes:@[ @0.f, @(1.f / kRevealAnimFrames), @(3.f / kRevealAnimFrames), @(6.f / kRevealAnimFrames), @(20.f / kRevealAnimFrames), @1.0f ]];
    [anim12 setValues:@[ @0.f, @0.f, @1.f, @1.f, @0.f, @.0f ]];
    [anim12 setValue:^(void) { [self.elementGlow.layer setOpacity:0.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [self.elementGlow.layer addAnimation:anim12 forKey:@"ElementGlowFadeInOutAnimation"];
    [self.elementGlow.layer setOpacity:0.f];
  
  REVEAL_KEYFRAME_ANIMATION(anim13, @"opacity")
    [anim13 setKeyTimes:@[ @0.f, @(2.f / kRevealAnimFrames), @(6.f / kRevealAnimFrames), @(14.f / kRevealAnimFrames), @1.0f ]];
    [anim13 setValues:@[ @0.f, @0.f, @1.f, @0.f, @.0f ]];
    [anim13 setValue:^(void) { [self.crystalGlow.layer setOpacity:0.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [self.crystalGlow.layer addAnimation:anim13 forKey:@"CrystalGlowFadeInOutAnimation"];
    [self.crystalGlow.layer setOpacity:0.f];
  
  REVEAL_KEYFRAME_ANIMATION(anim14, @"opacity")
    [anim14 setKeyTimes:@[ @0.f, @(8.f / kRevealAnimFrames), @(10.f / kRevealAnimFrames), @(12.f / kRevealAnimFrames), @1.0f ]];
    [anim14 setValues:@[ @0.f, @0.f, @1.f, @0.f, @.0f ]];
    [anim14 setValue:^(void) { [self.lightningBolt7.layer setOpacity:0.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [self.lightningBolt7.layer addAnimation:anim14 forKey:@"LightningBolt7FadeInOutAnimation"];
    [self.lightningBolt7.layer setOpacity:0.f];
  
  REVEAL_KEYFRAME_ANIMATION(anim15, @"opacity")
    [anim15 setKeyTimes:@[ @0.f, @(7.f / kRevealAnimFrames), @(9.f / kRevealAnimFrames), @(11.f / kRevealAnimFrames), @1.0f ]];
    [anim15 setValues:@[ @0.f, @0.f, @1.f, @0.f, @.0f ]];
    [anim15 setValue:^(void) { [self.lightningBolt6.layer setOpacity:0.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [self.lightningBolt6.layer addAnimation:anim15 forKey:@"LightningBolt6FadeInOutAnimation"];
    [self.lightningBolt6.layer setOpacity:0.f];
  
  REVEAL_KEYFRAME_ANIMATION(anim16, @"opacity")
    [anim16 setKeyTimes:@[ @0.f, @(6.f / kRevealAnimFrames), @(8.f / kRevealAnimFrames), @(10.f / kRevealAnimFrames), @1.0f ]];
    [anim16 setValues:@[ @0.f, @0.f, @1.f, @0.f, @.0f ]];
    [anim16 setValue:^(void) { [self.lightningBolt5.layer setOpacity:0.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [self.lightningBolt5.layer addAnimation:anim16 forKey:@"LightningBolt5FadeInOutAnimation"];
    [self.lightningBolt5.layer setOpacity:0.f];
  
  REVEAL_KEYFRAME_ANIMATION(anim17, @"opacity")
    [anim17 setKeyTimes:@[ @0.f, @(3.f / kRevealAnimFrames), @(5.f / kRevealAnimFrames), @(7.f / kRevealAnimFrames), @(9.f / kRevealAnimFrames), @1.0f ]];
    [anim17 setValues:@[ @0.f, @0.f, @1.f, @1.f, @.0f, @.0f ]];
    [anim17 setValue:^(void) { [self.lightningBolt4.layer setOpacity:0.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [self.lightningBolt4.layer addAnimation:anim17 forKey:@"LightningBolt4FadeInOutAnimation"];
    [self.lightningBolt4.layer setOpacity:0.f];
  
  REVEAL_KEYFRAME_ANIMATION(anim18, @"opacity")
    [anim18 setKeyTimes:@[ @0.f, @(2.f / kRevealAnimFrames), @(4.f / kRevealAnimFrames), @(6.f / kRevealAnimFrames), @1.0f ]];
    [anim18 setValues:@[ @0.f, @0.f, @1.f, @0.f, @.0f ]];
    [anim18 setValue:^(void) { [self.lightningBolt3.layer setOpacity:0.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [self.lightningBolt3.layer addAnimation:anim18 forKey:@"LightningBolt3FadeInOutAnimation"];
    [self.lightningBolt3.layer setOpacity:0.f];
  
  REVEAL_KEYFRAME_ANIMATION(anim19, @"opacity")
    [anim19 setKeyTimes:@[ @0.f, @(1.f / kRevealAnimFrames), @(3.f / kRevealAnimFrames), @(5.f / kRevealAnimFrames), @1.0f ]];
    [anim19 setValues:@[ @0.f, @0.f, @1.f, @0.f, @.0f ]];
    [anim19 setValue:^(void) { [self.lightningBolt2.layer setOpacity:0.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [self.lightningBolt2.layer addAnimation:anim19 forKey:@"LightningBolt2FadeInOutAnimation"];
    [self.lightningBolt2.layer setOpacity:0.f];
  
  REVEAL_KEYFRAME_ANIMATION(anim20, @"opacity")
    [anim20 setKeyTimes:@[ @0.f, @(0.f / kRevealAnimFrames), @(2.f / kRevealAnimFrames), @(4.f / kRevealAnimFrames), @1.0f ]];
    [anim20 setValues:@[ @0.f, @0.f, @1.f, @0.f, @.0f ]];
    [anim20 setValue:^(void) { [self.lightningBolt1.layer setOpacity:0.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [self.lightningBolt1.layer addAnimation:anim20 forKey:@"LightningBolt1FadeInOutAnimation"];
    [self.lightningBolt1.layer setOpacity:0.f];
  
  REVEAL_KEYFRAME_ANIMATION(anim21, @"opacity")
    [anim21 setKeyTimes:@[ @0.f, @(0.f / kRevealAnimFrames), @(3.f / kRevealAnimFrames), @(10.f / kRevealAnimFrames), @1.0f ]];
    [anim21 setValues:@[ @0.f, @0.f, @1.f, @0.f, @.0f ]];
    [anim21 setValue:^(void) { [self.afterGlow.layer setOpacity:0.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [self.afterGlow.layer addAnimation:anim21 forKey:@"AfterGlowFadeInOutAnimation"];
    [self.afterGlow.layer setOpacity:0.f];
  
  characterStatsView.hidden = NO;
  characterStatsView.alpha = 0.f;
  characterStatsView.transform = CGAffineTransformMakeScale(kStatsScaleAnimStartingScale, kStatsScaleAnimStartingScale);
  
  [UIView animateWithDuration:kStatsScaleAnimDuration delay:kRevealAnimDuration options:UIViewAnimationOptionCurveEaseIn animations:^{
    characterStatsView.alpha = 1.f;
    characterStatsView.transform = CGAffineTransformMakeScale(1.f, 1.f);
  } completion:^(BOOL finished) {
    [self shakeViews:@[ characterStatsView, self.animationContainerView ] withKey:@"ContainerViewsShakeAnimation" completion:^{
      [self restartOrEndAnimation];
    }];
  }];
  
  // Play the Gacha reveal SFX for the next character (if any) with a head start
  _startedNextRevealSoundEffect = NO;
  const NSTimeInterval t = (kRevealAnimDuration + kStatsScaleAnimDuration + kScreenShakeAnimDuration) + kRevealDelayInBetweenAnims - kSoundEffectAnimHeadStart;
  [self performBlockAfterDelay:t block:^{
    if (!_skippingAnimations && _currentCharacterIndex < _characterDescriptors.count - 1)
    {
      _startedNextRevealSoundEffect = YES;
      [SoundEngine gachaReveal];
    }
  }];
}

- (void) restartOrEndAnimation
{
  const NSInteger characterCount = _characterDescriptors.count;
  ++_currentCharacterIndex;
  
  if (!_skippingAnimations && _currentCharacterIndex < characterCount)
  {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kRevealDelayInBetweenAnims * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      self.contentScrollView.contentOffset = CGPointMake(self.width * _currentCharacterIndex, 0);
      self.characterScrollView.contentOffset = self.contentScrollView.contentOffset;
      
      [self beginAnimation];
    });
  }
  else
  {
    self.closeButton.hidden = NO;
    self.closeButton.alpha = 0.f;
    [UIView animateWithDuration:kCloseButtonFadeInAnimDuration delay:kCloseButtonFadeInAnimDelay options:UIViewAnimationOptionCurveLinear animations:^{
      self.closeButton.alpha = kCloseButtonTargetOpacity;
    } completion:nil];
    
    _particleEffectView.hidden = NO;
    _particleEffectView.alpha = 0.f;
    [UIView animateWithDuration:kPFXFadeInAnimDuration delay:0.f options:UIViewAnimationOptionCurveLinear animations:^{
      _particleEffectView.alpha = 1.f;
    } completion:nil];
    
    [UIView animateWithDuration:kLightPulseAnimDuration
                          delay:0.f
                        options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       self.lightCircle.alpha = 0.f;
                     } completion:nil];
    
    if (characterCount > 1)
    {
      self.contentScrollView.scrollEnabled = YES;
      
      self.contentPageControl.currentPage = _currentCharacterIndex - 1;
      self.contentPageControl.hidden = NO;
      self.contentPageControl.alpha = 0.f;
      
      self.contentPageLabel.text = [NSString stringWithFormat:@"%@ %ld/%ld", [MONSTER_NAME uppercaseString], (long)_currentCharacterIndex, (long)characterCount];
      self.contentPageLabel.hidden = NO;
      self.contentPageLabel.alpha = 0.f;
      
      self.prevButton.hidden = NO;
      self.prevButton.alpha = 0.f;
      
      self.nextButton.hidden = NO;
      self.nextButton.alpha = 0.f;
      
      self.prevButton.enabled = (self.contentPageControl.currentPage > 0);
      self.nextButton.enabled = (self.contentPageControl.currentPage < characterCount - 1);
      
      [UIView animateWithDuration:kCloseButtonFadeInAnimDuration delay:kCloseButtonFadeInAnimDelay options:UIViewAnimationOptionCurveLinear animations:^{
        self.contentPageControl.alpha = 1.f;
        self.contentPageLabel.alpha = 1.f;
        self.prevButton.alpha = 1.f;
        self.nextButton.alpha = 1.f;
      } completion:nil];
      
      if (!self.skipAllButton.hidden)
      {
        [UIView animateWithDuration:kCloseButtonFadeInAnimDuration delay:kCloseButtonFadeInAnimDelay options:UIViewAnimationOptionCurveLinear animations:^{
          self.skipAllButton.alpha = 0.f;
        } completion:^(BOOL finished) {
          self.skipAllButton.hidden = YES;
          self.skipAllButton.alpha = 1.f;
        }];
      }
      
      if (!_backgroundDuplicate)
      {
         _backgroundDuplicate = [[UIImageView alloc] initWithFrame:self.background.frame];
        [_backgroundDuplicate setAlpha:0.f];
        [_backgroundDuplicate setContentMode:self.background.contentMode];
        [self.animationContainerView insertSubview:_backgroundDuplicate aboveSubview:self.background];
      }
    }
  }
}

- (void) animationDidStop:(CAAnimation*)anim finished:(BOOL)flag
{
  RevealAnimCompletionBlock completionBlock = [anim valueForKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
  if (completionBlock) completionBlock();
}

- (void) shakeView:(UIView*)view withKey:(NSString*)key completion:(RevealAnimCompletionBlock)completion
{
  NSMutableArray *keyTimes = [NSMutableArray array];
  NSMutableArray *values = [NSMutableArray array];
  const CGPoint pos = view.layer.position;
  const int numFrames = 60.f * kScreenShakeAnimDuration;
  for (int i = 0; i < numFrames; ++i)
  {
    [keyTimes addObject:@((float)i / (float)numFrames)];
    [values addObject:[NSValue valueWithCGPoint:CGPointMake(pos.x + (CGFloat)arc4random_uniform(kScreenShakeAnimOffsetRange) - kScreenShakeAnimOffsetRange * .5f,
                                                            pos.y + (CGFloat)arc4random_uniform(kScreenShakeAnimOffsetRange) - kScreenShakeAnimOffsetRange * .5f)]];
  }
  CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
  [anim setDuration:kScreenShakeAnimDuration];
  [anim setCalculationMode:kCAAnimationLinear];
  [anim setKeyTimes:keyTimes];
  [anim setValues:values];
  if (completion) {
    [anim setDelegate:self];
    [anim setValue:completion forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
  }
  [view.layer addAnimation:anim forKey:key];
}

- (void) shakeViews:(NSArray*)views withKey:(NSString*)key completion:(RevealAnimCompletionBlock)completion
{
  NSMutableArray *keyTimes = [NSMutableArray array];
  NSMutableArray *baseValues = [NSMutableArray array];
  const int numFrames = 60.f * kScreenShakeAnimDuration;
  for (int i = 0; i < numFrames; ++i)
  {
    [keyTimes addObject:@((float)i / (float)numFrames)];
    [baseValues addObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)arc4random_uniform(kScreenShakeAnimOffsetRange) - kScreenShakeAnimOffsetRange * .5f,
                                                                (CGFloat)arc4random_uniform(kScreenShakeAnimOffsetRange) - kScreenShakeAnimOffsetRange * .5f)]];
  }
  
  BOOL completionBlockSet = NO;
  for (UIView* view in views)
  {
    NSMutableArray *values = [NSMutableArray array];
    const CGPoint pos = view.layer.position;
    for (NSValue* baseValue in baseValues)
      [values addObject:[NSValue valueWithCGPoint:CGPointMake(pos.x + [baseValue CGPointValue].x, pos.y + [baseValue CGPointValue].y)]];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [anim setDuration:kScreenShakeAnimDuration];
    [anim setCalculationMode:kCAAnimationLinear];
    [anim setKeyTimes:keyTimes];
    [anim setValues:values];
    
    if (completion && !completionBlockSet) {
      [anim setDelegate:self];
      [anim setValue:completion forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
      completionBlockSet = YES;
    }
    
    [view.layer addAnimation:anim forKey:key];
  }
}

- (void) scrollViewDidScroll:(UIScrollView*)scrollView
{
  // Positive value indicates swiping right (left/previous page coming into view)
  const CGFloat dx = self.characterScrollView.contentOffset.x - scrollView.contentOffset.x;
  
  // This is the delegate callback method for contentScrollView that's
  // user-interactable. Keeping characterScrollView scrolling in sync
  self.characterScrollView.contentOffset = scrollView.contentOffset;
  
  const NSInteger characterCount = _characterDescriptors.count;
  const NSInteger currentPage = floorf((scrollView.contentOffset.x + scrollView.width * .5f) / scrollView.width);
  if (currentPage != self.contentPageControl.currentPage)
  {
    self.contentPageLabel.text = [NSString stringWithFormat:@"%@ %ld/%ld", [MONSTER_NAME uppercaseString], (long)currentPage + 1, (long)characterCount];
    
    self.prevButton.enabled = (currentPage > 0);
    self.nextButton.enabled = (currentPage < characterCount - 1);
  }
  
  self.contentPageControl.currentPage = currentPage;
  
  const float n = clampf(scrollView.contentOffset.x, 0.f, scrollView.contentSize.width - scrollView.width) / scrollView.width;
  const int p0  = clampf(floorf(n) + (dx > 0.f), 0, characterCount - 1); // Page swiping from
  const int p1  = clampf(floorf(n) + (dx < 0.f), 0, characterCount - 1); // Page swiping to
  
  self.background.image = _characterBackgrounds[p0]; _backgroundDuplicate.image = _characterBackgrounds[p1];
  
  const float t = (n - p0) * (p1 - p0);
  self.background.alpha = 1. - t; _backgroundDuplicate.alpha = t;
}

- (IBAction) prevButtonClicked:(id)sender
{
  [self.contentScrollView scrollRectToVisible:CGRectMake((self.contentPageControl.currentPage - 1) * self.width, 0, self.width, self.height) animated:YES];
}

- (IBAction) nextButtonClicked:(id)sender
{
  [self.contentScrollView scrollRectToVisible:CGRectMake((self.contentPageControl.currentPage + 1) * self.width, 0, self.width, self.height) animated:YES];
}

- (void) skipAllClicked:(id)sender
{
  self.skipAllButton.hidden = YES;
  
  for (UIView* view in _characterStatsViews) view.hidden = NO;
  
  _skippingAnimations = YES;
  
  // Umm... not sure why this doesn't actually stop the sound effect
  if (_startedNextRevealSoundEffect) [SoundEngine stopLastPlayedEffect];
}

- (IBAction) closeClicked:(id)sender
{
  [UIView animateWithDuration:0.2f animations:^{
    self.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self removeFromSuperview];
    
    [_backgroundDuplicate removeFromSuperview]; _backgroundDuplicate = nil;
    [_lightCircleDuplicate removeFromSuperview]; _lightCircleDuplicate = nil;
    [_whiteLightCircleDuplicate removeFromSuperview]; _whiteLightCircleDuplicate = nil;
    [_characterWhite removeFromSuperview]; _characterWhite = nil;
    
    [self.lightCircle.layer removeAllAnimations];
    
    [_characterImageViews removeObject:self.character];
    [_characterImageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_characterImageViews removeAllObjects];
    _characterImageViews = nil;
    
    [_characterStatsViews removeObject:self.statsContainerView];
    [_characterStatsViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_characterStatsViews removeAllObjects];
    _characterStatsViews = nil;
    
    [_characterBackgrounds removeAllObjects];
    _characterBackgrounds = nil;
    
    self.alpha = 1.f;
  }];
}

@end

@implementation NewGachaFeaturedView

- (void) awakeFromNib {
  self.coverGradient.alpha = 0.f;
  
  if ([Globals isiPhone6Plus]) {
    self.imageContainerView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    self.imageContainerView.centerX -= 10.f;
  }
  
  self.offensiveSkill = nil;
  self.defensiveSkill = nil;
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  
  self.offensiveSkillView.origin = ccp(self.nameLabel.originX, self.attackLabel.originY + self.attackLabel.height + 5);
  self.defensiveSkillView.origin = ccpAdd(self.offensiveSkillView.origin, ccp(self.offensiveSkillView.width+8.f, 0));
  
  _leftSkillViewOrigin = self.offensiveSkillView.origin;
  _rightSkillViewOrigin = self.defensiveSkillView.origin;
  
  [Globals alignSubviewsToPixelsBoundaries:self.statsContainerView];
}

-(void)offensiveSkillTapped:(id)sender
{
  if (self.delegate && self.offensiveSkill)
  {
    UIView* parent = [self.delegate isKindOfClass:[UIViewController class]]
      ? ((UIViewController*)self.delegate).view
      : [UIApplication sharedApplication].keyWindow.rootViewController.view;
    [self.delegate skillTapped:self.offensiveSkill
                     offensive:YES
                       element:_curMonsterElement
                      position:[self.offensiveSkillView.superview convertPoint:CGPointMake(self.offensiveSkillView.centerX, self.offensiveSkillView.originY) toView:parent]];
  }
}

-(void)defensiveSkillTapped:(id)sender
{
  if (self.delegate && self.defensiveSkill)
  {
    UIView* parent = [self.delegate isKindOfClass:[UIViewController class]]
      ? ((UIViewController*)self.delegate).view
      : [UIApplication sharedApplication].keyWindow.rootViewController.view;
    [self.delegate skillTapped:self.defensiveSkill
                     offensive:NO
                       element:_curMonsterElement
                      position:[self.defensiveSkillView.superview convertPoint:CGPointMake(self.defensiveSkillView.centerX, self.defensiveSkillView.originY) toView:parent]];
  }
}

- (void) updateForMonsterId:(int)monsterId {
  if (!monsterId) {
    self.hidden = YES;
    return;
  } else {
    self.hidden = NO;
  }
  
  if (_curMonsterId == monsterId) {
    return;
  }
  
  _curMonsterId = monsterId;
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  MonsterProto *proto = [gs monsterWithId:monsterId];
  
  self.nameLabel.text = proto.displayName;
  self.rarityIcon.image = [Globals imageNamed:[@"battle" stringByAppendingString:[Globals imageNameForRarity:proto.quality suffix:@"tag.png"]]];
  
  _curMonsterElement = proto.monsterElement;
  
  NSString *fileName = [proto.imagePrefix stringByAppendingString:@"Character.png"];
  [Globals imageNamedWithiPhone6Prefix:fileName withView:self.monsterIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  UserMonster *um = [[UserMonster alloc] init];
  um.monsterId = monsterId;
  um.level = proto.maxLevel;
  um.offensiveSkillId = proto.baseOffensiveSkillId;
  um.defensiveSkillId = proto.baseDefensiveSkillId;
  self.attackLabel.text = [Globals commafyNumber:[gl calculateTotalDamageForMonster:um]];
  self.hpLabel.text = [Globals commafyNumber:[gl calculateMaxHealthForMonster:um]];
  self.speedLabel.text = [Globals commafyNumber:um.speed];
  
  [self updateSkillsForMonster:um];
}

- (void) updateSkillsForMonster:(UserMonster*)monster
{
  GameState *gs = [GameState sharedGameState];
  
  self.offensiveSkill = nil;
  self.defensiveSkill = nil;
  
  if (monster.offensiveSkillId == 0)
  {
    self.offensiveSkillView.hidden = YES;
    self.defensiveSkillView.origin = _leftSkillViewOrigin;
  }
  else
  {
    SkillProto* skillProto = [gs.staticSkills objectForKey:[NSNumber numberWithInteger:monster.offensiveSkillId]];
    if (skillProto)
    {
      [Globals imageNamed:[skillProto.imgNamePrefix stringByAppendingString:kSkillIconImageNameSuffix]
                 withView:self.offensiveSkillIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:NO];
      self.offensiveSkillView.hidden = NO;
      self.defensiveSkillView.origin = _rightSkillViewOrigin;
      self.offensiveSkill = skillProto;
    }
  }
  
  if (monster.defensiveSkillId == 0)
  {
    self.defensiveSkillView.hidden = YES;
  }
  else
  {
    SkillProto* skillProto = [gs.staticSkills objectForKey:[NSNumber numberWithInteger:monster.defensiveSkillId]];
    if (skillProto)
    {
      [Globals imageNamed:[skillProto.imgNamePrefix stringByAppendingString:kSkillIconImageNameSuffix]
                 withView:self.defensiveSkillIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:NO];
      self.defensiveSkillView.hidden = NO;
      self.defensiveSkill = skillProto;
    }
  }
}

@end

@implementation NewGachaItemCell

- (void) awakeFromNib {
  self.iconLabel.strokeSize = 1.5f;
  self.iconLabel.strokeColor = [UIColor colorWithHexString:@"ebebeb"];
  
  self.itemView.frame = self.mainView.frame;
  [self.mainView.superview addSubview:self.itemView];
}

- (void) updateForGachaDisplayItem:(BoosterDisplayItemProto *)item {
  RewardProto* reward = item.reward;
  
  self.itemView.hidden = YES;
  self.mainView.hidden = NO;
  
  NSString *iconName = nil;
  if (reward.typ == RewardProto_RewardTypeMonster) {
    
    GameState *gs = [GameState sharedGameState];
    MonsterProto *mp = [gs monsterWithId:reward.staticDataId];
    if (mp) {
      if (reward.amt > 0) { // Complete monster
        iconName = [@"gacha" stringByAppendingString:[Globals imageNameForRarity:mp.quality suffix:@"ball.png"]];
        self.shadowIcon.hidden = NO;
      } else {
        iconName = [@"gacha" stringByAppendingString:[Globals imageNameForRarity:mp.quality suffix:@"piece.png"]];
        self.shadowIcon.hidden = YES;
      }
      self.label.text = [[Globals stringForRarity:mp.quality] uppercaseString];
      self.label.textColor = [Globals colorForRarity:mp.quality];
      
      self.diamondIcon.hidden = YES;
      self.icon.hidden = NO;
    }
  } else if (reward.typ == RewardProto_RewardTypeItem) {
    
    UserItem *ui = [[UserItem alloc] init];
    ui.itemId = reward.staticDataId;
    
    [Globals imageNamed:ui.iconImageName withView:self.itemIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    self.iconLabel.text = ui.iconText;
    self.itemQuantityLabel.text = [NSString stringWithFormat:@"%dx", reward.amt];
    self.itemQuantityLabel.superview.hidden = (reward.amt <= 1);
    
    self.itemView.hidden = NO;
    self.mainView.hidden = YES;
  } else if (reward.typ == RewardProto_RewardTypeGems) {
    
    self.label.text = [Globals commafyNumber:reward.amt];
    self.label.textColor = [Globals purplishPinkColor];
    
    self.diamondIcon.hidden = NO;
    self.shadowIcon.hidden = YES;
    self.icon.hidden = YES;
  } else {
    // Other reward types unsupported
  }
  [Globals imageNamed:iconName withView:self.icon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
}

- (void) shakeIconNumTimes:(int)numTimes durationPerShake:(float)duration delay:(float)delay completion:(void (^)(void))comp {
  CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
  // Divide by 2 to account for autoreversing
  int repeatCt = numTimes;
  [animation setDuration:duration];
  [animation setRepeatCount:repeatCt];
  [animation setBeginTime:CACurrentMediaTime()+delay];
  animation.values = [NSArray arrayWithObjects:   	// i.e., Rotation values for the 3 keyframes, in RADIANS
                      [NSNumber numberWithFloat:0.0 * M_PI],
                      [NSNumber numberWithFloat:0.04 * M_PI],
                      [NSNumber numberWithFloat:-0.04 * M_PI],
                      [NSNumber numberWithFloat:0.0 * M_PI], nil];
  animation.keyTimes = [NSArray arrayWithObjects:
                        [NSNumber numberWithFloat:0],
                        [NSNumber numberWithFloat:.25],
                        [NSNumber numberWithFloat:.75],
                        [NSNumber numberWithFloat:1.0], nil];
  animation.timingFunctions = [NSArray arrayWithObjects:
                               [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                               [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                               [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], nil];
  animation.removedOnCompletion = YES;
  animation.delegate = self;
  _completion = comp;
  [self.icon.layer addAnimation:animation forKey:@"rotation"];
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  if (_completion) {
    _completion();
  }
}

@end
