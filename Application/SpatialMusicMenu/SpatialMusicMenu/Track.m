//
//  Track.m
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 10/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "Track.h"

#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"

@implementation Track

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"title": @"title",
             @"preview": @"preview"
             };
}

+ (NSValueTransformer *)previewJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
