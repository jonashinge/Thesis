//
//  SMMClient.m
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 08/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "DeezerClient.h"

#import "DeezerConnect.h"
#import "Playlist.h"
#import "AppDelegate.h"
#import "Track.h"
#import "Album.h"
#import <Deezer/PlayerFactory.h>

#import <AVFoundation/AVFoundation.h>


#define DEEZER_TOKEN_KEY @"DeezerTokenKey"
#define DEEZER_EXPIRATION_DATE_KEY @"DeezerExpirationDateKey"
#define DEEZER_USER_ID_KEY @"DeezerUserId"

#define kDeezerAppId @"133691"

@interface DeezerClient () <DeezerSessionDelegate, DeezerRequestDelegate, PlayerDelegate, BufferDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) DeezerConnect *deezerConnect;

@property (strong, nonatomic) DeezerRequest *requestAllPlaylists;
@property (strong, nonatomic) DeezerRequest *requestPlaylist;

@property (strong, nonatomic) PlayerFactory *deezerPlayer;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (strong) AVAssetReader *assetReader;
@property (strong) AVAssetWriter *assetWriter;
@property (strong) AVAssetWriterInput *assetWriterInput;
@property (strong) NSString *exportPath;

@end

// Set the DEBUG_PRINTOUT define to '1' to enable printouts of the received values
#define DEBUG_PRINTOUT      1

#if !DEBUG_PRINTOUT
#define DEBUGLog(format, ...)
#else
#define DEBUGLog(format, ...) NSLog(format, ## __VA_ARGS__)
#endif

@implementation DeezerClient

- (id)init
{
    self = [super init];
    if(self)
    {
        _deezerPlayer = [PlayerFactory createPlayer];
        [_deezerPlayer setPlayerDelegate:self];
        [_deezerPlayer setBufferDelegate:self];
    }
    return self;
}

#pragma mark - Misc

- (void)connect
{
    _deezerConnect = [[DeezerConnect alloc] initWithAppId:kDeezerAppId andDelegate:self];
    [self retrieveTokenAndExpirationDate];
    if(_deezerConnect.isSessionValid)
    {
        return;
    }
    else
    {
        /* List of permissions available from the Deezer SDK web site */
        NSMutableArray* permissionsArray = [NSMutableArray arrayWithObjects:@"basic_access", @"email", @"offline_access", @"manage_library", @"delete_library", nil];
        
        [_deezerConnect authorize:permissionsArray];
    }
}

- (void)sync
{
    if(_deezerConnect.isSessionValid)
    {
        [self fetchAllPlaylists];
    }
    else
    {
        NSLog(@"Connect before syncing!");
    }
}

- (void)fetchAllPlaylists
{
    NSString *servicePath = [NSString stringWithFormat:@"user/%@/playlists",_deezerConnect.userId];
    _requestAllPlaylists = [self.deezerConnect createRequestWithServicePath:servicePath
                                                                       params:nil
                                                                     delegate:self];
    
    [self.deezerConnect launchAsyncRequest:_requestAllPlaylists];
}

- (void)playTrackWithId:(NSString* )trackId andStream:(NSString*)stream
{
    DEBUGLog(@"Playing track with deezer api - id: %@ and stream: %@", trackId, stream);
    [_deezerPlayer preparePlayerForTrackWithDeezerId:trackId stream:stream andDeezerConnect:_deezerConnect];
}

- (void)playPreviewTrackWithId:(NSString* )trackId
{
    DEBUGLog(@"Playing preview with - id: %@", trackId);
    
    NSError *error;
    
    NSArray *dirs = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    NSString *exportPath = [documentsDirectoryPath
                            stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3",trackId]];
    NSURL *url = [NSURL fileURLWithPath:exportPath isDirectory:NO];
    
    [_audioPlayer stop];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    _audioPlayer.delegate = self;
    if (error) {
        NSLog(@"Error playing sound '%@': %@", trackId, error);
        _audioPlayer = nil;
    }
    else {
        _audioPlayer.volume = 0.1;
        
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
}

- (void)pausePlayback
{
    [_deezerPlayer pause];
    [_audioPlayer pause];
}

- (void)continuePlayback
{
    [_deezerPlayer play];
}

- (void)stopPlayback
{
    [_deezerPlayer stop];
}


#pragma mark - DeezerSessionDelegate implementation

- (void)deezerDidLogin
{
    DEBUGLog(@"Deezer user did login");
    
    [self saveToken:[_deezerConnect accessToken] andExpirationDate:[_deezerConnect expirationDate] forUserId:[_deezerConnect userId]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DEEZER_CONNECTION_STATUS_CHANGED
                                                        object:self
                                                      userInfo:@{@"status":@"Connected"}];
}

- (void)deezerDidLogout
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DEEZER_CONNECTION_STATUS_CHANGED
                                                        object:self
                                                      userInfo:@{@"status":@"Disconnected"}];
}

