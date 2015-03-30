//
//  ProfileViews.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/16/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ProfileViews.h"

#import "Protocols.pb.h"
#import "GameState.h"
#import "Globals.h"

@implementation ProfileMonsterTeamView

- (void) updateForUserMonster:(UserMonster *)um {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:um.monsterId];
  
  [self.monsterView updateForMonsterId:um.monsterId];
  self.nameLabel.text = mp.monsterName;
  self.levelLabel.text = [NSString stringWithFormat:@"LEVEL %d", um.level];
}

- (void) updateForEmptySlot:(int)slotNum {
  self.emptyLabel.text = [NSString stringWithFormat:@"Slot %d Empty", slotNum];
  
  self.monsterView.hidden = YES;
  self.nameLabel.hidden = YES;
  self.levelLabel.hidden = YES;
  self.emptyLabel.hidden = NO;
}

@end

@implementation ProfileMonsterDescriptionView

- (void) awakeFromNib {
  self.monsterIcon.superview.transform = CGAffineTransformMakeScale(0.8, 0.8);
  
  if ([Globals isiPhone6] || [Globals isiPhone6Plus]) {
    self.monsterIcon.transform = CGAffineTransformMakeScale(0.82, 0.82);
  }
}

- (void) updateForUserMonster:(UserMonster *)um {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  MonsterProto *proto = [gs monsterWithId:um.monsterId];
  
  self.nameLabel.text = proto.displayName;
  self.rarityIcon.image = [Globals imageNamed:[@"battle" stringByAppendingString:[Globals imageNameForRarity:proto.quality suffix:@"tag.png"]]];
  self.levelLabel.text = [NSString stringWithFormat:@"LEVEL %d", um.level];
  
  self.elementLabel.text = [Globals stringForElement:proto.monsterElement];
  self.elementLabel.textColor = [Globals colorForElementOnLightBackground:proto.monsterElement];
  
  NSString *fileName = [proto.imagePrefix stringByAppendingString:@"Character.png"];
  [Globals imageNamedWithiPhone6Prefix:fileName withView:self.monsterIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  [Globals imageNamed:[Globals imageNameForElement:proto.monsterElement suffix:@"orb.png"] withView:self.elementIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.attackLabel.text = [Globals commafyNumber:[gl calculateBaseTotalDamageForMonster:um]];
  self.hpLabel.text = [Globals commafyNumber:[gl calculateBaseMaxHealthForMonster:um]];
  self.speedLabel.text = [Globals commafyNumber:um.speed];
}

@end

@implementation ProfileStatsView

- (void) awakeFromNib {
  if ([Globals isiPhone6] || [Globals isiPhone6Plus]) {
    self.monsterIcon.transform = CGAffineTransformMakeScale(0.82, 0.82);
  }
}

- (void) updateForUser:(FullUserProto *)user {
  GameState *gs = [GameState sharedGameState];
  
  MonsterProto *mp = [gs monsterWithId:user.avatarMonsterId];
  NSString *fileName = [mp.imagePrefix stringByAppendingString:@"Character.png"];
  [Globals imageNamedWithiPhone6Prefix:fileName withView:self.monsterIcon maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.winsLabel.text = [Globals commafyNumber:user.pvpLeagueInfo.battlesWon];
  self.levelLabel.text = [NSString stringWithFormat:@"%d", user.level];
  
  if (user.hasClan) {
    [self.clanButton setTitle:user.clan.name forState:UIControlStateNormal];
    self.clanButton.enabled = YES;
    
    self.shieldIcon.hidden = NO;
    ClanIconProto *icon = [gs clanIconWithId:user.clan.clanIconId];
    [Globals imageNamed:icon.imgName withView:self.shieldIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    CGRect r = self.clanButton.frame;
    r.origin.x = self.shieldIcon.frame.size.width+3;
    self.clanButton.frame = r;
  } else {
    self.clanButton.enabled = NO;
    self.shieldIcon.hidden = YES;
    
    CGRect r = self.clanButton.frame;
    r.origin.x = 0;
    self.clanButton.frame = r;
  }
  
  if (user.hasPvpLeagueInfo) {
    [self.leagueView updateForUserLeague:user.pvpLeagueInfo ribbonSuffix:@"profribbon.png"];
    self.leagueView.hidden = NO;
  } else {
    self.leagueView.hidden = YES;
  }
}

@end
