//
//  Globals.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/29/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "Globals.h"
#import "LNSynthesizeSingleton.h"
#import "IAPHelper.h"
#import "GameState.h"
#import "Protocols.pb.h"
#import "Downloader.h"
#import "GenericPopupController.h"
#import "SoundEngine.h"
#import "HomeMap.h"
#import "OutgoingEventController.h"
#import "GameViewController.h"
#import "OpenUDID.h"
#import "SocketCommunication.h"
#import "ODIN.h"
#import "AppDelegate.h"
#import "HospitalQueueSimulator.h"
#import "OneLineNotificationViewController.h"

#define FONT_LABEL_OFFSET 1.f
#define SHAKE_DURATION 0.05f
#define PULSE_TIME 0.8f

#define BUNDLE_SCHEDULE_INTERVAL 30

@implementation Globals

static NSString *fontName = @"AxeHandel";
static int fontSize = 12;

LN_SYNTHESIZE_SINGLETON_FOR_CLASS(Globals);

- (id) init {
  if ((self = [super init])) {
    self.imageCache = [NSMutableDictionary dictionary];
    self.imageViewsWaitingForDownloading = [NSMutableDictionary dictionary];
    self.animatingSpriteOffsets = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void) updateInAppPurchases {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  
  for (InAppPurchasePackageProto *pkg in self.iapPackages) {
    [dict setObject:pkg forKey:pkg.iapPackageId];
  }
  self.productIdsToPackages = dict;
  [[IAPHelper sharedIAPHelper] requestProducts];
}

- (void) updateConstants:(StartupResponseProto_StartupConstants *)constants {
  self.iapPackages = constants.inAppPurchasePackagesList;
  [self updateInAppPurchases];
  
  self.maxLevelForUser = constants.maxLevelForUser;
  self.maxRepeatedNormStructs = constants.maxNumOfSingleStruct;
  self.minNameLength = constants.minNameLength;
  self.maxNameLength = constants.maxNameLength;
  self.maxLengthOfChatString = constants.maxLengthOfChatString;
  self.levelToShowRateUsPopup = constants.levelToShowRateUsPopup;
  self.fbConnectRewardDiamonds = constants.fbConnectRewardDiamonds;
  self.faqFileName = constants.faqFileName;
  self.adminChatUser = constants.adminChatUserProto;
  self.numBeginnerSalesAllowed = constants.numBeginnerSalesAllowed;
  self.minutesPerGem = constants.minutesPerGem;
  self.pvpRequiredMinLvl = constants.pvpRequiredMinLvl;
  self.gemsPerResource = constants.gemsPerResource;
  self.continueBattleGemCostMultiplier = constants.continueBattleGemCostMultiplier;
  self.addAllFbFriends = constants.addAllFbFriends;
  self.maxObstacles = constants.maxObstacles;
  self.minutesPerObstacle = constants.minutesPerObstacle;
  self.maxMinutesForFreeSpeedUp = constants.maxMinutesForFreeSpeedUp;
  
  self.battleRunAwayBasePercent = constants.battleRunAwayBasePercent;
  self.battleRunAwayIncrement = constants.battleRunAwayIncrement;
  
  self.miniTutorialConstants = constants.miniTuts;
  
  self.maxTeamSize = constants.userMonsterConstants.maxNumTeamSlots;
  self.baseInventorySize = constants.userMonsterConstants.initialMaxNumMonsterLimit;
  
  self.cashPerHealthPoint = constants.monsterConstants.cashPerHealthPoint;
  self.elementalStrength = constants.monsterConstants.elementalStrength;
  self.elementalWeakness = constants.monsterConstants.elementalWeakness;
  self.oilPerMonsterLevel = constants.monsterConstants.oilPerMonsterLevel;
  
  self.mapSectionImagePrefix = constants.taskMapConstants.mapSectionImagePrefix;
  self.mapNumberOfSections = constants.taskMapConstants.mapNumberOfSections;
  self.mapSectionHeight = constants.taskMapConstants.mapSectionHeight;
  self.mapTotalHeight = constants.taskMapConstants.mapTotalHeight;
  self.mapTotalWidth = constants.taskMapConstants.mapTotalWidth;
  
  self.coinPriceToCreateClan = constants.clanConstants.coinPriceToCreateClan;
  self.maxCharLengthForClanName = constants.clanConstants.maxCharLengthForClanName;
  self.maxCharLengthForClanDescription = constants.clanConstants.maxCharLengthForClanDescription;
  self.maxCharLengthForClanTag = constants.clanConstants.maxCharLengthForClanTag;
  self.maxClanSize = constants.clanConstants.maxClanSize;
  
  self.tournamentWinsWeight = constants.touramentConstants.winsWeight;
  self.tournamentLossesWeight = constants.touramentConstants.lossesWeight;
  self.tournamentFleesWeight = constants.touramentConstants.fleesWeight;
  self.tournamentNumHrsToDisplayAfterEnd = constants.touramentConstants.numHoursToShowAfterEventEnd;
  
  for (StartupResponseProto_StartupConstants_ClanHelpConstants *c in constants.clanHelpConstantsList) {
    if (c.helpType == GameActionTypeHeal) {
      self.healClanHelpConstants = c;
    } else if (c.helpType == GameActionTypeUpgradeStruct) {
      self.buildingClanHelpConstants = c;
    } else if (c.helpType == GameActionTypeEvolve) {
      self.evolveClanHelpConstants = c;
    } else if (c.helpType == GameActionTypeMiniJob) {
      self.miniJobClanHelpConstants = c;
    } else if (c.helpType == GameActionTypeEnhanceTime) {
      self.enhanceClanHelpConstants = c;
    }
  }
  
  if (constants.hasDownloadableNibConstants) {
    StartupResponseProto_StartupConstants_DownloadableNibConstants_Builder *b = [StartupResponseProto_StartupConstants_DownloadableNibConstants builderWithPrototype:self.downloadableNibConstants];
    [b mergeFrom:constants.downloadableNibConstants];
    self.downloadableNibConstants = [b build];
  }
  
  for (StartupResponseProto_StartupConstants_AnimatedSpriteOffsetProto *aso in constants.animatedSpriteOffsetsList) {
    [self.animatingSpriteOffsets setObject:aso.offSet forKey:aso.imageName];
  }
}

+ (void) asyncDownloadBundles {
  //  Globals *gl = [Globals sharedGlobals];
  //  StartupResponseProto_StartupConstants_DownloadableNibConstants *n = gl.downloadableNibConstants;
  NSArray *bundleNames = [NSArray arrayWithObjects:nil];
  Downloader *dl = [Downloader sharedDownloader];
  
  int i = BUNDLE_SCHEDULE_INTERVAL;
  for (NSString *name in bundleNames) {
    if (![self bundleExists:name]) {
      [dl performSelector:@selector(asyncDownloadBundle:) withObject:name afterDelay:i];
      LNLog(@"Scheduled download of bundle %@ in %d seconds", name, i);
      i += BUNDLE_SCHEDULE_INTERVAL;
    }
  }
}

+ (NSString *) font {
  return fontName;
}

+ (int) fontSize {
  return fontSize;
}

+ (CGSize)screenSize {
  CGSize screenSize = [UIScreen mainScreen].bounds.size;
  if ((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
    return CGSizeMake(screenSize.height, screenSize.width);
  } else {
    return screenSize;
  }
}

+ (NSString *) convertTimeToString:(int)secs withDays:(BOOL)withDays {
  if (secs < 0) {
    return @"00:00:00";
  }
  
  int days = 0;
  
  if (withDays) {
    days = secs / 86400;
    secs %= 86400;
  }
  int hrs = secs / 3600;
  secs %= 3600;
  int mins = secs / 60;
  secs %= 60;
  
  NSString *daysString = days ? [NSString stringWithFormat:@"%d:", days] : @"";
  return [NSString stringWithFormat:@"%@%02d:%02d:%02d", daysString, hrs, mins, secs];
}

+ (NSString *) convertTimeToShortString:(int)secs {
  if (secs <= 0) {
    return @"0s";
  }
  
  int days = secs / 86400;
  secs %= 86400;
  int hrs = secs / 3600;
  secs %= 3600;
  int mins = secs / 60;
  secs %= 60;
  
  if (days > 0) {
    NSString *hrsStr = hrs == 0 ? @"" : [NSString stringWithFormat:@" %dh", hrs];
    return [NSString stringWithFormat:@"%dd%@", days, hrsStr];
  }
  
  if (hrs > 0) {
    NSString *minsStr = mins == 0 ? @"" : [NSString stringWithFormat:@" %dm", mins];
    return [NSString stringWithFormat:@"%dh%@", hrs, minsStr];
  }
  
  if (mins > 0) {
    NSString *secsStr = secs == 0 ? @"" : [NSString stringWithFormat:@" %ds", secs];
    return [NSString stringWithFormat:@"%dm%@", mins, secsStr];
  }
  
  return [NSString stringWithFormat:@"%ds", secs];
}

+ (NSString *) convertTimeToShorterString:(int)secs {
  NSString *s = [self convertTimeToShortString:secs];
  NSRange r = [s rangeOfString:@" "];
  if (r.location != NSNotFound) {
    s = [s substringToIndex:r.location];
  }
  return s;
}

+ (NSString *) convertTimeToMediumString:(int)secs {
  NSString *longStr = [self convertTimeToLongString:secs];
  
  if ([longStr componentsSeparatedByString:@" "].count > 2) {
    longStr = [longStr stringByReplacingOccurrencesOfString:@"Minute" withString:@"Min"];
    longStr = [longStr stringByReplacingOccurrencesOfString:@"Second" withString:@"Sec"];
    longStr = [longStr stringByReplacingOccurrencesOfString:@"Hour" withString:@"Hr"];
  }
  
  return longStr;
}

+ (NSString *) convertTimeToLongString:(int)secs {
  if (secs <= 0) {
    return @"0 Seconds";
  }
  
  int days = secs / 86400;
  secs %= 86400;
  int hrs = secs / 3600;
  secs %= 3600;
  int mins = secs / 60;
  secs %= 60;
  
  if (days > 0) {
    NSString *hrsStr = hrs == 0 ? @"" : [NSString stringWithFormat:@" %d Hour%@", hrs,  hrs != 1 ? @"s" : @""];
    return [NSString stringWithFormat:@"%d Day%@%@", days, days != 1 ? @"s" : @"", hrsStr];
  }
  
  if (hrs > 0) {
    NSString *minsStr = mins == 0 ? @"" : [NSString stringWithFormat:@" %d Minute%@", mins, mins != 1 ? @"s" : @""];
    return [NSString stringWithFormat:@"%d Hour%@%@", hrs,  hrs != 1 ? @"s" : @"", minsStr];
  }
  
  if (mins > 0) {
    NSString *secsStr = secs == 0 ? @"" : [NSString stringWithFormat:@" %d Second%@", secs, secs != 1 ? @"s" : @""];
    return [NSString stringWithFormat:@"%d Minute%@%@", mins, mins != 1 ? @"s" : @"", secsStr];
  }
  
  return [NSString stringWithFormat:@"%d Second%@", secs, secs != 1 ? @"s" : @""];
}

+ (UIColor *) colorForRarity:(Quality)rarity {
  switch (rarity) {
    case QualityCommon:
      return [UIColor colorWithWhite:40/255.f alpha:1.f];
      
    case QualityRare:
      return [self blueColor];
      
    case QualityUltra:
      return [self yellowColor];
      
    case QualityEpic:
      return [self purpleColor];
      
    case QualityLegendary:
      return [self redColor];
      
    case QualityEvo:
      return [self orangeColor];
      
    case QualitySuper:
      return [UIColor colorWithRed:14/255.f green:185/255.f blue:131/255.f alpha:1.f];
      
    default:
      break;
  }
  return nil;
}

+ (UIColor *) colorForElementOnDarkBackground:(Element)element {
  ccColor3B c;
  switch (element) {
    case ElementDark:
      c = ccc3(129, 7, 181);
      break;
      
    case ElementWater:
      c = ccc3(10, 220, 210);
      break;
      
    case ElementFire:
      c = ccc3(220, 40, 0);
      break;
      
    case ElementLight:
      c = ccc3(255, 215, 0);
      break;
      
    case ElementEarth:
      c = ccc3(100, 220, 20);
      break;
      
    case ElementRock:
      c = ccc3(100, 100, 100);
      break;
      
    default:
      c = ccc3(255, 255, 255);
      break;
  }
  return [UIColor colorWithRed:c.r/255.f green:c.g/255.f blue:c.b/255.f alpha:1.f];
}

+ (UIColor *) colorForElementOnLightBackground:(Element)element {
  ccColor3B c;
  switch (element) {
    case ElementDark:
      c = ccc3(128, 59, 185);
      break;
      
    case ElementWater:
      c = ccc3(36, 158, 195);
      break;
      
    case ElementFire:
      c = ccc3(209, 63, 37);
      break;
      
    case ElementLight:
      c = ccc3(255, 171, 0);
      break;
      
    case ElementEarth:
      c = ccc3(96, 146, 25);
      break;
      
    case ElementRock:
      c = ccc3(77, 82, 84);
      break;
      
    default:
      c = ccc3(255, 255, 255);
      break;
  }
  return [UIColor colorWithRed:c.r/255.f green:c.g/255.f blue:c.b/255.f alpha:1.f];
}

+ (NSString *) stringForRarity:(Quality)rarity {
  switch (rarity) {
    case QualityCommon:
      return @"Common";
      
    case QualityRare:
      return @"Rare";
      
    case QualitySuper:
      return @"Super";
      
    case QualityUltra:
      return @"Ultra";
      
    case QualityEpic:
      return @"Epic";
      
    case QualityLegendary:
      return @"Legend";
      
    default:
      return nil;
      break;
  }
}

+ (NSString *) imageNameForRarity:(Quality)rarity suffix:(NSString *)str {
  NSString *base = [[[self stringForRarity:rarity] stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
  return [base stringByAppendingString:str];
}

+ (NSString *) shortenedStringForRarity:(Quality)rarity {
  NSString *str = [self stringForRarity:rarity];
  
  if (str.length > 5) {
    str = [str stringByReplacingCharactersInRange:NSMakeRange(3, str.length-3) withString:@"."];
  }
  return [str uppercaseString];
}

+ (NSString *) stringForElement:(Element)element {
  switch (element) {
    case ElementDark:
      return @"Night";
      
    case ElementFire:
      return @"Fire";
      
    case ElementEarth:
      return @"Earth";
      
    case ElementLight:
      return @"Light";
      
    case ElementWater:
      return @"Water";
      
    case ElementRock:
      return @"Rock";
      
    case ElementNoElement:
      return @"No Element";
      
    default:
      return nil;
      break;
  }
}

+ (Element) elementForSuperEffective:(Element)element {
  switch (element) {
    case ElementDark:
      return ElementLight;
      
    case ElementLight:
      return ElementDark;
      
    case ElementFire:
      return ElementEarth;
      
    case ElementEarth:
      return ElementWater;
      
    case ElementWater:
      return ElementFire;
      
    default:
      return ElementRock;
      break;
  }
}

+ (Element) elementForNotVeryEffective:(Element)element {
  switch (element) {
    case ElementDark:
      return ElementLight;
      
    case ElementLight:
      return ElementDark;
      
    case ElementFire:
      return ElementWater;
      
    case ElementEarth:
      return ElementFire;
      
    case ElementWater:
      return ElementEarth;
      
    default:
      return ElementRock;
      break;
  }
}

+ (NSString *) stringForClanStatus:(UserClanStatus)status {
  NSString *typeText = @"";
  switch (status) {
    case UserClanStatusLeader:
      typeText = @"Squad Leader";
      break;
    case UserClanStatusJuniorLeader:
      typeText = @"Jr. Leader";
      break;
    case UserClanStatusCaptain:
      typeText = @"Squad Captain";
      break;
    case UserClanStatusMember:
      typeText = @"Squad Member";
      break;
    case UserClanStatusRequesting:
      typeText = @"Requestee";
      break;
  }
  return typeText;
}

+ (NSString *) stringForResourceType:(ResourceType)res {
  switch (res) {
    case ResourceTypeCash:
      return @"Cash";
    case ResourceTypeGems:
      return @"Gems";
    case ResourceTypeOil:
      return @"Oil";
      
    default:
      break;
  }
  return nil;
}

+ (NSString *) imageNameForElement:(Element)element suffix:(NSString *)str {
  NSString *base = [[[self stringForElement:element] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
  return [base stringByAppendingString:str];
}

+ (NSString *) stringForTimeSinceNow:(MSDate *)date shortened:(BOOL)shortened {
  int time = -1*[date timeIntervalSinceNow];
  
  
  if (time < 0) {
    return @"In the future!";
  }
  
  int interval = 1;
  if (time < interval*60) {
    return [NSString stringWithFormat:@"%d%@%@ ago", time / interval, shortened ? @"s" : @" second", !shortened && time / interval != 1 ? @"s" : @""];
  }
  
  interval *= 60;
  if (time < interval*60) {
    return [NSString stringWithFormat:@"%d%@%@ ago", time / interval, shortened ? @"m" : @" minute", !shortened && time / interval != 1 ? @"s" : @""];
  }
  
  interval *= 60;
  if (time < interval*24) {
    return [NSString stringWithFormat:@"%d%@%@ ago", time / interval, shortened ? @"h" : @" hour", !shortened && time / interval != 1 ? @"s" : @""];
  }
  
  interval *= 24;
  if (time < interval*7) {
    return [NSString stringWithFormat:@"%d%@%@ ago", time / interval, shortened ? @"d" : @" day", !shortened && time / interval != 1 ? @"s" : @""];
  }
  
  interval *= 7;
  if (time < interval*5) {
    return [NSString stringWithFormat:@"%d%@%@ ago", time / interval, shortened ? @"w" : @" week", !shortened && time / interval != 1 ? @"s" : @""];
  }
  
  // Approximate the size of a month to 30 days
  interval = interval/7*30;
  if (time < interval*13) {
    return [NSString stringWithFormat:@"%d%@%@ ago", time / interval, shortened ? @"mo" : @" month", !shortened && time / interval != 1 ? @"s" : @""];
  }
  
  interval = interval/30*365;
  return [NSString stringWithFormat:@"%d%@%@ ago", time / interval, shortened ? @"y" : @" year", !shortened && time / interval != 1 ? @"s" : @""];
}

#pragma mark - Font Adjustment

+ (void) adjustFontSizeForSize:(int)size withUIView:(UIView *)somethingWithText {
  if ([somethingWithText respondsToSelector:@selector(setFont:)]) {
    UIFont *f = [UIFont fontWithName:[self font] size:size];
    [somethingWithText performSelector:@selector(setFont:) withObject:f];
    
    // Move frame down to account for this font
    CGRect tmp = somethingWithText.frame;
    tmp.origin.y += FONT_LABEL_OFFSET;
    somethingWithText.frame = tmp;
  }
}

+ (void) adjustFontSizeForSize:(int)size withUIViews:(UIView *)field1, ... {
  va_list params;
	va_start(params,field1);
	
  for (UIView *arg = field1; arg != nil; arg = va_arg(params, UIView *))
  {
    [self adjustFontSizeForSize:size withUIView:field1];
  }
  va_end(params);
}

+ (void) adjustFontSizeForUIViewWithDefaultSize:(UIView *)somethingWithText {
  [self adjustFontSizeForSize:[self fontSize] withUIView:somethingWithText];
}

+ (void) adjustFontSizeForUIViewsWithDefaultSize:(UIView *)field1, ...
{
	va_list params;
	va_start(params,field1);
	
  for (UIView *arg = field1; arg != nil; arg = va_arg(params, UIView *))
  {
    [self adjustFontSizeForUIViewWithDefaultSize:arg];
  }
  va_end(params);
}

+ (void) adjustFontSizeForUILabel:(UILabel *)label {
  [self adjustFontSizeForSize:label.font.pointSize withUIView:label];
}

+ (void) adjustFontSizeForUILabels:(UILabel *)field1, ...
{
	va_list params;
	va_start(params,field1);
	
  for (UILabel *arg = field1; arg != nil; arg = va_arg(params, UILabel *))
  {
    [self adjustFontSizeForUILabel:arg];
  }
  va_end(params);
}

+ (void) adjustFontSizeForCCLabelTTF:(CCLabelTTF *)label size:(int)size {
  label.position = ccpAdd(label.position, ccp(0,-FONT_LABEL_OFFSET * size / [self fontSize]));
}

+ (void) adjustFontSizeForSize:(int)size CCLabelTTFs:(CCLabelTTF *)field1, ...
{
	va_list params;
	va_start(params,field1);
	
  for (CCLabelTTF *arg = field1; arg != nil; arg = va_arg(params, CCLabelTTF *))
  {
    [self adjustFontSizeForCCLabelTTF:arg size:size];
  }
  va_end(params);
}

#pragma mark - Strings

+ (NSString *) cashStringForNumber:(int)n {
  return [NSString stringWithFormat:@"$%@", [self commafyNumber:n]];
}

+ (NSString *) commafyNumber:(float)f {
  int n = (int)f;
  float r = f-n;
  
  BOOL neg = n < 0;
  n = abs(n);
  NSString *s = [NSString stringWithFormat:@"%03d", n%1000];
  n /= 1000;
  while (n > 0) {
    s = [NSString stringWithFormat:@"%03d,%@", n%1000, s];
    n /= 1000;
  }
  
  int x = 0;
  while (x < s.length && [s characterAtIndex:x] == '0') {
    x++;
  }
  s = [s substringFromIndex:x];
  NSString *pre = neg ? @"-" : @"";
  NSString *toRet = s.length > 0 ? [pre stringByAppendingString:s] : @"0";
  
  if (r > 0) {
    toRet = [toRet stringByAppendingString:[[NSString stringWithFormat:@"%.2f", r] substringFromIndex:1]];
  }
  
  return toRet;
}

+ (NSString *) qualifierStringForNumber:(int)rank {
  int lastDigit = rank % 10;
  int secondDigit = (rank / 10) % 10;
  NSString *qualifier = @"th";
  if (secondDigit != 1 && lastDigit >= 1 && lastDigit <= 3) {
    if (lastDigit == 1) {
      qualifier = @"st";
    } else if (lastDigit == 2) {
      qualifier = @"nd";
    } else if (lastDigit == 3) {
      qualifier = @"rd";
    }
  }
  return qualifier;
}

#pragma mark - Array Differences

+ (void) calculateDifferencesBetweenOldArray:(NSArray *)oArr newArray:(NSArray *)nArr removalIps:(NSMutableArray *)removals additionIps:(NSMutableArray *)additions section:(int)section {
  [self calculateDifferencesBetweenOldArray:oArr newArray:nArr removalIps:removals additionIps:additions movedIps:nil section:section];
}

+ (void) calculateDifferencesBetweenOldArray:(NSArray *)oArr newArray:(NSArray *)nArr removalIps:(NSMutableArray *)removals additionIps:(NSMutableArray *)additions movedIps:(NSMutableDictionary *)moves section:(int)section {
  // Used for animatedly reloading a table
  NSMutableSet *old = [NSMutableSet setWithArray:oArr];
  NSMutableSet *cur = [NSMutableSet setWithArray:nArr];
  
  NSMutableSet *added = cur.mutableCopy;
  [added minusSet:old];
  
  NSMutableSet *removed = old.mutableCopy;
  [removed minusSet:cur];
  
  for (id um in added) {
    [additions addObject:[NSIndexPath indexPathForRow:[nArr indexOfObject:um] inSection:section]];
  }
  for (id um in removed) {
    [removals addObject:[NSIndexPath indexPathForRow:[oArr indexOfObject:um] inSection:section]];
  }
  
  // Now look for the guys that were moved around by removing all adds and removes
  NSMutableArray *o = [oArr mutableCopy];
  NSMutableArray *n = [nArr mutableCopy];
  [o removeObjectsInArray:removed.allObjects];
  [n removeObjectsInArray:added.allObjects];
  
  // Now all objects should be the same.. cept things will be moved around potentially
  if (o.count == n.count) {
    int i = 0;
    while (i < o.count) {
      id oObj = o[i];
      id nObj = n[i];
      if (oObj == nObj) {
        i++;
      } else {
        NSInteger idx = [n indexOfObject:oObj];
        if (idx != NSNotFound) {
          [o removeObjectAtIndex:i];
          [n removeObjectAtIndex:idx];
          [moves setObject:[NSIndexPath indexPathForRow:[nArr indexOfObject:oObj] inSection:section] forKey:[NSIndexPath indexPathForRow:[oArr indexOfObject:oObj] inSection:section]];
        } else {
          LNLog(@"SOMETHING WENT WRONG.. LOOK AT CALCULATE DIFFERENCES");
          break;
        }
      }
    }
  }
}

#pragma mark - View helpers

+ (UIImage *) snapShotView:(UIView *)view {
  UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.f);
//  if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
//    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
//  } else {
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
//  }
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return image;
}

+ (UIImage *) greyScaleImageWithBaseImage:(UIImage *)inputImage {
  if (!inputImage) {
    return nil;
  }
  
  const int RED = 1;
  const int GREEN = 2;
  const int BLUE = 3;
  
  // Create image rectangle with current image width/height
  CGRect imageRect = CGRectMake(0, 0, inputImage.size.width * inputImage.scale, inputImage.size.height * inputImage.scale);
  
  int width = imageRect.size.width;
  int height = imageRect.size.height;
  
  // the pixels will be painted to this array
  uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
  
  // clear the pixels so any transparency is preserved
  memset(pixels, 0, width * height * sizeof(uint32_t));
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  
  // create a context with RGBA pixels
  CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                               kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
  
  // paint the bitmap to our context which will fill in the pixels array
  CGContextDrawImage(context, CGRectMake(0, 0, width, height), [inputImage CGImage]);
  
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++) {
      uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
      
      // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
      uint8_t gray = (uint8_t) ((29 * rgbaPixel[RED] + 29 * rgbaPixel[GREEN] + 29 * rgbaPixel[BLUE]) / 100);
      
      // set the pixels to gray
      rgbaPixel[RED] = gray;
      rgbaPixel[GREEN] = gray;
      rgbaPixel[BLUE] = gray;
    }
  }
  
  // create a new CGImageRef from our context with the modified pixels
  CGImageRef image = CGBitmapContextCreateImage(context);
  
  // we're done with the context, color space, and pixels
  CGContextRelease(context);
  CGColorSpaceRelease(colorSpace);
  free(pixels);
  
  // make a new UIImage to return
  UIImage *resultUIImage = [UIImage imageWithCGImage:image
                                               scale:inputImage.scale
                                         orientation:UIImageOrientationUp];
  
  // we're done with image now too
  CGImageRelease(image);
  
  return resultUIImage;
}

+ (UIImage*) maskImage:(UIImage *)image withColor:(UIColor *)color {
  
  CGImageRef alphaImage = CGImageRetain(image.CGImage);
  float width = image.size.width;
  float height = image.size.height;
  
  UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0.f);
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  if (!context) {
    CGImageRelease(alphaImage);
    return nil;
  }
  
	CGRect r = CGRectMake(0, 0, width, height);
	CGContextTranslateCTM(context, 0.0, r.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
  CGContextSetFillColorWithColor(context, color.CGColor);
  
	// You can also use the clip rect given to scale the mask image
	CGContextClipToMask(context, CGRectMake(0.0, 0.0, width, height), alphaImage);
	// As above, not being careful with bounds since we are clipping.
	CGContextFillRect(context, r);
  
  UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  CGImageRelease(alphaImage);
  
  // return the image
  return theImage;
}

+ (void) shakeView:(UIView *)view duration:(float)duration offset:(int)offset {
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
  // Divide by 2 to account for autoreversing
  int repeatCt = duration / SHAKE_DURATION / 2;
  [animation setDuration:SHAKE_DURATION];
  [animation setRepeatCount:repeatCt];
  [animation setAutoreverses:YES];
  [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
  [animation setFromValue:[NSValue valueWithCGPoint:
                           CGPointMake(view.center.x - offset, view.center.y)]];
  [animation setToValue:[NSValue valueWithCGPoint:
                         CGPointMake(view.center.x + offset, view.center.y)]];
  [view.layer addAnimation:animation forKey:@"position"];
}

+ (void) displayUIView:(UIView *)view {
  AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  UINavigationController *nav = (UINavigationController *)ad.window.rootViewController;
  UIViewController *vc = nav.visibleViewController;
  UIView *sv = vc.view;
  
  CGRect r = view.frame;
  r.size.width = MIN(r.size.width, sv.frame.size.width);
  view.frame = r;
  
  view.center = CGPointMake(sv.frame.size.width/2, sv.frame.size.height/2);
  
  [sv addSubview:view];
}

#pragma mark - Downloading

+ (NSString *) pathToFile:(NSString *)fileName useiPhone6Prefix:(BOOL)useiPhone6Prefix {
  if (!fileName) {
    return nil;
  }
  
  // prevents overloading the autorelease pool
  NSString *resName = [self getDoubleResolutionImage:fileName useiPhone6Prefix:useiPhone6Prefix];
  NSString *fullpath = [[NSBundle mainBundle] pathForResource:resName ofType:nil];
  
  // Added for Utopia project
  if (!fullpath) {
    // Image not in NSBundle: look in documents
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    fullpath = [documentsPath stringByAppendingPathComponent:resName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullpath]) {
      return nil;
    }
  }
  
  return fullpath;
}

+ (BOOL) isFileDownloaded:(NSString *)fileName useiPhone6Prefix:(BOOL)useiPhone6Prefix {
  return !![self pathToFile:fileName useiPhone6Prefix:useiPhone6Prefix];
}

+ (NSString *) downloadFile:(NSString *)fileName useiPhone6Prefix:(BOOL)useiPhone6Prefix {
  if (!fileName) {
    return nil;
  }
  
  if (![self isFileDownloaded:fileName useiPhone6Prefix:useiPhone6Prefix]) {
    NSString *resName = [self getDoubleResolutionImage:fileName useiPhone6Prefix:useiPhone6Prefix];
    [[Downloader sharedDownloader] syncDownloadFile:resName];
  }
  
  return [self pathToFile:fileName useiPhone6Prefix:useiPhone6Prefix];
}

+ (void) downloadAllFilesForSpritePrefixes:(NSArray *)spritePrefixes completion:(void (^)(void))completed {
  NSMutableArray *arr = [NSMutableArray array];
  for (NSString *spritePrefix in spritePrefixes) {
    for (NSString *str in @[@"%@RunNF.plist", @"%@AttackNF.plist", @"%@Card.png"]) {
      NSString *fileName = [NSString stringWithFormat:str, spritePrefix];
      [arr addObject:fileName];
    }
  }
  [self checkAndLoadFiles:arr completion:^(BOOL success) {
    completed();
  }];
}

+ (void) checkAndLoadFiles:(NSArray *)fileNames completion:(void (^)(BOOL success))completion {
  __block int i = 0;
  __block BOOL finalSuccess = YES;
  for (NSString *fileName in fileNames) {
    if (![self isFileDownloaded:fileName useiPhone6Prefix:NO]) {
      i++;
      
      id comp = ^(BOOL success) {
        i--;
        finalSuccess = finalSuccess & success;
        if (i == 0) {
          completion(finalSuccess);
        }
      };
      
      if ([fileName.pathExtension isEqualToString:@"plist"]) {
        [self checkAndLoadSpriteSheet:fileName completion:comp];
      } else {
        [self checkAndLoadFile:fileName completion:comp];
      }
    }
  }
  
  if (i == 0) {
    completion(finalSuccess);
  }
}

+ (void) checkAndLoadFile:(NSString *)fileName useiPhone6Prefix:(BOOL)useiPhone6Prefix completion:(void (^)(BOOL success))completion {
  if ([self isFileDownloaded:fileName useiPhone6Prefix:useiPhone6Prefix]) {
    if (completion) {
      completion(YES);
    }
  } else {
    NSString *resName = [self getDoubleResolutionImage:fileName useiPhone6Prefix:useiPhone6Prefix];
    [[Downloader sharedDownloader] asyncDownloadFile:resName completion:completion];
  }
}

+ (void) checkAndLoadFile:(NSString *)fileName completion:(void (^)(BOOL success))completion {
  [self checkAndLoadFile:fileName useiPhone6Prefix:NO completion:completion];
}

+ (void) checkAndLoadSpriteSheet:(NSString *)fileName completion:(void (^)(BOOL success))completion {
  [self checkAndLoadFile:fileName completion:^(BOOL success) {
    if (success) {
      NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[self pathToFile:fileName useiPhone6Prefix:NO]];
      NSDictionary *metadataDict = [dict objectForKey:@"metadata"];
      NSString *texturePath = [metadataDict objectForKey:@"textureFileName"];
      [self checkAndLoadFile:texturePath completion:^(BOOL success) {
        completion(success);
      }];
    } else {
      if (completion) {
        completion(NO);
      }
    }
  }];
}

+ (NSString *) pathToBundle:(NSString *)bundleName {
  NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  NSString *fullPath = [cachesDirectory stringByAppendingPathComponent:bundleName];
  return fullPath;
}

+ (BOOL) bundleExists:(NSString *)bundleName {
  return [[NSFileManager defaultManager] fileExistsAtPath:[self pathToBundle:bundleName]];
}

+ (NSBundle *) bundleNamed:(NSString *)bundleName {
  if (!bundleName) {
    return nil;
  }
  NSString *fullPath = [self pathToBundle:bundleName];
  
  if (![self bundleExists:bundleName]) {
    [[Downloader sharedDownloader] syncDownloadBundle:bundleName];
  }
  
  return [NSBundle bundleWithPath:fullPath];
}

+ (UIImage *) imageNamed:(NSString *)path {
  return [self imageNamed:path useiPhone6Prefix:NO];
}

+ (UIImage *) imageNamed:(NSString *)path useiPhone6Prefix:(BOOL)useiPhone6Prefix {
  if (!path) {
    return nil;
  }
  
  Globals *gl = [Globals sharedGlobals];
  UIImage *cachedImage = [gl.imageCache objectForKey:path];
  if (cachedImage) {
    return cachedImage;
  }
  
  NSString *fullPath = [self downloadFile:path useiPhone6Prefix:useiPhone6Prefix];
  UIImage *image = [UIImage imageWithContentsOfFile:fullPath];
  
  if (image) {
    [gl.imageCache setObject:image forKey:path];
  }
  
  return image;
}

+ (void) imageNamed:(NSString *)imageName withView:(UIView *)view maskedColor:(UIColor *)color indicator: (UIActivityIndicatorViewStyle)indicatorStyle clearImageDuringDownload:(BOOL)clear {
  [self imageNamed:imageName withView:view maskedColor:color greyscale:NO indicator:indicatorStyle clearImageDuringDownload:clear useiPhone6Prefix:NO];
}

+ (void) imageNamed:(NSString *)imageName withView:(UIView *)view greyscale:(BOOL)greyscale indicator: (UIActivityIndicatorViewStyle)indicatorStyle clearImageDuringDownload:(BOOL)clear {
  [self imageNamed:imageName withView:view maskedColor:nil greyscale:greyscale indicator:indicatorStyle clearImageDuringDownload:clear useiPhone6Prefix:NO];
}

+ (void) imageNamedWithiPhone6Prefix:(NSString *)imageName withView:(UIView *)view maskedColor:(UIColor *)color indicator: (UIActivityIndicatorViewStyle)indicatorStyle clearImageDuringDownload:(BOOL)clear {
  [self imageNamed:imageName withView:view maskedColor:color greyscale:NO indicator:indicatorStyle clearImageDuringDownload:clear useiPhone6Prefix:YES];
}

+ (void) imageNamedWithiPhone6Prefix:(NSString *)imageName withView:(UIView *)view greyscale:(BOOL)greyscale indicator: (UIActivityIndicatorViewStyle)indicatorStyle clearImageDuringDownload:(BOOL)clear {
  [self imageNamed:imageName withView:view maskedColor:nil greyscale:greyscale indicator:indicatorStyle clearImageDuringDownload:clear useiPhone6Prefix:YES];
}

+ (void) imageNamed:(NSString *)imageName withView:(UIView *)view maskedColor:(UIColor *)color greyscale:(BOOL)greyscale indicator: (UIActivityIndicatorViewStyle)indicatorStyle clearImageDuringDownload:(BOOL)clear useiPhone6Prefix:(BOOL)useiPhone6Prefix {
  // If imageName is null, it will clear the view's pre-downloading stuff
  // If view is null, it will download image without worrying about the view
  Globals *gl = [Globals sharedGlobals];
  NSString *key = [NSString stringWithFormat:@"%p", view];
  
  NSString *greyImageKey = [imageName stringByAppendingString:@"greyscale"];
  
  // Remove possible previous spinner
  UIActivityIndicatorView *loadingView = (UIActivityIndicatorView *)[view viewWithTag:150];
  [loadingView stopAnimating];
  [loadingView removeFromSuperview];
  
  if (!imageName || imageName.length == 0) {
    if ([view isKindOfClass:[UIImageView class]]) {
      [(UIImageView *)view setImage:nil];
    } else if ([view isKindOfClass:[UIButton class]]) {
      [(UIButton *)view setImage:nil forState:UIControlStateNormal];
    }
    return;
  }
  
  UIImage *cachedImage = imageName ? [gl.imageCache objectForKey:imageName] : nil;
  if (cachedImage) {
    if (color) {
      cachedImage = [self maskImage:cachedImage withColor:color];
    } else if (greyscale) {
      // Search for the cached greyscale image
      UIImage *greyImage = [gl.imageCache objectForKey:greyImageKey];
      if (greyImage) {
        cachedImage = greyImage;
      } else {
        cachedImage = [self greyScaleImageWithBaseImage:cachedImage];
        [gl.imageCache setObject:cachedImage forKey:greyImageKey];
      }
    }
    if ([view isKindOfClass:[UIImageView class]]) {
      [(UIImageView *)view setImage:cachedImage];
    } else if ([view isKindOfClass:[UIButton class]]) {
      [(UIButton *)view setImage:cachedImage forState:UIControlStateNormal];
    }
    
    return;
  }
  
  // Set up new spinner
  if (indicatorStyle >= 0 && ![view viewWithTag:150]) {
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:indicatorStyle];
    loadingView.tag = 150;
    [loadingView startAnimating];
    [view addSubview:loadingView];
    loadingView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
    
    // Set up scale
    float scale = MIN(1.f, MIN(view.frame.size.width/loadingView.frame.size.width/2.f, view.frame.size.width/loadingView.frame.size.width/2.f));
    loadingView.transform = CGAffineTransformMakeScale(scale, scale);
  }
  
  // Clear the previous image if required
  if (clear) {
    if ([view isKindOfClass:[UIImageView class]]) {
      [(UIImageView *)view setImage:nil];
    } else if ([view isKindOfClass:[UIButton class]]) {
      [(UIButton *)view setImage:nil forState:UIControlStateNormal];
    }
  }
  
  // Add key so we can grab it later
  // This also means, the image might be used for something else, in which case we wouldn't overwrite it.
  [[gl imageViewsWaitingForDownloading] setObject:imageName forKey:key];
  
  [self checkAndLoadFile:imageName useiPhone6Prefix:useiPhone6Prefix completion:^(BOOL success) {
    NSString *str = [[gl imageViewsWaitingForDownloading] objectForKey:key];
    if ([str isEqualToString:imageName]) {
      if (success) {
        NSString *path = [self pathToFile:imageName useiPhone6Prefix:useiPhone6Prefix];
        
        if (path) {
          UIImage *img = [UIImage imageWithContentsOfFile:path];
          
          if (img) {
            [gl.imageCache setObject:img forKey:imageName];
            if (color) {
              img = [self maskImage:img withColor:color];
            } else if (greyscale) {
              img = [self greyScaleImageWithBaseImage:img];
              [gl.imageCache setObject:img forKey:greyImageKey];
            }
          }
          
          if ([view isKindOfClass:[UIImageView class]]) {
            [(UIImageView *)view setImage:img];
          } else if ([view isKindOfClass:[UIButton class]]) {
            [(UIButton *)view setImage:img forState:UIControlStateNormal];
          }
        }
      }
      
      // Do some cleanup
      [[view viewWithTag:150] removeFromSuperview];
      [[gl imageViewsWaitingForDownloading] removeObjectForKey:key];
    }
  }];
}

+ (void) imageNamed:(NSString *)imageName toReplaceSprite:(CCSprite *)s {
  [Globals imageNamed:imageName toReplaceSprite:s completion:nil];
}

+ (void) imageNamed:(NSString *)imageName toReplaceSprite:(CCSprite *)s completion:(void(^)(BOOL success))completion {
  Globals *gl = [Globals sharedGlobals];
  NSString *key = [NSString stringWithFormat:@"%p", s];
  
  [[gl imageViewsWaitingForDownloading] setObject:imageName forKey:key];
  [self checkAndLoadFile:imageName useiPhone6Prefix:NO completion:^(BOOL success) {
    NSString *str = [[gl imageViewsWaitingForDownloading] objectForKey:key];
    if (success && [str isEqual:imageName]) {
      [s setSpriteFrame:[CCSpriteFrame frameWithImageNamed:imageName]];
    }
    
    if (completion) {
      completion(success);
    }
  }];
}

+ (NSString*) getDoubleResolutionImage:(NSString*)path useiPhone6Prefix:(BOOL)iPhone6Prefix {
  if ([path rangeOfString:@"http"].location != NSNotFound) {
    return path;
  }
  
  if (iPhone6Prefix) {
    if ([self isiPhone6] || [self isiPhone6Plus]) {
      path = [@"6" stringByAppendingString:path];
    }
    // Not using this atm
    else if ([self isiPhone6Plus]) {
      path = [@"6+" stringByAppendingString:path];
    }
  }
  
  int scale = [UIScreen mainScreen].scale;
  if(scale > 1) {
    NSString *pathWithoutExtension = [path stringByDeletingPathExtension];
    NSString *name = [pathWithoutExtension lastPathComponent];
    
    // check if path already has the suffix.
    if( [name rangeOfString:@"@2x"].location != NSNotFound ) {
      return path;
    }
    
    NSString *extension = [path pathExtension];
    
    if([extension isEqualToString:@"ccz"] || [extension isEqualToString:@"gz"]) {
      // All ccz / gz files should be in the format filename.xxx.ccz
      // so we need to pull off the .xxx part of the extension as well
      extension = [NSString stringWithFormat:@"%@.%@", [pathWithoutExtension pathExtension], extension];
      pathWithoutExtension = [pathWithoutExtension stringByDeletingPathExtension];
    }
    
    NSString *retinaName = [pathWithoutExtension stringByAppendingString:@"@2x"];
    retinaName = [retinaName stringByAppendingPathExtension:extension];
    
    return retinaName;
    
    CCLOG(@"cocos2d: CCFileUtils: Warning HD file not found: %@", [retinaName lastPathComponent] );
  }
  
  return path;
}

+ (void) setFrameForView:(UIView *)view forPoint:(CGPoint)pt {
  // place it so that the bottom middle is at pt
  // Remember, frame is relative to top left corner
  float width = view.frame.size.width;
  float height = view.frame.size.height;
  view.frame = CGRectMake(pt.x-width/2, ([[CCDirector sharedDirector] viewSize].height - pt.y)-height, width, height);
}

+ (NSArray *) convertCurrentTeamToArray:(UserCurrentMonsterTeamProto *)team {
  NSMutableArray *arr = [NSMutableArray array];
  for (FullUserMonsterProto *m in team.currentTeamList) {
    [arr addObject:[UserMonster userMonsterWithProto:m]];
  }
  return arr;
}

+ (NSDictionary *) convertUserTeamArrayToDictionary:(NSArray *)array {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  for (UserCurrentMonsterTeamProto *team in array) {
    [dict setObject:[self convertCurrentTeamToArray:team] forKey:team.userUuid];
  }
  return dict;
}

+ (BOOL) shouldShowFatKidDungeon {
  GameState *gs = [GameState sharedGameState];
  UserStruct *us = gs.myLaboratory;
  return us.staticStruct.structInfo.level > FAT_KID_DUNGEON_LEVEL || (us.staticStruct.structInfo.level == FAT_KID_DUNGEON_LEVEL && us.isComplete);
}

#pragma mark - Formulas

- (int) calculateGemSpeedupCostForTimeLeft:(int)timeLeft allowFreeSpeedup:(BOOL)free {
  // 5 mins are free
  if (free && timeLeft < self.maxMinutesForFreeSpeedUp*60) {
    return 0;
  }
  return MAX(1.f, ceilf(timeLeft/60.f/self.minutesPerGem));
}

- (int) calculateGemConversionForResourceType:(ResourceType)type amount:(int)amount {
  if (type == ResourceTypeCash || type == ResourceTypeOil) {
    return MAX(1, roundf(amount*self.gemsPerResource));
  }
  return amount;
}

- (int) baseStructIdForStructId:(int)structId {
  GameState *gs = [GameState sharedGameState];
  id<StaticStructure> ss = [gs structWithId:structId];
  while (ss.structInfo.predecessorStructId) {
    ss = [gs structWithId:ss.structInfo.predecessorStructId];
  }
  return ss.structInfo.structId;
}

- (int) calculateMaxQuantityOfStructId:(int)structId withTownHall:(TownHallProto *)thp {
  GameState *gs = [GameState sharedGameState];
  id<StaticStructure> ss = [gs structWithId:structId];
  
  switch (ss.structInfo.structType) {
    case StructureInfoProto_StructTypeHospital:
      return thp.numHospitals;
      break;
      
    case StructureInfoProto_StructTypeResidence:
      return thp.numResidences;
      break;
      
    case StructureInfoProto_StructTypeResourceGenerator:
    {
      ResourceGeneratorProto *rgp = (ResourceGeneratorProto *)ss;
      if (rgp.resourceType == ResourceTypeCash) {
        return thp.numResourceOneGenerators;
      } else if (rgp.resourceType == ResourceTypeOil) {
        return thp.numResourceTwoGenerators;
      }
      break;
    }
      
    case StructureInfoProto_StructTypeResourceStorage:
    {
      ResourceStorageProto *rsp = (ResourceStorageProto *)ss;
      if (rsp.resourceType == ResourceTypeCash) {
        return thp.numResourceOneStorages;
      } else if (rsp.resourceType == ResourceTypeOil) {
        return thp.numResourceTwoStorages;
      }
      break;
    }
      
    case StructureInfoProto_StructTypeLab:
      return thp.numLabs;
      
    case StructureInfoProto_StructTypeEvo:
      return thp.numEvoChambers;
      
    case StructureInfoProto_StructTypeTownHall:
      return 1;
      
    case StructureInfoProto_StructTypeTeamCenter:
      return 1;
      
    case StructureInfoProto_StructTypeMiniJob:
      return 1;
      
    case StructureInfoProto_StructTypeClan:
      return 1;
      
    default:
      break;
  }
  return 0;
}

- (int) calculateMaxQuantityOfStructId:(int)structId {
  GameState *gs = [GameState sharedGameState];
  TownHallProto *thp = (TownHallProto *)[[gs myTownHall] staticStructForCurrentConstructionLevel];
  return [self calculateMaxQuantityOfStructId:structId withTownHall:thp];
}

- (int) calculateNumberOfUnpurchasedStructs {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  int num = 0;
  for (id<StaticStructure> s in gs.staticStructs.allValues) {
    StructureInfoProto *structInfo = [s structInfo];
    if (!structInfo.predecessorStructId) {
      int cur = [gl calculateCurrentQuantityOfStructId:structInfo.structId structs:gs.myStructs];
      int max = [gl calculateMaxQuantityOfStructId:structInfo.structId];
      
      NSArray *prereqs = [gs prerequisitesForGameType:GameTypeStructure gameEntityId:structInfo.structId];
      
      BOOL satisfiesPrereqs = YES;
      for (PrereqProto *pre in prereqs) {
        if (![gl isPrerequisiteComplete:pre]) {
          satisfiesPrereqs = NO;
        }
      }
      
      if (cur < max && satisfiesPrereqs) {
        num += max-cur;
      }
    }
  }
  return num;
}

- (TownHallProto *) calculateNextTownHallForQuantityIncreaseForStructId:(int)structId {
  GameState *gs = [GameState sharedGameState];
  TownHallProto *thp = (TownHallProto *)[[gs myTownHall] staticStructForCurrentConstructionLevel];
  int curMax = [self calculateMaxQuantityOfStructId:structId withTownHall:thp];
  while (thp.structInfo.successorStructId) {
    thp = (TownHallProto *)[gs structWithId:thp.structInfo.successorStructId];
    int newMax = [self calculateMaxQuantityOfStructId:structId withTownHall:thp];
    
    if (newMax > curMax) {
      return thp;
    }
  }
  return nil;
}

- (int) calculateCurrentQuantityOfStructId:(int)structId structs:(NSArray *)structs {
  int quantity = 0;
  structId = [self baseStructIdForStructId:structId];
  
  for (UserStruct *us in structs) {
    if (us.baseStructId == structId) {
      quantity++;
    }
  }
  return quantity;
}

- (int) calculateNumMinutesForNewExpansion {
  GameState *gs = [GameState sharedGameState];
  NSInteger totalExp = gs.userExpansions.count;
  CityExpansionCostProto *exp = [gs.expansionCosts objectForKey:@(totalExp)];
  return exp.numMinutesToExpand;
}

- (int) calculateSilverCostForNewExpansion {
  GameState *gs = [GameState sharedGameState];
  NSInteger totalExp = gs.userExpansions.count;
  CityExpansionCostProto *exp = [gs.expansionCosts objectForKey:@(totalExp+1)];
  return exp.expansionCostCash;
}

- (NSString *) expansionPhraseForExpandSpot:(CGPoint)pt {
  int index = pt.x+1+(pt.y+1)*3;
  NSArray *phrases = [NSArray arrayWithObjects:
                      @"A magnificent parcel of land.",
                      @"A fresh parcel of land.",
                      @"A perfect parcel of land.",
                      @"A boring parcel of land.",
                      @""
                      @"A cool parcel of land.",
                      @"A supa-fresh parcel of land.",
                      @"A ridiculous parcel of land.",
                      @"A normal parcel of land.",
                      nil];
  return index < phrases.count && index >= 0 ? [phrases objectAtIndex:index] : @"";
}

- (int) calculateTotalDamageForMonster:(UserMonster *)um {
  int fire = [self calculateElementalDamageForMonster:um element:ElementFire];
  int water = [self calculateElementalDamageForMonster:um element:ElementWater];
  int earth = [self calculateElementalDamageForMonster:um element:ElementEarth];
  int light = [self calculateElementalDamageForMonster:um element:ElementLight];
  int night = [self calculateElementalDamageForMonster:um element:ElementDark];
  int rock = [self calculateElementalDamageForMonster:um element:ElementRock];
  
  return fire+water+earth+light+night+rock;
}

- (int) calculateElementalDamageForMonster:(UserMonster *)um element:(Element)element {
  MonsterProto *mp = um.staticMonster;
  MonsterLevelInfoProto *min = [mp.lvlInfoList firstObject];
  MonsterLevelInfoProto *max = [mp.lvlInfoList lastObject];
  
  int base = 0;
  int final = 0;
  switch (element) {
    case ElementFire:
      base = min.fireDmg;
      final = max.fireDmg;
      break;
    case ElementEarth:
      base = min.grassDmg;
      final = max.grassDmg;
      break;
    case ElementWater:
      base = min.waterDmg;
      final = max.waterDmg;
      break;
    case ElementLight:
      base = min.lightningDmg;
      final = max.lightningDmg;
      break;
    case ElementDark:
      base = min.darknessDmg;
      final = max.darknessDmg;
      break;
    case ElementRock:
      base = min.rockDmg;
      final = max.rockDmg;
      break;
    default:
      break;
  }
  
  return base+(final-base)*powf((um.level-1)/(float)(max.lvl-1), max.dmgExponentBase);
}

- (int) calculateMaxHealthForMonster:(UserMonster *)um {
  MonsterProto *mp = um.staticMonster;
  MonsterLevelInfoProto *min = [mp.lvlInfoList firstObject];
  MonsterLevelInfoProto *max = [mp.lvlInfoList lastObject];
  return min.hp+(max.hp-min.hp)*powf((um.level-1)/(float)(max.lvl-1), max.hpExponentBase);
}

- (int) calculateSpeedForMonster:(UserMonster *)um {
  MonsterProto *mp = um.staticMonster;
  MonsterLevelInfoProto *min = [mp.lvlInfoList firstObject];
  MonsterLevelInfoProto *max = [mp.lvlInfoList lastObject];
  return min.speed+(max.speed-min.speed)*powf((um.level-1)/(float)(max.lvl-1), 1);
}

- (int) calculateCostToHealMonster:(UserMonster *)um {
  return ceilf(([self calculateMaxHealthForMonster:um]-um.curHealth)*self.cashPerHealthPoint);
}

- (int) calculateOilCostForNewMonsterWithEnhancement:(UserEnhancement *)ue feeder:(EnhancementItem *)feeder {
  int additionalLevel = [ue currentPercentageOfLevel];
  return self.oilPerMonsterLevel*(ue.baseMonster.userMonster.level+additionalLevel);
}

- (int) calculateTotalOilCostForEnhancement:(UserEnhancement *)ue {
  int oilCost = 0;
  for (EnhancementItem *ei in ue.feeders) {
    oilCost += [self calculateOilCostForNewMonsterWithEnhancement:ue feeder:ei];
  }
  return oilCost;
}

- (int) calculateSecondsForEnhancement:(EnhancementItem *)baseMonster feeder:(EnhancementItem *)feeder {
  GameState *gs = [GameState sharedGameState];
  LabProto *lab = (LabProto *)gs.myLaboratory.staticStruct;
  
  int expGain = [self calculateExperienceIncrease:baseMonster feeder:feeder];
  return (int)ceilf(expGain/lab.pointsPerSecond);
}

- (int) calculateExperienceIncrease:(UserEnhancement *)ue {
  float change = 0;
  for (EnhancementItem *f in ue.feeders) {
    change += [self calculateExperienceIncrease:ue.baseMonster feeder:f];
  }
  
  return change;
}

- (int) calculateExperienceIncrease:(EnhancementItem *)baseMonster feeder:(EnhancementItem *)feeder {
  GameState *gs = [GameState sharedGameState];
  LabProto *lab = (LabProto *)[[gs myLaboratory] staticStruct];
  UserMonster *base = baseMonster.userMonster;
  UserMonster *um = feeder.userMonster;
  float multiplier1 = lab.pointsMultiplier ?: 1;
  float multiplier2 = base.staticMonster.monsterElement == um.staticMonster.monsterElement ? 1.5 : 1;
  return um.feederExp*multiplier1*multiplier2;
}

- (float) calculateLevelForMonster:(int)monsterId experience:(float)experience {
  // Should return a percentage towards next level as well
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:monsterId];
  
  // This for loop is basically not being used at the moment..
//  for (int i = 1; i < mp.lvlInfoList.count; i++) {
//    MonsterLevelInfoProto *info = mp.lvlInfoList[i];
//    if (experience < info.curLvlRequiredExp) {
//      MonsterLevelInfoProto *curInfo = mp.lvlInfoList[i-1];
//      int expForThisLevel = experience-curInfo.curLvlRequiredExp;
//      int totalExpTillNextLevel = [mp.lvlInfoList[i] curLvlRequiredExp]-curInfo.curLvlRequiredExp;
//      return curInfo.lvl+expForThisLevel/(float)totalExpTillNextLevel;
//    }
//  }
  
  // Start over..
  float level = 1;
  if (mp.lvlInfoList.count > 0) {
    MonsterLevelInfoProto *info = [mp.lvlInfoList lastObject];
    float maxExp = info.curLvlRequiredExp;
    level = powf(experience/maxExp, 1.f/info.expLvlExponent)*(info.expLvlDivisor-1)+1;
    
    int curLevel = (int)level;
    int nextLevel = curLevel+1;
    
    int curReqExp = [self calculateExperienceRequiredForMonster:monsterId level:curLevel];
    int nextReqExp = [self calculateExperienceRequiredForMonster:monsterId level:nextLevel];
    
    level = curLevel+(experience-curReqExp)/(float)(nextReqExp-curReqExp);
  }
  return MIN(mp.maxLevel, level);
}

