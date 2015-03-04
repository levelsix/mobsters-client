//
//  RearchTreeViewController.m
//  Utopia
//
//  Created by Kenneth Cox on 3/3/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import "ResearchTreeViewController.h"

@implementation ResearchTreeViewController

-(id)initWithDomain:(ResearchDomain)domain {
  if((self = [super init])){
    switch (domain) {
      case ResearchDomainBattle:
        self.titleImageName = @"researchbattle.png";
        break;
      case ResearchDomainResources:
        self.titleImageName = @"researchresources.png";
        break;
      case ResearchDomainRestorative:
        self.titleImageName = @"researchtoons.png";
        break;
        
      default:
        break;
    }
  }
  return self;
}

-(void)viewDidLoad {
  self.title = @"Research";
  self.titleImageName = @"researchtoons.png";
//  ResearchInfoViewController *rivc = [[ResearchInfoViewController alloc] init];
//  [self.parentViewController pushViewController:rivc animated:YES];
}

-(void)researchButtonClickWithIndex:(NSInteger) index {
  
}

@end

@implementation ResearchButtonView



@end
