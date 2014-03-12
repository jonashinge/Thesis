//
//  DTWGestureRecognizer.h
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 12/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTWGestureRecognizer : NSObject

- (id)initWithDimension:(int)dimension GlobalThreshold:(double)threshold FirstThreshold:(double)firstThreshold AndMaxSlope:(int)maxSlope;

@end
