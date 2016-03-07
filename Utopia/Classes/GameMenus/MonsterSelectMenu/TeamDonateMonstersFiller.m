//
//  TeamDonateMonstersFiller.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "TeamDonateMonstersFiller.h"

#import "GameState.h"

#import "OutgoingEventController.h"
#import "MiniEventManager.h"

@implementation TeamDonateMonsterSelectCell

- (void) updateForListObject:(UserMonster *)um powerLimit:(int)powerLimit {
  Globals *gl = [Globals sharedGlobals];
  
  BOOL validPower = um.teamCost <= powerLimit;
  BOOL greyscale = !validPower || !um.isAvailable || um.curHealth < [gl calculateMaxHealthForMonster:um];
  
  [self.monsterView updateForMonsterId:um.monsterId greyscale:greyscale];
  
  self.healthBar.percentage = um.curHealth/(float)[gl calculateMaxHealthForMonster:um];
  self.healthLabel.text = [NSString stringWithFormat:@"%@/%@", [Globals commafyNumber:um.curHealth], [Globals commafyNumber:[gl calculateMaxHealthForMonster:um]]];
  
  self.statusLabel.hidden = YES;
  self.healthBar.superview.hidden = YES;
  if (!um.isAvailable) {
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:[um statusString]
                                                                           attributes:@{
                                                                                        NSStrokeWidthAttributeName: [NSNumber numberWithFloat:-3.0],
                                                                                        NSStrokeColorAttributeName:[UIColor blackColor]
                                                                                        }];
    self.statusLabel.attributedText = as;
    
    self.statusLabel.hidden = NO;
  } else if (!validPower) {
    NSString *str1 = @"Power: ";
    NSString *str2 = [Globals commafyNumber:[um teamCost]];
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", str1, str2]
                                                                           attributes:@{
                                                                                        NSStrokeWidthAttributeName: [NSNumber numberWithFloat:-3.0],
                                                                                        NSStrokeColorAttributeName:[UIColor blackColor]
                                                                                        }];
    [as addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"ff9494"] range:NSMakeRange(str1.length, str2.length)];
    
    self.statusLabel.attributedText = as;
    
    self.statusLabel.hidden = NO;
  } else {
    [Globals imageNamed:@"teamhealthbarcap.png" withView:self.healthBar.leftCap greyscale:greyscale indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
    [Globals imageNamed:@"teamhealthbarcap.png" withView:self.healthBar.rightCap greyscale:greyscale indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
    [Globals imageNamed:@"teamhealthbarmiddle.png" withView:self.healthBar.middleBar greyscale:greyscale indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
    
    self.healthBar.superview.hidden = NO;
  }
}

@end

@implementation TeamDonateMonstersFiller

- (id) initWithDonation:(ClanMemberTeamDonationProto *)donation {
  if ((self = [super init])) {
    self.donation = donation;
  }
  return self;
}

- (NSString *) titleName {
  return [NSString stringWithFormat:@"Donate %@", MONSTER_NAME];
}

- (NSString *) cellClassName {
  return @"TeamDonateMonsterSelectCell";
}

- (NSString *) footerTitle {
  return [NSString stringWithFormat:@"Tap a %@ to Donate", MONSTER_NAME];
}

- (NSString *) footerDescription {
  return [NSString stringWithFormat:@"Donated %@s lose their HP and need to be healed.", MONSTER_NAME];
}

- (void) updateCell:(TeamDonateMonsterSelectCell *)cell monster:(UserMonster *)monster {
  [cell updateForListObject:monster powerLimit:self.donation.powerAvailability];
}

- (BOOL) canDonateMonster:(UserMonster *)um {
  Globals *gl = [Globals sharedGlobals];
  return um.teamCost <= self.donation.powerAvailability && um.isAvailable && um.curHealth >= [gl calculateMaxHealthForMonster:um];
}

- (NSArray *) reloadMonstersArray {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *arr = [NSMutableArray array];
  
  for (UserMonster *um in gs.myMonsters) {
    if (um.isComplete) {
      [arr addObject:um];
    }
  }
  
  [arr sortUsingComparator:^NSComparisonResult(UserMonster *um1, UserMonster *um2) {
    BOOL greyscale1 = ![self canDonateMonster:um1];
    BOOL greyscale2 = ![self canDonateMonster:um2];
    
    if (greyscale1 != greyscale2) {
      return [@(greyscale1) compare:@(greyscale2)];
    }
    return [um1 compare:um2];
  }];
  
  return arr;
}

- (void) monsterSelected:(UserMonster *)um viewController:(MonsterSelectViewController *)viewController {
  if ([self canDonateMonster:um]) {
    if (self.donation.isFulfilled) {
      [Globals addAlertNotification:@"This donation request has already been fulfilled."];
    } else {
      [[OutgoingEventController sharedOutgoingEventController] fulfillClanTeamDonation:um solicitation:self.donation];
      
      Globals *gl = [Globals sharedGlobals];
      [[MiniEventManager sharedInstance] checkClanDonate:[gl calculateStrengthForMonster:um]];
      
      [self.delegate monsterChosen];
    }
    
    [viewController closeClicked:nil];
  } else {
    Globals *gl = [Globals sharedGlobals];
    NSString *alert = nil;
    if (!um.isAvailable) {
      alert = [NSString stringWithFormat:@"This %@ is currently unavailable. Please use a different %@.", MONSTER_NAME, MONSTER_NAME];
    } else if (um.teamCost > self.donation.powerAvailability) {
      alert = [NSString stringWithFormat:@"You can only donate %@s with a Power cost of %d or less.", MONSTER_NAME, self.donation.powerAvailability];
    } else if (um.curHealth < [gl calculateMaxHealthForMonster:um]) {
      alert = [NSString stringWithFormat:@"You can only donate full health %@s. Heal %@ before donating.", MONSTER_NAME, um.staticMonster.displayName];
    }
    
    if (alert) {
      [Globals addAlertNotification:alert];
    }
  }
}

- (void) monsterSelectClosed {
  [self.delegate monsterSelectClosed];
}

@end
