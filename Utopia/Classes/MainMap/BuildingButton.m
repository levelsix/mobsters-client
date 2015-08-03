//
//  BuildingButton.m
//  Utopia
//
//  Created by Behrouz N. on 7/7/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "BuildingButton.h"
#import "Globals.h"

@implementation BuildingButton

+ (instancetype) buttonSell
{
  return [BuildingButton regularButtonWithTitle:[NSString stringWithFormat:@"Sell %@s", MONSTER_NAME] image:@"roundbuildingsell.png" config:MapBotViewButtonSell];
}

+ (instancetype) buttonBonusSlots
{
  return [BuildingButton regularButtonWithTitle:@"Bonus Slots" image:@"roundbuildingbonusslots.png" config:MapBotViewButtonBonusSlots];
}

+ (instancetype) buttonHeal
{
  return [BuildingButton regularButtonWithTitle:[NSString stringWithFormat:@"Heal %@s", MONSTER_NAME] image:@"roundbuildingheal.png" config:MapBotViewButtonHeal];
}

+ (instancetype) buttonEnhance
{
  return [BuildingButton regularButtonWithTitle:@"Enhance" image:@"roundbuildingenhance.png" config:MapBotViewButtonEnhance];
}

+ (instancetype) buttonEvolve
{
  return [BuildingButton regularButtonWithTitle:@"Evolve" image:@"roundbuildingevolve.png" config:MapBotViewButtonEvolve];
}

+ (instancetype) buttonResearch
{
  return [BuildingButton regularButtonWithTitle:@"Research" image:@"roundbuildingresearch.png" config:MapBotViewButtonResearch];
}

+ (instancetype) buttonTeam
{
  return [BuildingButton regularButtonWithTitle:@"Manage Team" image:@"roundbuildingmanage.png" config:MapBotViewButtonTeam];
}

+ (instancetype) buttonMiniJobs
{
  return [BuildingButton regularButtonWithTitle:@"Mini Jobs" image:@"roundbuildingminijobs.png" config:MapBotViewButtonMiniJob];
}

+ (instancetype) buttonInfo
{
  return [BuildingButton regularButtonWithTitle:@"Info" image:@"roundbuildinginfo.png" config:MapBotViewButtonInfo];
}

+ (instancetype) buttonJoinClan
{
  return [BuildingButton regularButtonWithTitle:@"Squads" image:@"roundbuildingsquad.png" config:MapBotViewButtonJoinClan];
}

+ (instancetype) buttonPvPBoard
{
  return [BuildingButton regularButtonWithTitle:@"Edit Board" image:@"roundbuildingeditboard.png" config:MapBotViewButtonPvpBoard];
}

+ (instancetype) buttonItemFactory
{
  return [BuildingButton regularButtonWithTitle:@"Create Items" image:@"roundbuildingcreateitems.png" config:MapBotViewButtonItemFactory];
}

+ (instancetype) buttonLeaderboard
{
  return [BuildingButton regularButtonWithTitle:@"Leaderboard" image:@"roundbuildingleaderboard.png" config:MapBotViewButtonLeaderBoard];
}

+ (instancetype) buttonClanHelp
{
  return [BuildingButton getHelpButtonWithTitle:@"Get Help!" image:@"roundbuildinggethelp.png" config:MapBotViewButtonClanHelp];
}

+ (instancetype) buttonRemoveWithResourceType:(ResourceType)resource cost:(int)cost
{
  return [[BuildingButton regularButtonWithTitle:@"Remove" image:@"roundbuildingremove.png" config:MapBotViewButtonRemove] addResourceCostLabel:resource cost:[Globals commafyNumber:cost]];
}

+ (instancetype) buttonUpgradeWithResourceType:(ResourceType)resource cost:(int)cost
{
  return [[BuildingButton regularButtonWithTitle:@"Upgrade" image:@"roundbuildingupgrade.png" config:MapBotViewButtonUpgrade] addResourceCostLabel:resource cost:[Globals commafyNumber:cost]];
}

+ (instancetype) buttonFixWithResourceType:(ResourceType)resource cost:(int)cost
{
  return [[BuildingButton regularButtonWithTitle:@"Fix" image:@"roundbuildingfix.png" config:MapBotViewButtonFix] addResourceCostLabel:resource cost:[Globals commafyNumber:cost]];
}

+ (instancetype) buttonFixWithIAPString:(NSString*)cost
{
  return [[BuildingButton regularButtonWithTitle:@"Renew" image:@"roundbuildingfix.png" config:MapBotViewButtonFix] addResourceCostLabel:ResourceTypeNoResource cost:cost];
}

+ (instancetype) buttonSpeedup:(BOOL)free
{
  return [BuildingButton speedupButtonWithTitle:@"Speed Up!" image:free ? @"roundbuildingfree.png" : @"roundbuildingspeedupicon.png" config:MapBotViewButtonSpeedup];
}

+ (instancetype) regularButtonWithTitle:(NSString*)title image:(NSString*)image config:(MapBotViewButtonConfig)config
{
  return [[BuildingButton alloc] initWithBackground:@"roundbuildingbutton.png" highlighted:@"roundbuildingbuttonpressed.png" title:title image:image config:config];
}

+ (instancetype) getHelpButtonWithTitle:(NSString*)title image:(NSString*)image config:(MapBotViewButtonConfig)config
{
  return [[BuildingButton alloc] initWithBackground:@"roundbuildinggethelpbutton.png" highlighted:@"roundbuildinggethelpbuttonpressed.png" title:title image:image config:config];
}

