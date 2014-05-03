//
//  PersistencyManager.m
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 27/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "PersistencyManager.h"

#import "AppDelegate.h"
#import "Playlist.h"
#import "Track.h"
#import "Album.h"
#import "Gesture.h"
#import "TrackArchiver.h"
#import "NSArray+Helpers.h"

@interface PersistencyManager ()

@property (strong, nonatomic) NSMutableArray *playlists;
@property (strong, nonatomic) NSMutableArray *albums;

@property (strong, nonatomic) NSMutableArray *gestures;

@end

// Set the DEBUG_PRINTOUT define to '1' to enable printouts of the received values
#define DEBUG_PRINTOUT      1

#if !DEBUG_PRINTOUT
#define DEBUGLog(format, ...)
#else
#define DEBUGLog(format, ...) NSLog(format, ## __VA_ARGS__)
#endif


#define TRACK_NUMBER @"TrackNumber"
#define ACTIVE_PLAYLIST_ID @"ActivePlaylistId"

@implementation PersistencyManager

dispatch_queue_t logQueue;

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
        
        data = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/albums.bin"]];
        _albums = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if(_albums == nil)
        {
            _albums = [[NSMutableArray alloc] init];
        }
        
        data = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/gestures.bin"]];
        _gestures = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if(_gestures == nil)
        {
            _gestures = [[NSMutableArray alloc] init];
        }
        
        logQueue = dispatch_queue_create("Log Queue",NULL);
    }
    return self;
}

#pragma mark - tracks

- (void)setTrackNumber:(int)nr
{
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:[NSNumber numberWithInt:nr] forKey:TRACK_NUMBER];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TRACK_NUMBER_UPDATED
                                                        object:self
                                                      userInfo:nil];
}

- (int)trackNumber
{
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *nr = [standardUserDefaults objectForKey:TRACK_NUMBER];
    if(nr)
    {
        return [nr integerValue];
    }
    else
    {
        return 3;
    }
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
    dispatch_queue_t myQueue = dispatch_queue_create("Playlist Queue",NULL);
    dispatch_async(myQueue, ^{
        
        // Perform long running process
        Playlist *pl;
        for (int i=0; i<[_playlists count]; i++) {
            pl = [_playlists objectAtIndex:i];
            if([pl.itemId isEqualToString:itemId])
            {
                // Tracks
                for (int j=0; j<[pl.tracks count]; j++)
                {
                    if(j < kTrackLimit)
                    {
                        Track *track = [pl.tracks objectAtIndex:j];
                        TrackArchiver *archiver = [[TrackArchiver alloc] init];
                        [archiver archiveTrack:track];
                        
                        archiver = nil;
                    }
                }
            }
        }
        // finished
        dispatch_async(dispatch_get_main_queue(), ^{
            // E.g. update the UI
            [[NSNotificationCenter defaultCenter] postNotificationName:DEEZER_PLAYLIST_DATA_UPDATED
                                                                object:self
                                                              userInfo:nil];
        });
    });
}



- (void)syncExistingAlbumsWithAlbum:(Album *)album
{
    BOOL albumAdded = NO;
    for (int i=0; i<[_albums count]; i++) {
        Album *alb = [_albums objectAtIndex:i];
        if([alb.itemId isEqualToString:album.itemId])
        {
            [_albums replaceObjectAtIndex:i withObject:album];
            albumAdded = YES;
        }
    }
    if(albumAdded == NO)
    {
        [_albums addObject:album];
    }
    
    NSString *filename = [NSHomeDirectory() stringByAppendingString:@"/Documents/albums.bin"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_albums];
    [data writeToFile:filename atomically:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DEEZER_ALBUM_INFO_UPDATED
                                                        object:self
                                                      userInfo:nil];
}

- (void)syncTrackDataForAlbumWithId:(NSString *)itemId
{
    dispatch_queue_t myQueue = dispatch_queue_create("Album Queue",NULL);
    dispatch_async(myQueue, ^{
        
        // Perform long running process
        Album *album;
        for (int i=0; i<[_albums count]; i++) {
            album = [_albums objectAtIndex:i];
            if([album.itemId isEqualToString:itemId])
            {
                // Tracks
                for (int j=0; j<[album.tracks count]; j++)
                {
                    if(j < kTrackLimit)
                    {
                        Track *track = [album.tracks objectAtIndex:j];
                        TrackArchiver *archiver = [[TrackArchiver alloc] init];
                        [archiver archiveTrack:track];
                        
                        archiver = nil;
                    }
                }
            }
        }
        // finished
        dispatch_async(dispatch_get_main_queue(), ^{
            // E.g. update the UI
            [[NSNotificationCenter defaultCenter] postNotificationName:DEEZER_ALBUM_DATA_UPDATED
                                                                object:self
                                                              userInfo:nil];
        });
    });
}

