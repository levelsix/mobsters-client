//
//  DetailViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 3/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "DetailViewController.h"
#import "GameState.h"

@implementation DetailViewCell

- (void)updateWithRank:(NSString *)rank description:(NSString *)description showCheckMark:(BOOL)show {
  self.rankLabel.text = rank;
  self.improvementLabel.text = description;
  self.checkMark.hidden = !show;
}

@end

@implementation DetailView

- (void) updateWithGameTypeProto:(id<GameTypeProtocol>)protocol index:(int)index imageNamed:(NSString *)imageName{
  
  {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:protocol.name attributes:@{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : self.nameLabel.font}];
    self.nameLabel.attributedText = attr;
    
    CGRect rect = [attr boundingRectWithSize:CGSizeMake(self.nameLabel.width, 9999) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    self.nameLabel.originY = floorf(CGRectGetMaxY(self.nameLabel.frame) - rect.size.height);
    self.nameLabel.height = ceilf(rect.size.height);
  }
  
  int curLevel = protocol.rank;
  self.rankLabel.text = [NSString stringWithFormat:@"%d/%d",curLevel, protocol.totalRanks];
  [Globals imageNamed:imageName withView:self.icon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
}

@end

@implementation DetailViewController

- (id) initWithGameTypeProto:(id<GameTypeProtocol>)gameTypeProto index:(int)index imageNamed:(NSString *)imageName{
  return [self initWithGameTypeProto:gameTypeProto index:index imageNamed:imageName columnName:@"LVL"];
}

- (id) initWithGameTypeProto:(id<GameTypeProtocol>)gameTypeProto index:(int)index imageNamed:(NSString *)imageName columnName:(NSString *)columnName {
  if ((self = [super init])){
    _gameTypeProto = gameTypeProto;
    _index = index;
    _imageName = imageName;
    _columnName = columnName;
  }
  return self;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.title = [NSString stringWithFormat:@"%@ Details", [_gameTypeProto statNameForIndex:_index]];
  self.columnNameLabel.text = _columnName;
  [self.detailView updateWithGameTypeProto:_gameTypeProto index:_index imageNamed:_imageName];
}

#pragma TableView Delegates

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  id<GameTypeProtocol> protocol = [_gameTypeProto fullFamilyList][indexPath.row];
  
  DetailViewCell *cell;
  cell = [tableView dequeueReusableCellWithIdentifier:@"DetailViewCell"];
  if (!cell) {
    cell = [[NSBundle mainBundle] loadNibNamed:@"DetailViewCell" owner:self options:nil][0];
  }
  
  if ([protocol rank] == [[_gameTypeProto successor] rank]) {
    cell.bgView.backgroundColor = [UIColor colorWithHexString:@"FFFFDC"];
  } else {
    cell.bgView.backgroundColor = [UIColor clearColor];
  }
  
  NSString *description = [protocol shortStatChangeForIndex:_index];
  [cell updateWithRank:[NSString stringWithFormat:@"%d",[protocol rank]] description:description showCheckMark:[protocol rank] <= [_gameTypeProto rank]];
  
  return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_gameTypeProto fullFamilyList].count;
}

@end
