//
//  BoardLayoutProto+Properties.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/27/14.
//  Copyright (c) 2014 LVL6. All rights reserved.
//

#import "Board.pb.h"

@interface BoardLayoutProto (Properties)

- (NSArray *) propertiesForColumn:(int)column row:(int)row;

@end
