//
//  Gesture.h
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 02/04/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "MTLModel.h"

@interface Gesture : MTLModel

@property (strong, nonatomic) NSDate *timestamp;
@property (strong, nonatomic) NSString *label;
@property (strong, nonatomic) NSArray *data;

@end
