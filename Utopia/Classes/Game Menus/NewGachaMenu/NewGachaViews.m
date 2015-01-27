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

static const CGFloat kRevealAnimDuration = 1.f; // Seconds
static const CGFloat kRevealAnimFrames = 20.f;  // Frames

static const CGFloat kStatsScaleAnimStartingScale = 8.f;
static const CGFloat kStatsScaleAnimDuration = .4f;   // Seconds
static const CGFloat kScreenShakeAnimDuration = .4f;  // Seconds
static const int kScreenShakeAnimOffsetRange = 15.f;  // Pixels

static const CGFloat kPFXFadeInAnimDuration = 1.f;    // Seconds
static const CGFloat kLightPulseAnimDuration = 1.f;   // Seconds
static const CGFloat kCloseButtonFadeInAnimDelay = 1.f;     // Seconds
static const CGFloat kCloseButtonFadeInAnimDuration = .5f;  // Seconds
static const CGFloat kCloseButtonTargetOpacity = .5f;

#define REVEAL_KEYFRAME_ANIMATION(__anim__, __key__) \
  CAKeyframeAnimation *__anim__ = [CAKeyframeAnimation animationWithKeyPath:__key__]; { \
  [__anim__ setDuration:kRevealAnimDuration]; \
  [__anim__ setCalculationMode:kCAAnimationLinear]; \
  [__anim__ setDelegate:self]; \
}

typedef void (^RevealAnimCompletionBlock)(void);
#define REVEAL_ANIM_COMPLETION_BLOCK_KEY @"RevealAnimCompletionBlock"

@implementation NewGachaPrizeView

- (void) awakeFromNib
{
  if ([Globals isiPhone6] || [Globals isiPhone6Plus])
  {
    // We good
  }
  else if ([Globals isSmallestiPhone])
  {
    const CGFloat heightToWidth = ([Globals screenSize].height / 375.f) / ([Globals screenSize].width / 667.f);
    for (UIView* subview in self.animationContainerView.subviews)
      subview.frame = CGRectMake(subview.originX * heightToWidth, subview.originY, subview.width * heightToWidth, subview.height);
    
    self.statsContainerView.originX += 110.f;
    self.nameLabel.width -= 30.f;
  }
  else
    self.statsContainerView.originX += 30.f;
  
  self.statsContainerView.layer.anchorPoint = CGPointMake(.25f, .5f);
  self.statsContainerView.originX -= self.statsContainerView.width * .25f;
  
  /*
  // Preload element-specific images
  for (Element element = ElementFire; element < ElementRock; ++element)
  {
    const NSString* elementStr = [[Globals stringForElement:element] lowercaseString];
    [Globals imageNamed:[elementStr stringByAppendingString:@"grbackground.png"]];
    [Globals imageNamed:[elementStr stringByAppendingString:@"grbigflash1.png"]];
    [Globals imageNamed:[elementStr stringByAppendingString:@"grglow2glowblend.png"]];
    [Globals imageNamed:[elementStr stringByAppendingString:@"grlightsflashlow1.png"]];
  }
   */
  
  const CGFloat deviceScale = [Globals screenSize].width / 667.f;
  UIEffectDesignerView* effectView = [UIEffectDesignerView effectWithFile:@"NewGachaSmoke.ped"];
  [effectView setFrame:CGRectMake(140.f * deviceScale, 250.f * deviceScale, 100.f * deviceScale, 20.f * deviceScale)];
  [effectView.emitter setEmitterSize:CGSizeMake(effectView.width, effectView.height)];
  [effectView.emitter setEmitterPosition:CGPointMake(effectView.emitter.emitterPosition.x - effectView.width * .5f, effectView.emitter.emitterPosition.y)];
  [self insertSubview:effectView belowSubview:self.closeButton];
  _particleEffectView = effectView;
}

- (void) preloadWithMonsterId:(int)monsterId
{
  GameState *gs = [GameState sharedGameState];
  MonsterProto *proto = [gs monsterWithId:monsterId];
  
  [Globals imageNamedWithiPhone6Prefix:[proto.imagePrefix stringByAppendingString:@"Character.png"]
                              withView:self.character
                           maskedColor:nil
                             indicator:UIActivityIndicatorViewStyleWhite
              clearImageDuringDownload:YES];
  
  const NSString* elementStr = [[Globals stringForElement:proto.monsterElement] lowercaseString];
  {
    self.background.image = [Globals imageNamed:[elementStr stringByAppendingString:@"grbackground.png"]];
    self.elementbigFlash.image = [Globals imageNamed:[elementStr stringByAppendingString:@"grbigflash1.png"]];
    self.elementGlow.image = [Globals imageNamed:[elementStr stringByAppendingString:@"grglow2glowblend.png"]];
    self.elementLightsFlash.image = [Globals imageNamed:[elementStr stringByAppendingString:@"grlightsflashlow1.png"]];
  }
}

