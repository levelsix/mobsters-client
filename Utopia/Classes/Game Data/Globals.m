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
  NSMutableArray *arr = [NSMutableArray array];
  for (InAppPurchasePackageProto *pkg in self.iapPackages) {
    [arr addObject:pkg];
  }
  self.iapPackages = arr;
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
  
  self.maxTeamSize = constants.userMonsterConstants.maxNumTeamSlots;
  self.baseInventorySize = constants.userMonsterConstants.initialMaxNumMonsterLimit;
  
  self.cashPerHealthPoint = constants.monsterConstants.cashPerHealthPoint;
  self.elementalStrength = constants.monsterConstants.elementalStrength;
  self.elementalWeakness = constants.monsterConstants.elementalWeakness;
  
  self.coinPriceToCreateClan = constants.clanConstants.hasCoinPriceToCreateClan;
  self.maxCharLengthForClanName = constants.clanConstants.maxCharLengthForClanName;
  self.maxCharLengthForClanDescription = constants.clanConstants.maxCharLengthForClanDescription;
  self.maxCharLengthForClanTag = constants.clanConstants.maxCharLengthForClanTag;
  
  self.tournamentWinsWeight = constants.touramentConstants.winsWeight;
  self.tournamentLossesWeight = constants.touramentConstants.lossesWeight;
  self.tournamentFleesWeight = constants.touramentConstants.fleesWeight;
  self.tournamentNumHrsToDisplayAfterEnd = constants.touramentConstants.numHoursToShowAfterEventEnd;
  
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

+ (void) downloadAllFilesForSpritePrefixes:(NSArray *)spritePrefixes completion:(void (^)(void))completed {
  __block int i = 0;
  for (NSString *spritePrefix in spritePrefixes) {
    for (NSString *str in @[@"%@RunNF.plist", @"%@AttackNF.plist", @"%@Card.png"]) {
      i++;
      NSString *fileName = [NSString stringWithFormat:str, spritePrefix];
      NSString *doubleRes = [self getDoubleResolutionImage:fileName];
      [[Downloader sharedDownloader] asyncDownloadFile:doubleRes completion:^{
        if ([fileName.pathExtension isEqualToString:@"plist"]) {
          NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[Globals pathToFile:fileName]];
          NSDictionary *metadataDict = [dict objectForKey:@"metadata"];
          NSString *texturePath = [metadataDict objectForKey:@"textureFileName"];
          [[Downloader sharedDownloader] asyncDownloadFile:texturePath completion:^{
            i--;
            if (i == 0) {
              completed();
            }
          }];
        } else {
          i--;
          if (i == 0) {
            completed();
          }
        }
      }];
    }
  }
}

+ (NSString *) font {
  return fontName;
}

