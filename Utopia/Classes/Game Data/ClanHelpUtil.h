//
//  ClanHelpUtil.h
//  Utopia
//
//  Created by Ashwin on 10/9/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ClanHelp.h"

@interface ClanHelpUtil : NSObject

@property (nonatomic, retain) NSMutableArray *myClanHelps;
@property (nonatomic, retain) NSMutableArray *allClanHelps;

@property (nonatomic, readonly) int userId;
@property (nonatomic, assign) int clanId;

- (id) initWithUserId:(int)userId clanId:(int)clanId clanHelpProtos:(NSArray *)clanHelps;

- (void) addClanHelpProtos:(NSArray *)clanHelpProtos fromUser:(MinimumUserProto *)sender;
- (void) addClanHelpProto:(ClanHelp *)help toArray:(NSMutableArray *)array;
- (void) removeClanHelpIds:(NSArray *)helps;

// Will return -1 if it doesn't exist
- (int) getNumClanHelpsForType:(ClanHelpType)type userDataId:(uint64_t)userDataId;
- (id<ClanHelp>) getMyClanHelpForType:(ClanHelpType)type userDataId:(uint64_t)userDataId;

- (NSArray *) getAllHelpableClanHelps;

- (void) giveClanHelps:(NSArray *)clanHelps;

- (void) cleanupRogueClanHelps;

@end