- (int) calculateExperienceRequiredForMonster:(int)monsterId level:(int)level {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:monsterId];
  int experience = 0;
  if (mp.lvlInfoList.count > 0) {
    MonsterLevelInfoProto *info = [mp.lvlInfoList lastObject];
    float maxExp = info.curLvlRequiredExp;
    experience = ceilf(powf((level-1)/(info.expLvlDivisor-1), info.expLvlExponent)*maxExp);
  }
  return experience;
}

- (float) calculateDamageMultiplierForAttackElement:(Element)aElement defenseElement:(Element)dElement {
  switch (aElement) {
    case ElementFire:
      if (dElement == ElementEarth) return self.elementalStrength;
      if (dElement == ElementWater) return self.elementalWeakness;
      break;
      
    case ElementWater:
      if (dElement == ElementFire) return self.elementalStrength;
      if (dElement == ElementEarth) return self.elementalWeakness;
      break;
      
    case ElementEarth:
      if (dElement == ElementWater) return self.elementalStrength;
      if (dElement == ElementFire) return self.elementalWeakness;
      break;
      
    case ElementLight:
      if (dElement == ElementDark) return self.elementalStrength;
      break;
      
    case ElementDark:
      if (dElement == ElementLight) return self.elementalStrength;
      break;
      
    default:
      break;
  }
  return 1.f;
}