- (void)saveActivePlaylist:(Playlist *)list
{
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:list.itemId forKey:ACTIVE_PLAYLIST_ID];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ACTIVE_PLAYLIST_UPDATED
                                                        object:self
                                                      userInfo:nil];
}

- (Playlist *)getActivePlaylist
{
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *itemId = [standardUserDefaults objectForKey:ACTIVE_PLAYLIST_ID];
    for(Playlist *pl in _playlists)
    {
        if([pl.itemId isEqualToString:itemId])
        {
            return pl;
        }
    }
    return nil;
}

- (NSArray *)getAlbumdistinctRandomTracksFromPlaylist:(Playlist *)playlist
{
    NSMutableArray *tracks = [[NSMutableArray alloc] init];
    NSArray *randomizedTracks = [playlist.tracks shuffled];
    for (Track *track in randomizedTracks)
    {
        BOOL alreadyThere = NO;
        for(Track *tr in tracks)
        {
            if([track.albumId isEqualToString:tr.albumId])
            {
                alreadyThere = YES;
            }
        }
        
        if(!alreadyThere)
        {
            [tracks addObject:track];
        }
    }
    return tracks;
}

- (NSArray *)getRandomAlbumTracksForTrack:(Track *)track
{
    NSMutableArray *tracks = [[NSMutableArray alloc] init];
    Playlist *pl = [self getActivePlaylist];
    NSArray *randomizedTracks = [pl.tracks shuffled];
    for (Track *tr in randomizedTracks)
    {
        if([tr.albumId isEqualToString:track.albumId])
        {
            [tracks addObject:tr];
        }
    }
    return tracks;
}

- (NSArray *)getPlaylists
{
    return _playlists;
}

- (Album *)getAlbumForTrack:(Track *)track
{
    for(int i=0; i<[_albums count]; i++)
    {
        Album *alb = [_albums objectAtIndex:i];
        if([alb.itemId isEqualToString:track.albumId])
        {
            return alb;
        }
    }
    return nil;
}

- (BOOL)playlistIsReady:(Playlist *)list
{
    if([list.tracks count] < 2)
    {
        return NO;
    }
    for (int i=0; i<[list.tracks count]; i++) {
        Track *track = [list.tracks objectAtIndex:i];
        NSArray *dirs = NSSearchPathForDirectoriesInDomains
        (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
        NSString *exportPath = [documentsDirectoryPath
                                stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav",track.itemId]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
        {
            for(int j=0; j<[_albums count]; j++)
            {
                Album *alb = [_albums objectAtIndex:j];
                if([alb.itemId isEqualToString:track.albumId])
                {
                    for(int k=0; k<[alb.tracks count]; k++)
                    {
                        if(k < kTrackLimit)
                        {
                            Track *albTrack = [alb.tracks objectAtIndex:k];
                            NSString *exportPath = [documentsDirectoryPath
                                                    stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav",albTrack.itemId]];
                            if (![[NSFileManager defaultManager] fileExistsAtPath:exportPath])
                            {
                                return NO;
                            }
                        }
                    }
                }
            }
        }
        else
        {
            return NO;
        }
    }
    return YES;
}


#pragma mark - gestures

- (void)addGesture:(Gesture *)gesture
{
    [_gestures addObject:gesture];
    
    NSString *filename = [NSHomeDirectory() stringByAppendingString:@"/Documents/gestures.bin"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_gestures];
    [data writeToFile:filename atomically:YES];
}

- (void)removeGesture:(Gesture *)gesture
{
    [_gestures removeObject:gesture];
    
    NSString *filename = [NSHomeDirectory() stringByAppendingString:@"/Documents/gestures.bin"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_gestures];
    [data writeToFile:filename atomically:YES];
}

- (NSArray *)getGestures
{
    return _gestures;
}

- (void)writeToLog:(NSString *)content
{
    //dispatch_queue_t myQueue = dispatch_queue_create("Log Queue",NULL);
    dispatch_async(logQueue, ^{
        
        // Perform long running process
        NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterMediumStyle];
        NSString *line = [NSString stringWithFormat:@"%@, Timestamp: %@\n",content, dateString];
        
        //Get the file path
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"activities.log"];
        
        //create file if it doesn't exist
        if(![[NSFileManager defaultManager] fileExistsAtPath:fileName])
            [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
        
        //append text to file (you'll probably want to add a newline every write)
        NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:fileName];
        [file seekToEndOfFile];
        [file writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
        [file closeFile];
        
        // finished
        dispatch_async(dispatch_get_main_queue(), ^{
            // E.g. update the UI
            DEBUGLog(@"Write to log finished");
        });
    });
}


@end
