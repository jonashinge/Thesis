//
//  PersistencyManager.h
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 27/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Playlist;
@class Album;
@class Track;
@class Gesture;

@interface PersistencyManager : NSObject

@property (nonatomic) int trackNumber;

- (void)syncExistingPlaylistsWithList:(Playlist *)list;
- (void)syncTrackDataForPlaylistWithId:(NSString *)itemId;

- (void)syncExistingAlbumsWithAlbum:(Album *)album;
- (void)syncTrackDataForAlbumWithId:(NSString *)itemId;

- (void)saveActivePlaylist:(Playlist *)list;
- (Playlist *)getActivePlaylist;
- (NSArray *)getPlaylists;
- (BOOL)playlistIsReady:(Playlist *)list;
- (Album *)getAlbumForTrack:(Track *)track;
- (NSArray *)getAlbumdistinctRandomTracksFromPlaylist:(Playlist *)playlist;
- (NSArray *)getRandomAlbumTracksForTrack:(Track *)track;

- (void)addGesture:(Gesture *)gesture;
- (void)removeGesture:(Gesture *)gesture;
- (NSArray *)getGestures;

- (void)writeToLog:(NSString *)content;
- (void)writeGestureData:(NSString *)content;

@end

// Notifications constants
#define DEEZER_PLAYLIST_INFO_UPDATED @"DeezerPlaylistInfoUpdated"
#define DEEZER_PLAYLIST_DATA_UPDATED @"DeezerPlaylistDataUpdated"

#define DEEZER_ALBUM_INFO_UPDATED @"DeezerAlbumInfoUpdated"
#define DEEZER_ALBUM_DATA_UPDATED @"DeezerAlbumDataUpdated"

#define TRACK_NUMBER_UPDATED @"TrackNumberUpdated"
#define ACTIVE_PLAYLIST_UPDATED @"ActivePlaylistUpdated"