- (int) calculateGemCostToHealTeamDuringBattle:(NSArray *)team {
  GameState *gs = [GameState sharedGameState];
  int cashCost = 0;
  int gemCost = 0;
  
  for (BattlePlayer *bp in team) {
    UserMonster *um = [gs myMonsterWithUserMonsterUuid:bp.userMonsterUuid];
    cashCost += [self calculateCostToHealMonster:um];
  }
  gemCost += [self calculateGemConversionForResourceType:ResourceTypeCash amount:cashCost];
  
  NSMutableArray *fakeQueue = [NSMutableArray array];
  for (BattlePlayer *bp in team) {
    UserMonsterHealingItem *heal = [[UserMonsterHealingItem alloc] init];
    heal.queueTime = [MSDate date];
    heal.userMonsterId = bp.userMonsterId;
    [fakeQueue addObject:heal];
  }
  HospitalQueueSimulator *sim = [[HospitalQueueSimulator alloc] initWithHospitals:[gs allHospitals] healingItems:fakeQueue];
  [sim simulate];
  
  MSDate *lastDate = nil;
  for (HealingItemSim *hi in sim.healingItems) {
    if (!lastDate || [lastDate compare:hi.endTime] == NSOrderedAscending) {
      lastDate = hi.endTime;
    }
  }
  gemCost += [self calculateGemSpeedupCostForTimeLeft:lastDate.timeIntervalSinceNow allowFreeSpeedup:NO];
  
  return gemCost*self.continueBattleGemCostMultiplier;
}

