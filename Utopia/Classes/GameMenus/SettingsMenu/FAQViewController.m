//
//  FAQViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 7/2/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "FAQViewController.h"

#import "Globals.h"

#define SECTION_IDENTIFIER @"Section"
#define QUESTION_IDENTIFIER @"Question"
#define SUBTITLE_IDENTIFIER @"Subtitle"
#define TEXT_IDENTIFIER @"Text"
#define NEWLINE_IDENTIFIER @"Newline"

#define HEADER_SUFFIX @"<h>"
#define SECTION_SUFFIX @"<s>"
#define SUBTITLE_SUFFIX @"<st>"
#define QUESTION_SUFFIX @"?"
#define REPLACEMENT_DELIMITER @"`"
#define LABEL_TAG 51

#define SECTION_FONT @"Ziggurat-HTF-Black"
#define TEXT_FONT @"Gotham-Book"
#define SUBTITLE_FONT @"Gotham-Ultra"
#define QUESTION_FONT @"Gotham-Ultra"

#define SECTION_FONT_SIZE 16
#define TEXT_FONT_SIZE 12
#define SUBTITLE_FONT_SIZE 13
#define QUESTION_FONT_SIZE 13

#define TEXT_LEFT_RIGHT_OFFSET 15
#define NEWLINE_VERTICAL_SPACING 10

@implementation FAQViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  [paragraphStyle setLineSpacing:6.f];
  _textParaStyle = paragraphStyle;
  
  paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  [paragraphStyle setLineSpacing:2.f];
  _questionParaStyle = paragraphStyle;
  
  [self loadFAQ];
}

- (void) loadFAQ {
  Globals *gl = [Globals sharedGlobals];
  [self loadFile:gl.faqFileName ? gl.faqFileName : @"FAQ.txt"];
}

- (void)loadFile:(NSString *)file {
  [self parseFile:file];
  [self.faqTable reloadData];
}

- (NSString *) replaceDelimitersInString:(NSString *)line {
  Globals *gl = [Globals sharedGlobals];
  while (true) {
    NSRange delimStart = [line rangeOfString:REPLACEMENT_DELIMITER];
    if (delimStart.location == NSNotFound) {
      break;
    }
    
    line = [line stringByReplacingCharactersInRange:delimStart withString:@""];
    NSRange delimEnd = [line rangeOfString:REPLACEMENT_DELIMITER];
    
    if (delimEnd.location == NSNotFound) {
      break;
    }
    
    line = [line stringByReplacingCharactersInRange:delimEnd withString:@""];
    NSString *val = [line substringWithRange:NSMakeRange(delimStart.location, delimEnd.location-delimStart.location)];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL selector = NSSelectorFromString(val);
    id glVal = nil;
    if ([gl respondsToSelector:selector]) {
      glVal = [gl performSelector:selector];
    } else {
      LNLog(@"%@ is not a valid selector in Globals", val);
    }
#pragma clang diagnostic pop
    // Get the letter right after the selector, it gives us the interpretation
    // f is float, i is int, p is percent
    NSString *interp = [line substringWithRange:delimEnd];
    
    if ([interp isEqualToString:@"f"]) {
      float *x = (void *)&glVal;
      line = [line stringByReplacingOccurrencesOfString:[val stringByAppendingString:interp] withString:[NSString stringWithFormat:@"%d", (int)*x]];
    } else if ([interp isEqualToString:@"i"]) {
      int *x = (void *)&glVal;
      line = [line stringByReplacingOccurrencesOfString:[val stringByAppendingString:interp] withString:[NSString stringWithFormat:@"%d", *x]];
    } else if ([interp isEqualToString:@"p"]) {
      float *x = (void *)&glVal;
      line = [line stringByReplacingOccurrencesOfString:[val stringByAppendingString:interp] withString:[NSString stringWithFormat:@"%d", (int)((*x)*100)]];
    }
  }
  return line;
}

- (void)parseFile:(NSString *)faqFile {
  [self parseFile:faqFile shouldAttemptDownload:YES];
}

- (void) parseFile:(NSString *)faqFile shouldAttemptDownload:(BOOL)shouldAttemptDownload {
  [Globals checkAndLoadFile:faqFile useiPhone6Prefix:NO useiPadSuffix:NO completion:^ (BOOL success) {
    if (success) {
      NSError *e;
      NSString *filePath = [Globals pathToFile:faqFile useiPhone6Prefix:NO useiPadSuffix:NO];
      NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&e];
      
      if (!fileContents) {
        LNLog(@"fileContents is nil! error = %@", e);
        return;
      }
      
      NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];
      
      NSMutableArray *text = [NSMutableArray array];
      NSMutableArray *curArr = nil;
      for (NSString *line in lines) {
        // Replace delimited strings with their proper constants..
        NSString *line2 = [self replaceDelimitersInString:line];
        
        if ([line2 hasSuffix:HEADER_SUFFIX]) {
          curArr = [NSMutableArray array];
          [text addObject:curArr];
          line2 = [line2 stringByReplacingOccurrencesOfString:HEADER_SUFFIX withString:@""];
          [curArr addObject:line2];
        } else {
          [curArr addObject:line2];
        }
      }
      self.textStrings = text;
    } else {
      NSLog(@"Failed to download %@", faqFile);
    }
  }];
  
}

