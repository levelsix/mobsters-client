//
//  ClanHelp.h
//  Utopia
//
//  Created by Ashwin on 10/9/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UserData.h"
#import "Protocols.pb.h"

#import "ChatObject.h"

@class ClanHelp;

@protocol ClanHelp <ChatObject>

- (int) maxHelpers;
- (int) numHelpers;

- (NSString *) helpString;
- (NSString *) justHelpedString:(NSString *)name;
- (NSString *) justSolicitedString;

- (MSDate *) requestedTime;
- (MinimumUserProto *) requester;
- (NSString *) clanUuid;

- (BOOL) isOpen;

- (void) consumeClanHelp:(ClanHelp *)clanHelp;

// Since this object may be bundled up or not..
- (ClanHelp *) getClanHelpForType:(GameActionType)type userDataUuid:(NSString *)userDataUuid;

- (NSArray *) helpableClanHelpIdsForUserUuid:(NSString *)userUuid;
- (BOOL) canHelpForUserUuid:(NSString *)userUuid;
- (BOOL) hasHelpedForUserUuid:(NSString *)userUuid;

- (NSArray *) allIndividualClanHelps;
// Return value dictates whether this clan help is no longer valid so it can be removed from the util's list
- (BOOL) removeClanHelps:(NSArray *)clanHelps;

- (void) incrementHelpForUserUuid:(NSString *)userUuid;

@end

@interface ClanHelp : NSObject <ClanHelp>

@property (nonatomic, retain) NSString *clanHelpUuid;
@property (nonatomic, retain) MinimumUserProto *requester;
@property (nonatomic, retain) NSString *clanUuid;
@property (nonatomic, retain) MSDate *requestedTime;
@property (nonatomic, assign) GameActionType helpType;
@property (nonatomic, retain) NSString *userDataUuid;
@property (nonatomic, assign) int staticDataId;
@property (nonatomic, assign) int maxHelpers;
@property (nonatomic, retain) NSMutableSet *helperUserUuids;
@property (nonatomic, assign) BOOL isOpen;

- (id) initWithClanHelpProto:(ClanHelpProto *)chp;

- (NSString *) statusStingWithPossessive:(NSString *)possessive;

- (IBAction)helpClicked:(id)sender;

@end

@interface BundleClanHelp : NSObject <ClanHelp>

@property (nonatomic, retain) MinimumUserProto *requester;
@property (nonatomic, retain) NSString *clanUuid;
@property (nonatomic, assign) GameActionType helpType;

// Basically we are going to just hold the list and parse it for all protocol functions.
@property (nonatomic, retain) NSMutableArray *clanHelps;

+ (id<ClanHelp>) getPossibleBundleFromClanHelp:(ClanHelp *)clanHelp;

@end
