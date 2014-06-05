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
#import "UnreadNotifications.h"

@implementation ChatPopoverView

- (void) awakeFromNib {
  self.layer.anchorPoint = ccp(0.2578, 1);
}

- (void) openAtPoint:(CGPoint)pt {
  [self close:^{
    self.hidden = NO;
    self.center = pt;
    
    self.alpha = 0.f;
    self.transform = CGAffineTransformMakeScale(0.f, 0.f);
    [UIView animateWithDuration:0.2f animations:^{
      self.alpha = 1.f;
      self.transform = CGAffineTransformIdentity;
    }];
  }];
}

- (void) close {
  [self close:nil];
}

- (void) close:(void (^)(void))completion {
  if (!self.hidden) {
    [UIView animateWithDuration:0.1f animations:^{
      self.transform = CGAffineTransformMakeScale(0.f, 0.f);
      self.alpha = 0.f;
    } completion:^(BOOL finished) {
      self.hidden = YES;
      self.transform = CGAffineTransformIdentity;
      if (completion) {
        completion();
      }
    }];
  } else {
    if (completion) {
      completion();
    }
  }
}

- (IBAction)profileClicked:(id)sender {
  [self.delegate profileClicked];
  [self close];
}

- (IBAction)messageClicked:(id)sender {
  [self.delegate messageClicked];
  [self close];
}

- (IBAction)muteClicked:(id)sender {
  [self.delegate muteClicked];
  [self close];
}

@end

@implementation ChatView

- (void) awakeFromNib {
  self.originalBottomViewRect = self.bottomView.frame;
  
  self.chatTable.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
}

- (void) updateForChats:(NSArray *)chats animated:(BOOL)animated {
  NSInteger oldCount = self.chats.count;
  self.chats = chats;
  NSInteger newCount = self.chats.count;
  
  NSIndexPath *lastIp = [NSIndexPath indexPathForRow:newCount-1 inSection:0];
  BOOL shouldScrollToBottom = NO;
  if (animated && oldCount < newCount) {
    NSMutableArray *indexes = [NSMutableArray array];
    for (int i = oldCount; i < newCount; i++) {
      [indexes addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.chatTable insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationBottom];
    
    if (self.chatTable.contentOffset.y > self.chatTable.contentSize.height-self.chatTable.frame.size.height-100) {
      shouldScrollToBottom = YES;
    }
  } else {
    [self.chatTable reloadData];
    [self closePopover];
    shouldScrollToBottom = YES;
  }
  
  if (shouldScrollToBottom && newCount) {
    [self.chatTable scrollToRowAtIndexPath:lastIp atScrollPosition:UITableViewScrollPositionBottom animated:animated];
  }
  
  GameState *gs = [GameState sharedGameState];
  [self.monsterView updateForMonsterId:gs.avatarMonsterId];
}

- (IBAction)sendChatClicked:(id)sender {
  if (self.textField.text.length > 0) {
    self.textField.text = nil;
    [self.textField resignFirstResponder];
  }
}

#pragma mark - Popover delegate

- (void) displayPopoverOverCell:(ChatCell *)cell {
  CGPoint pt = [self.popoverView.superview convertPoint:cell.bubbleAlignView.frame.origin fromView:cell.bubbleAlignView.superview];
  pt.x += self.popoverView.layer.anchorPoint.x*self.popoverView.frame.size.width;
  [self.popoverView openAtPoint:pt];
  self.popoverView.delegate = self;
  
  _clickedMsg = cell.chatMessage;
}

- (void) closePopover {
  [self.popoverView close];
  _clickedMsg = nil;
}

- (void) profileClicked {
  if (_clickedMsg) {
    [self.delegate profileClicked:_clickedMsg.sender.minUserProto.userId];
  }
}

- (void) messageClicked {
  if (_clickedMsg) {
    MinimumUserProto *mup = _clickedMsg.sender.minUserProto;
    [self.delegate beginPrivateChatWithUserId:mup.userId name:mup.name];
  }
}

- (void) muteClicked {
  if (_clickedMsg) {
    [self.delegate muteClicked:_clickedMsg.sender.minUserProto.userId name:_clickedMsg.sender.minUserProto.name];
  }
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

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.chats.count;
}

- (NSString *) cellClassName {
  return @"ChatCell";
}

- (BOOL) showsClanTag {
  return YES;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellClassName]];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:[self cellClassName] owner:self options:nil];
    cell = self.chatCell;
  }
  
  [cell updateForChat:self.chats[indexPath.row] showsClanTag:[self showsClanTag]];
  
  return cell;
}

