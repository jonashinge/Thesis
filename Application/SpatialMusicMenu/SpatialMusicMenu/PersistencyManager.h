//
//  PersistencyManager.h
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 27/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Playlist;

@interface PersistencyManager : NSObject

@property (nonatomic) int trackNumber;

- (void)syncExistingPlaylistsWithList:(Playlist *)list;
- (void)syncTrackDataForPlaylistWithId:(NSString *)itemId;

- (void)saveActivePlaylist:(Playlist *)list;
- (Playlist *)getActivePlaylist;
- (NSArray *)getPlaylists;

@end

// Notifications constants
#define DEEZER_PLAYLIST_INFO_UPDATED @"DeezerPlaylistInfoUpdated"
#define DEEZER_PLAYLIST_DATA_UPDATED @"DeezerPlaylistDataUpdated"
#define TRACK_NUMBER_UPDATED @"TrackNumberUpdated"
#define ACTIVE_PLAYLIST_UPDATED @"ActivePlaylistUpdated"
