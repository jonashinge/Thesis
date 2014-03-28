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

#import <AVFoundation/AVFoundation.h>


#define DEEZER_TOKEN_KEY @"DeezerTokenKey"
#define DEEZER_EXPIRATION_DATE_KEY @"DeezerExpirationDateKey"
#define DEEZER_USER_ID_KEY @"DeezerUserId"

#define kDeezerAppId @"133691"

@interface DeezerClient () <DeezerSessionDelegate, DeezerRequestDelegate>

@property (strong, nonatomic) DeezerConnect *deezerConnect;

@property (strong, nonatomic) DeezerRequest *requestAllPlaylists;
@property (strong, nonatomic) DeezerRequest *requestPlaylist;

@property (strong) AVAssetReader *assetReader;
@property (strong) AVAssetWriter *assetWriter;
@property (strong) AVAssetWriterInput *assetWriterInput;
@property (strong) NSString *exportPath;

@end

// Set the DEBUG_PRINTOUT define to '1' to enable printouts of the received values
#define DEBUG_PRINTOUT      0

#if !DEBUG_PRINTOUT
#define DEBUGLog(format, ...)
#else
#define DEBUGLog(format, ...) NSLog(format, ## __VA_ARGS__)
#endif

@implementation DeezerClient

#pragma mark - Misc

- (void)connectAndStartSync
{
    _deezerConnect = [[DeezerConnect alloc] initWithAppId:kDeezerAppId andDelegate:self];
    [self retrieveTokenAndExpirationDate];
    if(_deezerConnect.isSessionValid)
    {
        [self fetchAllPlaylists];
    }
    else
    {
        /* List of permissions available from the Deezer SDK web site */
        NSMutableArray* permissionsArray = [NSMutableArray arrayWithObjects:@"basic_access", @"email", @"offline_access", @"manage_library", @"delete_library", nil];
        
        [_deezerConnect authorize:permissionsArray];
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


#pragma mark - DeezerSessionDelegate implementation

- (void)deezerDidLogin
{
    DEBUGLog(@"Deezer user did login");
    
    [self saveToken:[_deezerConnect accessToken] andExpirationDate:[_deezerConnect expirationDate] forUserId:[_deezerConnect userId]];
    
    [self fetchAllPlaylists];
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
        Playlist *playlist = [MTLJSONAdapter modelOfClass:[Playlist class] fromJSONDictionary:json error:&error];
        
        DEBUGLog(@"Playlist mantle object: %@",playlist);
        
        [APP_DELEGATE.persistencyManager syncExistingPlaylistsWithList:playlist];
        [APP_DELEGATE.persistencyManager syncTrackDataForPlaylistWithId:playlist.itemId];
    }
}

-(void)request:(DeezerRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}

- (BOOL)isSessionValid {
    return [_deezerConnect isSessionValid];
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
