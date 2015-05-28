//
//  Analytics.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/7/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "Analytics.h"
//#import "Apsalar.h"
#import "Globals.h"
#import "GameState.h"
#import <StoreKit/StoreKit.h>
//#import "Crittercism.h"
#import "Amplitude.h"
#import "TutorialController.h"
#import "Protocols.pb.h"
#import "GameViewController.h"

#import <MobileAppTracker/MobileAppTracker.h>
#import <Adjust.h>
//#import "ScopelyAttributionWrapper.h"
//#import <WithBuddiesAnalytics/WithBuddiesAnalytics.h>
#import <AdSupport/AdSupport.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#define MAT_ADVERTISER_ID    @"21754"
#define MAT_APP_KEY          @"f2f5c8b9c43496e4e0f988fa9f8827f4"
#define MAT_VERSION_KEY      @"MATVersionKey"


#ifdef MOBSTERS

#define TITAN_CLASS nil//[WBAnalyticService class]
#define TITAN_API_KEY @"08db55ae-2d33-4de8-8dd3-18c07a350f8a"
#define ADJUST_APP_TOKEN     @"stfgmupd2vmn"
#define ADJUST_TRACKED_PROPS @"AdjustTrackedProps"
#define AMPLITUDE_KEY        @"8e54e30d4126a84a784328c4117bf72c"
#define ADJUST_REV_TOKEN     nil

#else

#define TITAN_CLASS nil
#define TITAN_API_KEY nil
#define ADJUST_APP_TOKEN     @"7t35a4nm9x7f"
#define AMPLITUDE_KEY        @"4a7dcc75209c734285e4eae85142936b"
#define ADJUST_REV_TOKEN     @"unalrt"

#endif

#ifdef DEBUG
#define AMPLITUDE_CLASS nil
#else
#define AMPLITUDE_CLASS [Amplitude class]
#endif

#define S(a) [@(a) stringValue]

@implementation Analytics

static Class titanClass = nil;
static Class amplitudeClass = nil;

