//
//  ClanTeamDonateUtil.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/30/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Protocols.pb.h"
#import "ChatObject.h"
#import "UserData.h"

@interface ClanMemberTeamDonationProto (ChatObject) <ChatObject>

- (UserMonster *) donatedMonster;
- (MSDate *) fulfilledDate;

- (IBAction) donateClicked:(id)sender;

@end

@interface ClanTeamDonateUtil : NSObject

@property (nonatomic, retain) NSMutableArray *teamDonations;

- (void) addClanTeamDonations:(NSArray *)teamDonations;
- (void) removeClanTeamDonationWithUuids:(NSArray *)donationUuids;

- (ClanMemberTeamDonationProto *) myTeamDonation;

@end