+ (int) fontSize {
  return fontSize;
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

+ (NSString *) imageNameForConstructionWithSize:(CGSize)size {
  return [NSString stringWithFormat:@"ConstructionSite%dx%d.png", (int)size.width, (int)size.height];
}

+ (NSString *) imageNameForStruct:(int)structId {
  StructureInfoProto *fsp = [[[GameState sharedGameState] structWithId:structId] structInfo];
  NSString *str = [fsp.name.capitalizedString stringByReplacingOccurrencesOfString:@" " withString:@""];
  str = [str stringByReplacingOccurrencesOfString:@"'" withString:@""];
  str = [str stringByReplacingOccurrencesOfString:@"-" withString:@""];
  NSString *file = [str stringByAppendingString:@".png"];
  return file;
}

+ (UIImage *) imageForStruct:(int)structId {
  return structId == 0 ? nil : [self imageNamed:[self imageNameForStruct:structId]];
}

+ (void) loadImageForStruct:(int)structId toView:(UIImageView *)view masked:(BOOL)mask indicator:(UIActivityIndicatorViewStyle)indicator {
  if (!structId || !view) return;
  [self imageNamed:[self imageNameForStruct:structId] withView:view greyscale:mask indicator:indicator clearImageDuringDownload:YES];
}

+ (UIColor *) colorForRarity:(MonsterProto_MonsterQuality)rarity {
  switch (rarity) {
    case MonsterProto_MonsterQualityCommon:
      return [self creamColor];
      
    case MonsterProto_MonsterQualityRare:
      return [self blueColor];
      
    case MonsterProto_MonsterQualityUltra:
      return [self yellowColor];
      
    case MonsterProto_MonsterQualityEpic:
      return [self purpleColor];
      
    case MonsterProto_MonsterQualityLegendary:
      return [self redColor];
      
    case MonsterProto_MonsterQualityEvo:
      return [self orangeColor];
      
    default:
      break;
  }
}

+ (UIColor *) colorForElementOnDarkBackground:(MonsterProto_MonsterElement)element {
  ccColor3B c;
  switch (element) {
    case MonsterProto_MonsterElementDarkness:
      c = ccc3(129, 7, 181);
      break;
      
    case MonsterProto_MonsterElementWater:
      c = ccc3(10, 220, 210);
      break;
      
    case MonsterProto_MonsterElementFire:
      c = ccc3(220, 40, 0);
      break;
      
    case MonsterProto_MonsterElementLightning:
      c = ccc3(255, 215, 0);
      break;
      
    case MonsterProto_MonsterElementGrass:
      c = ccc3(100, 220, 20);
      break;
      
    case MonsterProto_MonsterElementRock:
      c = ccc3(100, 100, 100);
      break;
      
    default:
      c = ccc3(255, 255, 255);
      break;
  }
  return [UIColor colorWithRed:c.r/255.f green:c.g/255.f blue:c.b/255.f alpha:1.f];
}

+ (UIColor *) colorForElementOnLightBackground:(MonsterProto_MonsterElement)element {
  ccColor3B c;
  switch (element) {
    case MonsterProto_MonsterElementDarkness:
      c = ccc3(128, 59, 185);
      break;
      
    case MonsterProto_MonsterElementWater:
      c = ccc3(36, 158, 195);
      break;
      
    case MonsterProto_MonsterElementFire:
      c = ccc3(209, 63, 37);
      break;
      
    case MonsterProto_MonsterElementLightning:
      c = ccc3(177, 121, 71);
      break;
      
    case MonsterProto_MonsterElementGrass:
      c = ccc3(96, 146, 25);
      break;
      
    case MonsterProto_MonsterElementRock:
      c = ccc3(77, 82, 84);
      break;
      
    default:
      c = ccc3(255, 255, 255);
      break;
  }
  return [UIColor colorWithRed:c.r/255.f green:c.g/255.f blue:c.b/255.f alpha:1.f];
}

+ (NSString *) stringForRarity:(MonsterProto_MonsterQuality)rarity {
  switch (rarity) {
    case MonsterProto_MonsterQualityCommon:
      return @"Common";
      
    case MonsterProto_MonsterQualityRare:
      return @"Rare";
      
    case MonsterProto_MonsterQualityUltra:
      return @"Ultra";
      
    case MonsterProto_MonsterQualityEpic:
      return @"Epic";
      
    case MonsterProto_MonsterQualityLegendary:
      return @"Legend";
      
    default:
      return nil;
      break;
  }
}

+ (NSString *) imageNameForRarity:(MonsterProto_MonsterQuality)rarity suffix:(NSString *)str {
  NSString *base = [[[self stringForRarity:rarity] stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
  return [base stringByAppendingString:str];
}

+ (NSString *) shortenedStringForRarity:(MonsterProto_MonsterQuality)rarity {
  NSString *str = [self stringForRarity:rarity];
  
  if (str.length > 4) {
    str = [str stringByReplacingCharactersInRange:NSMakeRange(3, str.length-3) withString:@"."];
  }
  return [str uppercaseString];
}

+ (NSString *) stringForElement:(MonsterProto_MonsterElement)element {
  switch (element) {
    case MonsterProto_MonsterElementDarkness:
      return @"Night";
      
    case MonsterProto_MonsterElementFire:
      return @"Fire";
      
    case MonsterProto_MonsterElementGrass:
      return @"Earth";
      
    case MonsterProto_MonsterElementLightning:
      return @"Light";
      
    case MonsterProto_MonsterElementWater:
      return @"Water";
      
    case MonsterProto_MonsterElementRock:
      return @"Rock";
      
    default:
      return nil;
      break;
  }
}

+ (NSString *) imageNameForElement:(MonsterProto_MonsterElement)element suffix:(NSString *)str {
  NSString *base = [[self stringForElement:element] lowercaseString];
  return [base stringByAppendingString:str];
}

+ (NSString *) stringForTimeSinceNow:(NSDate *)date shortened:(BOOL)shortened {
  int time = -1*[date timeIntervalSinceNow];
  
  
  if (time < 0) {
    return @"In the future!";
  }
  
  int interval = 1;
  if (time < interval*60) {
    return [NSString stringWithFormat:@"%d %@%@ ago", time / interval, shortened ? @"sec" : @"second", time / interval != 1 ? @"s" : @""];
  }
  
  interval *= 60;
  if (time < interval*60) {
    return [NSString stringWithFormat:@"%d %@%@ ago", time / interval, shortened ? @"min" : @"minute", time / interval != 1 ? @"s" : @""];
  }
  
  interval *= 60;
  if (time < interval*24) {
    return [NSString stringWithFormat:@"%d %@%@ ago", time / interval, shortened ? @"hr" : @"hour", time / interval != 1 ? @"s" : @""];
  }
  
  interval *= 24;
  if (time < interval*7) {
    return [NSString stringWithFormat:@"%d day%@ ago", time / interval, time / interval != 1 ? @"s" : @""];
  }
  
  interval *= 7;
  if (time < interval*4) {
    return [NSString stringWithFormat:@"%d week%@ ago", time / interval, time / interval != 1 ? @"s" : @""];
  }
  
  // Approximate the size of a month to 30 days
  interval = interval/7*30;
  if (time < interval*12) {
    return [NSString stringWithFormat:@"%d month%@ ago", time / interval, time / interval != 1 ? @"s" : @""];
  }
  
  interval = interval/30*365;
  return [NSString stringWithFormat:@"%d year%@ ago", time / interval, time / interval != 1 ? @"s" : @""];
}

+ (void) adjustFontSizeForSize:(int)size withUIView:(UIView *)somethingWithText {
  if ([somethingWithText respondsToSelector:@selector(setFont:)]) {
    UIFont *f = [UIFont fontWithName:[self font] size:size];
    [somethingWithText performSelector:@selector(setFont:) withObject:f];
    
    // Move frame down to account for this font
    CGRect tmp = somethingWithText.frame;
    tmp.origin.y += FONT_LABEL_OFFSET * size / [self fontSize];
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
    toRet = [toRet stringByAppendingString:[[NSString stringWithFormat:@"%g", r] substringFromIndex:1]];
  }
  
  return toRet;
}

+ (void) calculateDifferencesBetweenOldArray:(NSArray *)oArr newArray:(NSArray *)nArr removalIps:(NSMutableArray *)removals additionIps:(NSMutableArray *)additions section:(int)section {
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
}

+ (UIImage *) snapShotView:(UIView *)view {
  UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.f);
  [view.layer renderInContext:UIGraphicsGetCurrentContext()];
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

+ (NSString *) pathToFile:(NSString *)fileName {
  if (!fileName) {
    return nil;
  }
  
  // prevents overloading the autorelease pool
  NSString *resName = [self getDoubleResolutionImage:fileName];
  NSString *fullpath = [[NSBundle mainBundle] pathForResource:resName ofType:nil];
  
  // Added for Utopia project
  if (!fullpath) {
    // Image not in NSBundle: look in documents
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    fullpath = [documentsPath stringByAppendingPathComponent:resName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullpath]) {
      // Map not in docs: download it
      [[Downloader sharedDownloader] syncDownloadFile:fullpath.lastPathComponent];
    }
  }
  
  return fullpath;
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
  if (!path) {
    return nil;
  }
  
  Globals *gl = [Globals sharedGlobals];
  UIImage *cachedImage = [gl.imageCache objectForKey:path];
  if (cachedImage) {
    return cachedImage;
  }
  
  // prevents overloading the autorelease pool
  NSString *resName = [self getDoubleResolutionImage:path];
  UIImage *image = nil;
  NSString *fullpath = [[NSBundle mainBundle] pathForResource:resName ofType:nil];
  
  // Added for Utopia project
  if (!fullpath) {
    // Image not in NSBundle: look in documents
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    BOOL fileExists = NO;
    fullpath = [documentsPath stringByAppendingPathComponent:resName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullpath]) {
      fileExists = YES;
    }
    
    if (!fileExists) {
      // Image not in docs: download it
      [[Downloader sharedDownloader] syncDownloadFile:fullpath.lastPathComponent];
    }
  }
  
  image = [UIImage imageWithContentsOfFile:fullpath];
  
  if (image) {
    [gl.imageCache setObject:image forKey:path];
  }
  
  return image;
}

+ (void) imageNamed:(NSString *)imageName withView:(UIView *)view maskedColor:(UIColor *)color indicator: (UIActivityIndicatorViewStyle)indicatorStyle clearImageDuringDownload:(BOOL)clear {
  [self imageNamed:imageName withView:view maskedColor:color greyscale:NO indicator:indicatorStyle clearImageDuringDownload:clear];
}

+ (void) imageNamed:(NSString *)imageName withView:(UIView *)view greyscale:(BOOL)greyscale indicator: (UIActivityIndicatorViewStyle)indicatorStyle clearImageDuringDownload:(BOOL)clear {
  [self imageNamed:imageName withView:view maskedColor:nil greyscale:greyscale indicator:indicatorStyle clearImageDuringDownload:clear];
}

+ (void) imageNamed:(NSString *)imageName withView:(UIView *)view maskedColor:(UIColor *)color greyscale:(BOOL)greyscale indicator: (UIActivityIndicatorViewStyle)indicatorStyle clearImageDuringDownload:(BOOL)clear {
  // If imageName is null, it will clear the view's pre-downloading stuff
  // If view is null, it will download image without worrying about the view
  Globals *gl = [Globals sharedGlobals];
  NSString *key = [NSString stringWithFormat:@"%p", view];
  [[gl imageViewsWaitingForDownloading] removeObjectForKey:key];
  
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
      cachedImage = [self greyScaleImageWithBaseImage:cachedImage];
    }
    if ([view isKindOfClass:[UIImageView class]]) {
      [(UIImageView *)view setImage:cachedImage];
    } else if ([view isKindOfClass:[UIButton class]]) {
      [(UIButton *)view setImage:cachedImage forState:UIControlStateNormal];
      
      // For Armory View Controller
      CGRect r = view.frame;
      r.origin.y = CGRectGetMaxY(r)-cachedImage.size.height;
      r.size = cachedImage.size;
      view.frame = r;
    }
    
    return;
  }
  
  NSString *resName =  [imageName rangeOfString:@"http"].location != NSNotFound ? imageName : [self getDoubleResolutionImage:imageName];
  NSString *fullpath = [[NSBundle mainBundle] pathForResource:resName ofType:nil];
  
  if (!fullpath) {
    // Image not in NSBundle: look in documents
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    fullpath = [documentsPath stringByAppendingPathComponent:resName.lastPathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullpath]) {
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
      
      if (clear) {
        if ([view isKindOfClass:[UIImageView class]]) {
          [(UIImageView *)view setImage:nil];
        } else if ([view isKindOfClass:[UIButton class]]) {
          [(UIButton *)view setImage:nil forState:UIControlStateNormal];
        }
      }
      
      [[gl imageViewsWaitingForDownloading] setObject:imageName forKey:key];
      
      [[Downloader sharedDownloader] asyncDownloadFile:resName completion:^{
        NSString *str = [[gl imageViewsWaitingForDownloading] objectForKey:key];
        if ([str isEqualToString:imageName]) {
          UIImage *img = [UIImage imageWithContentsOfFile:fullpath];
          
          if (img) {
            [gl.imageCache setObject:img forKey:imageName];
          }
          if (color) {
            img = [self maskImage:img withColor:color];
          } else if (greyscale) {
            img = [self greyScaleImageWithBaseImage:img];
          }
          
          if ([view isKindOfClass:[UIImageView class]]) {
            [(UIImageView *)view setImage:img];
          } else if ([view isKindOfClass:[UIButton class]]) {
            [(UIButton *)view setImage:img forState:UIControlStateNormal];
            
            // For Armory View Controller
            CGRect r = view.frame;
            r.origin.y = CGRectGetMaxY(r)-img.size.height;
            r.size = img.size;
            view.frame = r;
          }
          
          UIActivityIndicatorView *loadingView = (UIActivityIndicatorView *)[view viewWithTag:150];
          [loadingView stopAnimating];
          [loadingView removeFromSuperview];
          [[gl imageViewsWaitingForDownloading] removeObjectForKey:key];
        }
      }];
      return;
    }
  }
  
  UIImage* image = [UIImage imageWithContentsOfFile:fullpath];
  UIView *loader = [view viewWithTag:150];
  if (loader) {
    [loader removeFromSuperview];
  }
  
  if (image) {
    [gl.imageCache setObject:image forKey:imageName];
    
    if (color) {
      image = [self maskImage:image withColor:color];
    } else if (greyscale) {
      image = [self greyScaleImageWithBaseImage:image];
    }
    
    if ([view isKindOfClass:[UIImageView class]]) {
      [(UIImageView *)view setImage:image];
    } else if ([view isKindOfClass:[UIButton class]]) {
      [(UIButton *)view setImage:image forState:UIControlStateNormal];
      
      // For Armory View Controller
      CGRect r = view.frame;
      r.origin.y = CGRectGetMaxY(r)-image.size.height;
      r.size = image.size;
      view.frame = r;
    }
    view.hidden = NO;
  }
}

