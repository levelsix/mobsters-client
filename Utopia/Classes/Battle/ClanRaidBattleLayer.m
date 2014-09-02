//
//  ClanRaidBattleLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/26/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "ClanRaidBattleLayer.h"
#import "GameState.h"
#import "OutgoingEventController.h"

@implementation ClanRaidBattleLayer

- (id) initWithEvent:(PersistentClanEventClanInfoProto *)event myUserMonsters:(NSArray *)monsters puzzleIsOnLeft:(BOOL)puzzleIsOnLeft {
  if ((self = [super initWithMyUserMonsters:monsters puzzleIsOnLeft:puzzleIsOnLeft gridSize:CGSizeMake(8, 8)])) {
    self.clanEventDetails = event;
    ClanRaidStageProto *stage = [self.clanEventDetails currentStage];
    
    NSMutableSet *set = [NSMutableSet set];
    NSMutableArray *enemyTeam = [NSMutableArray array];
    ClanRaidStageMonsterProto *curMon = [event currentMonster];
    BOOL _foundMon = NO;
    for (ClanRaidStageMonsterProto *mon in stage.monstersList) {
      int curHealth = mon.monsterHp;
      if (curMon.crsmId == mon.crsmId) {
        curHealth = [event curHealthOfActiveStageMonster];
        _curStage = (int)[stage.monstersList indexOfObject:mon]-1;
        _foundMon = YES;
      } else if (!_foundMon) {
        curHealth = 0;
      }
      BattlePlayer *bp = [BattlePlayer playerWithClanRaidStageMonster:mon curHealth:curHealth];
      [enemyTeam addObject:bp];
      
      [set addObject:bp.spritePrefix];
    }
    self.enemyTeam = enemyTeam;
    
    for (BattlePlayer *bp in self.myTeam) {
      bp.slotNum = (int)[self.myTeam indexOfObject:bp]+1;
      [set addObject:bp.spritePrefix];
    }
    
    [Globals downloadAllFilesForSpritePrefixes:set.allObjects completion:^{
      _downloadComplete = YES;
    }];
    
    self.clanMemberAttacks = [NSMutableArray array];
    self.nextMonsterClanMemberAttacks = [NSMutableArray array];
    self.clanSprites = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clanRaidAttackNotification:) name:CLAN_RAID_ATTACK_NOTIFICATION object:nil];
  }
  return self;
}

- (void) dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) updateHealthBars {
  [super updateHealthBars];
  [self updateRaidHealthBar];
}

- (void) updateRaidHealthBar {
  int totalHp = 0, curHp = 0;
  for (BattlePlayer *bp in self.enemyTeam) {
    totalHp += bp.maxHealth;
    curHp += bp.curHealth;
  }
  
  [self.raidHealthBar runAction:[CCActionProgressTo actionWithDuration:0.2f percent:(totalHp-curHp)/(float)totalHp]];
}

- (void) begin {
  [super begin];
  
  [self displayOrbLayer];
  
  ClanRaidStageProto *stage = [self.clanEventDetails currentStage];
  float width = self.contentSize.width-self.orbLayer.contentSize.width-14-2*10;
  ClanRaidHealthBar *healthBar = [[ClanRaidHealthBar alloc] initWithStage:stage width:width];
  [self addChild:healthBar];
  healthBar.position = ccp(-healthBar.contentSize.width, self.contentSize.height-healthBar.contentSize.height-5);
  self.raidHealthBar = healthBar;
  [self.raidHealthBar updateForPercentage:self.clanEventDetails.percentOfStageComplete];
  
  [self updateRaidHealthBar];
  
  [self.raidHealthBar runAction:[CCActionMoveTo actionWithDuration:0.4f position:ccp(10, self.raidHealthBar.position.y)]];
}

- (void) sendServerUpdatedValues {
  if (_myDamageDealt) {
    [[OutgoingEventController sharedOutgoingEventController] dealDamageToClanRaidMonster:_myDamageDealt attacker:self.myPlayerObject curTeam:self.myTeam];
  }
}

- (void) reachedNextScene {
  if (!_hasStarted) {
    if (!_downloadComplete) {
      [self.myPlayer beginWalking];
      [self.bgdLayer scrollToNewScene];
    } else {
      [self moveToNextEnemy];
      _hasStarted = YES;
    }
  } else {
    [super reachedNextScene];
  }
}

- (void) beginMyTurn {
  [super beginMyTurn];
  
  _allowClanMembersAttack = YES;
  if (self.clanMemberAttacks.count > 0) {
    [self spawnNextClanMember];
  }
}

- (void) checkIfAnyMovesLeft {
  if (![self checkIfBossIsTechnicallyDead]) {
    [super checkIfAnyMovesLeft];
  }
}

- (void) myTurnEnded {
  _allowClanMembersAttack = NO;
  
  if (self.clanSprites.count > 0) {
    [self displayNoInputLayer];
    _waitingForMyAttack = YES;
  } else {
    _waitingForMyAttack = NO;
    [super myTurnEnded];
  }
}

