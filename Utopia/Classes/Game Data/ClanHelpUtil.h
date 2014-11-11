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

@property (nonatomic, retain) NSString *userUuid;
@property (nonatomic, retain) NSString *clanUuid;

- (id) initWithUserUuid:(NSString *)userUuid clanUuid:(NSString *)clanUuid clanHelpProtos:(NSArray *)clanHelps;

- (void) addClanHelpProtos:(NSArray *)clanHelpProtos fromUser:(MinimumUserProto *)sender;
- (id<ClanHelp>) addClanHelpProto:(ClanHelp *)help toArray:(NSMutableArray *)array;
- (void) removeClanHelpIds:(NSArray *)helps;
- (void) removeClanHelpsForUserUuid:(NSString *)userUuid;

// Will return -1 if it doesn't exist
- (int) getNumClanHelpsForType:(GameActionType)type userDataUuid:(NSString *)userDataUuid;

- (NSArray *) getAllHelpableClanHelps;

- (void) giveClanHelps:(NSArray *)clanHelps;

- (void) cleanupRogueClanHelps;

@end
