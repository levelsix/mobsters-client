//
//  DetailViewController.h
//  Utopia
//
//  Created by Kenneth Cox on 3/2/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSubViewController.h"
#import "GameTypeProtocol.h"

@interface DetailViewCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UIView *bgView;
@property (nonatomic, assign) IBOutlet UIImageView *checkMark;
@property (nonatomic, assign) IBOutlet UILabel *rankLabel;
@property (nonatomic, assign) IBOutlet UILabel *improvementLabel;

- (void) updateWithRank:(NSString *)rank description:(NSString *)description showCheckMark:(BOOL)show;

@end

@interface DetailView : UIView

@property (nonatomic, assign) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign) IBOutlet UILabel *rankLabel;
@property (nonatomic, assign) IBOutlet UIImageView *icon;

- (void) updateWithGameTypeProto:(id<GameTypeProtocol>)gameTypeProto index:(int)index imageNamed:(NSString *)imageName;

@end

@interface DetailViewController : PopupSubViewController {
  id<GameTypeProtocol> _gameTypeProto;
  int _index;
  NSString *_imageName;
  NSString *_columnName;
}

@property (nonatomic, assign) IBOutlet UITableView *tableView;
@property (nonatomic, assign) IBOutlet NiceFontLabel10 *columnNameLabel;

- (id) initWithGameTypeProto:(id<GameTypeProtocol>)gameTypeProto index:(int)index imageNamed:(NSString *)imageName;
- (id) initWithGameTypeProto:(id<GameTypeProtocol>)gameTypeProto index:(int)index imageNamed:(NSString *)imageName columnName:(NSString *)columnName;

@property (nonatomic, assign) IBOutlet DetailView *view;

@end
