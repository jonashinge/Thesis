//
//  DTWGestureRecognizer.h
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 12/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTWRecognizer : NSObject

- (id)initWithDimension:(NSInteger)dimension GlobalThreshold:(CGFloat)threshold FirstThreshold:(CGFloat)firstThreshold AndMaxSlope:(NSInteger)maxSlope;
- (void)addKnownSequence:(NSArray *)seq WithLabel:(NSString *)label;
- (NSDictionary *)recognizeSequence:(NSArray *)seq;
- (void)clearAllKnownSequences;

- (double)outputAccuracy;

@end