- (void)deezerDidNotLogin:(BOOL)cancelled {
    NSLog(@"Deezer Did not login %@", cancelled ? @"Cancelled" : @"Not Cancelled");
}


#pragma mark - DeezerRequestDelegate

- (void)request:(DeezerRequest *)request didReceiveResponse:(NSData *)response
{
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:&error];
    
    // All playlists
    if(request == _requestAllPlaylists)
    {
        NSArray *data = [json objectForKey:@"data"];
        
        for (NSDictionary *dict in data) {
            Playlist *playlist = [MTLJSONAdapter modelOfClass:[Playlist class] fromJSONDictionary:dict error:&error];
            
            NSString *servicePath = [NSString stringWithFormat:@"playlist/%@",playlist.itemId];
            DeezerRequest *req = [self.deezerConnect createRequestWithServicePath:servicePath
                                                                             params:nil
                                                                           delegate:self];
            
            [self.deezerConnect launchAsyncRequest:req];
        }
    }
    // Playlist (including tracks)
    else
    {
        if([json objectForKey:@"type"] != nil)
        {
            NSString *type = [json objectForKey:@"type"];
            
            if([type isEqualToString:@"playlist"])
            {
                Playlist *playlist = [MTLJSONAdapter modelOfClass:[Playlist class] fromJSONDictionary:json error:&error];
                
                [APP_DELEGATE.persistencyManager syncExistingPlaylistsWithList:playlist];
                [APP_DELEGATE.persistencyManager syncTrackDataForPlaylistWithId:playlist.itemId];
                
                DEBUGLog(@"Playlist mantle object: %@",playlist);
                
                for (int i=0; i<[playlist.tracks count]; i++)
                {
                    if(i < kTrackLimit)
                    {
                        Track *track = [playlist.tracks objectAtIndex:i];
                        NSString *servicePath = [NSString stringWithFormat:@"album/%@",track.albumId];
                        DeezerRequest *req = [self.deezerConnect createRequestWithServicePath:servicePath
                                                                                       params:nil
                                                                                     delegate:self];
                        
                        [self.deezerConnect launchAsyncRequest:req];
                    }
                }
            }
            else if([type isEqualToString:@"album"])
            {
                //DEBUGLog(@"Album JSON: %@",json);
                
                Album *album = [MTLJSONAdapter modelOfClass:[Album class] fromJSONDictionary:json error:&error];
                
                [APP_DELEGATE.persistencyManager syncExistingAlbumsWithAlbum:album];
                [APP_DELEGATE.persistencyManager syncTrackDataForAlbumWithId:album.itemId];
                
                DEBUGLog(@"Album mantle object: %@",album);
            }
        }
    }
}

-(void)request:(DeezerRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}

- (BOOL)isSessionValid {
    return [_deezerConnect isSessionValid];
}


#pragma mark - Deezer PlayerDelegate
- (void)player:(PlayerFactory *)player stateChanged:(DeezerPlayerState)playerState
{
    DEBUGLog(@"Deezer player state changed: %u", playerState);
}

/* Progress of the buffering */
- (void)bufferProgressChanged:(float)bufferProgress {
}

/* An error occurred while buffering */
- (void)bufferDidFailWithError:(NSError*)error {
}


#pragma mark - BufferDelegate
/*  The buffer has a new state */
- (void)bufferStateChanged:(BufferState)bufferState {
    if (bufferState == BufferState_Started) {
        [_deezerPlayer play]; /* We try to play the track */
    }
    else if (bufferState == BufferState_Paused) {
    }
    else if (bufferState == BufferState_Ended) {
    }
    else if (bufferState == BufferState_Stopped) {
    }
}


#pragma mark - Token
// The token needs to be saved on the device
- (void)retrieveTokenAndExpirationDate {
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [_deezerConnect setAccessToken:[standardUserDefaults objectForKey:DEEZER_TOKEN_KEY]];
    [_deezerConnect setExpirationDate:[standardUserDefaults objectForKey:DEEZER_EXPIRATION_DATE_KEY]];
    [_deezerConnect setUserId:[standardUserDefaults objectForKey:DEEZER_USER_ID_KEY]];
}

- (void)saveToken:(NSString*)token andExpirationDate:(NSDate*)expirationDate forUserId:(NSString*)userId {
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:token forKey:DEEZER_TOKEN_KEY];
    [standardUserDefaults setObject:expirationDate forKey:DEEZER_EXPIRATION_DATE_KEY];
    [standardUserDefaults setObject:userId forKey:DEEZER_USER_ID_KEY];
    [standardUserDefaults synchronize];
}


@end
