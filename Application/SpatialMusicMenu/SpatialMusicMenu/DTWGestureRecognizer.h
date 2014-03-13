//
//  DTWGestureRecognizer.h
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 12/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTWGestureRecognizer : NSObject

- (id)initWithDimension:(NSInteger)dimension GlobalThreshold:(CGFloat)threshold FirstThreshold:(CGFloat)firstThreshold AndMaxSlope:(NSInteger)maxSlope;
- (void)addKnownSequence:(NSMutableArray *)seq WithLabel:(NSString *)label;
- (NSString *)recognizeSequence:(NSArray *)seq;

@end
