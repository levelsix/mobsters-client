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
#import "GameLayer.h"
#import "HomeMap.h"
#import "OutgoingEventController.h"
#import "GameViewController.h"
#import "OpenUDID.h"
#import "SocketCommunication.h"
#import "ODIN.h"
#import "AppDelegate.h"

#define FONT_LABEL_OFFSET 1.f
#define SHAKE_DURATION 0.05f
#define PULSE_TIME 0.8f

#define BUNDLE_SCHEDULE_INTERVAL 30

@implementation Globals

static NSString *fontName = @"Dirty Headline";
static int fontSize = 12;

SYNTHESIZE_SINGLETON_FOR_CLASS(Globals);

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
    InAppPurchasePackageProto *pkg2 = [[[InAppPurchasePackageProto builderWithPrototype:pkg] setIapPackageId:[@"com.lvl6.kingdom." stringByAppendingString:pkg.iapPackageId.pathExtension] ] build];
    [arr addObject:pkg2];
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
  
  self.diamondPriceToCreateClan = constants.clanConstants.diamondPriceToCreateClan;
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
    NSString *hrsStr = hrs == 0 ? @"" : [NSString stringWithFormat:@" %dH", hrs];
    return [NSString stringWithFormat:@"%dD%@", days, hrsStr];
  }
  
  if (hrs > 0) {
    NSString *minsStr = mins == 0 ? @"" : [NSString stringWithFormat:@" %dM", mins];
    return [NSString stringWithFormat:@"%dH%@", hrs, minsStr];
  }
  
  if (mins > 0) {
    NSString *secsStr = secs == 0 ? @"" : [NSString stringWithFormat:@" %dS", secs];
    return [NSString stringWithFormat:@"%dM%@", mins, secsStr];
  }

  return [NSString stringWithFormat:@"%dS", secs];
}

+ (NSString *) imageNameForConstructionWithSize:(CGSize)size {
  return [NSString stringWithFormat:@"ConstructionSite%dx%d.png", (int)size.width, (int)size.height];
}

+ (NSString *) imageNameForStruct:(int)structId {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:structId];
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
  [self imageNamed:[self imageNameForStruct:structId] withView:view maskedColor:mask ? [UIColor colorWithWhite:0.f alpha:0.7f] : nil indicator:indicator clearImageDuringDownload:YES];
}

+ (UIColor *) colorForRarity:(MonsterProto_MonsterQuality)rarity {
  switch (rarity) {
    case MonsterProto_MonsterQualityCommon:
      return [self creamColor];
      
    case MonsterProto_MonsterQualityUncommon:
      return [self greenColor];
      
    case MonsterProto_MonsterQualityRare:
      return [self blueColor];
      
    case MonsterProto_MonsterQualityUltra:
      return [self goldColor];
      
    case MonsterProto_MonsterQualityEpic:
      return [self purpleColor];
      
    case MonsterProto_MonsterQualityLegendary:
      return [self redColor];
      
    default:
      break;
  }
}

+ (NSString *) stringForRarity:(MonsterProto_MonsterQuality)rarity {
  switch (rarity) {
    case MonsterProto_MonsterQualityCommon:
      return @"Common";
      
    case MonsterProto_MonsterQualityUncommon:
      return @"Uncommon";
      
    case MonsterProto_MonsterQualityRare:
      return @"Rare";
      
    case MonsterProto_MonsterQualityUltra:
      return @"Super Rare";
      
    case MonsterProto_MonsterQualityEpic:
      return @"Epic";
      
    case MonsterProto_MonsterQualityLegendary:
      return @"Legendary";
      
    default:
      break;
  }
}