- (int) calculateTeamCostForTeam:(NSArray *)team {
  int cost = 0;
  for (UserMonster *um in team) {
    cost += [um teamCost];
  }
  return cost;
}

- (BOOL) currentBattleReadyTeamHasCostFor:(UserMonster *)um {
  GameState *gs = [GameState sharedGameState];
  int teamCost = [self calculateTeamCostForTeam:gs.allBattleAvailableAliveMonstersOnTeam];
  int maxCost = gs.maxTeamCost;
  
  return [um teamCost] <= maxCost-teamCost;
}

- (int) evoChamberLevelToEvolveMonster:(int)monsterId {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:monsterId];
  MonsterProto *evo = [gs monsterWithId:mp.evolutionMonsterId];
  
  EvoChamberProto *ecp = nil;
  for (EvoChamberProto *ss in gs.staticStructs.allValues) {
    if (ss.structInfo.structType == StructureInfoProto_StructTypeEvo &&
        ss.qualityUnlocked == evo.quality && ss.evoTierUnlocked == evo.evolutionLevel) {
      ecp = ss;
      break;
    }
  }
  
  return ecp.structInfo.level;
}

- (BOOL) isPrerequisiteComplete:(PrereqProto *)prereq {
  GameState *gs = [GameState sharedGameState];
  int quantity = 0;
  
  if (prereq.prereqGameType == GameTypeStructure) {
    // Go through struct list
    for (UserStruct *us in gs.myStructs) {
      if ([us isAncestorOfStructId:prereq.prereqGameEntityId]) {
        quantity++;
      }
    }
  }
  
  return quantity >= prereq.quantity;
}

