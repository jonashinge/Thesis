//
//  PersistencyManager.m
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 27/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "PersistencyManager.h"

#import "Playlist.h"
#import "Track.h"
#import "TrackArchiver.h"

@interface PersistencyManager ()

@property (strong, nonatomic) NSMutableArray *playlists;

@end

// Set the DEBUG_PRINTOUT define to '1' to enable printouts of the received values
#define DEBUG_PRINTOUT      0

#if !DEBUG_PRINTOUT
#define DEBUGLog(format, ...)
#else
#define DEBUGLog(format, ...) NSLog(format, ## __VA_ARGS__)
#endif

@implementation PersistencyManager

- (id)init
{
    self = [super init];
    if(self)
    {
        NSData *data = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/playlists.bin"]];
        _playlists = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if(_playlists == nil)
        {
            _playlists = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (void)syncExistingPlaylistsWithList:(Playlist *)list
{
    BOOL listAdded = NO;
    for (int i=0; i<[_playlists count]; i++) {
        Playlist *pl = [_playlists objectAtIndex:i];
        if([pl.itemId isEqualToString:list.itemId])
        {
            [_playlists replaceObjectAtIndex:i withObject:list];
            listAdded = YES;
        }
    }
    if(listAdded == NO)
    {
        [_playlists addObject:list];
    }
    
    NSString *filename = [NSHomeDirectory() stringByAppendingString:@"/Documents/playlists.bin"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_playlists];
    [data writeToFile:filename atomically:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DEEZER_PLAYLIST_INFO_UPDATED
                                                        object:self
                                                      userInfo:nil];
}

- (void)syncTrackDataForPlaylistWithId:(NSString *)itemId
{
    Playlist *pl;
    for (int i=0; i<[_playlists count]; i++) {
        pl = [_playlists objectAtIndex:i];
        if([pl.itemId isEqualToString:itemId])
        // Tracks
        for (int j=0; j<[pl.tracks count]; j++)
        {
            dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
            dispatch_async(myQueue, ^{
                // Perform long running process
                Track *track = [pl.tracks objectAtIndex:j];
                TrackArchiver *archiver = [[TrackArchiver alloc] init];
                [archiver archiveTrack:track];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update the UI
                    [[NSNotificationCenter defaultCenter] postNotificationName:DEEZER_PLAYLIST_DATA_UPDATED
                                                                        object:self
                                                                      userInfo:nil];
                });
            });
        }
    }
}

- (NSArray *)getPlaylists
{
    return _playlists;
}

@end