+ (void) imageNamed:(NSString *)imageName toReplaceSprite:(CCSprite *)s {
  Globals *gl = [Globals sharedGlobals];
  NSString *key = [NSString stringWithFormat:@"%p", s];
  [[gl imageViewsWaitingForDownloading] removeObjectForKey:key];
  
  NSString *resName = [self getDoubleResolutionImage:imageName];
  NSString *fullpath = [[NSBundle mainBundle] pathForResource:resName ofType:nil];
  
  if (!fullpath) {
    // Image not in NSBundle: look in documents
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    fullpath = [documentsPath stringByAppendingPathComponent:resName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullpath]) {
      [[gl imageViewsWaitingForDownloading] setObject:imageName forKey:key];
      
      [[Downloader sharedDownloader] asyncDownloadFile:fullpath.lastPathComponent completion:^{
        NSString *str = [[gl imageViewsWaitingForDownloading] objectForKey:key];
        if ([str isEqualToString:imageName]) {
          if ([[NSFileManager defaultManager] fileExistsAtPath:fullpath]) {
            CCSprite *newSprite = [CCSprite spriteWithImageNamed:imageName];
            [s.parent addChild:newSprite];
            newSprite.position = s.position;
            newSprite.anchorPoint = s.anchorPoint;
            newSprite.scale = s.scale;
          }
          [s removeFromParentAndCleanup:YES];
        }
      }];
      return;
    }
  }
  
  CCSprite *newSprite = [CCSprite spriteWithImageNamed:imageName];
  [s.parent addChild:newSprite];
  newSprite.position = s.position;
  newSprite.anchorPoint = s.anchorPoint;
  newSprite.scale = s.scale;
  [s removeFromParentAndCleanup:YES];
  
}

