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
    self.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
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
      self.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
      self.alpha = 0.f;
    } completion:^(BOOL finished) {
      self.hidden = YES;
      self.transform = CGAffineTransformIdentity;
      if (completion) {
        completion();
      }
    }];
  } else {
    self.hidden = YES;
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
  self.chatTable.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
  
  [[NSBundle mainBundle] loadNibNamed:[self cellClassName] owner:self options:nil];
  _testCell = self.chatCell;
}

- (void) updateForChats:(NSArray *)chats animated:(BOOL)animated {
  NSArray *oldArray = self.chats;
  self.chats = [chats sortedArrayUsingComparator:^NSComparisonResult(id<ChatObject> obj1, id<ChatObject> obj2) {
    return [[obj1 date] compare:[obj2 date]];
  }];
  
  BOOL shouldScrollToBottom = NO;
  if (animated) {
    NSMutableArray *removedIps = [NSMutableArray array], *addedIps = [NSMutableArray array];
    NSMutableDictionary *movedIps = [NSMutableDictionary dictionary];
    
    [Globals calculateDifferencesBetweenOldArray:oldArray newArray:self.chats removalIps:removedIps additionIps:addedIps movedIps:movedIps section:0];
    
    [self.chatTable beginUpdates];
    
    [self.chatTable deleteRowsAtIndexPaths:removedIps withRowAnimation:UITableViewRowAnimationFade];
    
    for (NSIndexPath *ip in movedIps) {
      NSIndexPath *newIp = movedIps[ip];
      [self.chatTable moveRowAtIndexPath:ip toIndexPath:newIp];
    }
    [self.chatTable insertRowsAtIndexPaths:addedIps withRowAnimation:UITableViewRowAnimationFade];
    
    [self.chatTable endUpdates];
    
    for (ChatCell *cell in self.chatTable.visibleCells) {
      id<ChatObject> co = self.chats[[self.chatTable indexPathForCell:cell].row];
      [co updateInChatCell:cell showsClanTag:[self showsClanTag]];
    }
    
    if (self.chatTable.contentOffset.y > self.chatTable.contentSize.height-self.chatTable.frame.size.height-100) {
      shouldScrollToBottom = YES;
    }
  } else {
    [self.chatTable reloadData];
    [self closePopover];
    shouldScrollToBottom = YES;
  }
  
  if (shouldScrollToBottom && self.chats.count) {
    [self.chatTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chats.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
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
  
  NSInteger row = [self.chatTable indexPathForCell:cell].row;
  _clickedMsg = self.chats[row];
}

- (void) closePopover {
  [self.popoverView close];
  _clickedMsg = nil;
}

- (void) profileClicked {
  if (_clickedMsg) {
    [self.delegate profileClicked:_clickedMsg.sender.userUuid];
  }
}

- (void) messageClicked {
  if (_clickedMsg) {
    MinimumUserProto *mup = _clickedMsg.sender;
    [self.delegate beginPrivateChatWithUserUuid:mup.userUuid name:mup.name];
  }
}

- (void) muteClicked {
  if (_clickedMsg) {
    [self.delegate muteClicked:_clickedMsg.sender.userUuid name:_clickedMsg.sender.name];
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
  
  [self.chats[indexPath.row] updateInChatCell:cell showsClanTag:[self showsClanTag]];
  
  return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [self.chats[indexPath.row] heightWithTestChatCell:_testCell];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (self.popoverView.hidden) {
    ChatCell *cell = (ChatCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    GameState *gs = [GameState sharedGameState];
    id<ChatObject> chatObject = self.chats[indexPath.row];
    if (![chatObject.sender.userUuid isEqualToString:gs.userUuid]) {
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
  
  if (!clan) {
    UserStruct *us = [gs myClanHouse];
    
    NSString *structName = nil;
    for (id<StaticStructure> ss in gs.staticStructs.allValues) {
      if (ss.structInfo.structType == StructureInfoProto_StructTypeClan && !ss.structInfo.predecessorStructId) {
        structName = ss.structInfo.name;
      }
    }
    
    if (!us.isComplete) {
      self.joinClanLabel.text = [NSString stringWithFormat:@"Build a %@ to join a Squad!", structName];
      self.joinClanButtonView.hidden = YES;
      self.joinClanLabel.centerY = self.joinClanLabel.superview.height/2;
    } else {
      self.joinClanLabel.text = @"Join a squad to chat with them!";
    }
  } else {
    [self reloadHelpsArray];
    if (self.helpsArray.count > 1){
      
    }
  }
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

- (void) reloadHelpsArray {
  // Don't want to delete any of the things in the array already.. so use a set.
  GameState *gs = [GameState sharedGameState];
  
  NSArray *arr = [gs.clanHelpUtil getAllHelpableClanHelps];
  NSMutableSet *newHelps = [NSMutableSet setWithArray:arr];
  
  for (id<ClanHelp> ch in self.helpsArray) {
    if ([[ch clanUuid] isEqualToString:gs.clan.clanUuid]) {
      [newHelps addObject:ch];
    }
  }
  
  NSArray *unionArr = newHelps.allObjects;
  
  NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id<ClanHelp> ch, NSDictionary *bindings) {
    return [ch isOpen];
  }];
  unionArr = [unionArr filteredArrayUsingPredicate:pred];
  
  unionArr = [unionArr sortedArrayUsingComparator:^NSComparisonResult(id<ClanHelp> obj1, id<ClanHelp> obj2) {
    return [[obj2 requestedTime] compare:[obj1 requestedTime]];
  }];
  
  self.helpsArray = [NSMutableArray arrayWithArray:unionArr];
  
  self.helpCountLabel.text = [NSString stringWithFormat:@"%i Squad Mates Requested Help", (int)self.helpsArray.count];
  self.helpAllView.hidden = self.helpsArray.count < 2;
}

- (IBAction)helpAllClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  [gs.clanHelpUtil giveClanHelps:self.helpsArray];
  [self.helpsArray removeAllObjects];
  
  [self updateForChats:self.chats andClan:self.clan animated:NO];
}

@end

@implementation PrivateChatView

- (void) awakeFromNib {
  [super awakeFromNib];
  self.backView.alpha = 0.f;
  [self.backView.superview bringSubviewToFront:self.backView];
  
  self.unrespondedChatMessages = [NSMutableArray array];
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
  self.curUserUuid = nil;
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
  [UIView animateWithDuration:0.3 animations:^{
    self.topLiveHelpView.alpha = 1.f;
  }];
}

- (IBAction)adminChatClicked:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  MinimumUserProto *mup = gl.adminChatUser;
  [self openConversationWithUserUuid:mup.userUuid name:mup.name animated:YES];
}

- (void) openConversationWithUserUuid:(NSString *)userUuid name:(NSString *)name animated:(BOOL)animated {
  GameState *gs = [GameState sharedGameState];
  if (![self.curUserUuid isEqualToString:userUuid]) {
    if (![gs.userUuid isEqualToString:userUuid]) {
      [[OutgoingEventController sharedOutgoingEventController] retrievePrivateChatPosts:userUuid delegate:self];
      [self loadConversationViewAnimated:animated];
      self.curUserUuid = userUuid;
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
  
  if (_isLoading && [proto.otherUserUuid isEqualToString:self.curUserUuid]) {
    _isLoading = NO;
    NSMutableArray *arr = [NSMutableArray array];
    for (GroupChatMessageProto *chat in proto.postsList) {
      [arr addObject:[[ChatMessage alloc] initWithProto:chat]];
    }
    
    Globals *gl = [Globals sharedGlobals];
    if (arr.count == 0 && [proto.otherUserUuid isEqualToString:gl.adminChatUser.userUuid]) {
      GroupChatMessageProto_Builder *p = [GroupChatMessageProto builder];
      p.sender = [[[MinimumUserProtoWithLevel builder] setMinUserProto:gl.adminChatUser] build];
      p.content = @"Hey there! I'll be with you shortly. What can I help you with today?";
      p.timeOfChat = [[MSDate date] timeIntervalSince1970]*1000;
      [arr addObject:[[ChatMessage alloc] initWithProto:p.build]];
    }
    
    self.baseChats = arr;
    [self updateForChats:arr animated:NO];
  }
}

- (void) addPrivateChat:(PrivateChatPostProto *)post {
  [post markAsRead];
  
  // Check unresponded messages for this
  id<ChatObject> unresponded = nil;
  for (id<ChatObject> cm in self.unrespondedChatMessages) {
    if ([cm.sender.userUuid isEqualToString:post.poster.minUserProto.userUuid] &&
        [cm.message isEqualToString:post.content]) {
      unresponded = cm;
    }
  }
  
  if (unresponded) {
    [self.unrespondedChatMessages removeObject:unresponded];
  } else {
    ChatMessage *cm = [[ChatMessage alloc] init];
    cm.sender = post.poster.minUserProto;
    cm.date = [MSDate dateWithTimeIntervalSince1970:post.timeOfPost/1000.];
    cm.message = post.content;
    [self addChatMessage:cm];
    
    if (!post.hasPrivateChatPostUuid) {
      [self.unrespondedChatMessages addObject:cm];
    }
  }
}

- (void) addChatMessage:(ChatMessage *)cm {
  [self.baseChats addObject:cm];
  [self updateForChats:self.baseChats animated:YES];
}

- (void) updateForChats:(NSArray *)chats animated:(BOOL)animated {
  NSMutableArray *arr = [chats mutableCopy];
  
  GameState *gs = [GameState sharedGameState];
  
  // Check for battle history
  for (PvpHistoryProto *pvp in gs.battleHistory) {
    if ([pvp.otherUser.userUuid isEqualToString:self.curUserUuid]) {
      [arr addObject:pvp];
    }
  }
  
  
  // Check for fb requests
  for (RequestFromFriend *req in gs.fbUnacceptedRequestsFromFriends) {
    if ([req.otherUser.userUuid isEqualToString:self.curUserUuid]) {
      [arr addObject:req];
    }
  }
  
  [super updateForChats:arr animated:animated];
}

- (IBAction)sendChatClicked:(id)sender {
  if (!_isLoading) {
    NSString *msg = self.textField.text;
    if (msg.length > 0) {
      [[OutgoingEventController sharedOutgoingEventController] privateChatPost:self.curUserUuid content:msg];
      
      GameState *gs = [GameState sharedGameState];
      ChatMessage *cm = [ChatMessage new];
      cm.date = [MSDate date];
      cm.message = msg;
      cm.sender = gs.minUserWithLevel.minUserProto;
      
      [self.unrespondedChatMessages addObject:cm];
      
      [self addChatMessage:cm];
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
    
    id<ChatObject> post = self.privateChatList[indexPath.row];
    [self openConversationWithUserUuid:post.otherUser.userUuid name:post.otherUser.name animated:YES];
    [post markAsRead];
    
    [self.delegate viewedPrivateChat];
  } else if (tableView == self.chatTable) {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  }
}

@end
