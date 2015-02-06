//
//  TeamDonateMonstersFiller.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MonsterSelectViewController.h"

#import "Protocols.pb.h"

@interface TeamDonateMonsterSelectCell : ListCollectionViewCell

@property (nonatomic, retain) IBOutlet MiniMonsterView *monsterView;

@property (nonatomic, retain) IBOutlet SplitImageProgressBar *healthBar;
@property (nonatomic, retain) IBOutlet UILabel *healthLabel;

@property (nonatomic, retain) IBOutlet UILabel *statusLabel;

- (void) updateForListObject:(id)listObject powerLimit:(int)powerLimit;

@end

@protocol TeamDonateMonstersFillerDelegate <NSObject>

- (void) monsterChosen;
- (void) monsterSelectClosed;

@end

@interface TeamDonateMonstersFiller : NSObject <MonsterSelectDelegate>

@property (nonatomic, retain) ClanMemberTeamDonationProto *donation;

@property (nonatomic, assign) id<TeamDonateMonstersFillerDelegate> delegate;

- (id) initWithDonation:(ClanMemberTeamDonationProto *)donation;

@end