+ (void) setFrameForView:(UIView *)view forPoint:(CGPoint)pt {
  // place it so that the bottom middle is at pt
  // Remember, frame is relative to top left corner
  float width = view.frame.size.width;
  float height = view.frame.size.height;
  view.frame = CGRectMake(pt.x-width/2, ([[CCDirector sharedDirector] viewSize].height - pt.y)-height, width, height);
}

+ (NSDictionary *) convertUserTeamArrayToDictionary:(NSArray *)array {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  for (UserCurrentMonsterTeamProto *team in array) {
    NSMutableArray *arr = [NSMutableArray array];
    for (FullUserMonsterProto *m in team.currentTeamList) {
      [arr addObject:[UserMonster userMonsterWithProto:m]];
    }
    [dict setObject:arr forKey:@(team.userId)];
  }
  return dict;
}

// Formulas

- (int) calculateGemSpeedupCostForTimeLeft:(int)timeLeft {
  return MAX(0.f, ceilf(timeLeft/60.f/self.minutesPerGem));
}

- (int) calculateGemConversionForResourceType:(ResourceType)type amount:(int)amount {
  if (type == ResourceTypeCash || type == ResourceTypeOil) {
    return ceilf(amount*self.gemsPerResource);
  }
  return amount;
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
      
    case StructureInfoProto_StructTypeTownHall:
      return 1;
      
    default:
      break;
  }
  return 0;
}

