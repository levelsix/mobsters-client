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

-(void)updateWithRank:(NSString *)rank description:(NSString *)description showCheckMark:(BOOL)show {
  self.rankLabel.text = rank;
  self.improvementLabel.text = description;
  self.checkMark.hidden = !show;
}

@end

@implementation DetailView

-(void) updateWithGameTypeProto:(id<GameTypeProto>)protocol index:(int)index imageNamed:(NSString *)imageName{
  self.Name.text = protocol.name;
  int curLevel = protocol.rank;
  self.Rank.text = [NSString stringWithFormat:@"%d/%d",curLevel, protocol.totalRanks];
  [Globals imageNamed:imageName withView:self.Icon greyscale:NO indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
}

@end

@implementation DetailViewController

- (id) initWithGameTypeProto:(id<GameTypeProto>)gameTypeProto index:(int)index imageNamed:(NSString *)imageName{
  return [self initWithGameTypeProto:gameTypeProto index:index imageNamed:imageName columnName:@"LVL"];
}

- (id) initWithGameTypeProto:(id<GameTypeProto>)gameTypeProto index:(int)index imageNamed:(NSString *)imageName columnName:(NSString *)columnName{
  _gameTypeProto = gameTypeProto;
  _index = index;
  _imageName = imageName;
  _columnName = columnName;
  
  if((self = [super init])){
    self.title = [NSString stringWithFormat:@"%@ Ranks", [gameTypeProto statNameForIndex:index]];
  }
  return self;
}

-(void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  self.title = [NSString stringWithFormat:@"%@ Details", [_gameTypeProto statNameForIndex:_index]];
  self.columnNameLabel.text = _columnName;
  [self.view updateWithGameTypeProto:_gameTypeProto index:_index imageNamed:_imageName];
}

#pragma TableView Delegates

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  id<GameTypeProto> protocol = [_gameTypeProto fullFamilyList][indexPath.row];
  
  DetailViewCell *cell;
  cell = [tableView dequeueReusableCellWithIdentifier:@"DetailViewCell"];
  if (!cell) {
    cell = [[NSBundle mainBundle] loadNibNamed:@"DetailViewCell" owner:self options:nil][0];
  }
  
  if ([protocol rank] == [_gameTypeProto rank]) {
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
