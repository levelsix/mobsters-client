//
//  SettingsViewController.m
//  Utopia
//
//  Created by Danny on 9/9/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "SettingsViewController.h"
#import "SoundEngine.h"
#import "GameState.h"

#define SECTION_IDENTIFIER @"Section"
#define QUESTION_IDENTIFIER @"Question"
#define TEXT_IDENTIFIER @"Text"
#define NEWLINE_IDENTIFIER @"Newline"

#define HEADER_SUFFIX @"<h>"
#define SECTION_SUFFIX @"<s>"
#define QUESTION_SUFFIX @"?"
#define REPLACEMENT_DELIMITER @"`"
#define LABEL_TAG 51

#define SECTION_FONT_SIZE 20
#define TEXT_FONT_SIZE 14
#define QUESTION_FONT_SIZE 13

#define TEXT_LEFT_RIGHT_OFFSET 20
#define NEWLINE_VERTICAL_SPACING 10

@implementation SettingsViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setUpCloseButton];
  [self setUpImageBackButton];
  
  [self maskButton];
  
  [self.view addSubview:self.faqView];
  self.faqView.frame = self.view.bounds;
  self.faqView.hidden = YES;
  
  self.menuTopBar.delegate = self;
  self.navigationItem.titleView = self.menuTopBar;
  
  [self loadSettings];
}

- (void) button1Clicked:(id)sender {
  self.settingsView.hidden = NO;
  self.faqView.hidden = YES;
}

- (void) button2Clicked:(id)sender {
  [self loadFAQ];
}

- (void) maskButton {
  for (int i = 1; i <= 3;i++) {
    UIImage *maskImage = [UIImage imageNamed:@"onoffswitchbg.png"];
    CALayer *mask = [CALayer layer];
    mask.contents = (id)[maskImage CGImage];
    mask.frame = CGRectMake(0, 0, maskImage.size.width, maskImage.size.height);
    
    SettingSwitchButton *button = (SettingSwitchButton *)[self.view viewWithTag:i];
    button.layer.mask = mask;
  }
}

- (void) loadFAQ {
  Globals *gl = [Globals sharedGlobals];
  [self loadFile:gl.faqFileName ? gl.faqFileName : @"FAQ.3.txt"];
  self.settingsView.hidden = YES;
  self.faqView.hidden = NO;
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
  NSError *e;
  NSString *fileRoot = [Globals pathToFile:faqFile];
  NSString *fileContents = [NSString stringWithContentsOfFile:fileRoot encoding:NSUTF8StringEncoding error:&e];
  
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
}

- (void)loadSettings {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  self.musicSwitchButton.isOn = ![ud boolForKey:MUSIC_DEFAULTS_KEY];
  self.soundSwitchButton.isOn = ![ud boolForKey:SOUND_EFFECTS_DEFAULTS_KEY];
  self.shakeSwitchButton.isOn = [ud boolForKey:SHAKE_DEFAULTS_KEY];
  [self.musicSwitchButton setOnOffPositon];
  [self.soundSwitchButton setOnOffPositon];
  [self.shakeSwitchButton setOnOffPositon];
}

#pragma mark - Settings IBActions

- (IBAction)emailSupport:(id)sender {
  NSString *e = @"support@lvl6.com";
  GameState *gs = [GameState sharedGameState];
  NSString *messageBody = [NSString stringWithFormat:@"\n\nSent by user %@ with referral code %@.", gs.name, gs.referralCode];
  if ([MFMailComposeViewController canSendMail]) {
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setToRecipients:[NSArray arrayWithObject:e]];
    
    [controller setMessageBody:messageBody isHTML:NO];
    if (controller) [self.navigationController presentViewController:controller animated:YES completion:nil];
  } else {
    // Launches the Mail application on the device.
    
    NSString *email = [NSString stringWithFormat:@"mailto:%@?body=%@", e, messageBody];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
  }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)forums:(id)sender {
  NSString *forumLink = @"http://forum.lvl6.com";
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:forumLink]];
}

- (IBAction)writeAReview:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:gl.reviewPageURL]];
}

