//
//  ClanRaidViews.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/18/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ClanRaidViews.h"
#import "Globals.h"
#import "GameState.h"
#import "PersistentEventProto+Time.h"

@implementation ClanRaidTeamEnterView

- (void) awakeFromNib {
  self.setTeamView.frame = self.switchToTeamView.frame;
  [self.switchToTeamView.superview addSubview:self.setTeamView];
}

- (void) updateForSetTeam:(NSArray *)team {
  self.setTeamView.hidden = NO;
  self.switchToTeamView.hidden = YES;
  
  [self addTeamViews:team];
}

- (void) updateForSwitchTeam:(NSArray *)team {
  self.setTeamView.hidden = YES;
  self.switchToTeamView.hidden = NO;
  
  [self addTeamViews:team];
}

- (void) addTeamViews:(NSArray *)team {
  for (int i = 0; i < 3; i++) {
    [[NSBundle mainBundle] loadNibNamed:@"ClanRaidStagePrizeView" owner:self options:nil];
    
    UserMonster *mon = nil;
    if (i < team.count) {
      mon = team[i];
      self.monsterView.lvlLabel.hidden = NO;
      self.monsterView.lvlLabel.text = [NSString stringWithFormat:@"Lvl %d", mon.level];
    }
    [self.monsterView updateForMonsterId:mon.monsterId];
    
    [self.teamContainer addSubview:self.monsterView];
    self.monsterView.center = ccp(self.teamContainer.frame.size.width/2-(self.monsterView.frame.size.width+5)*(1-i),
                                  self.teamContainer.frame.size.height/2);
  }
}

- (IBAction) close {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self removeFromSuperview];
  }];
}

@end

@implementation ClanRaidStageCell

- (void) awakeFromNib {
  _initialBattleButtonCenter = self.battleButtonView.center;
}

- (void) updateForRaidStage:(ClanRaidStageProto *)stage raid:(ClanRaidProto *)raid raidForClan:(PersistentClanEventClanInfoProto *)raidForClan canStartRaidStage:(BOOL)canStartRaidStage {
  self.raidStage = stage;
  
  self.titleLabel.text = stage.name;
  
  [self.prizesContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  for (int i = 0; i < stage.monstersList.count; i++) {
    ClanRaidStageMonsterProto *mon = stage.monstersList[i];
    [[NSBundle mainBundle] loadNibNamed:@"ClanRaidStagePrizeView" owner:self options:nil];
    [self.monsterView updateForMonsterId:mon.monsterId];
    
    [self.prizesContainer addSubview:self.monsterView];
    self.monsterView.center = ccp(self.prizesContainer.frame.size.width/2-((stage.monstersList.count-1)/2.f-i)*(self.monsterView.frame.size.width+5),
                                  self.prizesContainer.frame.size.height/2);
  }
  
  if (!raidForClan) {
    if (stage.stageNum == 1) {
      [self canBeginConfiguration:canStartRaidStage];
    } else {
      [self lockedConfiguration];
    }
  } else {
    ClanRaidStageProto *curStage = nil;
    for (ClanRaidStageProto *s in raid.raidStagesList) {
      if (s.clanRaidStageId == raidForClan.clanRaidStageId) {
        curStage = s;
        break;
      }
    }
    
    if (stage.stageNum == curStage.stageNum) {
      if (raidForClan.hasStageStartTime) {
        [self inProgressConfiguration:raidForClan];
      } else {
        [self canBeginConfiguration:canStartRaidStage];
      }
    } else if (stage.stageNum < curStage.stageNum) {
      [self alreadyCompleteConfiguration];
    } else {
      [self lockedConfiguration];
    }
  }
}

- (void) canBeginConfiguration:(BOOL)canStart {
  self.battleButtonView.hidden = NO;
  self.progressView.hidden = YES;
  self.bottomLabel.hidden = YES;
  
  self.headerBgdImage.highlighted = NO;
  
  self.battleButtonView.center = ccp(self.battleButtonView.superview.frame.size.width/2, self.battleButtonView.center.y);
  self.battleButtonLabel.text = @"Begin";
  
  UIImage *img = [Globals imageNamed:canStart ? @"profilebutton.png" : @"greybutton.png"];
  [self.battleButton setImage:img forState:UIControlStateNormal];
}

- (void) inProgressConfiguration:(PersistentClanEventClanInfoProto *)raidForClan {
  float completionPercent = raidForClan.percentOfStageComplete;
  int secsLeft = [raidForClan.stageEndTime timeIntervalSinceNow];
  
  self.battleButtonView.hidden = NO;
  self.progressView.hidden = NO;
  self.bottomLabel.hidden = YES;
  
  UIImage *img = [Globals imageNamed:@"profilebutton.png"];
  [self.battleButton setImage:img forState:UIControlStateNormal];
  
  self.headerBgdImage.highlighted = NO;
  
  self.battleButtonView.center = _initialBattleButtonCenter;
  self.battleButtonLabel.text = @"Begin";
  
  self.progressBar.percentage = completionPercent;
  self.progressLabel.text = [NSString stringWithFormat:@"%d%% Done / %@ Left", (int)(completionPercent*100), [Globals convertTimeToShortString:secsLeft]];
}

- (void) alreadyCompleteConfiguration {
  self.battleButtonView.hidden = YES;
  self.progressView.hidden = YES;
  self.bottomLabel.hidden = NO;
  
  self.headerBgdImage.highlighted = YES;
  
  self.bottomLabel.text = @"Completed";
}

- (void) lockedConfiguration {
  self.battleButtonView.hidden = YES;
  self.progressView.hidden = YES;
  self.bottomLabel.hidden = NO;
  
  self.headerBgdImage.highlighted = YES;
  
  self.bottomLabel.text = [NSString stringWithFormat:@"Complete stage %d to Unlock", self.raidStage.stageNum-1];
}

@end

@implementation ClanRaidListCell

- (void) updateForEvent:(PersistentClanEventProto *)event {
  GameState *gs = [GameState sharedGameState];
  ClanRaidProto *raid = [gs raidWithId:event.clanRaidId];
  if (event.isRunning) {
    [self updateForActiveRaid:raid];
  } else {
    [self updateForInactiveRaid:raid];
  }
  self.clanEvent = event;
  [self updateTime];
}

- (void) updateTime {
  int timeLeft = [self.clanEvent.endTime timeIntervalSinceNow];
  self.timeLeftLabel.text = [NSString stringWithFormat:@"Raid Active Now / %@ Left", [Globals convertTimeToShortString:timeLeft]];
}

- (void) updateForActiveRaid:(ClanRaidProto *)raid {
  [Globals imageNamed:raid.activeBackgroundImgName withView:self.bgdImage greyscale:NO indicator:UIActivityIndicatorViewStyleWhiteLarge clearImageDuringDownload:YES];
  [Globals imageNamed:raid.activeTitleImgName withView:self.titleImage greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  self.descriptionLabel.text = raid.activeDescription;
  [self.maskedButton remakeImage];
}

- (void) updateForInactiveRaid:(ClanRaidProto *)raid {
  [Globals imageNamed:raid.inactiveMonsterImgName withView:self.headImage greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  self.titleLabel.text = raid.clanRaidName;
  self.descriptionLabel.text = raid.inactiveDescription;
}

@end