- (NSArray *) incompletePrereqsForStructId:(int)structId {
  GameState *gs = [GameState sharedGameState];
  NSArray *arr = [gs prerequisitesForGameType:GameTypeStructure gameEntityId:structId];
  
  NSMutableArray *inc = [NSMutableArray array];
  
  for (PrereqProto *pp in arr) {
    if (![self isPrerequisiteComplete:pp]) {
      [inc addObject:pp];
    }
  }
  
  return inc;
}

- (BOOL) satisfiesPrereqsForStructId:(int)structId {
  return [self incompletePrereqsForStructId:structId].count == 0;
}

#pragma mark - Alerts

+ (void) popupMessage:(NSString *)msg {
  [GenericPopupController displayNotificationViewWithText:msg title:@"Notification"];
}

+ (void) addAlertNotification:(NSString *)msg {
  [self addAlertNotification:msg isImmediate:YES];
}

+ (void) addAlertNotification:(NSString *)msg isImmediate:(BOOL)isImmediate {
  GameViewController *gvc = [GameViewController baseController];
  OneLineNotificationViewController *oln = [[OneLineNotificationViewController alloc] initWithNotificationString:msg color:NotificationColorRed isImmediate:isImmediate];
  [gvc.notificationController addNotification:oln];
}

+ (void) addGreenAlertNotification:(NSString *)msg {
  [self addGreenAlertNotification:msg isImmediate:NO];
}