- (void) checkIfDimensionsLoaded {
  if (!msgLabelFont) {
    [[NSBundle mainBundle] loadNibNamed:[self cellClassName] owner:self options:nil];
    msgLabelFont = self.chatCell.msgLabel.font;
    msgLabelInitialFrame = self.chatCell.msgLabel.frame;
  }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  [self checkIfDimensionsLoaded];
  NSString *msg = [self.chats[indexPath.row] message];
  CGSize size = [msg sizeWithFont:msgLabelFont constrainedToSize:CGSizeMake(msgLabelInitialFrame.size.width, 999) lineBreakMode:NSLineBreakByWordWrapping];
  float height = size.height+msgLabelInitialFrame.origin.y+14.f;
  return height;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (self.popoverView.hidden) {
    ChatCell *cell = (ChatCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    GameState *gs = [GameState sharedGameState];
    if (cell.chatMessage.sender.minUserProto.userId != gs.userId) {
      [self.chatTable scrollToRowAtIndexPath:[self.chatTable indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionNone animated:NO];
      [self displayPopoverOverCell:cell];
    }
  } else {
    [self.popoverView close];
  }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
  [self.popoverView close];
  _clickedMsg = nil;
}

- (void) dealloc {
  self.chatTable.delegate = nil;
  self.chatTable.dataSource = nil;
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

- (void) updateForChats:(NSArray *)chats andClan:(MinimumClanProto *)clan animated:(BOOL)animated {
  GameState *gs = [GameState sharedGameState];
  
  [self updateForChats:chats animated:animated];
  
  self.clan = clan;
  
  self.clanLabel.text = clan.name;
  
  ClanIconProto *icon = [gs clanIconWithId:clan.clanIconId];
  [Globals imageNamed:icon.imgName withView:self.shieldIcon greyscale:NO indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.noClanView.hidden = clan != nil;
  self.mainView.hidden = clan == nil;
}

- (IBAction)sendChatClicked:(id)sender {
  if (self.textField.text.length > 0) {
    [[OutgoingEventController sharedOutgoingEventController] sendGroupChat:GroupChatScopeClan message:self.textField.text];
  }
  [super sendChatClicked:sender];
}

- (BOOL) showsClanTag {
  return NO;
}

@end

@implementation PrivateChatView

- (void) awakeFromNib {
  [super awakeFromNib];
  self.backView.alpha = 0.f;
  [self.backView.superview bringSubviewToFront:self.backView];
}

- (void) updateForPrivateChatList:(NSArray *)privateChats {
  self.privateChatList = privateChats;
  [self.listTable reloadData];
  
  self.emptyListLabel.hidden = privateChats.count > 0;
  
  GameState *gs = [GameState sharedGameState];
  [self.monsterView updateForMonsterId:gs.avatarMonsterId];
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
      self.backView.alpha = 0.f;
    } completion:^(BOOL finished) {
      [self.chatTable reloadData];
    }];
  } else {
    self.frame = r;
    self.backView.alpha = 0.f;
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
      self.backView.alpha = 1.f;
    }];
  } else {
    self.frame = r;
    self.backView.alpha = 1.f;
  }
}

- (IBAction)backClicked:(id)sender {
  [self loadListViewAnimated:YES];
}

- (void) openConversationWithUserId:(int)userId name:(NSString *)name animated:(BOOL)animated {
  GameState *gs = [GameState sharedGameState];
  if (self.curUserId != userId) {
    if (gs.userId != userId) {
      [[OutgoingEventController sharedOutgoingEventController] retrievePrivateChatPosts:userId delegate:self];
      [self loadConversationViewAnimated:animated];
      self.curUserId = userId;
      _isLoading = YES;
      [self.chatTable reloadData];
      
      self.titleLabel.text = name;
    } else {
      [self loadListViewAnimated:animated];
    }
  } else {
    [Globals addAlertNotification:[NSString stringWithFormat:@"You are already messaging %@.", name]];
  }
}

- (void) handleRetrievePrivateChatPostsResponseProto:(FullEvent *)fe {
  RetrievePrivateChatPostsResponseProto *proto = (RetrievePrivateChatPostsResponseProto *)fe.event;
  
  if (_isLoading && proto.otherUserId == self.curUserId) {
    _isLoading = NO;
    NSMutableArray *arr = [NSMutableArray array];
    for (GroupChatMessageProto *chat in proto.postsList) {
      [arr addObject:[[ChatMessage alloc] initWithProto:chat]];
    }
    [self updateForChats:[arr reversedArray] animated:NO];
  }
}

- (void) addPrivateChat:(PrivateChatPostProto *)post {
  [post markAsRead];
  
  ChatMessage *cm = [[ChatMessage alloc] init];
  cm.sender = post.poster;
  cm.date = [MSDate dateWithTimeIntervalSince1970:post.timeOfPost/1000.];
  cm.message = post.content;
  [self addChatMessage:cm];
}

- (void) addChatMessage:(ChatMessage *)cm {
  [self updateForChats:[self.chats arrayByAddingObject:cm] animated:YES];
}

- (IBAction)sendChatClicked:(id)sender {
  if (!_isLoading) {
    NSString *msg = self.textField.text;
    if (msg.length > 0) {
      [[OutgoingEventController sharedOutgoingEventController] privateChatPost:self.curUserId content:msg];
      
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.35f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        GameState *gs = [GameState sharedGameState];
        ChatMessage *cm = [ChatMessage new];
        cm.date = [MSDate date];
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

- (BOOL) showsClanTag {
  return NO;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
  if (_isLoading) {
    [Globals addAlertNotification:@"Oops, wait for the messages to load."];
  }
  return !_isLoading;
}

#pragma mark - TableView delegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (tableView == self.chatTable) {
    NSInteger num = [super tableView:tableView numberOfRowsInSection:section];
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
    [self openConversationWithUserId:post.otherUser.userId name:post.otherUser.name animated:YES];
    [post markAsRead];
    
    [self.delegate viewedPrivateChat];
  } else if (tableView == self.chatTable) {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  }
}

@end
