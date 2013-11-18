//
//  ChatView.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/11/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "ChatView.h"
#import "OutgoingEventController.h"
#import "GameState.h"
#import "PrivateChatPostProto+UnreadStatus.h"

@implementation ChatView

- (void) updateForChats:(NSArray *)chats animated:(BOOL)animated {
  int oldCount = self.chats.count;
  self.chats = chats;
  int newCount = self.chats.count;
  
  if (animated && oldCount < newCount) {
    NSMutableArray *indexes = [NSMutableArray array];
    for (int i = 0; i+oldCount < newCount; i++) {
      [indexes addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.chatTable insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationTop];
  } else {
    [self.chatTable reloadData];
  }
}

- (IBAction)sendChatClicked:(id)sender {
  if (self.textField.text.length > 0) {
    self.textField.text = nil;
    [self.textField resignFirstResponder];
  }
}

- (IBAction)nameClicked:(id)sender {
  while (sender && ![sender isKindOfClass:[ChatCell class]]) {
    sender = [sender superview];
  }
  ChatCell *cell = (ChatCell *)sender;
  [self.delegate profileClicked:cell.chatMessage.sender.minUserProto.userId];
}

- (IBAction)clanClicked:(id)sender {
  while (sender && ![sender isKindOfClass:[ChatCell class]]) {
    sender = [sender superview];
  }
  ChatCell *cell = (ChatCell *)sender;
  [self.delegate clanClicked:cell.chatMessage.sender.minUserProto.clan];
}

#pragma mark - TextField delegate methods

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  [self sendChatClicked:nil];
  return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  Globals *gl = [Globals sharedGlobals];
  NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
  if ([str length] > gl.maxLengthOfChatString) {
    return NO;
  }
  return YES;
}

#pragma mark - TableView delegate methods

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.chats.count;
}

- (NSString *) cellClassName {
  return @"ChatCell";
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellClassName]];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:[self cellClassName] owner:self options:nil];
    cell = self.chatCell;
  }
  
  [cell updateForChat:self.chats[indexPath.row]];
  
  return cell;
}

- (void) checkIfDimensionsLoaded {
  if (!msgLabelFont) {
    [[NSBundle mainBundle] loadNibNamed:[self cellClassName] owner:self options:nil];
    msgLabelFont = self.chatCell.msgLabel.font;
    msgLabelInitialFrame = self.chatCell.msgLabel.frame;
  }
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
  [self checkIfDimensionsLoaded];
  return msgLabelInitialFrame.size.height;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  [self checkIfDimensionsLoaded];
  NSString *msg = [self.chats[indexPath.row] message];
  CGSize size = [msg sizeWithFont:msgLabelFont constrainedToSize:CGSizeMake(msgLabelInitialFrame.size.width, 999) lineBreakMode:NSLineBreakByWordWrapping];
  float height = size.height+msgLabelInitialFrame.origin.y+8.f;
  return height;
}

@end

@implementation GlobalChatView

- (IBAction)sendChatClicked:(id)sender {
  if (self.textField.text.length > 0) {
    [[OutgoingEventController sharedOutgoingEventController] sendGroupChat:GroupChatScopeGlobal message:self.textField.text];
  }
  [super sendChatClicked:sender];
}

@end

@implementation ClanChatView

- (void) updateForChats:(NSArray *)chats andClan:(MinimumClanProto *)clan {
  [self updateForChats:chats animated:YES];
  
  self.clan = clan;
  
  self.clanLabel.text = clan.name;
  
  self.noClanLabel.hidden = clan != nil;
  self.mainView.hidden = clan == nil;
}

- (IBAction)infoClicked:(id)sender {
  [self.delegate clanClicked:self.clan];
}

- (IBAction)sendChatClicked:(id)sender {
  if (self.textField.text.length > 0) {
    [[OutgoingEventController sharedOutgoingEventController] sendGroupChat:GroupChatScopeClan message:self.textField.text];
  }
  [super sendChatClicked:sender];
}

- (NSString *) cellClassName {
  return @"ClanChatCell";
}

@end

@implementation PrivateChatView

- (void) updateForPrivateChatList:(NSArray *)privateChats {
  self.privateChatList = privateChats;
  [self.listTable reloadData];
  
  self.emptyListLabel.hidden = privateChats.count > 0;
}

