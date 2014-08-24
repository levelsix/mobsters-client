//
//  RWTSwap.m
//  orbCrunch
//
//  Created by Matthijs on 26-02-14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

#import "BattleSwap.h"
#import "BattleOrb.h"

@implementation BattleSwap

// By overriding this method you can use [NSSet containsObject:] to look for
// a matching RWTSwap object in that collection.
- (BOOL)isEqual:(id)object {

  // You can only compare this object against other RWTSwap objects.
  if (![object isKindOfClass:[BattleSwap class]]) return NO;

  // Two swaps are equal if they contain the same orb, but it doesn't
  // matter whether they're called A in one and B in the other.
  BattleSwap *other = (BattleSwap *)object;
  return (other.orbA == self.orbA && other.orbB == self.orbB) ||
         (other.orbB == self.orbA && other.orbA == self.orbB);
}

// If you override isEqual: you also need to override hash. The rule is that
// if two objects are equal, then their hashes must also be equal.
- (NSUInteger)hash {
  return [self.orbA hash] ^ [self.orbB hash];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@ swap %@ with %@", [super description], self.orbA, self.orbB];
}

@end