- (void) initializeWithMonsterId:(int)monsterId numPuzzlePieces:(int)numPuzzlePieces
{
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  MonsterProto *proto = [gs monsterWithId:monsterId];
  
  self.statsContainerView.hidden = YES;
  self.closeButton.hidden = YES;
  _particleEffectView.hidden = YES;
  
  self.nameLabel.text = proto.displayName;
  self.rarityIcon.image = [Globals imageNamed:[@"battle" stringByAppendingString:[Globals imageNameForRarity:proto.quality suffix:@"tag.png"]]];
  
  THLabel* label = (THLabel*)self.nameLabel;
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
  
  CGFloat offset = self.rarityIcon.width - self.rarityIcon.image.size.width;
  self.rarityIcon.width -= offset;
  self.pieceSeparator.originX -= offset;
  self.pieceIcon.originX -= offset;
  self.pieceLabel.originX -= offset;
  
  UserMonster *um = [[UserMonster alloc] init];
  um.monsterId = monsterId;
  um.level = proto.maxLevel;
  um.offensiveSkillId = proto.baseOffensiveSkillId;
  um.defensiveSkillId = proto.baseDefensiveSkillId;
  self.attackLabel.text = [Globals commafyNumber:[gl calculateTotalDamageForMonster:um]];
  self.hpLabel.text = [Globals commafyNumber:[gl calculateMaxHealthForMonster:um]];
  self.speedLabel.text = [Globals commafyNumber:um.speed];
  self.powerLabel.text = [Globals commafyNumber:um.teamCost];
  
  [self updateSkillsForMonster:um];
  [Globals alignSubviewsToPixelsBoundaries:self.statsContainerView];

  if (numPuzzlePieces > 0)
  {
    [Globals imageNamed:[@"gacha" stringByAppendingString:[Globals imageNameForRarity:proto.quality suffix:@"piece.png"]]
               withView:self.pieceIcon
            maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    self.pieceLabel.text = [NSString stringWithFormat:@"1 PIECE (%d/%d)", numPuzzlePieces, proto.numPuzzlePieces];
  }
  
  self.pieceSeparator.hidden = !(numPuzzlePieces > 0);
  self.pieceIcon.hidden = !(numPuzzlePieces > 0);
  self.pieceLabel.hidden = !(numPuzzlePieces > 0);
  
  [self.characterShadow.layer setOpacity:0.f];
  [self.character.layer setOpacity:0.f];
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
  
  _lightCircleDuplicate = [[UIImageView alloc] initWithFrame:self.lightCircle.frame];
  {
    [_lightCircleDuplicate setImage:self.lightCircle.image];
    [_lightCircleDuplicate setContentMode:self.lightCircle.contentMode];
    [self insertSubview:_lightCircleDuplicate aboveSubview:self.whiteLightCircle];
    [_lightCircleDuplicate.layer setOpacity:0.f];
  }
  _whiteLightCircleDuplicate = [[UIImageView alloc] initWithFrame:self.whiteLightCircle.frame];
  {
    [_whiteLightCircleDuplicate setImage:self.whiteLightCircle.image];
    [_whiteLightCircleDuplicate setContentMode:self.whiteLightCircle.contentMode];
    [self insertSubview:_whiteLightCircleDuplicate aboveSubview:_lightCircleDuplicate];
    [_whiteLightCircleDuplicate.layer setOpacity:0.f];
  }
  _characterWhite = [[UIImageView alloc] initWithFrame:self.character.frame];
  {
    [_characterWhite setImage:[Globals maskImage:self.character.image withColor:[UIColor whiteColor]]];
    [_characterWhite setContentMode:self.character.contentMode];
    [self insertSubview:_characterWhite aboveSubview:self.elementLightsFlash];
    [_characterWhite.layer setOpacity:0.f];
  }
}

- (void) beginAnimation
{
  REVEAL_KEYFRAME_ANIMATION(anim1, @"opacity")
    [anim1 setKeyTimes:@[ @0.f, @(6.f / kRevealAnimFrames), @(13.f / kRevealAnimFrames), @1.0f ]];
    [anim1 setValues:@[ @0.f, @0.f, @1.f, @1.f ]];
    [anim1 setValue:^(void) { [self.characterShadow.layer setOpacity:1.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [self.characterShadow.layer addAnimation:anim1 forKey:@"CharacterShadowFadeInAnimation"];
    [self.characterShadow.layer setOpacity:1.f];
  
  REVEAL_KEYFRAME_ANIMATION(anim2, @"opacity")
    [anim2 setKeyTimes:@[ @0.f, @(8.f / kRevealAnimFrames), @(9.f / kRevealAnimFrames), @1.0f ]];
    [anim2 setValues:@[ @0.f, @0.f, @1.f, @1.f ]];
    [anim2 setValue:^(void) { [self.character.layer setOpacity:1.f]; } forKey:REVEAL_ANIM_COMPLETION_BLOCK_KEY];
    [self.character.layer addAnimation:anim2 forKey:@"CharacterFadeInAnimation"];
    [self.character.layer setOpacity:1.f];
  
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
  
  self.statsContainerView.hidden = NO;
  self.statsContainerView.alpha = 0.f;
  self.statsContainerView.transform = CGAffineTransformMakeScale(kStatsScaleAnimStartingScale, kStatsScaleAnimStartingScale);
  
  [UIView animateWithDuration:kStatsScaleAnimDuration delay:kRevealAnimDuration options:UIViewAnimationOptionCurveEaseIn animations:^{
    self.statsContainerView.alpha = 1.f;
    self.statsContainerView.transform = CGAffineTransformMakeScale(1.f, 1.f);
  } completion:^(BOOL finished) {
    [self shakeViews:@[ self.statsContainerView, self.animationContainerView ] withKey:@"ContainerViewsShakeAnimation" completion:^{
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
    }];
  }];
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

- (void) updateSkillsForMonster:(UserMonster*)monster
{
  GameState *gs = [GameState sharedGameState];
  
  if (monster.offensiveSkillId == 0)
  {
    self.offensiveSkillView.hidden = YES;
    self.defensiveSkillView.originY = self.offensiveSkillView.originY;
  }
  else
  {
    SkillProto* skillProto = [gs.staticSkills objectForKey:[NSNumber numberWithInteger:monster.offensiveSkillId]];
    if (skillProto)
    {
      [Globals imageNamed:[skillProto.imgNamePrefix stringByAppendingString:kSkillIconImageNameSuffix]
                 withView:self.offensiveSkillIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:NO];
      self.offensiveSkillName.text = skillProto.name;
      self.offensiveSkillView.hidden = NO;
      self.defensiveSkillView.originY = CGRectGetMaxY(self.offensiveSkillView.frame) + 8.f;
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
      self.defensiveSkillName.text = skillProto.name;
      self.defensiveSkillView.hidden = NO;
    }
  }
  
  if (self.offensiveSkillView.hidden &&
      self.defensiveSkillView.hidden)
  {
    self.skillsSeparator.hidden = YES;
    self.statsContainerView.height = CGRectGetMaxY(self.powerLabel.frame) + 8.f;
  }
  else
  {
    self.skillsSeparator.hidden = NO;
    self.statsContainerView.height = CGRectGetMaxY(self.defensiveSkillView.frame) + 8.f;
  }
  
  self.statsContainerView.centerY = self.height * .5f;
}

- (IBAction) closeClicked:(id)sender {
  [UIView animateWithDuration:0.2f animations:^{
    self.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self removeFromSuperview];
    
    [_lightCircleDuplicate removeFromSuperview]; _lightCircleDuplicate = nil;
    [_whiteLightCircleDuplicate removeFromSuperview]; _whiteLightCircleDuplicate = nil;
    [_characterWhite removeFromSuperview]; _characterWhite = nil;
    
    [self.lightCircle.layer removeAllAnimations];
    
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
  
  /*
  UIView *container = self.monsterIcon.superview;
  container.centerX = self.hpLabel.superview.originX/2+10;
  
  if ([Globals isiPhone6Plus]) {
    container.transform = CGAffineTransformMakeScale(1.2, 1.2);
    container.centerY -= 20.f;
  }
   */
  
  self.offensiveSkill = nil;
  self.defensiveSkill = nil;
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  
  self.offensiveSkillView.origin = CGPointMake(self.nameLabel.originX, self.attackLabel.originY + self.attackLabel.height + 5);
  self.defensiveSkillView.origin = self.offensiveSkillView.origin;
  
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
  /*
  self.icon.layer.anchorPoint = ccp(0.5, 0.75);
  self.icon.center = ccpAdd(self.icon.center, ccp(0, self.icon.frame.size.height*(self.icon.layer.anchorPoint.y-0.5)));
   */
}

- (void) updateForGachaDisplayItem:(BoosterDisplayItemProto *)item {
  NSString *iconName = nil;
  if (item.isMonster) {
    //NSString *bgdImage = [@"gacha" stringByAppendingString:[Globals imageNameForRarity:item.quality suffix:@"bg.png"]];
    //[Globals imageNamed:bgdImage withView:self.bgdView greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    if (item.isComplete) {
      iconName = [@"gacha" stringByAppendingString:[Globals imageNameForRarity:item.quality suffix:@"ball.png"]];
      self.shadowIcon.hidden = NO;
    } else {
      iconName = [@"gacha" stringByAppendingString:[Globals imageNameForRarity:item.quality suffix:@"piece.png"]];
      self.shadowIcon.hidden = YES;
    }
    self.label.text = [[Globals stringForRarity:item.quality] uppercaseString];
    self.label.textColor = [Globals colorForRarity:item.quality];
    
    self.diamondIcon.hidden = YES;
    self.icon.hidden = NO;
  } else {
    //NSString *bgdImage = @"gachagemsbg.png";
    //[Globals imageNamed:bgdImage withView:self.bgdView greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    self.label.text = [Globals commafyNumber:item.gemReward];
    self.label.textColor = [Globals purplishPinkColor];
    
    self.diamondIcon.hidden = NO;
    self.shadowIcon.hidden = YES;
    self.icon.hidden = YES;
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
