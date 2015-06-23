//
//  MonsterPopUpViewController.m
//  Utopia
//
//  Created by Danny on 10/11/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "MonsterPopUpViewController.h"
#import "Globals.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "QuestUtil.h"
#import "GenericPopupController.h"
#import "SkillController.h"
#import "ResearchController.h"
#import "SkillProtoHelper.h"

#define LOCK_MOBSTER_DEFAULTS_KEY @"LockMobsterConfirmation"

NSMutableAttributedString *attributedStringWithResearch(ResearchProto *res, BOOL isActive, UIFont *font) {
  NSString *str1 = res.name;
  NSString *str2 = [NSString stringWithFormat:@" R%d", isActive ? res.level : 0];
  
  NSString *totalStr = [NSString stringWithFormat:@"%@%@", str1, str2];
  
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
  [paragraphStyle setLineSpacing:4];
  
  NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:totalStr attributes:@{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName:font}];
  
  if (isActive) {
    [attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:51/255.f alpha:1.f] range:NSMakeRange(0, str1.length)];
    [attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"457D0D"] range:NSMakeRange(str1.length, str2.length)];
  } else {
    [attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:135/255.f alpha:1.f] range:NSMakeRange(0, totalStr.length)];
  }
  
  return attr;
}

NSMutableAttributedString *attributedStringWithResearchBenefit(ResearchProto *res, UIFont *font) {
  ResearchController *rc = [ResearchController researchControllerWithProto:res];
  NSString *totalStr = [NSString stringWithFormat:@"%@: %@", rc.benefitName, rc.benefitString];
  
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  [paragraphStyle setLineSpacing:4];
  
  NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:totalStr attributes:@{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName:font}];
  
  return attr;
}

NSMutableAttributedString *attributedStringWithResearchChange(int total, int base) {
  NSString *str1 = [NSString stringWithFormat:@"%@", [Globals commafyNumber:total]];
  NSString *str2 = @"", *str3 = @"", *str4 = @"";
  
  if (total != base) {
    str2 = [NSString stringWithFormat:@" (%@ ", [Globals commafyNumber:base]];
    str3 = [NSString stringWithFormat:@"+ %@", [Globals commafyNumber:total-base]];
    str4 = @")";
  }
  
  NSString *totalStr = [NSString stringWithFormat:@"%@%@%@%@", str1, str2, str3, str4];
  NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:totalStr];
  
  [attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"457D0D"] range:NSMakeRange(str1.length+str2.length, str3.length)];
  
  return attr;
}

@implementation MonsterPopUpResearchView