- (int) calculateMaxQuantityOfStructId:(int)structId {
  GameState *gs = [GameState sharedGameState];
  TownHallProto *thp = (TownHallProto *)[[gs myTownHall] staticStruct];
  return [self calculateMaxQuantityOfStructId:structId withTownHall:thp];
}

- (int) calculateNextTownHallLevelForQuantityIncreaseForStructId:(int)structId {
  GameState *gs = [GameState sharedGameState];
  TownHallProto *thp = (TownHallProto *)[[gs myTownHall] staticStruct];
  int curMax = [self calculateMaxQuantityOfStructId:structId withTownHall:thp];
  while (thp.structInfo.successorStructId) {
    thp = (TownHallProto *)[gs structWithId:thp.structInfo.successorStructId];
    int newMax = [self calculateMaxQuantityOfStructId:structId withTownHall:thp];
    
    if (newMax > curMax) {
      return thp.structInfo.level;
    }
  }
  return 0;
}

- (int) calculateCurrentQuantityOfStructId:(int)structId structs:(NSArray *)structs {
  int quantity = 0;
  
  for (UserStruct *us in structs) {
    if (us.baseStructId == structId) {
      quantity++;
    }
  }
  return quantity;
}

- (int) calculateNumMinutesForNewExpansion {
  GameState *gs = [GameState sharedGameState];
  int totalExp = gs.userExpansions.count;
  CityExpansionCostProto *exp = [gs.expansionCosts objectForKey:@(totalExp)];
  return exp.numMinutesToExpand;
}