+ (NSString *) shortenedStringForRarity:(MonsterProto_MonsterQuality)rarity {
  NSString *str = [self stringForRarity:rarity];
  
  if (rarity == MonsterProto_MonsterQualityUltra) {
    return @"S. RA";
  }
  
  if (str.length > 4) {
    str = [str stringByReplacingCharactersInRange:NSMakeRange(3, str.length-3) withString:@"."];
  }
  return [str uppercaseString];
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

+ (NSString *) commafyNumber:(int) n {
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
  return s.length > 0 ? [pre stringByAppendingString:s] : @"0";
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
  GameViewController *gvc = [[((UINavigationController *)ad.window.rootViewController) childViewControllers] objectAtIndex:0];
  UIView *sv = nil;
  
  if (gvc.presentedViewController) {
    // For menu being presented as a modal controller
    sv = gvc.presentedViewController.view;
    
    CGRect r = view.frame;
    r.size.width = MIN(r.size.width, sv.frame.size.height);
    view.frame = r;
    
    view.center = CGPointMake(sv.frame.size.height/2, sv.frame.size.width/2);
  } else {
    sv = gvc.view;
    
    CGRect r = view.frame;
    r.size.width = MIN(r.size.width, sv.frame.size.width);
    view.frame = r;
    
    view.center = CGPointMake(sv.frame.size.width/2, sv.frame.size.height/2);
  }
  
  [sv addSubview:view];
}

+ (void) displayUIViewWithoutAdjustment:(UIView *)view {
//  UIView *sv = [[GameViewController sharedGameViewController] view];
//  view.center = CGPointMake(sv.frame.size.width/2, sv.frame.size.height/2);
//  [sv addSubview:view];
#warning fix
  [self displayUIView:view];
}

+ (NSString *) pathToFile:(NSString *)fileName {
  if (!fileName) {
    return nil;
  }
  
  // prevents overloading the autorelease pool
  NSString *resName = [CCFileUtils getDoubleResolutionImage:fileName validate:NO];
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
  NSString *resName = [CCFileUtils getDoubleResolutionImage:path validate:NO];
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
  
  NSString *resName = [CCFileUtils getDoubleResolutionImage:imageName validate:NO];
  NSString *fullpath = [[NSBundle mainBundle] pathForResource:resName ofType:nil];
  
  if (!fullpath) {
    // Image not in NSBundle: look in documents
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    fullpath = [documentsPath stringByAppendingPathComponent:resName];
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
      
      [[Downloader sharedDownloader] asyncDownloadFile:fullpath.lastPathComponent completion:^{
        NSString *str = [[gl imageViewsWaitingForDownloading] objectForKey:key];
        if ([str isEqualToString:imageName]) {
          NSString *resName = [CCFileUtils getDoubleResolutionImage:imageName validate:NO];
          NSArray *paths = NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES);
          NSString *documentsPath = [paths objectAtIndex:0];
          NSString *fullpath = [documentsPath stringByAppendingPathComponent:resName];
          UIImage *img = [UIImage imageWithContentsOfFile:fullpath];
          
          if (img) {
            [gl.imageCache setObject:img forKey:imageName];
          }
          if (color) {
            img = [self maskImage:img withColor:color];
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
  
  NSString *resName = [CCFileUtils getDoubleResolutionImage:imageName validate:NO];
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
            CCSprite *newSprite = [CCSprite spriteWithFile:imageName];
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
  
  CCSprite *newSprite = [CCSprite spriteWithFile:imageName];
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
  view.frame = CGRectMake(pt.x-width/2, ([[CCDirector sharedDirector] winSize].height - pt.y)-height, width, height);
}

+ (NSString *) nameForDialogueSpeaker:(DialogueProto_SpeechSegmentProto_DialogueSpeaker)speaker {
  switch (speaker) {
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerPlayerType:
      return [[GameState sharedGameState] name];
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver1:
      return @"Farmer Mitch";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver2:
      return @"Captain Riz";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver3:
      return @"Sean the Brave";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver4:
      return @"Captain Riz";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver5:
      return @"Sailor Steve";
    default:
      return nil;
      break;
  }
}

+ (NSString *) imageNameForDialogueSpeaker:(DialogueProto_SpeechSegmentProto_DialogueSpeaker)speaker {
  switch (speaker) {
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver1:
      return @"dialoguemitch.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver2:
      return @"dialogueriz.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver3:
      return @"dialoguesean.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver4:
      return @"dialogueriz.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver5:
      return @"dialoguesteve.png";
      break;
    default:
      return nil;
      break;
  }
}

+ (NSString *) imageNameForBigDialogueSpeaker:(DialogueProto_SpeechSegmentProto_DialogueSpeaker)speaker {
  switch (speaker) {
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerPlayerType:
      return nil;
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver1:
      return @"bigmitch2.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver2:
      return @"bigriz2.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver3:
      return @"bigsean2.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver4:
      return @"bigriz2.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver5:
      return @"bigsteve2.png";
      break;
    default:
      return nil;
      break;
  }
}

// Formulas

- (int) calculateDiamondCostForSpeedupWithBaseCost:(int)baseCost timeRemaining:(int)timeRemaining totalTime:(int)totalTime {
  float speedupMultiplierConstant = 1.5;
  float percentRemaining = timeRemaining/(float)totalTime;
  float speedupConstant = 1 + speedupMultiplierConstant*(1-percentRemaining);
  return (int)ceilf(baseCost*percentRemaining*speedupConstant);
}

- (int) calculateIncome:(int)income level:(int)level {
  return MAX(1, income * level * self.incomeFromNormStructMultiplier);
}

- (int) calculateIncomeForUserStruct:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  return [self calculateIncome:fsp.income level:us.level];
}

- (int) calculateIncomeForUserStructAfterLevelUp:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  return [self calculateIncome:fsp.income level:us.level+1];
}

- (int) calculateStructSilverSellCost:(UserStruct *)us {
//  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  return 0;
}

- (int) calculateStructGoldSellCost:(UserStruct *)us {
//  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  return 0;
}

- (int) calculateUpgradeCost:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  if (fsp.coinPrice > 0) {
    return MAX(0, (int)(fsp.coinPrice * powf(self.upgradeStructCoinCostExponentBase, us.level)));
  } else {
    return MAX(0, (int)(fsp.diamondPrice * powf(self.upgradeStructDiamondCostExponentBase, us.level)));
  }
}

- (int) calculateDiamondCostForInstaUpgrade:(UserStruct *)us timeLeft:(int)timeLeft {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  int baseCost = MAX(1,fsp.instaUpgradeDiamondCostBase * us.level * self.diamondCostForInstantUpgradeMultiplier);
  int mins = [self calculateMinutesToUpgrade:us];
  return [self calculateDiamondCostForSpeedupWithBaseCost:baseCost timeRemaining:timeLeft totalTime:mins*60];
}

- (int) calculateMinutesToUpgrade:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  return MAX(1, (int)(fsp.minutesToUpgradeBase * (us.level+1) * self.minutesToUpgradeForNormStructMultiplier));
}

- (int) calculateNumMinutesForNewExpansion {
  return 5;
}

- (int) calculateGoldCostToSpeedUpExpansionTimeLeft:(int)seconds {
  int mins = [self calculateNumMinutesForNewExpansion];
  int base = 100;
  return [self calculateDiamondCostForSpeedupWithBaseCost:base timeRemaining:seconds totalTime:mins*60];
}

- (int) calculateSilverCostForNewExpansion {
  return 5;
}

- (float) calculatePercentOfLevel:(int)percentage {
  return 0;
}

- (int) calculateEnhancementLevel:(int)percentage {
  return 0;
}

- (int) calculateEnhancementPercentageToNextLevel:(int)percentage {
  return 10000;
}

- (int) calculateEnhancementPercentageIncrease:(UserMonster *)enhancingMonster feeders:(NSArray *)feeders {
//  int change = 0;
//  for (UserEquip *f in feeders) {
//    change += [self calculateEnhancementPercentageIncrease:enhancingEquip feeder:f];
//  }
//  
//  int maxChange = ([self calculateEnhancementLevel:enhancingEquip.enhancementPercentage]+1)*self.enhancePercentPerLevel-enhancingEquip.enhancementPercentage;
//  
//  //  LNLog(@"totalChange=%d maxChange=%d", change, maxChange);
//  return MIN(maxChange, change);
  return 10;
}

- (int) calculateEnhancementPercentageIncrease:(UserMonster *)enhancingMonster feeder:(UserMonster *)feeder {
//  int mainAttack = [self calculateAttackForEquip:enhancingEquip.equipId level:enhancingEquip.level enhancePercent:enhancingEquip.enhancementPercentage];
//  int mainDefense = [self calculateDefenseForEquip:enhancingEquip.equipId level:enhancingEquip.level enhancePercent:enhancingEquip.enhancementPercentage];
//  int feederAttack = [self calculateAttackForEquip:feeder.equipId level:feeder.level enhancePercent:feeder.enhancementPercentage];
//  int feederDefense = [self calculateDefenseForEquip:feeder.equipId level:feeder.level enhancePercent:feeder.enhancementPercentage];
//  
//  int mainStats = mainAttack + mainDefense;
//  int feederStats = feederAttack + feederDefense;
//  
//  int result = (int)((((float)feederStats)/mainStats)/(self.enhancePercentConstantA*powf(self.enhancePercentConstantB, [self calculateEnhancementLevel:enhancingEquip.enhancementPercentage]+1))*self.enhancePercentPerLevel);
//  
//  //  LNLog(@"percentage=%d", result);
//  return MAX(result, 1);
  return 1;
}

- (int) calculateSilverCostForEnhancement:(UserMonster *)enhancingMonster feeders:(NSArray *)feeders {
//  int stats = 0;
//  for (UserEquip *f in feeders) {
//    stats += [self calculateAttackForEquip:f.equipId level:f.level enhancePercent:f.enhancementPercentage];
//    stats += [self calculateDefenseForEquip:f.equipId level:f.level enhancePercent:f.enhancementPercentage];
//  }
  
  return 5;
}

+ (void) popupMessage:(NSString *)msg {
  [GenericPopupController displayNotificationViewWithText:msg title:nil];
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

#pragma mark Colors
+ (UIColor *)creamColor {
  return [UIColor colorWithRed:240/255.f green:237/255.f blue:213/255.f alpha:1.f];
}

+ (UIColor *)goldColor {
  return [UIColor colorWithRed:255/255.f green:200/255.f blue:0/255.f alpha:1.f];
}

+ (UIColor *)greenColor {
  return [UIColor colorWithRed:176/255.f green:223/255.f blue:33/255.f alpha:1.f];
}

+ (UIColor *)orangeColor {
  return [UIColor colorWithRed:255/255.f green:102/255.f blue:0/255.f alpha:1.f];
}

+ (UIColor *)redColor {
  return [UIColor colorWithRed:217/255.f green:0/255.f blue:0/255.f alpha:1.f];
}

+ (UIColor *)blueColor {
  return [UIColor colorWithRed:92/255.f green:228/255.f blue:255/255.f alpha:1.f];
}

+ (UIColor *)purpleColor {
  return [UIColor colorWithRed:156/255.f green:0/255.f blue:255/255.f alpha:1.f];
}

+ (GameMap *)mapForQuest:(FullQuestProto *)fqp {
  if (fqp.cityId > 0) {
    GameLayer *gLay = [GameLayer sharedGameLayer];
    if (gLay.currentCity == fqp.cityId) {
      return (GameMap *)[gLay missionMap];
    } else {
      return nil;
    }
  } else {
//      return [HomeMap sharedHomeMap];
  }
  return nil;
}

+ (NSString *) bazaarQuestGiverName {
  return @"Bizzaro Byrone";
}

+ (NSString *) homeQuestGiverName {
  return @"Ruby";
}

#define ARROW_ANIMATION_DURATION 0.5f
#define ARROW_ANIMATION_DISTANCE 14
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

+ (void) animateCCArrow:(CCNode *)arrow atAngle:(float)angle {
  [arrow stopAllActions];
  arrow.rotation = CC_RADIANS_TO_DEGREES(-M_PI_2-angle);
  
  float scaleX = arrow.scaleX;
  float scaleY = arrow.scaleY;
  CCMoveBy *upAction = [CCEaseSineInOut actionWithAction:[CCSpawn actions:
                                                          [CCMoveTo actionWithDuration:ARROW_ANIMATION_DURATION position:ccpAdd(arrow.position, ccp(-ARROW_ANIMATION_DISTANCE*cosf(angle), -ARROW_ANIMATION_DISTANCE*sinf(angle)))],
                                                          [CCScaleTo actionWithDuration:ARROW_ANIMATION_DURATION scaleX:scaleX scaleY:scaleY],
                                                          nil]];
  CCMoveBy *downAction = [CCEaseSineInOut actionWithAction:[CCSpawn actions:
                                                            [CCMoveTo actionWithDuration:ARROW_ANIMATION_DURATION position:arrow.position],
                                                            [CCScaleTo actionWithDuration:ARROW_ANIMATION_DURATION scaleX:scaleX scaleY:0.9f*scaleY],
                                                            nil]];
  [arrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:upAction, downAction, nil]]];
}