+ (void) addGreenAlertNotification:(NSString *)msg isImmediate:(BOOL)isImmediate {
  GameViewController *gvc = [GameViewController baseController];
  OneLineNotificationViewController *oln = [[OneLineNotificationViewController alloc] initWithNotificationString:msg color:NotificationColorGreen isImmediate:isImmediate];
  [gvc.notificationController addNotification:oln];
}

+ (void) addPurpleAlertNotification:(NSString *)msg {
  GameViewController *gvc = [GameViewController baseController];
  OneLineNotificationViewController *oln = [[OneLineNotificationViewController alloc] initWithNotificationString:msg color:NotificationColorPurple isImmediate:NO];
  [gvc.notificationController addNotification:oln];
}

+ (void) addOrangeAlertNotification:(NSString *)msg {
  GameViewController *gvc = [GameViewController baseController];
  OneLineNotificationViewController *oln = [[OneLineNotificationViewController alloc] initWithNotificationString:msg color:NotificationColorOrange isImmediate:NO];
  [gvc.notificationController addNotification:oln];
}

+ (void) addBlueAlertNotification:(NSString *)msg {
  GameViewController *gvc = [GameViewController baseController];
  OneLineNotificationViewController *oln = [[OneLineNotificationViewController alloc] initWithNotificationString:msg color:NotificationColorBlue isImmediate:NO];
  [gvc.notificationController addNotification:oln];
}

