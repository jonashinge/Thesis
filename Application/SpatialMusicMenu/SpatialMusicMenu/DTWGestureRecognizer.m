//
//  DTWGestureRecognizer.m
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 12/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "DTWGestureRecognizer.h"

@interface DTWGestureRecognizer ()

// Known sequences and their labels
@property (strong, nonatomic) NSMutableArray *sequences;
@property (strong, nonatomic) NSMutableArray *labels;

// Size of obeservations vectors.
@property int dimension;
// Maximum DTW distance between an example and a sequence being classified.
@property double globalThreshold;
// Maximum distance between the last observations of each sequence.
@property double firstThreshold;
// Maximum vertical or horizontal steps in a row.
@property int maxSlope;

@end

@implementation DTWGestureRecognizer

- (id)initWithDimension:(int)dimension GlobalThreshold:(double)threshold FirstThreshold:(double)firstThreshold AndMaxSlope:(int)maxSlope
{
    self = [super init];
    if(self) {
        self.dimension = dimension;
        self.globalThreshold = threshold;
        self.firstThreshold = firstThreshold;
        self.maxSlope = maxSlope;
    }
    return self;
}

@end
