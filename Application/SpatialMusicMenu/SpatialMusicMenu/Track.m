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
             @"itemId": @"id",
             @"artist": @"artist.name",
             @"title": @"title",
             @"preview": @"preview",
             @"stream": @"stream",
             @"albumId": @"album.id",
             @"albumName": @"album.title"
             };
}

+ (NSValueTransformer *)previewJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