- (void) moveToNextEnemy {
  [super moveToNextEnemy];
  
  // This is in case a clan member begins attacking before we moved
  self.clanMemberAttacks = self.nextMonsterClanMemberAttacks;
  self.nextMonsterClanMemberAttacks = [NSMutableArray array];
  _currentGuyJustDied = NO;
}

- (BOOL) checkIfBossIsTechnicallyDead {
  int curHp = self.enemyPlayerObject.curHealth;
  
  for (ClanMemberAttack *cma in self.clanMemberAttacks) {
    curHp-=cma.attackDamage;
  }
  
  BOOL isDead = curHp <= 0;
  
  if (isDead) {
    [self.orbLayer disallowInput];
    [self displayNoInputLayer];
    _myDamageDealt = 0;
    
    if (self.clanMemberAttacks.count > 5) {
      _lastOneIsCombinedAttack = YES;
      
      ClanMemberAttack *cma = [[ClanMemberAttack alloc] init];
      for (int i = 3; i < self.clanMemberAttacks.count; i++) {
        cma.attackDamage += [self.clanMemberAttacks[i] attackDamage];
      }
      [self.clanMemberAttacks removeObjectsInRange:NSMakeRange(3, self.clanMemberAttacks.count-3)];
      [self.clanMemberAttacks addObject:cma];
    }
  }
  
  return isDead;
}

#pragma mark - Clanmates attacking

- (void) clanRaidAttackNotification:(NSNotification *)notif {
  AttackClanRaidMonsterResponseProto *proto = [notif.userInfo objectForKey:CLAN_RAID_ATTACK_KEY];
  
  GameState *gs = [GameState sharedGameState];
  if (proto.sender.userId != gs.userId) {
    for (int i = 0; i < 10; i++) {
      int dmg = proto.dmgDealt/10;
      if (i == 9) {
        dmg = proto.dmgDealt-9*dmg;
      }
      ClanMemberAttack *cma = [[ClanMemberAttack alloc] initWithMonsterId:(arc4random()%5)+1 attackDmg:dmg name:proto.sender.name];
      
      if (_currentGuyJustDied) {
        [self.nextMonsterClanMemberAttacks addObject:cma];
      } else {
        [self.clanMemberAttacks addObject:cma];
      }
    }
    
    if (proto.status == AttackClanRaidMonsterResponseProto_AttackClanRaidMonsterStatusSuccessMonsterJustDied) {
      _currentGuyJustDied = YES;
    }
    
    if (self.clanSprites.count == 0 && _allowClanMembersAttack) {
      [self spawnNextClanMember];
    }
    
    [self checkIfBossIsTechnicallyDead];
  }
}

- (void) spawnNextClanMember {
  NSInteger idx = self.clanSprites.count;
  if (idx < self.clanMemberAttacks.count) {
    if (_lastOneIsCombinedAttack && idx == self.clanMemberAttacks.count-1) {
      [self spawnPlaneWithTarget:self selector:@selector(dealPlaneDamage)];
    } else {
      ClanMemberAttack *cma = self.clanMemberAttacks[idx];
      [self spawnClanBattleSpriteForClanMemberAttack:cma comeFromTop:_shouldComeFromTop];
      _shouldComeFromTop = !_shouldComeFromTop;
    }
  }
}

#define CLAN_SPRITE_FORWARD_MULT 0.08
#define CLAN_SPRITE_PERP_MULT 0.06

- (void) spawnClanBattleSpriteForClanMemberAttack:(ClanMemberAttack *)cma comeFromTop:(BOOL)comeFromTop {
  GameState *gs = [GameState sharedGameState];
  MonsterProto *mp = [gs monsterWithId:cma.monsterId];
  BattleSprite *clanBs = [[BattleSprite alloc] initWithPrefix:mp.imagePrefix nameString:[[NSAttributedString alloc] initWithString:mp.displayName] rarity:mp.quality animationType:mp.attackAnimationType isMySprite:NO verticalOffset:mp.verticalPixelOffset];
  clanBs.isFacingNear = NO;
  clanBs.healthBgd.visible = NO;
  clanBs.cameFromTop = comeFromTop;
  [self.bgdContainer addChild:clanBs z:self.myPlayer.zOrder+(comeFromTop?-1:1)];
  
  CCLabelTTF *nameLabel = [CCLabelTTF labelWithString:cma.name fontName:[Globals font] fontSize:12];
  [clanBs addChild:nameLabel];
  nameLabel.position = ccp(clanBs.contentSize.width/2, clanBs.contentSize.height+3);
  nameLabel.color = [CCColor whiteColor];
  nameLabel.shadowOffset = ccp(0, -1);
  nameLabel.shadowColor = [CCColor colorWithWhite:0.f alpha:0.7f];
  
  CGPoint ptOffset = POINT_OFFSET_PER_SCENE;
  CGPoint forward = ccpMult(ptOffset, CLAN_SPRITE_FORWARD_MULT);
  CGPoint perp = ccpMult(ccp(-ptOffset.x, ptOffset.y), (comeFromTop?1:-1)*CLAN_SPRITE_PERP_MULT);
  CGPoint finalPos = ccpAdd(forward, self.myPlayer.position);
  CGPoint midPos = ccpAdd(perp, finalPos);
  float startX = -clanBs.contentSize.width;
  float xDelta = midPos.x-startX;
  CGPoint startPos = ccp(startX, midPos.y-xDelta*ptOffset.y/ptOffset.x);
  
  [clanBs beginWalking];
  clanBs.position = startPos;
  [clanBs runAction:
   [CCActionSequence actions:
    [CCActionMoveTo actionWithDuration:ccpDistance(midPos, startPos)/MY_WALKING_SPEED/2 position:midPos],
    [CCActionCallBlock actionWithBlock:
     ^{
       if (comeFromTop) {
         [clanBs stopWalking];
         [clanBs faceNearWithoutUpdate];
         [clanBs beginWalking];
         clanBs.sprite.flipX = YES;
       } else {
         clanBs.sprite.flipX = NO;
       }
     }],
    [CCActionMoveTo actionWithDuration:ccpDistance(finalPos, midPos)/MY_WALKING_SPEED/2 position:finalPos],
    [CCActionCallBlock actionWithBlock:
     ^{
       [clanBs stopWalking];
       if (comeFromTop) {
         [clanBs faceFarWithoutUpdate];
       }
       clanBs.sprite.flipX = YES;
       [clanBs performFarAttackAnimationWithStrength:0.f enemy:self.currentEnemy target:self selector:@selector(clanMemberAttacked)];
     }],
    nil]];
  
  [self.clanSprites addObject:clanBs];
}