#pragma mark - FAQ Table Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.textStrings.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[self.textStrings objectAtIndex:section] count] -1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSArray *arr = [self.textStrings objectAtIndex:indexPath.section];
  NSString *text = [arr objectAtIndex:indexPath.row+1];
  
  BOOL isSectionTitle = NO;
  BOOL isQuestion = NO;
  BOOL isNewline = NO;
  BOOL isSubtitle = NO;
  NSString *reuseId = TEXT_IDENTIFIER;
  NSDictionary *attrs = nil;
  if (text.length == 0) {
    reuseId = NEWLINE_IDENTIFIER;
    isNewline = YES;
  } else if ([text hasSuffix:SECTION_SUFFIX]) {
    isSectionTitle = YES;
    text = [text stringByReplacingOccurrencesOfString:SECTION_SUFFIX withString:@""];
    reuseId = SECTION_IDENTIFIER;
  } else if ([text hasSuffix:SUBTITLE_SUFFIX]) {
    isSubtitle = YES;
    text = [text stringByReplacingOccurrencesOfString:SUBTITLE_SUFFIX withString:@""];
    reuseId = SUBTITLE_IDENTIFIER;
  } else if ([text hasSuffix:QUESTION_SUFFIX]) {
    isQuestion = YES;
    reuseId = QUESTION_IDENTIFIER;
    attrs = @{NSParagraphStyleAttributeName:_questionParaStyle};
  } else {
    attrs = @{NSParagraphStyleAttributeName:_textParaStyle};
  }
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    cell.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.tag = LABEL_TAG;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.textColor = [UIColor colorWithWhite:51/255.f alpha:1.f];
    [cell.contentView addSubview:label];
    
    if (!isNewline) {
      if (isSectionTitle) {
        label.font = [UIFont fontWithName:SECTION_FONT size:SECTION_FONT_SIZE];
      } else if (isQuestion) {
        label.font = [UIFont fontWithName:QUESTION_FONT size:QUESTION_FONT_SIZE];
      } else if (isSubtitle) {
        label.font = [UIFont fontWithName:SUBTITLE_FONT size:SUBTITLE_FONT_SIZE];
      } else {
        label.font = [UIFont fontWithName:TEXT_FONT size:TEXT_FONT_SIZE];
      }
    }
  }
  
  UILabel *label = (UILabel *)[cell.contentView viewWithTag:LABEL_TAG];
  label.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attrs];
  
  CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
  label.frame = CGRectMake(TEXT_LEFT_RIGHT_OFFSET,0,tableView.frame.size.width-2*TEXT_LEFT_RIGHT_OFFSET,height);
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSArray *arr = [self.textStrings objectAtIndex:indexPath.section];
  NSString *text = [arr objectAtIndex:indexPath.row+1];
  
  if (text.length == 0) {
    return NEWLINE_VERTICAL_SPACING;
  }
  
  UIFont *font = [UIFont fontWithName:TEXT_FONT size:TEXT_FONT_SIZE];
  NSDictionary *attrs = nil;
  
  if ([text hasSuffix:SECTION_SUFFIX]) {
    text = [text stringByReplacingOccurrencesOfString:SECTION_SUFFIX withString:@""];
    font = [UIFont fontWithName:SECTION_FONT size:SECTION_FONT_SIZE];
  } else if ([text hasSuffix:SUBTITLE_SUFFIX]) {
    text = [text stringByReplacingOccurrencesOfString:SUBTITLE_SUFFIX withString:@""];
    font = [UIFont fontWithName:SUBTITLE_FONT size:SUBTITLE_FONT_SIZE];
  } else if ([text hasSuffix:QUESTION_SUFFIX]) {
    font = [UIFont fontWithName:QUESTION_FONT size:QUESTION_FONT_SIZE];
    attrs = @{NSParagraphStyleAttributeName:_questionParaStyle, NSFontAttributeName : font};
  } else {
    attrs = @{NSParagraphStyleAttributeName:_textParaStyle, NSFontAttributeName : font};
  }
  
  if (!attrs) {
    attrs = @{NSFontAttributeName : font};
  }
  
  CGRect rect = CGRectMake(TEXT_LEFT_RIGHT_OFFSET,0,tableView.frame.size.width-2*TEXT_LEFT_RIGHT_OFFSET,0);
  NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:text attributes:attrs];
  CGRect r = [attrText boundingRectWithSize:rect.size options:NSStringDrawingUsesLineFragmentOrigin context:NULL];
  
  return r.size.height+5;
}

@end
