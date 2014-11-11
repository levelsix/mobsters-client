//
//  QuestListViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 10/21/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "QuestListViewController.h"
#import "Globals.h"
#import "QuestUtil.h"

@implementation QuestListCell

- (void) awakeFromNib {
  self.completeView.frame = self.inProgressView.frame;
  [self.inProgressView.superview addSubview:self.completeView];
  
}

- (void) updateForQuest:(FullQuestProto *)quest withUserQuestData:(UserQuest *)userQuest {
  self.quest = quest;
  self.userQuest = userQuest;
  
  self.nameLabel.text = quest.name;
  
  [self.monsterView updateForElement:quest.monsterElement imgPrefix:quest.questGiverImagePrefix greyscale:NO];
  
  int progress = 0;
  for (QuestJobProto *job in quest.jobsList) {
    UserQuestJob *qj = [userQuest jobForId:job.questJobId];
    if (qj.isComplete) {
      progress++;
    }
  }
  self.progressLabel.text = [NSString stringWithFormat:@"%d/%d", progress, (int)quest.jobsList.count];
  
  self.questNewView.hidden = self.userQuest != nil;
  
  if (!userQuest.isComplete) {
    self.inProgressView.hidden = NO;
    self.completeView.hidden = YES;
  } else {
    self.completeView.hidden = NO;
    self.inProgressView.hidden = YES;
  }
}

- (IBAction)darkOverlayClicked:(id)sender {
  [self.delegate questListCellClicked:self];
}

@end

@implementation QuestListViewController

- (id) init {
  if ((self = [super init])) {
    self.title = @"Quests";
  }
  return self;
}

- (void) viewDidLoad {
  [super viewDidLoad];
  
  [self.questListTable reloadData];
}

- (void) reloadWithQuests:(NSArray *)quests userQuests:(NSDictionary *)userQuests {
  self.quests = quests;
  self.userQuests = userQuests;
  [self.questListTable reloadData];
}

#pragma mark - UITableViewDelegate/DataSource methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.quests.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  QuestListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuestListCell"];
  if (cell == nil) {
    [[NSBundle mainBundle] loadNibNamed:@"QuestListCell" owner:self options:nil];
    cell = self.questListCell;
    cell.delegate = (id<QuestListCellDelegate>)self.parentViewController;
  }
  
  FullQuestProto *quest = [self.quests objectAtIndex:indexPath.row];
  UserQuest *userQuest = [self.userQuests objectForKey:[NSNumber numberWithInt:quest.questId]];
  
  [cell updateForQuest:quest withUserQuestData:userQuest];
  
  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  
  QuestListCell *cell = (QuestListCell *)[tableView cellForRowAtIndexPath:indexPath];
  [cell.delegate questListCellClicked:cell];
}

@end
