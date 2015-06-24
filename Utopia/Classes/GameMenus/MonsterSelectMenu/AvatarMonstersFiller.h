//
//  AvatarMonstersFiller.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/24/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MonsterSelectViewController.h"

#import "Protocols.pb.h"

@interface AvatarMonsterSelectCell : ListCollectionViewCell

@property (nonatomic, retain) IBOutlet MiniMonsterView *monsterView;

- (void) updateForListObject:(id)listObject;

@end

@protocol AvatarMonstersFillerDelegate <NSObject>

- (void) avatarMonsterChosen;
- (void) monsterSelectClosed;

@end

@interface AvatarMonstersFiller : NSObject <MonsterSelectDelegate>

@property (nonatomic, weak) id<AvatarMonstersFillerDelegate> delegate;

@end