+ (void) setUpMobileAppTracker {
#ifdef MOBSTERS
  //  [ScopelyAttributionWrapper mat_initWithIFAEnabled:YES];
  //  [ScopelyAttributionWrapper mat_startSession];
#else
  [MobileAppTracker initializeWithMATAdvertiserId:MAT_ADVERTISER_ID
                                 MATConversionKey:MAT_APP_KEY];
  
  // Used to pass us the IFA, enabling highly accurate 1-to-1 attribution.
  // Required for many advertising networks.
  [MobileAppTracker setAppleAdvertisingIdentifier:[[ASIdentifierManager sharedManager] advertisingIdentifier]
                       advertisingTrackingEnabled:[[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]];
#endif
}

static NSString* urlEncodeString(NSString* nonEncodedString) {
  return [nonEncodedString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
}

+ (BOOL) isSandbox {
#ifndef APPSTORE
  BOOL sandbox = YES;
#else
  BOOL sandbox = NO;
#endif
  return sandbox;
}

+ (void) setUpAdjust {
  [Adjust appDidLaunch:[ADJConfig configWithAppToken:ADJUST_APP_TOKEN environment:[self isSandbox] ? ADJEnvironmentSandbox : ADJEnvironmentProduction]];
}

+ (NSMutableDictionary *) userPropertiesWithName:(NSString *)name level:(int)level segentationGroup:(int)segGroup {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  
  //app_version - we go ahead and set this, but this can be changed if a cutom version is set with adjust_customVersion()
  [dict setObject:urlEncodeString([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]) forKey:@"app_version"];
  
  //device_brand
  [dict setObject:@"apple" forKey:@"device_brand"];
  
  //device_carrier
  CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
  NSString* carrierName = urlEncodeString([[netinfo subscriberCellularProvider] carrierName]);
  if(carrierName != nil) {
    [dict setObject:urlEncodeString(carrierName) forKey:@"device_carrier"];
  }
  else {
    NSLog(@"device carrier not found");
  }
  
  //device_model
  [dict setObject:urlEncodeString([[UIDevice currentDevice] systemName]) forKey:@"device_model"];
  
  //os
  [dict setObject:@"ios" forKey:@"os"];
  
  //package_name
  [dict setObject:urlEncodeString([[NSBundle mainBundle] bundleIdentifier]) forKey:@"package_name"];
  
  //sandbox
  [dict setObject:[self isSandbox] ? @"True" : @"False" forKey:@"sandbox"];
  
  if (name) {
    [dict setObject:name forKey:@"user_name"];
    
    [dict setObject:[NSString stringWithFormat:@"%d", level] forKey:@"user_level"];
    
    [dict setObject:@(segGroup) forKey:@"segmentation_group"];
  }
  
  return dict;
}

+ (void) setupAmplitude {
  [amplitudeClass initializeApiKey:AMPLITUDE_KEY];
  
  [amplitudeClass setUserProperties:[self userPropertiesWithName:nil level:0 segentationGroup:0]];
}

+ (void) setupTitan {
  //[titanClass initializeWithApplicationKey:TITAN_API_KEY];
}

+ (void) initAnalytics {
  titanClass = TITAN_CLASS;
  amplitudeClass = AMPLITUDE_CLASS;
  
  [self setUpMobileAppTracker];
  [self setUpAdjust];
  [self setupAmplitude];
  [self setupTitan];
}

+ (void) event:(NSString *)event {
  [self event:event withArgs:nil];
}

+ (void) event:(NSString *)event withArgs:(NSDictionary *)args {
  [self event:event withArgs:args sendToTitan:NO];
}

+ (void) event:(NSString *)event withArgs:(NSDictionary *)args sendToTitan:(BOOL)toTitan {
  //LNLog(@"Logging event %@ with args: %@", event, args);
  [amplitudeClass logEvent:event withEventProperties:args];
  
  if (toTitan) {
    if (!args) {
      args = [NSDictionary dictionary];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:args];
    [dict setObject:event forKey:@"event"];
    
    //[titanClass trackEvent:event type:WBAnalyticEventTypeGame parameters:args];
  }
}

#pragma mark - Connect steps

static NSDate *timeSinceLastConnectStep = nil;

+ (void) connectStep:(int)connectStep {
  if (connectStep == ConnectStepInitializeConnection) {
    timeSinceLastConnectStep = nil;
  }
  
  NSDate *now = [NSDate date];
  double duration = ABS([timeSinceLastConnectStep timeIntervalSinceDate:now]);
  timeSinceLastConnectStep = now;
  
  BOOL isComplete = connectStep == ConnectStepComplete;
  
  NSString *event = [NSString stringWithFormat:@"connect_step_%d", connectStep];
  [self event:event withArgs:@{@"duration": @(duration),
                               @"is_complete": @(isComplete)}];
}

#pragma mark - Tutorial stuff

+ (void) equipTutorialStep:(int)tutorialStep {
  [self event:@"equip_tut_step" withArgs:@{@"step_num": @(tutorialStep)}];
}

+ (void) tutorialFbPopup {
  [self event:@"tut_fb_popup"];
}

+ (void) tutorialFbPopupConnect {
  [self event:@"tut_fb_popup_cnct"];
}

+ (void) tutorialFbPopupConnectSuccess {
  [self event:@"tut_fb_popup_cnct_success"];
}

+ (void) tutorialFbPopupConnectFail {
  [self event:@"tut_fb_popup_cnct_fail"];
}

+ (void) tutorialFbPopupConnectSkip {
  [self event:@"tut_fb_popup_skip"];
}

+ (void) tutorialFbConfirmConnect {
  [self event:@"tut_fb_cnfrm_cnct"];
}

+ (void) tutorialFbConfirmConnectSuccess {
  [self event:@"tut_fb_cnfrm_cnct_success"];
}

+ (void) tutorialFbConfirmConnectFail {
  [self event:@"tut_fb_cnfrm_cnct_fail"];
}

+ (void) tutorialFbConfirmSkip {
  [self event:@"tut_fb_cnfrm_skip"];
}

+ (void) tutorialWaitingOnUserCreate {
  [self event:@"tut_wait_for_user_create"];
}

+ (void) tutorialComplete {
#ifdef MOBSTERS
  //  [ScopelyAttributionWrapper mat_tutorialComplete];
#endif
  [self event:@"tut_complete"];
}

+ (void) sentFbSpam:(int)numUsers {
  [self event:@"fb_spam" withArgs:@{@"num_users":@(numUsers)}];
}

#pragma mark - Attribution stuff

+ (void) setUserUuid:(NSString *)userUuid name:(NSString *)name email:(NSString *)email level:(int)level segmentationGroup:(int)group {
  NSString *uid = userUuid;
#ifdef MOBSTERS
  //  [ScopelyAttributionWrapper mat_setUserInfoForUserId:uid withNameUser:name withEmail:email];
  //  [ScopelyAttributionWrapper adjust_setUserId:uid];
  //  [ScopelyAttributionWrapper adjust_trackEvent:@"w0uwrh"];
#endif
  
  [amplitudeClass setUserId:uid];
  [amplitudeClass setUserProperties:[self userPropertiesWithName:name level:level segentationGroup:group]];
}

+ (void) newAccountCreated {
#ifdef MOBSTERS
  //  [ScopelyAttributionWrapper mat_newAccountCreated];
#endif
}

+ (void) appOpen:(int)numTimesOpened {
#ifdef MOBSTERS
  //  if (numTimesOpened == 2) {
  //    [ScopelyAttributionWrapper mat_appOpen_002];
  //  } else if (numTimesOpened == 20) {
  //    [ScopelyAttributionWrapper mat_appOpen_020];
  //  }
#endif
}

+ (void) connectedToServerWithLevel:(int)level gems:(int)gems cash:(int)cash oil:(int)oil {
  NSDictionary *dict = @{@"gems_balance": @(gems), @"cash_balance": @(cash), @"oil_balance": @(oil)};
  //  [titanClass trackAppOpenWithLevel:S(level) extraParameters:dict];
  
  NSMutableDictionary *d2 = [dict mutableCopy];
  d2[@"level"] = @(level);
  [self event:@"app_open" withArgs:d2];
}

#pragma mark - Titan Standard Logs

static NSString *installTimeDefaultsKey = @"InstallTimeKey";

+ (void) checkInstall {
  NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
  NSDate *installTime = [def objectForKey:installTimeDefaultsKey];
  
  if (!installTime) {
    [self event:@"install"];
    //    [titanClass trackEvent:@"install" type:WBAnalyticEventTypeGame parameters:nil];
    [def setObject:[NSDate date] forKey:installTimeDefaultsKey];
  }
}

static NSDate *timeSinceLastTutStep = nil;

+ (void) tutorialStep:(int)tutorialStep {
  NSDate *now = [NSDate date];
  double duration = ABS([timeSinceLastTutStep timeIntervalSinceDate:now]);
  timeSinceLastTutStep = now;
  
  BOOL isComplete = tutorialStep == TutorialStepComplete;
  
  [self event:@"tut_step" withArgs:@{@"step_num": @(tutorialStep),
                                     @"duration": @(duration),
                                     @"is_complete": @(isComplete)}];
  
  //[titanClass trackFteFlow:tutorialStep isComplete:isComplete skip:NO duration:duration extraParams:nil];
}

+ (void) levelUpWithPrevLevel:(int)prevLevel curLevel:(int)curLevel {
  GameState *gs = [GameState sharedGameState];
  NSMutableDictionary *args = [NSMutableDictionary dictionary];
  
  args[@"prev_level"] = @(prevLevel);
  args[@"cur_level"] = @(curLevel);
  
  // Structs
  
  int cashPrinterLevel = 0;
  int cashVaultLevel = 0;
  int oilDrillLevel = 0;
  int oilSiloLevel = 0;
  int commandCenterlevel = 0;
  int evoChamberLevel = 0;
  int hospitalLevel = 0;
  int itemFactoryLevel = 0;
  int jobCenterLevel = 0;
  int labLevel = 0;
  int researchCenterLevel = 0;
  int residenceLevel = 0;
  int squadHqLevel = 0;
  int pvpBoardLevel = 0;
  int teamCenterLevel = 0;
  int moneyTreeLevel = 0;
  
  for (UserStruct *us in gs.myStructs) {
    StructureInfoProto *fsp = us.staticStructForCurrentConstructionLevel.structInfo;
    
    switch (fsp.structType) {
      case StructureInfoProto_StructTypeResourceGenerator:
      {
        ResourceGeneratorProto *rgp = (ResourceGeneratorProto *)us.staticStructForCurrentConstructionLevel;
        if (rgp.resourceType == ResourceTypeCash) {
          cashPrinterLevel = MAX(cashPrinterLevel, fsp.level);
        } else if (rgp.resourceType == ResourceTypeOil) {
          oilDrillLevel = MAX(oilDrillLevel, fsp.level);
        }
      }
        break;
        
      case StructureInfoProto_StructTypeResourceStorage:
      {
        ResourceStorageProto *rgp = (ResourceStorageProto *)us.staticStructForCurrentConstructionLevel;
        if (rgp.resourceType == ResourceTypeCash) {
          cashVaultLevel = MAX(cashVaultLevel, fsp.level);
        } else if (rgp.resourceType == ResourceTypeOil) {
          oilSiloLevel = MAX(oilSiloLevel, fsp.level);
        }
      }
        break;
        
      case StructureInfoProto_StructTypeTownHall:
        commandCenterlevel = MAX(commandCenterlevel, fsp.level);
        break;
        
      case StructureInfoProto_StructTypeEvo:
        evoChamberLevel = MAX(evoChamberLevel, fsp.level);
        break;
        
      case StructureInfoProto_StructTypeBattleItemFactory:
        itemFactoryLevel = MAX(itemFactoryLevel, fsp.level);
        break;
        
      case StructureInfoProto_StructTypeMiniJob:
        jobCenterLevel = MAX(jobCenterLevel, fsp.level);
        break;
        
      case StructureInfoProto_StructTypeLab:
        labLevel = MAX(labLevel, fsp.level);
        break;
        
      case StructureInfoProto_StructTypeResearchHouse:
        researchCenterLevel = MAX(researchCenterLevel, fsp.level);
        break;
        
      case StructureInfoProto_StructTypeResidence:
        residenceLevel = MAX(residenceLevel, fsp.level);
        break;
        
      case StructureInfoProto_StructTypeHospital:
        hospitalLevel = MAX(hospitalLevel, fsp.level);
        break;
        
      case StructureInfoProto_StructTypeClan:
        squadHqLevel = MAX(squadHqLevel, fsp.level);
        break;
        
      case StructureInfoProto_StructTypePvpBoard:
        pvpBoardLevel = MAX(pvpBoardLevel, fsp.level);
        break;
        
      case StructureInfoProto_StructTypeTeamCenter:
        teamCenterLevel = MAX(teamCenterLevel, fsp.level);
        break;
        
      case StructureInfoProto_StructTypeMoneyTree:
        moneyTreeLevel = MAX(moneyTreeLevel, fsp.level);
        break;
        
      case StructureInfoProto_StructTypeNoStruct:
        break;
    }
  }
  
  args[@"cash_printer_lvl"] = @(cashPrinterLevel);
  args[@"cash_vault_lvl"] = @(cashVaultLevel);
  args[@"oil_drill_lvl"] = @(oilDrillLevel);
  args[@"oil_silo_lvl"] = @(oilSiloLevel);
  args[@"command_center_lvl"] = @(commandCenterlevel);
  args[@"evo_chamber_lvl"] = @(evoChamberLevel);
  args[@"item_factory_lvl"] = @(itemFactoryLevel);
  args[@"job_center_lvl"] = @(jobCenterLevel);
  args[@"lab_lvl"] = @(labLevel);
  args[@"research_center_lvl"] = @(researchCenterLevel);
  args[@"residence_lvl"] = @(residenceLevel);
  args[@"hospital_lvl"] = @(hospitalLevel);
  args[@"squad_hq_lvl"] = @(squadHqLevel);
  args[@"pvp_board_lvl"] = @(pvpBoardLevel);
  args[@"team_center_lvl"] = @(teamCenterLevel);
  args[@"money_tree_lvl"] = @(moneyTreeLevel);
  
  // Farthest task beaten
  
  int farthestTaskBeaten = 0;
  for (TaskMapElementProto *me in gs.staticMapElements) {
    if ([gs isTaskCompleted:me.taskId]) {
      farthestTaskBeaten = MAX(farthestTaskBeaten, me.mapElementId);
    }
  }
  args[@"farthest_task_beaten"] = @(farthestTaskBeaten);
  
  // Toons
  int maxLvlToonId = 0;
  int maxLvlToonLvl = 0;
  int maxEvoTierToonId = 0;
  int maxEvoTier = 0;
  Quality maxRarity = QualityNoQuality;
  
  for (UserMonster *um in gs.myMonsters) {
    MonsterProto *mp = um.staticMonster;
    
    if (um.level > maxLvlToonLvl) {
      maxLvlToonId = um.monsterId;
      maxLvlToonLvl = um.level;
    }
    
    if (mp.evolutionLevel > maxEvoTier) {
      maxEvoTierToonId = um.monsterId;
      maxEvoTier = mp.evolutionLevel;
    }
    
    if (mp.quality > maxRarity) {
      maxRarity = mp.quality;
    }
  }
  args[@"max_lvl_toon_id"] = @(maxLvlToonId);
  args[@"max_lvl_toon_lvl"] = @(maxLvlToonLvl);
  args[@"max_evo_tier_toon_id"] = @(maxEvoTierToonId);
  args[@"max_evo_tier"] = @(maxEvoTier);
  args[@"max_rarity"] = [Globals stringForRarity:maxRarity];
  
  [self event:@"level_up" withArgs:args];
  
  //[titanClass trackLevelUp:S(prevLevel) newLevel:S(curLevel) extraParams:nil];
}

+ (void) connectedToFacebookWithData:(NSDictionary *)fbData {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  NSString *firstName = fbData[@"first_name"];
  NSString *lastName = fbData[@"last_name"];
  NSString *gender = [fbData[@"gender"] lowercaseString];
  NSString *birthday = fbData[@"birthday"];
  NSString *fbId = fbData[@"id"];
  
  if (fbId) dict[@"id"] = fbId;
  
  //  WBAnalyticGender gen = WBAnalyticGenderUnknown;
  //  char f = [gender characterAtIndex:0];
  //  if (f == 'm') {
  //    gen = WBAnalyticGenderMale;
  //  } else if (f == 'f') {
  //    gen = WBAnalyticGenderFemale;
  //  }
  
  //  NSDateFormatter *df = [[NSDateFormatter alloc] init];
  //  [df setDateFormat:@"MM/dd/yyyy"];
  //  NSDate *date = birthday ? [df dateFromString:birthday] : nil;
  
  //[titanClass trackSocialConnect:@"Facebook" firstName:firstName lastName:lastName gender:gen birthDate:date extraParams:dict];
  
  if (firstName) dict[@"first_name"] = firstName;
  if (lastName) dict[@"last_name"] = lastName;
  if (birthday) dict[@"birthday"] = birthday;
  if (gender) dict[@"gender"] = gender;
  
  [self event:@"fb_connect" withArgs:dict];
}

+ (void) inviteFacebook {
  
#ifdef MOBSTERS
  //  [ScopelyAttributionWrapper mat_inviteFacebook];
#endif
  
  [self event:@"fb_invite"];
  
  //[titanClass trackViral:@"FacebookInvite" extraParams:nil];
}

+ (void) redeemedAchievement:(int)achievementId {
  [self event:@"achievement" withArgs:@{@"achievement_id": @(achievementId)}];
  
  //[titanClass trackAchievement:S(achievementId) extraParams:nil];
}

+ (void) iapWithSKProduct:(SKProduct *)product forTransacton:(SKPaymentTransaction *)transaction amountUS:(float)amountUS uuid:(NSString *)uuid {
  if (!product) return;
#ifdef MOBSTERS
  //  [ScopelyAttributionWrapper mat_iapWithSKProduct:product forTransacton:transaction];
#endif
  
  NSString* currencyCode = [product.priceLocale objectForKey:NSLocaleCurrencyCode];
  float unitPrice = [product.price floatValue];
  
  NSDictionary *dict = @{@"amount_us": @(amountUS),
                         @"amount_local": @(unitPrice),
                         @"local_cur_code": currencyCode,
                         @"store_sku": product.productIdentifier,
                         @"sale_uuid" : uuid};
  
  [self event:@"iap_purchased" withArgs:dict];
  
  if (product && transaction) {
    [amplitudeClass logRevenue:product.productIdentifier quantity:1 price:@(amountUS) receipt:transaction.transactionReceipt];
  } else {
    [amplitudeClass logRevenue:@(amountUS)];
  }
  
  //[titanClass trackPayment:YES error:nil amountLocal:@(unitPrice) amountUS:@(amountUS) localCurrencyName:currencyCode special:nil specialId:nil storeSku:product.productIdentifier gameSku:nil extraParams:nil];
  
  ADJEvent *event = [ADJEvent eventWithEventToken:ADJUST_REV_TOKEN];
  [event setRevenue:round(amountUS*100)/100. currency:@"USD"];
  [event setTransactionId:transaction.transactionIdentifier];
  [event setCallbackParameters:@{@"productName": product.productIdentifier}.mutableCopy];
  [Adjust trackEvent:event];
}

+ (void) iapFailedWithSKProduct:(SKProduct *)product error:(NSString *)error {
  if (!product.productIdentifier) return;
  
  [self event:@"iap_failed" withArgs:@{@"reason": error ?: @"", @"store_sku": product.productIdentifier}];
  
  //NSString* currencyCode = [product.priceLocale objectForKey:NSLocaleCurrencyCode];
  //float unitPrice = [product.price floatValue];
  //
  //[titanClass trackPayment:NO error:error amountLocal:@(unitPrice) amountUS:@0 localCurrencyName:currencyCode special:nil specialId:nil storeSku:product.productIdentifier gameSku:nil extraParams:nil];
}

#pragma mark - Titan Game Specific Logs

+ (void) foundMatch:(NSString *)action {
  [self event:@"find_match" withArgs:@{@"type": action} sendToTitan:YES];
}

+ (void) openChat {
  [self event:@"open_chat" withArgs:nil sendToTitan:YES];
}

+ (void) createSquad:(NSString *)squadName {
  [self event:@"create_squad" withArgs:@{@"squad_name": squadName} sendToTitan:YES];
}

+ (void) joinSquad:(NSString *)squadName isRequestType:(BOOL)isRequestType {
  [self event:@"join_squad" withArgs:@{@"squad_name": squadName,
                                       @"type": isRequestType ? @"request" : @"free_to_join"} sendToTitan:YES];
}

+ (void) pveHit:(int)dungeonId isEnemyAttack:(BOOL)isEnemyAttack attackerMonsterId:(int)attackerMonsterId attackerLevel:(int)attackerLevel attackerHp:(int)attackerHp defenderMonsterId:(int)defenderMonsterId defenderLevel:(int)defenderLevel defenderHp:(int)defenderHp damageDealt:(int)damageDealt hitOrder:(int)hitOrder isKill:(BOOL)isKill isFinalBlow:(BOOL)isFinalBlow skillId:(int)skillId numContinues:(int)numContinues {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  dict[@"dungeon_id"] = @(dungeonId);
  dict[@"attacker_type"] = isEnemyAttack ? @"enemy" : @"player";
  dict[@"attacking_toon_id"] = @(attackerMonsterId);
  dict[@"attacking_toon_level"] = @(attackerLevel);
  dict[@"attacking_toon_current_hp"] = @(attackerHp);
  dict[@"defending_toon_id"] = @(defenderMonsterId);
  dict[@"defending_toon_level"] = @(defenderLevel);
  dict[@"defending_toon_current_hp"] = @(defenderHp);
  dict[@"damage_dealt"] = @(damageDealt);
  dict[@"hit_order"] = @(hitOrder);
  dict[@"is_kill"] = @(isKill);
  dict[@"is_final"] = @(isFinalBlow);
  dict[@"skill_id"] = @(skillId);
  dict[@"num_continues"] = @(numContinues);
  
  // Only fire on test flight
#ifdef RELEASE
  [self event:@"pve_hit" withArgs:dict];
#endif
}

+ (void) pveMatchEnd:(BOOL)won numEnemiesDefeated:(int)enemiesDefeated type:(NSString *)type mobstersUsed:(NSArray *)mobstersUsed numPiecesGained:(int)numPieces mobsterIdsGained:(NSArray *)mobsterIdsGained totalRounds:(int)totalRounds dungeonId:(int)dungeonId numContinues:(int)numContinues outcome:(NSString *)outcome {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  dict[@"win"] = @(won);
  dict[@"enemies_defeated"] = @(enemiesDefeated);
  dict[@"type"] = type;
  dict[@"num_pieces_gained"] = @(numPieces);
  dict[@"rounds"] = @(totalRounds);
  dict[@"dungeon_id"] = @(dungeonId);
  dict[@"continue"] = @(numContinues);
  dict[@"outcome"] = outcome;
  
  int curIdx = 1;
  for (BattlePlayer *bp in mobstersUsed) {
    if (bp.isClanMonster) {
      dict[@"donated_toon_id"] = @(bp.monsterId);
      dict[@"donated_toon_lvl"] = @(bp.level);
      dict[@"donated_toon_remaining_hp"] = @(bp.curHealth);
      dict[@"donated_toon_max_hp"] = @(bp.maxHealth);
    } else {
      dict[[NSString stringWithFormat:@"toon_%d_id", curIdx]] = @(bp.monsterId);
      dict[[NSString stringWithFormat:@"toon_%d_lvl", curIdx]] = @(bp.level);
      dict[[NSString stringWithFormat:@"toon_%d_remaining_hp", curIdx]] = @(bp.curHealth);
      dict[[NSString stringWithFormat:@"toon_%d_max_hp", curIdx]] = @(bp.maxHealth);
      
      curIdx++;
    }
  }
  
  for (int i = 0; i < mobsterIdsGained.count; i++) {
    dict[[NSString stringWithFormat:@"mobster_gained_%d", i+1]] = mobsterIdsGained[i];
  }
  
  [self event:@"pve_match_end" withArgs:dict sendToTitan:YES];
}

+ (void) pvpMatchEnd:(BOOL)won numEnemiesDefeated:(int)enemiesDefeated mobstersUsed:(NSArray *)mobstersUsed totalRounds:(int)totalRounds elo:(int)elo oppElo:(int)oppElo oppId:(NSString *)oppId outcome:(NSString *)outcome league:(NSString *)league {
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  dict[@"win"] = @(won);
  dict[@"enemies_defeated"] = @(enemiesDefeated);
  dict[@"type"] = @"PvP";
  dict[@"rounds"] = @(totalRounds);
  dict[@"elo"] = @(elo);
  dict[@"opp_elo"] = @(oppElo);
  dict[@"opp_id"] = oppId;
  dict[@"outcome"] = outcome;
  dict[@"league"] = league;
  
  int curIdx = 1;
  for (BattlePlayer *bp in mobstersUsed) {
    if (bp.isClanMonster) {
      dict[@"donated_toon_id"] = @(bp.monsterId);
      dict[@"donated_toon_lvl"] = @(bp.level);
      dict[@"donated_toon_remaining_hp"] = @(bp.curHealth);
      dict[@"donated_toon_max_hp"] = @(bp.maxHealth);
    } else {
      dict[[NSString stringWithFormat:@"toon_%d_id", curIdx]] = @(bp.monsterId);
      dict[[NSString stringWithFormat:@"toon_%d_lvl", curIdx]] = @(bp.level);
      dict[[NSString stringWithFormat:@"toon_%d_remaining_hp", curIdx]] = @(bp.curHealth);
      dict[[NSString stringWithFormat:@"toon_%d_max_hp", curIdx]] = @(bp.maxHealth);
      
      curIdx++;
    }
  }
  
  [self event:@"pvp_match_end" withArgs:dict sendToTitan:YES];
}

#pragma mark - Game Transaction Logs

+ (void) gameTransactionWithTransactionType:(NSString *)transactionType context:(NSString *)context itemIds:(NSArray *)itemIds itemChanges:(NSArray *)itemChanges itemBalances:(NSArray *)itemBalances extraParams:(NSDictionary *)extraParams  {
  NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:extraParams];
  params[@"transaction_type"] = transactionType;
  
  if (context) {
    params[@"context"] = context;
  }
  
  for (int i = 0; i < itemIds.count; i++) {
    params[itemIds[i]] = itemChanges[i];
    params[[NSString stringWithFormat:@"%@_balance", itemIds[i]]] = itemBalances[i];
  }
  
  [self event:@"game_transaction" withArgs:params];
  
  //  [titanClass trackGameTransactions:itemIds quantities:itemChanges itemBalances:itemBalances transactionType:transactionType context:context extraParams:extraParams];
}

+ (void) gameTransactionWithTransactionType:(NSString *)transactionType context:(NSString *)context cashChange:(int)cashChange cashBalance:(int)cashBalance oilChange:(int)oilChange oilBalance:(int)oilBalance
                                  gemChange:(int)gemChange gemBalance:(int)gemBalance tokenChange:(int)tokenChange tokenBalance:(int)tokenBalance extraParams:(NSDictionary *)extraParams {
  NSMutableArray *itemIds = [NSMutableArray array];
  NSMutableArray *itemChanges = [NSMutableArray array];
  NSMutableArray *itemBalances = [NSMutableArray array];
  
  if (gemChange) {
    [itemIds addObject:@"gems"];
    [itemChanges addObject:@(gemChange)];
    [itemBalances addObject:@(gemBalance)];
  }
  
  if (tokenChange) {
    [itemIds addObject:@"tokens"];
    [itemChanges addObject:@(tokenChange)];
    [itemBalances addObject:@(tokenBalance)];
  }
  
  if (cashChange) {
    [itemIds addObject:@"cash"];
    [itemChanges addObject:@(cashChange)];
    [itemBalances addObject:@(cashBalance)];
  }
  
  if (oilChange) {
    [itemIds addObject:@"oil"];
    [itemChanges addObject:@(oilChange)];
    [itemBalances addObject:@(oilBalance)];
  }
  
  
  if (itemIds.count) {
    [self gameTransactionWithTransactionType:transactionType context:context itemIds:itemIds itemChanges:itemChanges itemBalances:itemBalances extraParams:extraParams];
  }
}

+ (void) userCreateWithCashChange:(int)cashChange cashBalance:(int)cashBalance oilChange:(int)oilChange oilBalance:(int)oilBalance gemChange:(int)gemChange gemBalance:(int)gemBalance tokenChange:(int)tokenChange tokenBalance:(int)tokenBalance {
  [self gameTransactionWithTransactionType:@"user_create" context:nil cashChange:cashChange cashBalance:cashBalance oilChange:oilChange oilBalance:oilBalance gemChange:gemChange gemBalance:gemBalance tokenChange:tokenChange tokenBalance:tokenBalance extraParams:nil];
}

+ (void) instantFinish:(NSString *)waitType gemChange:(int)gemChange gemBalance:(int)gemBalance {
  [self gameTransactionWithTransactionType:@"instant_finish" context:waitType cashChange:0 cashBalance:0 oilChange:0 oilBalance:0 gemChange:gemChange gemBalance:gemBalance tokenChange:0 tokenBalance:0 extraParams:nil];
}

+ (void) buyBuilding:(int)buildingId cashChange:(int)cashChange cashBalance:(int)cashBalance oilChange:(int)oilChange oilBalance:(int)oilBalance gemChange:(int)gemChange gemBalance:(int)gemBalance {
  [self gameTransactionWithTransactionType:@"build_building" context:nil cashChange:cashChange cashBalance:cashBalance oilChange:oilChange oilBalance:oilBalance gemChange:gemChange gemBalance:gemBalance tokenChange:0 tokenBalance:0 extraParams:@{@"id": @(buildingId)}];
}

+ (void) upgradeBuilding:(int)buildingId cashChange:(int)cashChange cashBalance:(int)cashBalance oilChange:(int)oilChange oilBalance:(int)oilBalance gemChange:(int)gemChange gemBalance:(int)gemBalance {
  [self gameTransactionWithTransactionType:@"upgrade_building" context:nil cashChange:cashChange cashBalance:cashBalance oilChange:oilChange oilBalance:oilBalance gemChange:gemChange gemBalance:gemBalance tokenChange:0 tokenBalance:0 extraParams:@{@"id": @(buildingId)}];
}

+ (void) removeObstacle:(int)obstacleId cashChange:(int)cashChange cashBalance:(int)cashBalance oilChange:(int)oilChange oilBalance:(int)oilBalance gemChange:(int)gemChange gemBalance:(int)gemBalance {
  [self gameTransactionWithTransactionType:@"remove_obstacle" context:nil cashChange:cashChange cashBalance:cashBalance oilChange:oilChange oilBalance:oilBalance gemChange:gemChange gemBalance:gemBalance tokenChange:0 tokenBalance:0 extraParams:@{@"id": @(obstacleId)}];
}

+ (void) retrieveCurrency:(int)buildingId cashChange:(int)cashChange cashBalance:(int)cashBalance oilChange:(int)oilChange oilBalance:(int)oilBalance gemChange:(int)gemChange gemBalance:(int)gemBalance{
  [self gameTransactionWithTransactionType:@"collect_currency" context:nil cashChange:cashChange cashBalance:cashBalance oilChange:oilChange oilBalance:oilBalance gemChange:gemChange gemBalance:gemBalance tokenChange:0 tokenBalance:0 extraParams:@{@"id": @(buildingId)}];
}


+ (void) donateMonsters:(int)monsterId amountDonated:(int)amountDonated numLeft:(int)numLeft questJobId:(int)questJobId {
  [self gameTransactionWithTransactionType:@"donate_monster" context:nil itemIds:@[[NSString stringWithFormat:@"monster_%d", monsterId]] itemChanges:@[@(-amountDonated)] itemBalances:@[@(numLeft)] extraParams:@{@"quest_job_id": @(questJobId)}];
}

+ (void) redeemQuest:(int)questId cashChange:(int)cashChange cashBalance:(int)cashBalance oilChange:(int)oilChange oilBalance:(int)oilBalance gemChange:(int)gemChange gemBalance:(int)gemBalance {
  [self gameTransactionWithTransactionType:@"redeem_quest" context:nil cashChange:cashChange cashBalance:cashBalance oilChange:oilChange oilBalance:oilBalance gemChange:gemChange gemBalance:gemBalance tokenChange:0 tokenBalance:0 extraParams:@{@"id": @(questId)}];
}

+ (void) redeemAchievement:(int)achievementId gemChange:(int)gemChange gemBalance:(int)gemBalance {
  [self gameTransactionWithTransactionType:@"redeem_achievement" context:nil cashChange:0 cashBalance:0 oilChange:0 oilBalance:0 gemChange:gemChange gemBalance:gemBalance tokenChange:0 tokenBalance:0 extraParams:@{@"id": @(achievementId)}];
}


+ (void) iapPurchased:(NSString *)productId gemChange:(int)gemChange gemBalance:(int)gemBalance {
  [self gameTransactionWithTransactionType:@"iap_purchased" context:nil cashChange:0 cashBalance:0 oilChange:0 oilBalance:0 gemChange:gemChange gemBalance:gemBalance tokenChange:0 tokenBalance:0 extraParams:@{@"id": productId}];
}

+ (void) fillStorage:(NSString *)resourceType percAmount:(int)percAmount cashChange:(int)cashChange cashBalance:(int)cashBalance oilChange:(int)oilChange oilBalance:(int)oilBalance gemChange:(int)gemChange gemBalance:(int)gemBalance {
  [self gameTransactionWithTransactionType:@"fill_storage" context:resourceType cashChange:cashChange cashBalance:cashBalance oilChange:oilChange oilBalance:oilBalance gemChange:gemChange gemBalance:gemBalance tokenChange:0 tokenBalance:0 extraParams:@{@"fill": @(percAmount)}];
}


+ (void) createClan:(NSString *)clanName cashChange:(int)cashChange cashBalance:(int)cashBalance gemChange:(int)gemChange gemBalance:(int)gemBalance {
  [self gameTransactionWithTransactionType:@"create_squad" context:nil cashChange:cashChange cashBalance:cashBalance oilChange:0 oilBalance:0 gemChange:gemChange gemBalance:gemBalance tokenChange:0 tokenBalance:0 extraParams:@{@"name": clanName}];
}


+ (void) buyGacha:(int)machineId monsterList:(NSArray*)monsterList itemId:(int)itemId itemQuantity:(int)itemQuantity highRoller:(BOOL)highRoller gemChange:(int)gemChange gemBalance:(int)gemBalance tokenChange:(int)tokenChange tokenBalance:(int)tokenBalance {
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  params[@"machine_id"] = @(machineId);
  params[@"high_roller"] = @(highRoller);
  
  NSString *context = @"gems";
  if (monsterList && monsterList.count) {
    params[@"monster_list"] = monsterList;
    context = @"monster";
  }
  else if (itemId && itemQuantity) {
    params[@"item_id"] = @(itemId);
    params[@"item_quantity"] = @(itemQuantity);
    context = @"item";
  }
  
  [self gameTransactionWithTransactionType:@"buy_gacha" context:context cashChange:0 cashBalance:0 oilChange:0 oilBalance:0 gemChange:gemChange gemBalance:gemBalance tokenChange:tokenChange tokenBalance:tokenBalance extraParams:params];
}


+ (void) enterDungeon:(int)dungeonId gemChange:(int)gemChange gemBalance:(int)gemBalance {
  [self gameTransactionWithTransactionType:@"enter_dungeon" context:nil cashChange:0 cashBalance:0 oilChange:0 oilBalance:0 gemChange:gemChange gemBalance:gemBalance tokenChange:0 tokenBalance:0 extraParams:@{@"id": @(dungeonId)}];
}

+ (void) endDungeon:(int)dungeonId cashChange:(int)cashChange cashBalance:(int)cashBalance oilChange:(int)oilChange oilBalance:(int)oilBalance {
  [self gameTransactionWithTransactionType:@"end_dungeon" context:nil cashChange:cashChange cashBalance:cashBalance oilChange:oilChange oilBalance:oilBalance gemChange:0 gemBalance:0 tokenChange:0 tokenBalance:0 extraParams:@{@"id": @(dungeonId)}];
}

+ (void) continueDungeon:(int)dungeonId gemChange:(int)gemChange gemBalance:(int)gemBalance {
  [self gameTransactionWithTransactionType:@"continue_dungeon" context:nil cashChange:0 cashBalance:0 oilChange:0 oilBalance:0 gemChange:gemChange gemBalance:gemBalance tokenChange:0 tokenBalance:0 extraParams:@{@"id": @(dungeonId)}];
}


+ (void) nextPvpWithCashChange:(int)cashChange cashBalance:(int)cashBalance gemChange:(int)gemChange gemBalance:(int)gemBalance {
  [self gameTransactionWithTransactionType:@"next_pvp" context:nil cashChange:cashChange cashBalance:cashBalance oilChange:0 oilBalance:0 gemChange:gemChange gemBalance:gemBalance tokenChange:0 tokenBalance:0 extraParams:nil];
}

+ (void) endPvpWithCashChange:(int)cashChange cashBalance:(int)cashBalance oilChange:(int)oilChange oilBalance:(int)oilBalance {
  [self gameTransactionWithTransactionType:@"end_pvp" context:nil cashChange:cashChange cashBalance:cashBalance oilChange:oilChange oilBalance:oilBalance gemChange:0 gemBalance:0 tokenChange:0 tokenBalance:0 extraParams:nil];
}


+ (void) bonusSlots:(NSString *)position askedFriends:(BOOL)askedFriends invChange:(int)invChange invBalance:(int)invBalance gemChange:(int)gemChange gemBalance:(int)gemBalance {
  NSMutableArray *itemIds = [NSMutableArray array];
  NSMutableArray *itemChanges = [NSMutableArray array];
  NSMutableArray *itemBalances = [NSMutableArray array];
  
  if (gemChange) {
    [itemIds addObject:@"gems"];
    [itemChanges addObject:@(gemChange)];
    [itemBalances addObject:@(gemBalance)];
  }
  
  [itemIds addObject:@"inv_size"];
  [itemChanges addObject:@(invChange)];
  [itemBalances addObject:@(invBalance)];
  
  [self gameTransactionWithTransactionType:@"bonus_slot" context:position itemIds:itemIds itemChanges:itemChanges itemBalances:itemBalances extraParams:@{@"ask_friends": @(askedFriends)}];
}


+ (void) healMonster:(int)monsterId cashChange:(int)cashChange cashBalance:(int)cashBalance gemChange:(int)gemChange gemBalance:(int)gemBalance {
  [self gameTransactionWithTransactionType:@"heal_monster" context:nil cashChange:cashChange cashBalance:cashBalance oilChange:0 oilBalance:0 gemChange:gemChange gemBalance:gemBalance tokenChange:0 tokenBalance:0 extraParams:@{@"id": @(monsterId)}];
}

+ (void) cancelHealMonster:(int)monsterId cashChange:(int)cashChange cashBalance:(int)cashBalance {
  [self gameTransactionWithTransactionType:@"cancel_heal_monster" context:nil cashChange:cashChange cashBalance:cashBalance oilChange:0 oilBalance:0 gemChange:0 gemBalance:0 tokenChange:0 tokenBalance:0 extraParams:@{@"id": @(monsterId)}];
}


+ (void) enhanceMonster:(int)baseMonsterId feederId:(int)feederId oilChange:(int)oilChange oilBalance:(int)oilBalance gemChange:(int)gemChange gemBalance:(int)gemBalance {
  [self gameTransactionWithTransactionType:@"enhance_monster" context:nil cashChange:0 cashBalance:0 oilChange:oilChange oilBalance:oilBalance gemChange:gemChange gemBalance:gemBalance tokenChange:0 tokenBalance:0 extraParams:@{@"base_id": @(baseMonsterId), @"feeder_id": @(feederId)}];
}

+ (void) cancelEnhanceMonster:(int)baseMonsterId feederId:(int)feederId oilChange:(int)oilChange oilBalance:(int)oilBalance {
  [self gameTransactionWithTransactionType:@"cancel_enhance_monster" context:nil cashChange:0 cashBalance:0 oilChange:oilChange oilBalance:oilBalance gemChange:0 gemBalance:0 tokenChange:0 tokenBalance:0 extraParams:@{@"base_id": @(baseMonsterId), @"feeder_id": @(feederId)}];
}


+ (void) evolveMonster:(int)monsterId oilChange:(int)oilChange oilBalance:(int)oilBalance gemChange:(int)gemChange gemBalance:(int)gemBalance {
  [self gameTransactionWithTransactionType:@"evolve_monster" context:nil cashChange:0 cashBalance:0 oilChange:oilChange oilBalance:oilBalance gemChange:gemChange gemBalance:gemBalance tokenChange:0 tokenBalance:0 extraParams:@{@"id": @(monsterId)}];
}


+ (void) redeemMiniJob:(int)miniJobId cashChange:(int)cashChange cashBalance:(int)cashBalance oilChange:(int)oilChange oilBalance:(int)oilBalance {
  [self gameTransactionWithTransactionType:@"redeem_mini_job" context:nil cashChange:cashChange cashBalance:cashBalance oilChange:oilChange oilBalance:oilBalance gemChange:0 gemBalance:0 tokenChange:0 tokenBalance:0 extraParams:@{@"id": @(miniJobId)}];
}

@end