- (void) updateForActiveResearch:(ResearchProto *)rp {
  [Globals imageNamed:rp.iconImgName withView:self.researchIcon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  self.topLabel.attributedText = attributedStringWithResearch(rp, YES, self.topLabel.font);
  
  // For some reason having foreground color makes the 1 liner labels have extra height so ask for attr string in inactive state so there's no color
  CGRect rect = [attributedStringWithResearch(rp, NO, self.topLabel.font) boundingRectWithSize:CGSizeMake(self.topLabel.width, 9999) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
  self.topLabel.height = ceilf(rect.size.height);
  
  self.botLabel.attributedText = attributedStringWithResearchBenefit(rp, self.botLabel.font);
  
  rect = [self.botLabel.attributedText boundingRectWithSize:CGSizeMake(self.botLabel.width, 9999) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
  self.botLabel.originY = CGRectGetMaxY(self.topLabel.frame)+7.f;
  self.botLabel.height = ceilf(rect.size.height);
  
  self.height = CGRectGetMaxY(self.botLabel.frame)+11.f;
}


- (void) updateForNonActiveResearch:(ResearchProto *)rp {
  [Globals imageNamed:rp.iconImgName withView:self.researchIcon greyscale:YES indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
  
  self.botLabel.hidden = YES;
  
  self.topLabel.attributedText = attributedStringWithResearch(rp, NO, self.topLabel.font);
  
  CGRect rect = [self.topLabel.attributedText boundingRectWithSize:CGSizeMake(self.topLabel.width, 9999) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
  self.topLabel.height = ceilf(rect.size.height);
  
  self.height = CGRectGetMaxY(self.topLabel.frame)+([Globals isiPad]?19.f:11.f);
}

@end

@implementation ElementDisplayView

- (void) updateStatsWithElementType:(Element)element damage:(int)damage baseDmage:(int)baseDamage {
  NSString *name = [Globals imageNameForElement:element suffix:@"orb.png"];
  [Globals imageNamed:name withView:self.elementIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  self.elementLabel.text = [Globals stringForElement:element];
  self.elementLabel.textColor = [Globals colorForElementOnLightBackground:element];
  
  self.statLabel.attributedText = attributedStringWithResearchChange(damage, baseDamage);
}

@end

@implementation MonsterPopUpViewController

- (id)initWithMonsterProto:(UserMonster *)monster {
  if ((self = [super init])) {
    self.monster = monster;
  }
  return self;
}

- (id)initWithMonsterProto:(UserMonster *)monster allowSell:(BOOL)allowSell {
  if ((self = [self initWithMonsterProto:monster])) {
    _allowSell = allowSell;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.backButtonView.hidden = YES;
  
  self.mainView.layer.cornerRadius = POPUP_CORNER_RADIUS;
  self.container.layer.cornerRadius = POPUP_CORNER_RADIUS;
  self.bottomBgView.layer.cornerRadius = POPUP_CORNER_RADIUS;
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if ([Globals isiPhone6] || [Globals isiPhone6Plus]) {
    float aspectRatio = self.mainView.width/self.mainView.height;
    float newHeight = 339.f;//self.view.height-36.f; // Keep the 6+ same size as 6
    self.mainView.size = CGSizeMake(roundf(newHeight*aspectRatio), newHeight);
    self.mainView.center = ccp(self.view.width/2, self.view.height/2);
    
    // Adjust the view so that
    self.researchInfoView.frame = self.descriptionView.frame;
  }
  
  [self updateMonster];
}

- (void) updateMonster {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserMonster *um = self.monster;
  MonsterProto *mp = [gs monsterWithId:um.monsterId];
  self.monsterNameLabel.text = [NSString stringWithFormat:@"%@ (L%d/%d)", mp.monsterName, um.level, mp.maxLevel];
  self.enhanceLabel.text = [NSString stringWithFormat:@"%d  (Max. %d)", um.level, mp.maxLevel];
  [self updateSkillData:YES];
  
  self.rarityTag.image = [Globals imageNamed:[@"battle" stringByAppendingString:[Globals imageNameForRarity:mp.quality suffix:@"tag.png"]]];
  
  self.buttonsContainer.hidden = ![um.userUuid isEqualToString:gs.userUuid];
  self.avatarButton.enabled = um.monsterId != gs.avatarMonsterId;
  [self updateProtectedButton];
  
  int atk = [gl calculateTotalDamageForMonster:um];
  int baseAtk = [gl calculateBaseTotalDamageForMonster:um];
  self.attackLabel.attributedText = attributedStringWithResearchChange(atk, baseAtk);
  
  int speed = [gl calculateSpeedForMonster:um];
  int baseSpeed = [gl calculateBaseSpeedForMonster:um];
  self.speedLabel.attributedText = attributedStringWithResearchChange(speed, baseSpeed);
  
  int maxHealth = [gl calculateMaxHealthForMonster:um];
  int baseHealth = [gl calculateBaseMaxHealthForMonster:um];
  self.hpLabel.attributedText = attributedStringWithResearchChange(maxHealth, baseHealth);
  
  self.strengthLabel.text = [Globals commafyNumber:[gl calculateStrengthForMonster:um]];
  
  self.progressBar.percentage = ((float)um.curHealth)/maxHealth;
  
  self.powerLabel.text = [NSString stringWithFormat:@"%@ Power", [Globals commafyNumber:[um teamCost]]];
  self.powerLabel.superview.originX = self.rarityTag.originX+self.rarityTag.image.size.width+2.f;
  
  // Individual Elements
  NSDictionary *dict = @{@(ElementFire):self.fireView,
                         @(ElementWater):self.waterView,
                         @(ElementEarth):self.earthView,
                         @(ElementLight):self.lightView,
                         @(ElementDark):self.nightView,
                         @(ElementRock):self.rockView };
  
  for (Element elem = ElementFire; elem <= ElementRock; elem++) {
    ElementDisplayView *elemView = dict[@(elem)];
    
    int dmg = [gl calculateElementalDamageForMonster:um element:elem];
    int baseDmg = [gl calculateBaseElementalDamageForMonster:um element:elem];
    
    [elemView updateStatsWithElementType:elem damage:dmg baseDmage:baseDmg];
  }
  
  self.elementLabel.text = [Globals stringForElement:mp.monsterElement];
  self.elementLabel.textColor = [Globals colorForElementOnLightBackground:mp.monsterElement];
  
  NSString *fileName = [mp.imagePrefix stringByAppendingString:@"Character.png"];
  [Globals imageNamed:fileName withView:self.monsterImageView maskedColor:nil greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES useiPhone6Prefix:YES useiPadSuffix:YES];
  
  self.elementType.image = [Globals imageNamed:[Globals imageNameForElement:mp.monsterElement suffix:@"orb.png"]];
  [Globals adjustViewForCentering:self.monsterNameLabel.superview withLabel:self.monsterNameLabel];
  
  [self updateResearchScrollView];
}

- (void) updateResearchScrollView {
  MonsterProto *mp = self.monster.staticMonster;
  ResearchUtil *ru = self.monster.researchUtil;
  
  NSArray *userResearches = [ru allUserResearchesForElement:mp.monsterElement evoTier:mp.evolutionLevel];
  NSMutableArray *staticResearches = [[ru allResearchProtosForElement:mp.monsterElement evoTier:mp.evolutionLevel] mutableCopy];
  
  self.noResearchLabel.hidden = userResearches.count > 0;
  
  float maxX = 0;
  for (UserResearch *ur in userResearches) {
    ResearchProto *rp = ur.staticResearchForBenefitLevel;
    
    UIImageView *iv = [[UIImageView alloc] init];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    iv.size = CGSizeMake(25, 25);
    iv.centerY = self.researchScrollView.height/2;
    iv.originX = maxX ;
    
    [self.researchScrollView addSubview:iv];
    
    [Globals imageNamed:rp.iconImgName withView:iv greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
    
    maxX = iv.originX+iv.width;
  }
  
  self.researchScrollView.contentSize = CGSizeMake(maxX, self.researchScrollView.height);
  
  // Update the research info view
  float maxY = 20.f;
  MonsterPopUpResearchView *lastRv = nil;
  for (UserResearch *ur in userResearches) {
    ResearchProto *rp = ur.staticResearch;
    
    MonsterPopUpResearchView *rv = [[NSBundle mainBundle] loadNibNamed:@"MonsterPopUpResearchView" owner:self options:nil][0];
    rv.width = self.researchInfoView.width;
    rv.originY = maxY;
    
    [rv updateForActiveResearch:rp];
    
    maxY += rv.height;
    
    [self.researchInfoScrollView addSubview:rv];
    
    lastRv = rv;
    
    [staticResearches removeObject:[rp minLevelResearch]];
  }
  
  for (ResearchProto *rp in staticResearches) {
    MonsterPopUpResearchView *rv = [[NSBundle mainBundle] loadNibNamed:@"MonsterPopUpResearchView" owner:self options:nil][0];
    rv.width = self.researchInfoView.width;
    rv.originY = maxY;
    
    [rv updateForNonActiveResearch:rp];
    
    maxY += rv.height;
    
    [self.researchInfoScrollView addSubview:rv];
    
    lastRv = rv;
  }
  
  lastRv.dividerLine.hidden = YES;
  self.researchInfoScrollView.contentSize = CGSizeMake(self.researchInfoScrollView.width, maxY);
}

- (void) updateSkillData:(BOOL)offensive
{
  GameState *gs = [GameState sharedGameState];
  
  // No skills
  if (self.monster.offensiveSkillId == 0 && self.monster.defensiveSkillId == 0)
  {
    self.skillView.hidden = YES;
    self.skillView.userInteractionEnabled = NO;
    [self setDescriptionLabelString:[NSString stringWithFormat:@"This %@ does not have an offensive or defensive skill.", MONSTER_NAME]];
    return;
  }
  
  if (! self.monster.offensiveSkillId)
  {
    self.offensiveSkillArrow.hidden = YES;
    offensive = NO;
  }
  if (! self.monster.defensiveSkillId)
  {
    self.defensiveSkillArrow.hidden = YES;
    offensive = YES;
  }
  
  // Offensive
  if (self.monster.offensiveSkillId != 0)
  {
    SkillProto* skillProto = [gs.staticSkills objectForKey:[NSNumber numberWithInteger:self.monster.offensiveSkillId]];
    if (skillProto)
    {
      [Globals imageNamed:[skillProto.imgNamePrefix stringByAppendingString:kSkillIconImageNameSuffix]
                 withView:self.offensiveSkillIcon greyscale:!offensive indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:NO];
      self.offensiveSkillIcon.hidden = NO;
      self.offensiveSkillName.text = skillProto.name;
      if (offensive)
      {
        [self setDescriptionLabelString:[SkillProtoHelper offDescForSkill:skillProto]];
        self.offensiveSkillName.textColor = [UIColor colorWithHexString:@"1a85e3"];
      }
      else
        self.offensiveSkillName.textColor = self.offensiveSkillType.textColor;
    }
    
    if (offensive)
    {
      self.offensiveSkillArrow.hidden = NO;
      self.offensiveSkillBg.image = [Globals imageNamed:@"activeskill.png"];
    }
    else
    {
      self.offensiveSkillArrow.hidden = YES;
      self.offensiveSkillBg.image = [Globals imageNamed:@"inactiveskill.png"];
    }
  }
  
  // Defensive
  if (self.monster.defensiveSkillId != 0)
  {
    SkillProto* skillProto = [gs.staticSkills objectForKey:[NSNumber numberWithInteger:self.monster.defensiveSkillId]];
    if (skillProto)
    {
      [Globals imageNamed:[skillProto.imgNamePrefix stringByAppendingString:kSkillIconImageNameSuffix]
                 withView:self.defensiveSkillIcon greyscale:offensive indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:NO];
      self.defensiveSkillIcon.hidden = NO;
      self.defensiveSkillName.text = skillProto.name;
      if (! offensive)
      {
        [self setDescriptionLabelString:[SkillProtoHelper defDescForSkill:skillProto]];
        self.defensiveSkillName.textColor = [UIColor colorWithHexString:@"1a85e3"];
      }
      else
        self.defensiveSkillName.textColor = self.defensiveSkillType.textColor;
    }
    
    if (! offensive)
    {
      self.defensiveSkillArrow.hidden = NO;
      self.defensiveSkillBg.image = [Globals imageNamed:@"activeskill.png"];
    }
    else
    {
      self.defensiveSkillArrow.hidden = YES;
      self.defensiveSkillBg.image = [Globals imageNamed:@"inactiveskill.png"];
    }
  }
}

- (void) updateProtectedButton {
  [self.protectedButton setImage:[Globals imageNamed:(self.monster.isProtected ? @"lockedactive.png" : @"lockedinactive.png")] forState:UIControlStateNormal];
}

- (void) setDescriptionLabelString:(NSString *)labelText {
  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  [paragraphStyle setLineSpacing:3];
  [paragraphStyle setAlignment:NSTextAlignmentCenter];
  [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
  self.monsterDescription.attributedText = attributedString;
}

static int descriptionWidthChange = 50;

- (void) pushContentView:(UIView *)contentView labelText:(NSString *)labelText {
  [self.container addSubview:contentView];
  contentView.frame = self.descriptionView.frame;
  contentView.center = CGPointMake(self.descriptionView.center.x+contentView.frame.size.height, self.descriptionView.center.y);
  self.backButtonView.hidden = NO;
  
  CGPoint mainViewCenter = self.descriptionView.center;
  [UIView animateWithDuration:0.3f animations:^{
    self.descriptionView.center = CGPointMake(self.descriptionView.center.x-self.descriptionView.frame.size.width, self.descriptionView.center.y);
    contentView.center = mainViewCenter;
    self.backButtonView.alpha = 1.f;
    self.skillView.alpha = 0.f;
    self.monsterDescription.originX -= descriptionWidthChange/2;
    self.monsterDescription.width += descriptionWidthChange;
    self.buttonsContainer.alpha = 0.f;
  }completion:^(BOOL finished) {
    self.descriptionView.hidden = YES;
    self.skillView.userInteractionEnabled = NO;
  }];
  
  CATransition *animation = [CATransition animation];
  animation.duration = 0.3;
  animation.type = kCATransitionFade;
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [self.monsterDescription.layer addAnimation:animation forKey:@"changeTextTransition"];
  [self setDescriptionLabelString:labelText];
}

- (IBAction)attackInfoClicked:(id)sender {
  [self pushContentView:self.elementView labelText:@"Attack numbers represent the damage done by each orb destroyed in battle."];
}

- (IBAction)researchInfoClicked:(id)sender {
  [self pushContentView:self.researchInfoView labelText:[NSString stringWithFormat:@"This %@ is affected by the above Research.", MONSTER_NAME]];
}

- (IBAction)backClicked:(id)sender {
  CGPoint mainViewCenter = ccp(self.descriptionView.superview.width/2, self.descriptionView.superview.height/2);
  self.descriptionView.hidden = NO;
  
  [UIView animateWithDuration:0.3f animations:^{
    self.descriptionView.center = mainViewCenter;
    self.elementView.center = CGPointMake(self.elementView.center.x+self.elementView.frame.size.width, self.elementView.center.y);
    self.researchInfoView.center = CGPointMake(self.researchInfoView.center.x+self.researchInfoView.frame.size.width, self.researchInfoView.center.y);
    self.backButtonView.alpha = 0.f;
    self.buttonsContainer.alpha = 1.f;
    self.skillView.alpha = 1.f;
    self.monsterDescription.originX += descriptionWidthChange/2;
    self.monsterDescription.width -= descriptionWidthChange;
  } completion:^(BOOL finished) {
    [self.elementView removeFromSuperview];
    [self.researchInfoView removeFromSuperview];
    self.backButtonView.hidden = YES;
    self.skillView.userInteractionEnabled = YES;
  }];
  
  CATransition *animation = [CATransition animation];
  animation.duration = 0.3;
  animation.type = kCATransitionFade;
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [self.monsterDescription.layer addAnimation:animation forKey:@"changeTextTransition"];
  [self updateSkillData:YES];
}

- (IBAction)sellClicked:(id)sender {
  [GenericPopupController displayConfirmationWithDescription:[NSString stringWithFormat:@"Are you sure you would like to sell %@ for %@?", self.monster.staticMonster.displayName, [Globals cashStringForNumber:self.monster.sellPrice]] title:@"Sell?" okayButton:@"Sell" cancelButton:@"Cancel" target:self selector:@selector(sell)];
}

- (void) sell {
  [[OutgoingEventController sharedOutgoingEventController] sellUserMonsters:@[self.monster.userMonsterUuid]];
  [self close:nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:MONSTER_SOLD_COMPLETE_NOTIFICATION object:nil];
  [QuestUtil checkAllDonateQuests];
  
  if (self.monster.teamSlot > 0) {
    [[NSNotificationCenter defaultCenter] postNotificationName:MY_TEAM_CHANGED_NOTIFICATION object:nil];
  }
}

- (IBAction)heartClicked:(id)sender {
  [GenericPopupController displayConfirmationWithDescription:[NSString stringWithFormat:@"Would you like to make %@ your avatar?", self.monster.staticMonster.displayName] title:@"Set Avatar?" okayButton:@"Yup!" cancelButton:@"Cancel" target:self selector:@selector(changeAvatar)];
}

- (IBAction)offensiveSkillTapped:(id)sender {
  [self updateSkillData:YES];
}

- (IBAction)defensiveSkillTapped:(id)sender {
  [self updateSkillData:NO];
}

- (void) changeAvatar {
  GameState *gs = [GameState sharedGameState];
  if (!self.monster.isComplete) {
    [Globals addAlertNotification:[NSString stringWithFormat:@"You must fully own this %@ before making it your avatar.", MONSTER_NAME]];
  } else if ([self.monster.userUuid isEqualToString:gs.userUuid]) {
    [[OutgoingEventController sharedOutgoingEventController] setAvatarMonster:self.monster.monsterId];
    self.avatarButton.enabled = NO;
  }
}

- (IBAction)lockClicked:(id)sender {
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  if (![def boolForKey:LOCK_MOBSTER_DEFAULTS_KEY]) {
    NSString *str = [NSString stringWithFormat:@"Locking this %@ will prevent you from accidentally selling, sacrificing in enhancement, or donating them.", MONSTER_NAME];
    [GenericPopupController displayConfirmationWithDescription:str title:[NSString stringWithFormat:@"Lock %@?", MONSTER_NAME] okayButton:@"Lock" cancelButton:@"Cancel" target:self selector:@selector(doLock)];
    
    [def setBool:YES forKey:LOCK_MOBSTER_DEFAULTS_KEY];
  } else {
    [self doLock];
  }
}

- (void) doLock {
  if (!self.monster.isProtected) {
    [[OutgoingEventController sharedOutgoingEventController] protectUserMonster:self.monster.userMonsterUuid];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] unprotectUserMonster:self.monster.userMonsterUuid];
  }
  
  [self updateProtectedButton];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:MONSTER_LOCK_CHANGED_NOTIFICATION object:nil];
}

- (IBAction)close:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
  }];
}

@end
