//
//  SkillProtoHelper.h
//  Utopia
//
//  Created by Rob Giusti on 4/7/15.
//  Copyright (c) 2015 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Skill.pb.h"


@interface SkillProtoHelper : NSObject

+ (NSString*) offDescForSkill:(SkillProto*)skill;
+ (NSString*) offShortDescForSkill:(SkillProto*)skill;
+ (NSString*) defDescForSkill:(SkillProto*)skill;
+ (NSString*) defShortDescForSkill:(SkillProto*)skill;

@end
