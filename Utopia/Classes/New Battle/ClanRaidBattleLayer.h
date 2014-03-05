//
//  ClanRaidBattleLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/26/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "NewBattleLayer.h"
#import "Protocols.pb.h"
#import "PersistentEventProto+Time.h"
#import "ClanRaidHealthBar.h"

@interface ClanRaidBattleLayer : NewBattleLayer {
  BOOL _downloadComplete;
  BOOL _shouldComeFromTop;
  
  BOOL _allowClanMembersAttack;
  BOOL _waitingForMyAttack;
  
  BOOL _currentGuyJustDied;
  int _lastOneIsCombinedAttack;
}

@property (nonatomic, retain) PersistentClanEventClanInfoProto *clanEventDetails;

@property (nonatomic, retain) ClanRaidHealthBar *raidHealthBar;

@property (nonatomic, retain) NSMutableArray *clanMemberAttacks;
@property (nonatomic, retain) NSMutableArray *nextMonsterClanMemberAttacks;
@property (nonatomic, retain) NSMutableArray *clanSprites;

- (id) initWithEvent:(PersistentClanEventClanInfoProto *)event myUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft;

@end