- (void) clanMemberAttacked {
  if (self.clanMemberAttacks.count > 0) {
    ClanMemberAttack *cma = self.clanMemberAttacks[0];
    [self dealDamage:cma.attackDamage enemyIsAttacker:NO usingAbility:NO withTarget:self withSelector:@selector(checkEnemyHealth)];
    [self.clanMemberAttacks removeObject:cma];
  } else {
    NSLog(@"SOMETHING IS WRONG.... No clan member attack.");
  }
  
  float perc = ((float)self.enemyPlayerObject.curHealth)/self.enemyPlayerObject.maxHealth;
  if (perc < PULSE_CONT_THRESH) {
    [self pulseHealthLabel:YES];
  } else {
    [self.currentEnemy.healthLabel stopActionByTag:RED_TINT_TAG];
    self.currentEnemy.healthLabel.color = [CCColor whiteColor];
  }
  
  // Make the clan member run out
  if (self.clanSprites.count > 0) {
    BattleSprite *clanBs = self.clanSprites[0];
    BOOL comeFromTop = clanBs.cameFromTop;
    
    CGPoint ptOffset = POINT_OFFSET_PER_SCENE;
    CGPoint perp = ccpMult(ccp(-ptOffset.x, ptOffset.y), (comeFromTop?1:-1)*CLAN_SPRITE_PERP_MULT);
    CGPoint startPos = clanBs.position;
    CGPoint midPos = ccpAdd(perp, startPos);
    float startX = -clanBs.contentSize.width;
    float xDelta = midPos.x-startX;
    CGPoint finalPos = ccp(startX, midPos.y-xDelta*ptOffset.y/ptOffset.x);
    
    if (comeFromTop) {
      [clanBs beginWalking];
      clanBs.sprite.flipX = NO;
    } else {
      [clanBs faceNearWithoutUpdate];
      [clanBs beginWalking];
      clanBs.sprite.flipX = YES;
    }
    [clanBs runAction:
     [CCActionSequence actions:
      [CCActionMoveTo actionWithDuration:ccpDistance(midPos, startPos)/MELEE_RUN_SPEED position:midPos],
      [CCActionCallBlock actionWithBlock:
       ^{
         if (comeFromTop) {
           [clanBs stopWalking];
           [clanBs faceNearWithoutUpdate];
           [clanBs beginWalking];
         } else {
           clanBs.sprite.flipX = NO;
         }
       }],
      [CCActionMoveTo actionWithDuration:ccpDistance(finalPos, midPos)/MELEE_RUN_SPEED position:finalPos],
      [CCActionCallFunc actionWithTarget:clanBs selector:@selector(removeFromParent)],
      nil]];
    
    [self.clanSprites removeObject:clanBs];
    if (_allowClanMembersAttack && self.clanMemberAttacks.count > 0) {
      [self spawnNextClanMember];
    } else if (_waitingForMyAttack) {
      [self myTurnEnded];
    }
  }
}

- (void) dealPlaneDamage {
  if (self.clanMemberAttacks.count == 1) {
    ClanMemberAttack *cma = self.clanMemberAttacks[0];
    [self dealDamage:cma.attackDamage enemyIsAttacker:NO usingAbility:NO withTarget:self withSelector:@selector(checkEnemyHealth)];
    [self.clanMemberAttacks removeObject:cma];
  } else {
    NSLog(@"SOMETHING IS WRONG.... More than one attack for plane.");
  }
}

@end
