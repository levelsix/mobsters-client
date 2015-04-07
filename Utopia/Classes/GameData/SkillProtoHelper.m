//
//  SkillProtoHelper.m
//  Utopia
//
//  Created by Rob Giusti on 4/7/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SkillProtoHelper.h"


@implementation SkillProtoHelper

+ (NSString *)offDescForSkill:(SkillProto *)skill {
  return [self processDescription:skill.offDesc forSkill:skill];
}

+ (NSString *)offShortDescForSkill:(SkillProto *)skill {
  return [self processDescription:skill.shortOffDesc forSkill:skill];
}

+ (NSString *)defDescForSkill:(SkillProto *)skill {
  return [self processDescription:skill.defDesc forSkill:skill];
}

+ (NSString *)defShortDescForSkill:(SkillProto *)skill {
  return [self processDescription:skill.shortDefDesc forSkill:skill];
}

+ (NSString *)processDescription:(NSString*)tip forSkill:(SkillProto*)skill {
  for (SkillPropertyProto *property in skill.propertiesList) {
    tip = [self replaceMultiplier:tip pattern:property.name value:property.skillValue];
    tip = [self replacePercentage:tip pattern:property.name value:property.skillValue];
    tip = [self replaceNormal:tip pattern:property.name value:property.skillValue];
  }
  tip = [self replaceNormal:tip pattern:@"DURATION" value:skill.skillEffectDuration];
  return tip;
}

+ (NSString *)replaceNormal:(NSString*)tip pattern:(NSString*)pattern value:(int)value {
  NSError *error = NULL;
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"\\$%@", pattern] options:0 error:&error];
  
  return [regex stringByReplacingMatchesInString:tip options:0 range:NSMakeRange(0, [tip length]) withTemplate:[NSString stringWithFormat:@"%i", value]];
}

+ (NSString *)replaceMultiplier:(NSString*)tip pattern:(NSString*)pattern value:(float)value {
  NSError *error = NULL;
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"\\$%@x", pattern] options:0 error:&error];
  
  return [regex stringByReplacingMatchesInString:tip options:0 range:NSMakeRange(0, [tip length]) withTemplate:[NSString stringWithFormat:@"%.2gx", value]];
  
}

+ (NSString *)replacePercentage:(NSString*)tip pattern:(NSString*)pattern value:(float)value {
  NSError *error = NULL;
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"\\$%@%%", pattern] options:0 error:&error];
  
  return [regex stringByReplacingMatchesInString:tip options:0 range:NSMakeRange(0, [tip length]) withTemplate:[NSString stringWithFormat:@"%i%%", (int)(value*100)]];
}

@end
