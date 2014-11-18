//
//  ClanInfoViews.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/12/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ClanInfoViews.h"
#import "GameState.h"
#import "Globals.h"

@implementation ClanMemberCell

- (void) awakeFromNib {
  CGRect r = self.editMemberView.frame;
  self.editMemberView.frame = r;
  
  for (MiniMonsterView *mv in self.monsterViews) {
    mv.transform = CGAffineTransformMakeScale(0.6, 0.6);
  }
}

- (void) loadForUser:(MinimumUserProtoForClans *)mup currentTeam:(NSArray *)currentTeam myStatus:(UserClanStatus)myStatus {
  MinimumUserProtoWithLevel *mupl = mup.minUserProtoWithLevel;
  self.user = mup;
  
  [self.userIcon updateForMonsterId:self.user.minUserProtoWithLevel.minUserProto.avatarMonsterId];
  self.nameLabel.text = mupl.minUserProto.name;
  self.raidContributionLabel.text = [NSString stringWithFormat:@"%d%%", (int)roundf(mup.raidContribution*100.f)];
  self.battleWinsLabel.text = [NSString stringWithFormat:@"%@ Win%@", [Globals commafyNumber:mup.battlesWon], mup.battlesWon == 1 ? @"" : @"s"];
  
  self.typeLabel.text = [Globals stringForClanStatus:mup.clanStatus];
  self.typeLabel.highlighted = (mup.clanStatus == UserClanStatusRequesting);
  self.levelLabel.text = [Globals commafyNumber:mupl.level];
  
  for (int i = 0; i < self.monsterViews.count; i++) {
    MiniMonsterView *mv = self.monsterViews[i];
    UserMonster *um = i < currentTeam.count ? currentTeam[i] : nil;
    
    [mv updateForMonsterId:um.monsterId];
  }
  
  if (myStatus == UserClanStatusLeader) {
    if (mup.clanStatus != UserClanStatusLeader) {
      [self editMemberConfiguration];
    } else {
      [self regularConfiguration];
    }
  } else if (myStatus == UserClanStatusJuniorLeader) {
    if (mup.clanStatus != UserClanStatusLeader && mup.clanStatus != UserClanStatusJuniorLeader) {
      [self editMemberConfiguration];
    } else {
      [self regularConfiguration];
    }
  } else {
    [self regularConfiguration];
  }
}

- (void) editMemberConfiguration {
  self.editMemberView.hidden = NO;
  self.profileView.hidden = YES;
}

- (void) respondInviteConfiguration {
  self.editMemberView.hidden = YES;
  self.profileView.hidden = YES;
}

- (void) regularConfiguration {
  self.editMemberView.hidden = YES;
  self.profileView.hidden = NO;
}

@end

@implementation ClanInfoView

- (void) awakeFromNib {
  self.requestView.frame = self.leaderView.frame;
  [self.leaderView.superview addSubview:self.requestView];
  
  self.cancelView.frame = self.leaderView.frame;
  [self.leaderView.superview addSubview:self.cancelView];
  
  self.leaveView.frame = self.leaderView.frame;
  [self.leaderView.superview addSubview:self.leaveView];
  
  self.joinView.frame = self.leaderView.frame;
  [self.leaderView.superview addSubview:self.joinView];
  
  self.anotherClanView.frame = self.leaderView.frame;
  [self.leaderView.superview addSubview:self.anotherClanView];
  
  _baseHeight = self.frame.size.height;
  
  [self stopAllSpinners];
}

- (void) hideAllViews {
  self.requestView.hidden = YES;
  self.cancelView.hidden = YES;
  self.leaveView.hidden = YES;
  self.joinView.hidden = YES;
  self.leaderView.hidden = YES;
  self.anotherClanView.hidden = YES;
  self.gradientView.hidden = YES;
}