#pragma mark - Bounce View
+ (void) bounceView:(UIView *)view fromScale:(float)fScale toScale:(float)tScale duration:(float)duration {
  view.layer.transform = CATransform3DMakeScale(fScale, fScale, 1.0);
  
  CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
  bounceAnimation.values = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:fScale],
                            [NSNumber numberWithFloat:1.1*tScale],
                            [NSNumber numberWithFloat:0.95*tScale],
                            [NSNumber numberWithFloat:tScale], nil];
  
  bounceAnimation.keyTimes = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0],
                              [NSNumber numberWithFloat:0.4],
                              [NSNumber numberWithFloat:0.7],
                              [NSNumber numberWithFloat:0.9],
                              [NSNumber numberWithFloat:1.0], nil];
  
  bounceAnimation.timingFunctions = [NSArray arrayWithObjects:
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], nil];
  
  bounceAnimation.duration = duration;
  [view.layer addAnimation:bounceAnimation forKey:@"bounce"];
  
  view.layer.transform = CATransform3DMakeScale(tScale, tScale, 1.0);
}

+ (void) bounceView:(UIView *)view {
  [self bounceView:view fromScale:0.3 toScale:1.f duration:0.5];
}

+ (void) bounceView:(UIView *)view fadeInBgdView:(UIView *)bgdView completion:(void (^)(BOOL finished))completed {
  view.alpha = 0;
  bgdView.alpha = 0;
  [UIView animateWithDuration:0.15 animations:^{
    view.alpha = 0.99f;
    bgdView.alpha = 0.99f;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.35 animations:^{
      view.alpha = 1.f;
      bgdView.alpha = 1.f;
    } completion:completed];
  }];
  [self bounceView:view];
  
  [SoundEngine menuPopUp];
}

+ (void) bounceView:(UIView *)view fadeInBgdView:(UIView *)bgdView {
  [self bounceView:view fadeInBgdView:bgdView completion:nil];
}

+ (void) popOutView:(UIView *)view fadeOutBgdView:(UIView *)bgdView completion:(void (^)(void))completed {
  [UIView animateWithDuration:0.3 animations:^{
    view.alpha = 0.f;
    bgdView.alpha = 0.f;
    view.transform = CGAffineTransformMakeScale(2.0, 2.0);
  } completion:^(BOOL finished) {
    view.transform = CGAffineTransformIdentity;
    if (completed) {
      completed();
    }
  }];
}

+ (NSString *) urlStringForFacebookId:(NSString *)uid {
  return [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=200&height=200&pic=/%@.png", uid, uid];
}

+ (BOOL) isSmallestiPhone {
  return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [self screenSize].width == 480.0);
}

+ (BOOL) isiPhone6 {
  return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [self screenSize].width == 667.0);
}

+ (BOOL) isiPhone6Plus {
  return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [self screenSize].width == 736.0);
}

#pragma mark Colors
+ (UIColor *)creamColor {
  return [UIColor colorWithRed:240/255.f green:237/255.f blue:213/255.f alpha:1.f];
}

+ (UIColor *)goldColor {
  return [UIColor colorWithRed:255/255.f green:195/255.f blue:0/255.f alpha:1.f];
}

+ (UIColor *)greenColor {
  return [UIColor colorWithRed:154/255.f green:205/255.f blue:43/255.f alpha:1.f];
}

+ (UIColor *)orangeColor {
  return [UIColor colorWithRed:255/255.f green:102/255.f blue:0/255.f alpha:1.f];
}

+ (UIColor *)redColor {
  return [UIColor colorWithRed:185/255.f green:13/255.f blue:13/255.f alpha:1.f];
}

+ (UIColor *)lightRedColor {
  return [UIColor colorWithRed:255/255.f green:46/255.f blue:0/255.f alpha:1.f];
}

+ (UIColor *)blueColor {
  return [UIColor colorWithRed:4/255.f green:161/255.f blue:206/255.f alpha:1.f];
}

+ (UIColor *)purpleColor {
  return [UIColor colorWithRed:111/255.f green:16/255.f blue:178/255.f alpha:1.f];
}

+ (UIColor *)purplishPinkColor {
  return [UIColor colorWithRed:157/255.f green:9/255.f blue:170/255.f alpha:1.f];
}

+ (UIColor *)yellowColor {
  return [UIColor colorWithRed:217/255.f green:158/255.f blue:0/255.f alpha:1.f];
}

+ (UIColor *)greyishTanColor {
  return [UIColor colorWithRed:120/255.f green:117/255.f blue:98/255.f alpha:1.f];
}

+ (NSString *) bazaarQuestGiverName {
  return @"Bizzaro Byrone";
}

+ (NSString *) homeQuestGiverName {
  return @"Ruby";
}

#define ARROW_ANIMATION_DURATION 0.5f
#define ARROW_ANIMATION_DISTANCE 14
#define ARROW_TAG 123152
+ (void) animateUIArrow:(UIView *)arrow atAngle:(float)angle {
  [arrow.layer removeAllAnimations];
  float rotation = -M_PI_2-angle;
  arrow.layer.transform = CATransform3DMakeScale(1.f, 0.9f, 1.f);
  arrow.layer.transform = CATransform3DRotate(arrow.layer.transform, rotation, 0.0f, 0.0f, 1.0f);
  UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
  [UIView animateWithDuration:ARROW_ANIMATION_DURATION delay:0.f options:opt animations:^{
    arrow.layer.transform = CATransform3DMakeRotation(rotation, 0.0f, 0.0f, 1.0f);
    arrow.center = CGPointMake(arrow.center.x-ARROW_ANIMATION_DISTANCE*cosf(angle), arrow.center.y+ARROW_ANIMATION_DISTANCE*sinf(angle));
  } completion:nil];
}

+ (CGPoint) pointOnRect:(CGRect)r atAngle:(float)angle {
  float vx = cosf(angle);
  float vy = sinf(angle);
  CGPoint pt1 = r.origin;
  CGPoint pt2 = ccp(pt1.x+r.size.width, pt1.y+r.size.height);
  CGPoint p = ccp(pt1.x+r.size.width/2, pt1.y+r.size.height/2);
  
  float tl = -1, tr = -1, tu = -1, tb = -1;
  
  if (ABS(vx) > 0.01) {
    tl = (pt1.x-p.x)/vx;
    tr = (pt2.x-p.x)/vx;
  }
  if (ABS(vy) > 0.01) {
    tu = (pt1.y-p.y)/vy;
    tb = (pt2.y-p.y)/vy;
  }
  
  float t = MAXFLOAT;
  if (tl > 0 && tl < t) {
    t = tl;
  } if (tr > 0 && tr < t) {
    t = tr;
  } if (tu > 0 && tu < t) {
    t = tu;
  } if (tb > 0 && tb < t) {
    t = tb;
  }
  
  return ccp(p.x+t*vx, p.y+t*vy);
}

+ (void) createUIArrowForView:(UIView *)view atAngle:(float)angle {
  UIImageView *img = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"arrow.png"]];
  [view.superview addSubview:img];
  
  CGPoint pt = [self pointOnRect:CGRectInset(view.frame, -20, -20) atAngle:-angle];
  img.center = pt;
  img.tag = ARROW_TAG;
  
  [self animateUIArrow:img atAngle:M_PI+angle];
  img.alpha = 0.f;
  [UIView animateWithDuration:0.3f animations:^{
    img.alpha = 1.f;
  }];
  
  UIImageView *light = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"arrowlight.png"]];
  [img addSubview:light];
  
  light.alpha = 1.f;
  [UIView animateWithDuration:ARROW_ANIMATION_DURATION delay:0.f options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
    light.alpha = 0.f;
  } completion:nil];
}

+ (void) removeUIArrowFromViewRecursively:(UIView *)view {
  if (view.tag == ARROW_TAG) {
    [UIView animateWithDuration:0.3f animations:^{
      view.alpha = 0.f;
    } completion:^(BOOL finished) {
      [view removeFromSuperview];
    }];
  }
  for (UIView *v in view.subviews) {
    [self removeUIArrowFromViewRecursively:v];
  }
}

+ (void) animateCCArrow:(CCNode *)arrow atAngle:(float)angle {
  arrow.rotation = CC_RADIANS_TO_DEGREES(-M_PI_2-angle);
  
  float scaleX = arrow.scaleX;
  float scaleY = arrow.scaleY;
  CCActionMoveBy *upAction = [CCActionEaseInOut actionWithAction:[CCActionSpawn actions:
                                                                  [CCActionMoveTo actionWithDuration:ARROW_ANIMATION_DURATION position:ccpAdd(arrow.position, ccp(-ARROW_ANIMATION_DISTANCE*cosf(angle), -ARROW_ANIMATION_DISTANCE*sinf(angle)))],
                                                                  [CCActionScaleTo actionWithDuration:ARROW_ANIMATION_DURATION scaleX:scaleX scaleY:scaleY],
                                                                  nil]];
  CCActionMoveBy *downAction = [CCActionEaseInOut actionWithAction:[CCActionSpawn actions:
                                                                    [CCActionMoveTo actionWithDuration:ARROW_ANIMATION_DURATION position:arrow.position],
                                                                    [CCActionScaleTo actionWithDuration:ARROW_ANIMATION_DURATION scaleX:scaleX scaleY:0.9f*scaleY],
                                                                    nil]];
  CCAction *a = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:upAction, downAction, nil]];
  a.tag = 1953;
  [arrow stopActionByTag:a.tag];
  [arrow runAction:a];
}

- (BOOL) validateUserName:(NSString *)name {
  // make sure length is okay
  if (name.length < self.minNameLength) {
    [Globals addAlertNotification:[NSString stringWithFormat:@"Your name must be atleast %d character%@.", self.minNameLength, self.minNameLength == 1 ? @"" : @"s"]];
    return NO;
  } else if (name.length > self.maxNameLength) {
    [Globals addAlertNotification:[NSString stringWithFormat:@"Your name must be less than %d characters.", self.maxNameLength]];
    return NO;
  }
  
  // make sure there are no obvious swear words
  NSString *lowerStr = [name lowercaseString];
  NSArray *swearWords = [NSArray arrayWithObjects:@"fuck", @"shit", @"bitch", nil];
  for (NSString *swear in swearWords) {
    if ([lowerStr rangeOfString:swear].location != NSNotFound) {
      [Globals addAlertNotification:@"Please refrain from using vulgar language within this game."];
      return NO;
    }
  }
  return YES;
}

+ (NSString *) fullNameWithName:(NSString *)name clanTag:(NSString *)tag {
  if (tag.length > 0) {
    return [NSString stringWithFormat:@"%@ [%@]", name, tag];
  } else {
    return name;
  }
}

- (void) openAppStoreLink {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.appStoreLink]];
}

#define RATE_US_POPUP_DEFAULT_KEY @"RateUsLastPopupTimeKey"
#define RATE_US_CLICKED_LATER @"RateUsClickedLater"
#define RATE_US_CLICKED_REVIEW @"RateUsClickedReview"

+ (void) checkRateUsPopup {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  MSDate *lastSeen = [defaults objectForKey:RATE_US_POPUP_DEFAULT_KEY];
  if (!lastSeen) {
    [[Globals sharedGlobals] displayRateUsPopup];
    [defaults setObject:[NSDate date] forKey:RATE_US_POPUP_DEFAULT_KEY];
  }
}

