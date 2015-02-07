//
//  SkillThickSkin.h
//  Utopia
//
//  Created by Behrouz N. on 12/4/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "SkillControllerActiveBuff.h"

@interface SkillThickSkin : SkillControllerActiveBuff
{
  // Properties
  float _bonusResistance;
  
  // Temp
  BOOL _logoShown;
  NSInteger _damageAbsorbed;
}

@end