- (IBAction)moreGames:(id)sender {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/artist/lvl6-inc/id477653814"]];
}

- (IBAction)changeCharacter:(id)sender {
  
}

- (IBAction)changeName:(id)sender {
  
}

- (void)buttonTurnedOn:(SettingSwitchButton *)button {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  if (button.tag == 1) {
    [ud setBool:NO forKey:MUSIC_DEFAULTS_KEY];
    [[SoundEngine sharedSoundEngine] resumeBackgroundMusic];
  } else if (button.tag == 2) {
    [ud setBool:NO forKey:SOUND_EFFECTS_DEFAULTS_KEY];
  } else if (button.tag == 3) {
    [ud setBool:YES forKey:SHAKE_DEFAULTS_KEY];
  }
}

- (void) buttonTurnedOff:(SettingSwitchButton *)button {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  if (button.tag == 1) {
    [ud setBool:YES forKey:MUSIC_DEFAULTS_KEY];
    [[SoundEngine sharedSoundEngine] stopBackgroundMusic];
  } else if (button.tag == 2) {
    [ud setBool:YES forKey:SOUND_EFFECTS_DEFAULTS_KEY];
  } else if (button.tag == 3) {
    [ud setBool:NO forKey:SHAKE_DEFAULTS_KEY];
  }
}

#pragma mark - FAQ Table Data Source

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.textStrings.count;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[self.textStrings objectAtIndex:section] count] -1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSArray *arr = [self.textStrings objectAtIndex:indexPath.section];
  NSString *text = [arr objectAtIndex:indexPath.row+1];
  
  BOOL isSectionTitle = NO;
  BOOL isQuestion = NO;
  BOOL isNewline = NO;
  NSString *reuseId = TEXT_IDENTIFIER;
  if (text.length == 0) {
    reuseId = NEWLINE_IDENTIFIER;
    isNewline = YES;
  } else if ([text hasSuffix:SECTION_SUFFIX]) {
    isSectionTitle = YES;
    text = [text stringByReplacingOccurrencesOfString:SECTION_SUFFIX withString:@""];
    reuseId = SECTION_IDENTIFIER;
  } else if ([text hasSuffix:QUESTION_SUFFIX]) {
    isQuestion = YES;
    reuseId = QUESTION_IDENTIFIER;
  }
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    cell.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.tag = LABEL_TAG;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    [cell.contentView addSubview:label];
    
    if (!isNewline) {
      if (isSectionTitle) {
        label.font = [UIFont fontWithName:[Globals font] size:SECTION_FONT_SIZE];
        label.textColor = [UIColor colorWithRed:0 green:232 blue:255 alpha:1.0f];
        //label.textColor = [Globals creamColor];
      } else if (isQuestion) {
        label.font = [UIFont fontWithName:[Globals font]size:QUESTION_FONT_SIZE];
        label.textColor = [Globals goldColor];
      } else {
        label.font = [UIFont fontWithName:[Globals font] size:TEXT_FONT_SIZE];
        label.textColor = [Globals creamColor];
      }
    }
  }
  
  UILabel *label = (UILabel *)[cell.contentView viewWithTag:LABEL_TAG];
  label.text = text;
  
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
  
  UIFont *font = [UIFont fontWithName:[Globals font]size:TEXT_FONT_SIZE];
  
  if ([text hasSuffix:SECTION_SUFFIX]) {
    text = [text stringByReplacingOccurrencesOfString:SECTION_SUFFIX withString:@""];
    font = [UIFont fontWithName:[Globals font] size:SECTION_FONT_SIZE];
  } else if ([text hasSuffix:QUESTION_SUFFIX]) {
    font = [UIFont fontWithName:[Globals font] size:QUESTION_FONT_SIZE];
  }
  
  CGRect rect = CGRectMake(TEXT_LEFT_RIGHT_OFFSET,0,tableView.frame.size.width-2*TEXT_LEFT_RIGHT_OFFSET,9999);
  CGSize size = [text sizeWithFont:font constrainedToSize:rect.size];
  
  return size.height;
}

@end