- (int) calculateSilverCostForNewExpansion {
  GameState *gs = [GameState sharedGameState];
  int totalExp = gs.userExpansions.count;
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
  int fire = [self calculateElementalDamageForMonster:um element:MonsterProto_MonsterElementFire];
  int water = [self calculateElementalDamageForMonster:um element:MonsterProto_MonsterElementWater];
  int earth = [self calculateElementalDamageForMonster:um element:MonsterProto_MonsterElementGrass];
  int light = [self calculateElementalDamageForMonster:um element:MonsterProto_MonsterElementLightning];
  int night = [self calculateElementalDamageForMonster:um element:MonsterProto_MonsterElementDarkness];
  
  return fire+water+earth+light+night;
}

- (int) calculateElementalDamageForMonster:(UserMonster *)um element:(MonsterProto_MonsterElement)element {
  MonsterLevelInfoProto *li = um.currentLevelInfo;
  
  int base = 0;
  switch (element) {
    case MonsterProto_MonsterElementFire:
      base = li.fireDmg;
      break;
    case MonsterProto_MonsterElementGrass:
      base = li.grassDmg;
      break;
    case MonsterProto_MonsterElementWater:
      base = li.waterDmg;
      break;
    case MonsterProto_MonsterElementLightning:
      base = li.lightningDmg;
      break;
    case MonsterProto_MonsterElementDarkness:
      base = li.darknessDmg;
      break;
    case MonsterProto_MonsterElementRock:
      base = li.rockDmg;
      break;
  }
  return base;
}

- (int) calculateMaxHealthForMonster:(UserMonster *)um {
  return um.currentLevelInfo.hp;
}

- (int) calculateCostToHealMonster:(UserMonster *)um {
  return ceilf(([self calculateMaxHealthForMonster:um]-um.curHealth)*self.cashPerHealthPoint);
}

- (int) calculateOilCostForEnhancement:(EnhancementItem *)baseMonster feeder:(EnhancementItem *)feeder {
  UserMonster *um = baseMonster.userMonster;
  return 100*um.level;
}

- (int) calculateSecondsForEnhancement:(EnhancementItem *)baseMonster feeder:(EnhancementItem *)feeder {
  GameState *gs = [GameState sharedGameState];
  LabProto *lab = (LabProto *)gs.myLaboratory.staticStruct;
  
  int expGain = [self calculateExperienceIncrease:baseMonster feeder:feeder];
  return (int)ceilf(expGain/lab.pointsPerSecond);
}

- (int) calculateTimeLeftForEnhancement:(UserEnhancement *)ue {
  int timeLeft = 0;
  for (int i = 0; i < ue.feeders.count; i++) {
    EnhancementItem *item = [ue.feeders objectAtIndex:i];
    if (i == 0) {
      timeLeft += [item.expectedEndTime timeIntervalSinceNow];
    } else {
      timeLeft += [item secondsForCompletion];
    }
  }
  return timeLeft;
}

- (int) calculateExperienceIncrease:(UserEnhancement *)ue {
  float change = 0;
  for (EnhancementItem *f in ue.feeders) {
    change += [self calculateExperienceIncrease:ue.baseMonster feeder:f];
  }
  
  return change;
}

- (int) calculateExperienceIncrease:(EnhancementItem *)baseMonster feeder:(EnhancementItem *)feeder {
  UserMonster *um = feeder.userMonster;
  return um.currentLevelInfo.feederExp;
}

- (float) calculateLevelForMonster:(int)monsterId experience:(int)experience {
  // Should return a percentage towards next level as well
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:monsterId];
  
  for (int i = 1; i < mp.lvlInfoList.count; i++) {
    MonsterLevelInfoProto *info = mp.lvlInfoList[i];
    if (experience < info.curLvlRequiredExp) {
      MonsterLevelInfoProto *curInfo = mp.lvlInfoList[i-1];
      int expForThisLevel = experience-curInfo.curLvlRequiredExp;
      int totalExpTillNextLevel = [mp.lvlInfoList[i] curLvlRequiredExp]-curInfo.curLvlRequiredExp;
      return curInfo.lvl+expForThisLevel/(float)totalExpTillNextLevel;
    }
  }
  return mp.maxLevel;
}

