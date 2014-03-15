//
//  ClanRaidDetailsViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/18/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ClanRaidDetailsViewController.h"
#import <cocos2d.h>
#import "Globals.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "MyCroniesViewController.h"
#import "GenericPopupController.h"

#define TABLE_CELL_WIDTH 223.f

@implementation ClanRaidDetailsViewController

- (id) initWithClanEvent:(PersistentClanEventProto *)event {
  if ((self = [super init])) {
    self.clanEvent = event;
    
    GameState *gs = [GameState sharedGameState];
    self.clanRaid = [gs raidWithId:self.clanEvent.clanRaidId];
  }
  return self;
}

- (void) viewDidLoad {
  [self setUpCloseButton];
  [self setUpImageBackButton];
  
  self.raidStageHeader.transform = CGAffineTransformMakeRotation(-M_PI_2);
  
  [self setupStageTable];
  
  [Globals imageNamed:self.clanRaid.spotlightMonsterImgName withView:self.monsterImage greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  self.dialogueLabel.text = self.clanRaid.dialogueText;
}

- (void) viewWillAppear:(BOOL)animated {
  self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}


- (void) viewDidDisappear:(BOOL)animated {
  [self.timer invalidate];
  self.timer = nil;
}

- (void) setCanStartRaidStage:(BOOL)canStartRaidStage {
  _canStartRaidStage = canStartRaidStage;
  [self.stageTable reloadData];
}

- (void) updateLabels {
  GameState *gs = [GameState sharedGameState];
  for (ClanRaidStageCell *cell in self.stageTable.visibleViews) {
    if (gs.curClanRaidInfo.hasStageStartTime && gs.curClanRaidInfo.clanRaidStageId == cell.raidStage.clanRaidStageId) {
      [cell inProgressConfiguration:gs.curClanRaidInfo];
    }
  }
}

// Will return 0 if cur team works, 1 if it is forced, 2 if you can still set it
- (int) setCurrentRaidTeam {
  GameState *gs = [GameState sharedGameState];
  PersistentClanEventUserInfoProto *userInfo = gs.myClanRaidInfo;
  NSArray *forcedMonsters = userInfo.userMonsters.currentTeamList;
  NSArray *currentTeam = gs.allMonstersOnMyTeam;
  
  // First check to see if current team is basically same as forced
  if (forcedMonsters.count == currentTeam.count) {
    BOOL curTeamWorks = YES;
    for (UserMonster *um in currentTeam) {
      BOOL found = NO;
      for (FullUserMonsterProto *fup in forcedMonsters) {
        if (fup.userMonsterId == um.userMonsterId) {
          found = YES;
        }
      }
      
      if (!found) {
        curTeamWorks = NO;
      }
    }
    
    if (curTeamWorks) {
      self.raidTeam = currentTeam;
      return 0;
    }
  }
  
  // Grab the forced monsters
  NSMutableArray *team = [NSMutableArray array];
  for (FullUserMonsterProto *fup in forcedMonsters) {
    UserMonster *um = [gs myMonsterWithUserMonsterId:(int)fup.userMonsterId];
    if (um) {
      [team addObject:um];
    }
  }
  
  int status = 1;
  // Use teamNum instead of team.count in case one of the forced monsters no longer exists
  NSInteger teamNum = forcedMonsters.count;
  for (int i = 0; i < currentTeam.count; i++) {
    UserMonster *um = currentTeam[i];
    if (teamNum < 3 && ![team containsObject:um]) {
      [team addObject:um];
      status = 2;
      teamNum++;
    }
  }
  
  self.raidTeam = team;
  return status;
}

- (IBAction)battleClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  PersistentClanEventClanInfoProto *info = gs.curClanRaidInfo;
  if (info.hasStageStartTime) {
    int status = [self setCurrentRaidTeam];
    
    if (self.raidTeam.count > 0) {
      if (status == 0) {
        [self enterDungeonWithTeam];
      } else {
        [[NSBundle mainBundle] loadNibNamed:@"ClanRaidTeamEnterView" owner:self options:nil];
        if (status == 1) {
          [self.teamEnterView updateForSwitchTeam:self.raidTeam];
        } else {
          [self.teamEnterView updateForSetTeam:self.raidTeam];
        }
        
        [self.navigationController.view addSubview:self.teamEnterView];
        [Globals bounceView:self.teamEnterView.mainView fadeInBgdView:self.teamEnterView.bgdView];
      }
    } else {
      if (gs.myClanRaidInfo.userMonsters.currentTeamList.count > 0) {
        [Globals popupMessage:@"Sorry, you can no longer enter this raid. Your original team no longer exists."];
      } else {
        // This will automatically ask if you want to set a team
        [Globals checkEnteringDungeonWithTarget:self selector:@selector(manageClicked:)];
      }
    }
  } else {
    if (self.canStartRaidStage) {
      [[OutgoingEventController sharedOutgoingEventController] beginClanRaid:self.clanEvent delegate:self];
    } else {
      [Globals popupMessage:@"Only the Clan Leader, Junior Leaders, and Captains can begin a clan raid."];
    }
  }
}

- (void) enterDungeonWithTeam {
  [self.delegate beginClanRaidBattle:self.clanEvent withTeam:self.raidTeam];
  [self menuCloseClicked:nil];
}

#pragma mark - EasyTableView delegate

- (void)setupStageTable {
  self.stageTable = [[EasyTableView alloc] initWithFrame:self.tableContainerView.bounds numberOfColumns:0 ofWidth:TABLE_CELL_WIDTH];
  self.stageTable.delegate = self;
  self.stageTable.tableView.separatorColor = [UIColor clearColor];
  self.stageTable.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self.tableContainerView addSubview:self.stageTable];
}

- (IBAction) headerClicked:(id)sender {
  [self.stageTable.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (NSUInteger) numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section {
  return self.clanRaid.raidStagesList.count;
}

- (UIView *) easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect withIndexPath:(NSIndexPath *)indexPath {
  [[NSBundle mainBundle] loadNibNamed:@"ClanRaidStageCell" owner:self options:nil];
  self.stageCell.center = ccp(rect.size.width/2, rect.size.height/2);
  return self.stageCell;
}

- (void) easyTableView:(EasyTableView *)easyTableView setDataForView:(ClanRaidStageCell *)view forIndexPath:(NSIndexPath *)indexPath {
  GameState *gs = [GameState sharedGameState];
  PersistentClanEventClanInfoProto *info = gs.curClanRaidInfo.clanRaidId == self.clanRaid.clanRaidId ? gs.curClanRaidInfo : nil;
  [view updateForRaidStage:self.clanRaid.raidStagesList[indexPath.row] raid:self.clanRaid raidForClan:info canStartRaidStage:self.canStartRaidStage];
}

#pragma mark ClanRaidTeamEnterView IBActions

- (IBAction)setEnterClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] setClanRaidTeam:self.raidTeam delegate:self];
}

- (IBAction)switchEnterClicked:(id)sender {
  [self enterDungeonWithTeam];
}

- (IBAction)manageClicked:(id)sender {
  [self.navigationController pushViewController:[[MyCroniesViewController alloc] init] animated:YES];
}

- (void) handleBeginClanRaidResponseProto:(FullEvent *)fe {
  BeginClanRaidResponseProto *proto = (BeginClanRaidResponseProto *)fe.event;
  
  if (proto.hasUserDetails) {
    [self enterDungeonWithTeam];
  }
  
  [self.stageTable reloadData];
}

@end