- (void) loadForClan:(FullClanProtoWithClanSize *)c clanStatus:(UserClanStatus)clanStatus {
  if (c) {
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    
    self.nameLabel.text = c.clan.name;
    self.membersLabel.text = [NSString stringWithFormat:@"%d/%d MEM.", c.clanSize, gl.maxClanSize];
    self.descriptionView.text = c.clan.description;
    
    ClanIconProto *icon = [gs clanIconWithId:c.clan.clanIconId];
    [Globals imageNamed:icon.imgName withView:self.iconImage greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    MSDate *date = [MSDate dateWithTimeIntervalSince1970:c.clan.createTime/1000.0];
    self.foundedLabel.text = [NSString stringWithFormat:@"Founded: %@", [dateFormatter stringFromDate:date.relativeNSDate]];
    
    if (c.clan.requestToJoinRequired) {
      self.typeLabel.text = @"By Request Only";
    } else {
      self.typeLabel.text = @"Anyone Can Join";
    }
    
    [self hideAllViews];
    self.gradientView.hidden = NO;
    if ([gs.clan.clanUuid isEqualToString:c.clan.clanUuid]) {
      if (clanStatus == UserClanStatusLeader || clanStatus == UserClanStatusJuniorLeader) {
        self.leaderView.hidden = NO;
      } else if (clanStatus) {
        // Only show if clan status is there, aka this is the editable screen
        self.leaveView.hidden = NO;
      }
    } else if (gs.clan) {
      self.anotherClanView.hidden = NO;
    } else {
      if ([gs.requestedClans containsObject:c.clan.clanUuid]) {
        self.cancelView.hidden = NO;
      } else {
        if (c.clan.requestToJoinRequired) {
          self.requestView.hidden = NO;
        } else {
          self.joinView.hidden = NO;
        }
      }
    }
  } else {
    self.nameLabel.text = nil;
    self.membersLabel.text = nil;
    self.typeLabel.text = nil;
    self.foundedLabel.text = nil;
    self.descriptionView.text = nil;
    self.iconImage.image = nil;
    [self hideAllViews];
  }
  
  CGSize size = [self.descriptionView.text getSizeWithFont:self.descriptionView.font constrainedToSize:self.descriptionView.frame.size];
  CGFloat newSize = MAX(_baseHeight, size.height+self.descriptionView.frame.origin.x);
  CGRect r = self.frame;
  r.size.height = ceilf(newSize);
  self.frame = r;
}

- (void) beginSpinners {
  NSArray *views = @[self.requestView, self.joinView, self.leaveView, self.cancelView];
  for (UIView *v in views) {
    for (UIView *sv in v.subviews) {
      if ([sv isKindOfClass:[UILabel class]]) {
        sv.hidden = YES;
      } else if ([sv isKindOfClass:[UIActivityIndicatorView class]]) {
        sv.hidden = NO;
        [(UIActivityIndicatorView *)sv startAnimating];
      }
    }
  }
}

- (void) stopAllSpinners {
  NSArray *views = @[self.requestView, self.joinView, self.leaveView, self.cancelView];
  for (UIView *v in views) {
    for (UIView *sv in v.subviews) {
      if ([sv isKindOfClass:[UIActivityIndicatorView class]]) {
        sv.hidden = YES;
      } else {
        sv.hidden = NO;
      }
    }
  }
}

@end

@implementation ClanInfoSettingsButtonView

- (void) updateForSetting:(ClanSetting)setting {
  self.setting = setting;
  
  NSString *topText = nil;
  NSString *botText = nil;
  switch (setting) {
    case ClanSettingBoot:
      topText = @"Boot From";
      botText = @"Squad";
      break;
    case ClanSettingDemoteToCaptain:
      topText = @"Demote To";
      botText = @"Captain";
      break;
    case ClanSettingDemoteToMember:
      topText = @"Demote To";
      botText = @"Member";
      break;
    case ClanSettingPromoteToCaptain:
      topText = @"Promote To";
      botText = @"Captain";
      break;
    case ClanSettingPromoteToJrLeader:
      topText = @"Promote To";
      botText = @"Jr. Leader";
      break;
    case ClanSettingTransferLeader:
      topText = @"Transfer";
      botText = @"Leadership";
      break;
    case ClanSettingAcceptMember:
      topText = @"Accept";
      botText = @"Requestee";
      break;
    case ClanSettingRejectMember:
      topText = @"Reject";
      botText = @"Requestee";
      break;
      
    default:
      break;
  }
  self.topLabel.text = topText;
  self.botLabel.text = botText;
  
  [self stopSpinning];
}

- (IBAction) buttonClicked:(id)sender {
  [self.delegate settingClicked:self];
}

- (void) beginSpinning {
  self.topLabel.hidden = YES;
  self.botLabel.hidden = YES;
  self.spinner.hidden = NO;
}

- (void) stopSpinning {
  self.topLabel.hidden = NO;
  self.botLabel.hidden = NO;
  self.spinner.hidden = YES;
}

@end