- (float) calculateDamageMultiplierForAttackElement:(MonsterProto_MonsterElement)aElement defenseElement:(MonsterProto_MonsterElement)dElement {
  switch (aElement) {
    case MonsterProto_MonsterElementFire:
      if (dElement == MonsterProto_MonsterElementGrass) return self.elementalStrength;
      if (dElement == MonsterProto_MonsterElementWater) return self.elementalWeakness;
      break;
      
    case MonsterProto_MonsterElementWater:
      if (dElement == MonsterProto_MonsterElementFire) return self.elementalStrength;
      if (dElement == MonsterProto_MonsterElementGrass) return self.elementalWeakness;
      break;
      
    case MonsterProto_MonsterElementGrass:
      if (dElement == MonsterProto_MonsterElementWater) return self.elementalStrength;
      if (dElement == MonsterProto_MonsterElementFire) return self.elementalWeakness;
      break;
      
    case MonsterProto_MonsterElementLightning:
      if (dElement == MonsterProto_MonsterElementDarkness) return self.elementalStrength;
      break;
      
    case MonsterProto_MonsterElementDarkness:
      if (dElement == MonsterProto_MonsterElementLightning) return self.elementalStrength;
      break;
      
    default:
      break;
  }
  return 1.f;
}

+ (void) popupMessage:(NSString *)msg {
  [GenericPopupController displayNotificationViewWithText:msg title:@"Notification"];
}

+ (void) addAlertNotification:(NSString *)msg {
  GameViewController *gvc = [GameViewController baseController];
  OneLineNotificationViewController *oln = gvc.notifViewController;
  [oln addNotification:msg color:[self lightRedColor]];
}

#pragma mark Bounce View
+ (void) bounceView:(UIView *)view
{
  view.layer.transform = CATransform3DMakeScale(0.3, 0.3, 1.0);
  
  CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
  bounceAnimation.values = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.3],
                            [NSNumber numberWithFloat:1.1],
                            [NSNumber numberWithFloat:0.95],
                            [NSNumber numberWithFloat:1.0], nil];
  
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
  
  bounceAnimation.duration = 0.5;
  [view.layer addAnimation:bounceAnimation forKey:@"bounce"];
  
  view.layer.transform = CATransform3DIdentity;
}

+ (void) bounceView:(UIView *)view fadeInBgdView:(UIView *)bgdView completion:(void (^)(BOOL))completed {
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
    if (finished && completed) {
      completed();
    }
  }];
}

+ (NSString *) urlStringForFacebookId:(NSString *)uid {
  return [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=200&height=200&pic=/%@.png", uid, uid];
}

+ (BOOL)isLongiPhone {
  return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568.0);
}

#pragma mark Colors
+ (UIColor *)creamColor {
  return [UIColor colorWithRed:240/255.f green:237/255.f blue:213/255.f alpha:1.f];
}

+ (UIColor *)goldColor {
  return [UIColor colorWithRed:255/255.f green:200/255.f blue:0/255.f alpha:1.f];
}

+ (UIColor *)greenColor {
  return [UIColor colorWithRed:89/255.f green:145/255.f blue:17/255.f alpha:1.f];
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

#define ARROW_ANIMATION_DURATION 0.7f
#define ARROW_ANIMATION_DISTANCE 14
#define ARROW_TAG 123152
+ (void) animateUIArrow:(UIView *)arrow atAngle:(float)angle {
  [arrow.layer removeAllAnimations];
  float rotation = -M_PI_2-angle;
  arrow.layer.transform = CATransform3DMakeRotation(rotation, 0.0f, 0.0f, 1.0f);
  arrow.layer.transform = CATransform3DScale(arrow.layer.transform, 1.f, 0.9f, 1.f);
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
  
  if (abs(vx) > 0.1) {
    tl = (pt1.x-p.x)/vx;
    tr = (pt2.x-p.x)/vx;
  }
  if (abs(vy) > 0.1) {
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
  
  CGPoint pt = [self pointOnRect:CGRectInset(view.frame, -16, -16) atAngle:-angle];
  img.center = pt;
  img.tag = ARROW_TAG;
  
  [self animateUIArrow:img atAngle:M_PI+angle];
  img.alpha = 0.f;
  [UIView animateWithDuration:0.3f animations:^{
    img.alpha = 1.f;
  }];
}

+ (void) removeUIArrowFromViewRecursively:(UIView *)view {
  if (view.tag == ARROW_TAG) {
    [UIView animateWithDuration:0.3f animations:^{
      view.alpha = 0.f;
    } completion:^(BOOL finished) {
      [view removeFromSuperview];
    }];
    [view removeFromSuperview];
  }
  for (UIView *v in view.subviews) {
    [self removeUIArrowFromViewRecursively:v];
  }
}

+ (void) animateCCArrow:(CCNode *)arrow atAngle:(float)angle {
  [arrow stopAllActions];
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
  [arrow runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:upAction, downAction, nil]]];
}