- (void) loadListViewAnimated:(BOOL)animated {
  CGRect r = self.frame;
  r.origin.x = 0;
  
  [self.listTable reloadData];
  self.chats = nil;
  self.curUserId = 0;
  if (animated) {
    [UIView animateWithDuration:0.3f animations:^{
      self.frame = r;
    } completion:^(BOOL finished) {
      [self.chatTable reloadData];
    }];
  } else {
    self.frame = r;
    [self.chatTable reloadData];
  }
}

- (void) loadConversationViewAnimated:(BOOL)animated {
  CGRect r = self.frame;
  r.origin.x = self.superview.frame.size.width-self.frame.size.width;
  
  [self.chatTable reloadData];
  if (animated) {
    [UIView animateWithDuration:0.3f animations:^{
      self.frame = r;
    }];
  } else {
    self.frame = r;
  }
}

- (IBAction)backClicked:(id)sender {
  [self loadListViewAnimated:YES];
}

- (void) openConversationWithUserId:(int)userId animated:(BOOL)animated {
  [[OutgoingEventController sharedOutgoingEventController] retrievePrivateChatPosts:userId delegate:self];
  [self loadConversationViewAnimated:animated];
  self.curUserId = userId;
  _isLoading = YES;
  [self.chatTable reloadData];
}

- (void) handleRetrievePrivateChatPostsResponseProto:(FullEvent *)fe {
  RetrievePrivateChatPostsResponseProto *proto = (RetrievePrivateChatPostsResponseProto *)fe.event;
  
  if (_isLoading && proto.otherUserId == self.curUserId) {
    _isLoading = NO;
    NSMutableArray *arr = [NSMutableArray array];
    for (GroupChatMessageProto *chat in proto.postsList) {
      [arr addObject:[[ChatMessage alloc] initWithProto:chat]];
    }
    [self updateForChats:arr animated:NO];
  }
}

- (void) addPrivateChat:(PrivateChatPostProto *)post {
  [post markAsRead];
  
  ChatMessage *cm = [[ChatMessage alloc] init];
  cm.sender = post.poster;
  cm.date = [NSDate dateWithTimeIntervalSince1970:post.timeOfPost/1000.];
  cm.message = post.content;
  [self addChatMessage:cm];
}

- (void) addChatMessage:(ChatMessage *)cm {
  [self updateForChats:[[NSArray arrayWithObject:cm] arrayByAddingObjectsFromArray:self.chats] animated:YES];
}

- (IBAction)sendChatClicked:(id)sender {
  if (!_isLoading) {
    NSString *msg = self.textField.text;
    if (msg.length > 0) {
      [[OutgoingEventController sharedOutgoingEventController] privateChatPost:self.curUserId content:msg];
      
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.35f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        GameState *gs = [GameState sharedGameState];
        ChatMessage *cm = [ChatMessage new];
        cm.date = [NSDate date];
        cm.message = msg;
        cm.sender = gs.minUserWithLevel;
        [self addChatMessage:cm];
      });
    }
    [super sendChatClicked:sender];
  } else {
    [Globals popupMessage:@"Hold on! We are still loading this conversation."];
  }
}

#pragma mark - TableView delegate

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  if (tableView == self.chatTable) {
    return [super numberOfSectionsInTableView:tableView];
  }
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (tableView == self.chatTable) {
    int num = [super tableView:tableView numberOfRowsInSection:section];
    if (num == 0) {
      self.spinner.hidden = !_isLoading;
      self.noPostsLabel.hidden = _isLoading;
    } else {
      self.spinner.hidden = YES;
      self.noPostsLabel.hidden = YES;
    }
    return num;
  }
  return self.privateChatList.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (tableView == self.chatTable) {
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
  }
  
  PrivateChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PrivateChatListCell"];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"PrivateChatListCell" owner:self options:nil];
    cell = self.listCell;
  }
  
  [cell updateForPrivateChat:self.privateChatList[indexPath.row]];
  
  return cell;
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (tableView == self.chatTable) {
    return [super tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
  }
  
  return self.listTable.rowHeight;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (tableView == self.chatTable) {
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
  }
  
  return self.listTable.rowHeight;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (tableView == self.listTable) {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    PrivateChatPostProto *post = self.privateChatList[indexPath.row];
    [self openConversationWithUserId:post.otherUserId animated:YES];
    [post markAsRead];
  }
}

@end
