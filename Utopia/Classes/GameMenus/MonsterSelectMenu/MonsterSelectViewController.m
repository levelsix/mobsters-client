//
//  MonsterSelectViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "MonsterSelectViewController.h"

#import "Globals.h"

@implementation MonsterSelectViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.listView.cellClassName = [self.delegate cellClassName];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self reloadData];
}

- (void) reloadData {
  [self reloadDataAnimated:NO];
}

- (void) reloadDataAnimated:(BOOL)animated {
  self.monsters = [self.delegate reloadMonstersArray];
  [self.listView reloadTableAnimated:animated listObjects:self.monsters];
  
  self.titleLabel.text = [self.delegate titleName];
  
  if ([self.delegate respondsToSelector:@selector(footerTitle)] &&
      [self.delegate respondsToSelector:@selector(footerDescription)]) {
    self.footerTitleLabel.text = [self.delegate footerTitle];
    
    NSString *desc = [self.delegate footerDescription];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:3];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:desc];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, desc.length)];
    self.footerDescLabel.attributedText = attributedString;
  } else {
    self.footerTitleLabel.superview.hidden = YES;
  }
  
}

- (IBAction)closeClicked:(id)sender {
  [super closeClicked:sender];
  
  [self.delegate monsterSelectClosed];
  self.delegate = nil;
}

#pragma mark - ListCollectionView delegate

- (void) listView:(ListCollectionView *)listView updateCell:(ListCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath listObject:(id)listObject {
  [self.delegate updateCell:cell monster:listObject];
}

- (void) listView:(ListCollectionView *)listView cardClickedAtIndexPath:(NSIndexPath *)indexPath {
  UserMonster *um = self.monsters[indexPath.row];
  [self.delegate monsterSelected:um viewController:self];
}

@end
