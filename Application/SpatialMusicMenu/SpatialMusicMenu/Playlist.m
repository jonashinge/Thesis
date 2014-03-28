//
//  Playlist.m
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 27/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "Playlist.h"

#import "Track.h"

#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"


@implementation Playlist

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

+ (NSValueTransformer *)previewJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

- (BOOL)isReadyForSpatialAudioUse
{
    if([_tracks count] < 2)
    {
        return NO;
    }
    for (int i=0; i<[_tracks count]; i++) {
        Track *track = [_tracks objectAtIndex:i];
        NSArray *dirs = NSSearchPathForDirectoriesInDomains
        (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
        NSString *exportPath = [documentsDirectoryPath
                       stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav",track.itemId]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:exportPath])
        {
            return NO;
        }
    }
    return YES;
}

@end
