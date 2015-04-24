//
//  ClanRaidDetailsViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/18/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenViewController.h"
#import "EasyTableView.h"
#import "ClanRaidViews.h"
#import "Protocols.pb.h"

@protocol ClanRaidDetailsDelegate <NSObject>

- (void) beginClanRaidBattle:(PersistentClanEventProto *)clanEvent withTeam:(NSArray *)team;

@end

@interface ClanRaidDetailsViewController : GenViewController <EasyTableViewDelegate>

@property (nonatomic, retain) IBOutlet UIImageView *monsterImage;
@property (nonatomic, retain) IBOutlet UILabel *dialogueLabel;

@property (nonatomic, retain) IBOutlet UIView *raidStageHeader;
@property (nonatomic, retain) IBOutlet UIView *tableContainerView;

@property (nonatomic, retain) IBOutlet ClanRaidStageCell *stageCell;

@property (nonatomic, retain) EasyTableView *stageTable;

@property (nonatomic, retain) PersistentClanEventProto *clanEvent;
@property (nonatomic, retain) ClanRaidProto *clanRaid;

@property (nonatomic, retain) IBOutlet ClanRaidTeamEnterView *teamEnterView;

@property (nonatomic, retain) NSArray *raidTeam;

@property (nonatomic, retain) NSTimer *timer;

@property (nonatomic, weak) id<ClanRaidDetailsDelegate> delegate;

@property (nonatomic, assign) BOOL canStartRaidStage;

- (id) initWithClanEvent:(PersistentClanEventProto *)event;

- (IBAction) headerClicked:(id)sender;
- (IBAction)setEnterClicked:(id)sender;
- (IBAction)switchEnterClicked:(id)sender;
- (IBAction)manageClicked:(id)sender;

@end