- (void) displayRateUsPopup {
  GameState *gs = [GameState sharedGameState];
  NSString *desc = [NSString stringWithFormat:@"Hey %@! Are you enjoying %@?", gs.name, GAME_NAME];
  [GenericPopupController displayConfirmationWithDescription:desc title:[NSString stringWithFormat:@"Enjoying %@?", GAME_ABBREV] okayButton:@"Yes" cancelButton:@"No" okTarget:self okSelector:@selector(userClickedLike) cancelTarget:self cancelSelector:@selector(userClickedDislike)];
}

- (void) userClickedDislike {
  [Globals popupMessage:@"Thank you for the feedback. Email support@lvl6.com with suggestions."];
}

- (void) userClickedLike {
  NSString *desc = self.reviewPageConfirmationMessage;
  [GenericPopupController displayConfirmationWithDescription:desc title:@"Rate Us!" okayButton:@"Rate" cancelButton:@"Later" okTarget:self okSelector:@selector(rateUs) cancelTarget:self cancelSelector:@selector(later)];
}

- (void) rateUs {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.reviewPageURL]];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:RATE_US_CLICKED_REVIEW];
}

- (void) later {
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:RATE_US_CLICKED_LATER];
}

+ (void) adjustViewForCentering:(UIView *)view withLabel:(UILabel *)label {
  [self adjustView:view withLabel:label forXAnchor:0.5];
}

+ (void) adjustView:(UIView *)view withLabel:(UILabel *)label forXAnchor:(float)xAnchor {
  CGSize size = [label.text getSizeWithFont:label.font constrainedToSize:label.frame.size lineBreakMode:label.lineBreakMode];
  float oldX = view.frame.origin.x+xAnchor*view.frame.size.width;
  
  CGRect r = view.frame;
  r.size.width = [view convertPoint:label.frame.origin fromView:label.superview].x + size.width;
  r.origin.x = oldX-r.size.width*xAnchor;
  view.frame = r;
}

+ (UIColor *) colorForColorProto:(ColorProto *)cp {
  return [UIColor colorWithRed:cp.red/255.f green:cp.green/255.f blue:cp.blue/255.f alpha:255.f];
}

- (InAppPurchasePackageProto *) packageForProductId:(NSString *)pid {
  return [self.productIdsToPackages objectForKey:pid];
}

+ (BOOL) checkEnteringDungeon {
  return [self checkEnteringDungeonWithTarget:[GameViewController baseController] noTeamSelector:@selector(pointArrowOnManageTeam) inventoryFullSelector:@selector(pointArrowOnSellMobsters)];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
+ (BOOL) checkEnteringDungeonWithTarget:(id)target noTeamSelector:(SEL)noTeamSelector inventoryFullSelector:(SEL)inventoryFullSelector {
  // Check that team is valid
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  NSArray *team = [gs allBattleAvailableMonstersOnTeam];
  BOOL hasValidTeam = NO;
  BOOL hasDeadMonster = NO;
  for (UserMonster *um in team) {
    if (um.curHealth > 0) {
      hasValidTeam = YES;
    } else {
      hasDeadMonster = YES;
    }
  }
  
  BOOL hasFullTeam = team.count >= gl.maxTeamSize && !hasDeadMonster;
  BOOL hasAvailMobsters = NO;
  for (UserMonster *um in gs.myMonsters) {
    if ([um isAvailable] && !um.teamSlot && um.curHealth > 0 && [gl currentBattleReadyTeamHasCostFor:um]) {
      hasAvailMobsters = YES;
    }
  }
  
  if (!hasValidTeam) {
    NSString *description = @"";
    if (team.count == 0) {
      description = [NSString stringWithFormat:@"You have no %@s on your team. Manage your team now.", MONSTER_NAME];
    } else {
      description = [NSString stringWithFormat:@"Uh oh, you have no healthy %@s on your team. Manage your team now.", MONSTER_NAME];
    }
    [Globals addAlertNotification:description];
    [target performSelector:noTeamSelector];
    
    return NO;
  } else if (!hasFullTeam && hasAvailMobsters) {
    NSString *description = [NSString stringWithFormat:@"You have healthy %@s available. Manage your team now.", MONSTER_NAME];
    
    [Globals addGreenAlertNotification:description isImmediate:YES];
    [target performSelector:noTeamSelector];
    
    return NO;
  }
  
  // Check that inventory is not full
  NSInteger curInvSize = gs.myMonsters.count;
  if (curInvSize > gs.maxInventorySlots) {
    // Let the selector control the notification
    // NSString *description = [NSString stringWithFormat:@"Your residences are full. Sell %@s to free up space.", MONSTER_NAME];
    // [Globals addAlertNotification:description];
    [target performSelector:inventoryFullSelector];
    return NO;
  }
  
  return YES;
}
#pragma clang diagnostic pop

+ (void) animateStartView:(UIView *)startView toEndView:(UIView *)endView fakeStartView:(UIView *)fakeStart fakeEndView:(UIView *)fakeEnd {
  fakeStart.center = [fakeStart.superview convertPoint:startView.center fromView:startView.superview];
  fakeEnd.center = fakeStart.center;
  fakeStart.alpha = 1.f;
  fakeEnd.alpha = 0.f;
  fakeStart.transform = CGAffineTransformIdentity;
  fakeEnd.transform = CGAffineTransformIdentity;
  
  startView.hidden = YES;
  endView.hidden = YES;
  [UIView animateWithDuration:0.3f animations:^{
    fakeEnd.alpha = 1.f;
    fakeEnd.center = [fakeEnd.superview convertPoint:endView.center fromView:endView.superview];
    
    float scale = fakeEnd.frame.size.width/fakeStart.frame.size.width;
    fakeStart.transform = CGAffineTransformMakeScale(scale, scale);
    fakeStart.center = fakeEnd.center;
    fakeStart.alpha = 0.f;
  } completion:^(BOOL finished) {
    // In case this start and view get asked to something else
    if (finished) {
      [fakeStart removeFromSuperview];
      [fakeEnd removeFromSuperview];
    }
    
    startView.hidden = NO;
    endView.hidden = NO;
  }];
}

+ (NSString *) getRandomTipFromFile:(NSString *)file {
  NSError *e;
  NSString *s = [[NSBundle mainBundle] pathForResource:file.lastPathComponent.stringByDeletingPathExtension ofType:@"txt"];
  NSString *fileContents = [NSString stringWithContentsOfFile:s encoding:NSUTF8StringEncoding error:&e];
  if (fileContents) {
    NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];
    NSMutableArray *mut = [lines mutableCopy];
    [mut shuffle];
    NSString *first = mut[0];
    first = [first stringByReplacingOccurrencesOfString:@"x_character" withString:MONSTER_NAME];
    return first;
  }
  return nil;
}

#pragma mark - Muting Players

- (void) muteUserId:(int)userId {
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  NSMutableDictionary *dict = [[def dictionaryForKey:MUTED_PLAYERS_KEY] mutableCopy];
  
  if (!dict) {
    dict = [NSMutableDictionary dictionary];
  }
  
  [dict setObject:[NSDate date] forKey:[NSString stringWithFormat:@"%d", userId]];
  [def setObject:dict forKey:MUTED_PLAYERS_KEY];
}

- (BOOL) isUserIdMuted:(int)userId {
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  NSMutableDictionary *dict = [[def dictionaryForKey:MUTED_PLAYERS_KEY] mutableCopy];
  NSDate *date = [dict objectForKey:[NSString stringWithFormat:@"%d", userId]];
  date = [date dateByAddingTimeInterval:24*60*60];
  
  return date && date.timeIntervalSinceNow > 0;
}

- (void) unmuteAllPlayers {
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  [def removeObjectForKey:MUTED_PLAYERS_KEY];
}

@end

@implementation CCNode (RecursiveOpacity)

- (void) recursivelyApplyOpacity:(CGFloat)opacity {
  self.opacity = opacity;
  if ([self isKindOfClass:[CCProgressNode class]]) {
    self.visible = opacity > 0.6f;
  }
  for (CCNode *c in self.children) {
    [c recursivelyApplyOpacity:opacity];
  }
}

- (void) recursivelyApplyColor:(CCColor *)color {
  self.color = color;
  for (CCNode *c in self.children) {
    [c recursivelyApplyColor:color];
  }
}

@end

@implementation RecursiveFadeTo

-(void) update: (CCTime) t
{
	[_target recursivelyApplyOpacity:_fromOpacity + ( _toOpacity - _fromOpacity ) * t];
}

@end

@implementation RecursiveTintTo

-(void) update: (CCTime) t
{
	CCNode* tn = (CCNode*) _target;
  
	ccColor4F fc = _from.ccColor4f;
	ccColor4F tc = _to.ccColor4f;
  
	[tn recursivelyApplyColor:[CCColor colorWithRed:fc.r + (tc.r - fc.r) * t green:fc.g + (tc.g - fc.g) * t blue:fc.b + (tc.b - fc.b) * t alpha:tn.opacity]];
}

@end

@implementation NSMutableArray (ShufflingAndCloning)

- (void) shuffle
{
  NSUInteger count = [self count];
  for (NSUInteger i = 0; i < count; ++i) {
    
    // Select a random element between i and end of array to swap with.
    NSInteger nElements = count - i;
    NSInteger n = (arc4random() % nElements) + i;
    
    [self exchangeObjectAtIndex:i withObjectAtIndex:n];
  }
}

- (id) clone {
  NSMutableArray *arr = [NSMutableArray array];
  for (id object in self) {
    [arr addObject:[object copy]];
  }
  return arr;
}

- (NSArray *)reversedArray {
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
  NSEnumerator *enumerator = [self reverseObjectEnumerator];
  for (id element in enumerator) {
    [array addObject:element];
  }
  return array;
}

@end

@implementation CCActionEaseRate (BaseRate)

- (CCActionInterval *) initWithAction:(CCActionInterval *)action {
  return [self initWithAction:action rate:2];
}

@end

@implementation CCNode (UIImage)

- (UIImage *) UIImage {
  CCRenderTexture* renderer = [CCRenderTexture renderTextureWithWidth:self.contentSize.width height:self.contentSize.height];
  
  const CGPoint ANCHORBEFORE = self.anchorPoint;
  self.anchorPoint = CGPointZero;
  
  [renderer begin];
  [self visit];
  [renderer end];
  self.anchorPoint = ANCHORBEFORE;
  
  return [renderer getUIImage];
}

@end

@implementation PBArray (NSArrayCreation)

- (NSArray *) toNSArray {
  NSMutableArray *arr = [NSMutableArray array];
  for (int i = 0; i < self.count; i++) {
    [arr addObject:[self objectAtIndexedSubscript:i]];
  }
  return arr;
}

@end
