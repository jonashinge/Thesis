//
//  NSArray+Helpers.m
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 03/05/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "NSArray+Helpers.h"

@implementation NSArray (Helpers)

- (NSArray *) shuffled
{
	// create temporary autoreleased mutable array
	NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[self count]];
    
	for (id anObject in self)
	{
		NSUInteger randomPos = arc4random()%([tmpArray count]+1);
		[tmpArray insertObject:anObject atIndex:randomPos];
	}
    
	return [NSArray arrayWithArray:tmpArray];  // non-mutable autoreleased copy
}

@end