- (BOOL) validateUserName:(NSString *)name {
  // make sure length is okay
  if (name.length < self.minNameLength) {
    [Globals popupMessage:[NSString stringWithFormat:@"Your name must be atleast %d characters.", self.minNameLength]];
    return NO;
  } else if (name.length > self.maxNameLength) {
    [Globals popupMessage:[NSString stringWithFormat:@"Your name must be less than %d characters.", self.maxNameLength]];
    return NO;
  }
  
  // make sure there are no obvious swear words
  NSString *lowerStr = [name lowercaseString];
  NSArray *swearWords = [NSArray arrayWithObjects:@"fuck", @"shit", @"bitch", nil];
  for (NSString *swear in swearWords) {
    if ([lowerStr rangeOfString:swear].location != NSNotFound) {
      [Globals popupMessage:@"Please refrain from using vulgar language within this game."];
      return NO;
    }
  }
  return YES;
}

+ (NSString *) fullNameWithName:(NSString *)name clanTag:(NSString *)tag {
  if (tag.length > 0) {
    return [NSString stringWithFormat:@"[%@] %@", tag, name];
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
  NSDate *lastSeen = [defaults objectForKey:RATE_US_POPUP_DEFAULT_KEY];
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
  CGSize size = [label.text sizeWithFont:label.font constrainedToSize:label.frame.size lineBreakMode:label.lineBreakMode];
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

+ (BOOL) userHasBeginnerShield:(uint64_t)createTime hasActiveShield:(BOOL)hasActiveShield {
  if (!hasActiveShield) {
    return NO;
  }
  
  uint64_t curTime = [[NSDate date] timeIntervalSince1970]*1000.;
  uint64_t shieldEndTime = createTime + sharedGlobals.defaultDaysBattleShieldIsActive*24*60*60*1000;
  
  return curTime < shieldEndTime;
}

+ (BOOL) checkEnteringDungeonWithTarget:(id)target selector:(SEL)selector {
  // Check that team is valid
  GameState *gs = [GameState sharedGameState];
  //  Globals *gl = [Globals sharedGlobals];
  NSArray *team = [gs allMonstersOnMyTeam];
  BOOL hasValidTeam = NO;
  for (UserMonster *um in team) {
    if (um.curHealth > 0) {
      hasValidTeam = YES;
    }
  }
  
  if (!hasValidTeam) {
    NSString *description = @"";
    if (team.count == 0) {
      description = @"Uh oh, you have no mobsters on your team. Manage your team?";
    } else {
      description = @"Uh oh, your mobsters are out of health. Manage your team?";
    }
    [GenericPopupController displayConfirmationWithDescription:description title:@"Can't Begin" okayButton:@"Manage" cancelButton:@"Later" target:target selector:selector];
    
    return NO;
  }
  
  // Check that inventory is not full
  int curInvSize = gs.myMonsters.count;
  if (curInvSize > gs.maxInventorySlots) {
    NSString *description = @"Uh oh, you have recruited too many mobsters. Manage your team?";
    [GenericPopupController displayConfirmationWithDescription:description title:@"Can't Begin" okayButton:@"Manage" cancelButton:@"Later" target:target selector:selector];
    return NO;
  }
  
  return YES;
}

- (int) calculateGemCostToHealTeamDuringBattle:(NSArray *)team {
  GameState *gs = [GameState sharedGameState];
  int cashCost = 0;
  int gemCost = 0;
  
  for (BattlePlayer *bp in team) {
    UserMonster *um = [gs myMonsterWithUserMonsterId:bp.userMonsterId];
    cashCost += [self calculateCostToHealMonster:um];
  }
  gemCost += [self calculateGemConversionForResourceType:ResourceTypeCash amount:cashCost];
  
  NSMutableArray *fakeQueue = [NSMutableArray array];
  for (BattlePlayer *bp in team) {
    UserMonsterHealingItem *heal = [[UserMonsterHealingItem alloc] init];
    heal.queueTime = [NSDate date];
    heal.userMonsterId = bp.userMonsterId;
    [fakeQueue addObject:heal];
  }
  HospitalQueueSimulator *sim = [[HospitalQueueSimulator alloc] initWithHospitals:[gs allHospitals] healingItems:fakeQueue];
  [sim simulate];
  
  NSDate *lastDate = nil;
  for (HealingItemSim *hi in sim.healingItems) {
    if (!lastDate || [lastDate compare:hi.endTime] == NSOrderedAscending) {
      lastDate = hi.endTime;
    }
  }
  gemCost += [self calculateGemSpeedupCostForTimeLeft:lastDate.timeIntervalSinceNow];
  
  return gemCost*self.continueBattleGemCostMultiplier;
}

+ (NSString*) getDoubleResolutionImage:(NSString*)path {
	if([CCDirector sharedDirector].contentScaleFactor == 2) {
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
