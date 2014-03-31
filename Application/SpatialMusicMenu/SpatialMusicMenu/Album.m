//
//  Album.m
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 31/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "Album.h"

#import "Track.h"

#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"

@implementation Album

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"itemId": @"id",
             @"title": @"title",
             @"tracks": @"tracks.data"
             };
}

+ (NSValueTransformer *)tracksJSONTransformer
{
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[Track class]];
}

@end
