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
  
  NSString *file = [quest.questGiverImageSuffix stringByAppendingString:@"Thumbnail.png"];
  [Globals imageNamed:file withView:self.questGiverImageView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhiteLarge clearImageDuringDownload:YES];
  
  if (quest.quantity < 100) {
    int progress = userQuest.progress;
    
    if (!userQuest && quest.questType == FullQuestProto_QuestTypeDonateMonster) {
      progress = [QuestUtil checkQuantityForDonateQuest:quest];
    }
    
    self.progressLabel.text = [NSString stringWithFormat:@"%d/%d", progress, quest.quantity];
  } else {
    self.progressLabel.text = [NSString stringWithFormat:@"%@", [Globals commafyNumber:userQuest.progress]];
  }
  
  self.badgeView.hidden = self.userQuest != nil;
  
  if (!userQuest.isComplete) {
    self.inProgressView.hidden = NO;
    self.completeView.hidden = YES;
  } else {
    self.completeView.hidden = NO;
    self.inProgressView.hidden = YES;
  }
  
  // For some reason if we screw with the rotation imediately, it screws up
  [self performSelector:@selector(rotate) withObject:nil afterDelay:0.01];
}

- (void) rotate {
  self.completeView.transform = CGAffineTransformMakeRotation(-M_PI/18);
  self.badgeView.transform = CGAffineTransformMakeRotation(-M_PI/18);
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

@end