- (BOOL) validateUserName:(NSString *)name {
  // make sure length is okay
  if (name.length < self.minNameLength) {
    [Globals popupMessage:@"This name is too short."];
    return NO;
  } else if (name.length > self.maxNameLength) {
    [Globals popupMessage:@"This name is too long."];
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
  CGSize size = [label.text sizeWithFont:label.font constrainedToSize:label.frame.size lineBreakMode:label.lineBreakMode];
  CGPoint oldCenter = view.center;
  
  CGRect r = view.frame;
  r.size.width = label.frame.origin.x + size.width;
  view.frame = r;
  
  view.center = oldCenter;
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

@end

@implementation CCNode (RecursiveOpacity)

- (void) recursivelyApplyOpacity:(GLubyte)opacity {
  if ([self conformsToProtocol:@protocol(CCRGBAProtocol)]) {
    [(id<CCRGBAProtocol>)self setOpacity:opacity];
  }
  if ([self isKindOfClass:[CCProgressTimer class]]) {
    self.visible = opacity > 150;
  }
  for (CCNode *c in self.children) {
    [c recursivelyApplyOpacity:opacity];
  }
}

@end

@implementation RecursiveFadeTo

-(void) update: (ccTime) t
{
	[_target recursivelyApplyOpacity:_fromOpacity + ( _toOpacity - _fromOpacity ) * t];
}

@end

@implementation NSMutableArray (Shuffling)

- (void)shuffle
{
  NSUInteger count = [self count];
  for (NSUInteger i = 0; i < count; ++i) {
    // Select a random element between i and end of array to swap with.
    NSInteger nElements = count - i;
    NSInteger n = (arc4random() % nElements) + i;
    [self exchangeObjectAtIndex:i withObjectAtIndex:n];
  }
}

@end