+ (instancetype) speedupButtonWithTitle:(NSString*)title image:(NSString*)image config:(MapBotViewButtonConfig)config
{
  return [[BuildingButton alloc] initWithBackground:@"roundbuildingbuttonspeedup.png" highlighted:@"roundbuildingbuttonspeeduppressed.png" title:title image:image config:config];
}

- (instancetype) initWithBackground:(NSString*)background highlighted:(NSString*)highlighted title:(NSString*)title image:(NSString*)image config:(MapBotViewButtonConfig)config
{
  if (self = [super initWithTitle:nil
                      spriteFrame:[CCSpriteFrame frameWithImageNamed:background]
           highlightedSpriteFrame:[CCSpriteFrame frameWithImageNamed:highlighted]
              disabledSpriteFrame:nil])
  {
    _buttonConfig = config;
    
    CCSprite* buttonImage = [CCSprite spriteWithImageNamed:image];
    buttonImage.position = ccp(self.contentSize.width * .5f, self.contentSize.height * .5f + 8.f);
    
    CCLabelTTF* label = [BuildingButton styledLabelWithString:title fontSize:18.f];
    label.anchorPoint = ccp(.5f, 1.f);
    label.position = ccp(self.contentSize.width * .5f, 16.f);
    label.dimensions = CGSizeMake(140.f, 140.f);
    
    [self addChild:buttonImage];
    [self addChild:label];
    
    return self;
  }
  return nil;
}

- (instancetype) addResourceCostLabel:(ResourceType)resource cost:(NSString*)cost
{
  CCLabelTTF* label = [BuildingButton styledLabelWithString:cost fontSize:16.f];
  label.position = ccp(self.contentSize.width * .5f, self.contentSize.height);
  
  CCSprite* icon = nil;
  switch (resource)
  {
    case ResourceTypeCash:
      icon = [CCSprite spriteWithImageNamed:@"moneystack.png"];
      break;
    case ResourceTypeOil:
      icon = [CCSprite spriteWithImageNamed:@"oilicon.png"];
      break;
      
    default:
      break;
  }
  
  if (icon)
  {
    icon.anchorPoint = ccp(1.f, .5f);
    icon.position = ccp(label.position.x - label.contentSize.width * .5f - 4.f, label.position.y);
    icon.scale = .8f;
    
    // Shift things over horizontally so the label and icon are center-aligned with the button
    const float xOffset = (icon.contentSize.width * icon.scale + 4.f) * .5f;
    label.position = ccpAdd(label.position, ccp(xOffset, 0.f));
    icon.position = ccpAdd(icon.position, ccp(xOffset, 0.f));
  }
  
  [self addChild:label];
  [self addChild:icon];
  
  return self;
}

#pragma mark - Arrows

- (void) displayArrow:(ArrowPlacement)placement
{
  [self removeArrow];
  
  CCSprite* arrow = [CCSprite spriteWithImageNamed:@"arrow.png"];
  arrow.name = @"AnimatedArrow";
  
  float scale = 1.f / self.parent.scale;
  
  arrow.scale = scale;

  float angle = 0.f;
  switch (placement)
  {
    case ArrowPlacementTop:
      arrow.anchorPoint = ccp(.5f, 0.f);
      arrow.position = ccp(self.contentSize.width * .5f, self.contentSize.height);
      angle = -M_PI_2;
      break;
    case ArrowPlacementRight:
      arrow.anchorPoint = ccp(0.f, .5f);
      arrow.position = ccp(self.contentSize.width + 15.f * scale, self.contentSize.height * .5f + 40.f * scale);
      angle = -M_PI;
      break;
    case ArrowPlacementBottom:
      arrow.anchorPoint = ccp(.5f, 1.f);
      arrow.position = ccp(self.contentSize.width * .5f, -40.f * scale);
      angle = -M_PI - M_PI_2;
      break;
    case ArrowPlacementLeft:
      arrow.anchorPoint = ccp(1.f, .5f);
      arrow.position = ccp(-15.f * scale, (self.contentSize.height * .5f + 40.f * scale));
      angle = -M_PI * 2;
      break;
      
    default:
      return;
  }
  
  
  
  [self addChild:arrow];
  [arrow runAction:[CCActionFadeIn actionWithDuration:.5f]];
  [Globals animateCCArrow:arrow atAngle:angle pulseAlpha:NO];
}

- (void) removeArrow
{
  CCNode* arrow = [self getChildByName:@"AnimatedArrow" recursively:NO];
  if (arrow)
  {
    [arrow runAction:[CCActionSequence actions:[CCActionFadeOut actionWithDuration:.5f], [CCActionRemove action], nil]];
  }
}

#pragma mark - Helpers

+ (CCLabelTTF*) styledLabelWithString:(NSString*)string fontSize:(CGFloat)size
{
  CCLabelTTF* label = [CCLabelTTF labelWithString:string fontName:@"Ziggurat-HTF-Black" fontSize:size];
  label.horizontalAlignment = CCTextAlignmentCenter;
  label.verticalAlignment = CCVerticalTextAlignmentTop;
  label.fontColor = [CCColor whiteColor];
  label.outlineColor = [CCColor colorWithWhite:.2f alpha:1.f];
  label.outlineWidth = 1.5f;
  label.shadowColor = [CCColor colorWithWhite:.2f alpha:.75];
  label.shadowOffset = ccp(0.f, -2.f);
  label.shadowBlurRadius = 1.5f;
  
  return label;
}

@end
