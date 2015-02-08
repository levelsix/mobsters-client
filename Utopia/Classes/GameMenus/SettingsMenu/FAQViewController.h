//
//  FAQViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 7/2/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "PopupSubViewController.h"

@interface FAQViewController : PopupSubViewController <UITableViewDataSource, UITableViewDelegate> {
  NSParagraphStyle *_paraStyle;
}

@property (nonatomic, strong) NSArray *textStrings;

@property (nonatomic, strong) IBOutlet UITableView *faqTable;

@end
