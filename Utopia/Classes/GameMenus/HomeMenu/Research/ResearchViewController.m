//
//  ResearchViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 2/27/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ResearchViewController.h"
#import "ResearchTreeViewController.h"

#import "GameState.h"

@implementation ResearchViewController

- (void) viewDidLoad {
  [super viewDidLoad];
  
  GameState *gs = [GameState sharedGameState];
  
  self.titleImageName = @"residencemenuheader.png";
  self.title = @"RESEARCH LAB";
  
  UserResearch *curResearch = [gs.researchUtil currentResearch];
  if(curResearch) {
    CGPoint position = self.selectFieldView.center;
    [self.selectFieldView removeFromSuperview];
    [self.view addSubview:self.curReseaerchBar];
    self.curReseaerchBar.center = position;
  }
}

#pragma mark - TableView Delegates

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ResearchCategoryCell *cell;
  cell = [tableView dequeueReusableCellWithIdentifier:@"ResearchCategoryCell"];
  if (!cell) {
    cell = [[NSBundle mainBundle] loadNibNamed:@"ResearchCategoryCell" owner:self options:nil][0];
  }
  
  ResearchDomain domain = (ResearchDomain)indexPath.row+2; //add 2 to avoid 0 and NO_DOMAIN
  [cell updateForDomain:domain];
  
  return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 4;//it looks like there is no way to just count how many enums there are
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  ResearchTreeViewController *rtvc = [[ResearchTreeViewController alloc] initWithDomain:(ResearchDomain)indexPath.row+2];
  [self.parentViewController pushViewController:rtvc animated:YES];
}

#pragma mark - updateLabels

-(void)updateLabels {
  //oneday
}

@end

@implementation ResearchCategoryCell : UITableViewCell

- (void) updateForDomain:(ResearchDomain) domain {
  
  switch (domain) {
    case ResearchDomainRestorative:
      self.categoryTitle.text = @"Restorative";
      self.categoryIcon.image = [Globals imageNamed:@"researchtoons.png"];
      break;
    case ResearchDomainBattle:
      self.categoryTitle.text = @"Battle";
      self.categoryIcon.image =[Globals imageNamed:@"researchbattle.png"];
      break;
    case ResearchDomainLevelup:
      self.categoryTitle.text = @"Level Up";
      break;
    case ResearchDomainResources:
      self.categoryTitle.text = @"Resources";
      self.categoryIcon.image =[Globals imageNamed:@"researchresources.png"];
      break;
      
    case ResearchDomainNoDomain:
      self.categoryTitle.text = @"No Domain";
      break;
      
      default:
      self.categoryTitle.text = [NSString stringWithFormat:@"Had a problem loading domain type %d",domain];
      break;
  }
  
}

@end
