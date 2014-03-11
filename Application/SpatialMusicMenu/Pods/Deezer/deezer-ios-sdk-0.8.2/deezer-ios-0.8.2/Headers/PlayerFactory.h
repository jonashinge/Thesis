#import <Foundation/Foundation.h>

#import "PlayerDelegate.h"
#import "BufferDelegate.h"


/**
 * A type uses for specifying network restrictions you want.
 */
typedef enum {
	Network_WIFI_ONLY,      //Stream a track ONLY with a WiFi connection.
    NetWork_WIFI_AND_3G,    //Stream a track with both WiFi and 3G/Edge connection.
} Network;

@class DeezerConnect;
@interface PlayerFactory : NSObject {
    id<PlayerDelegate>  _playerDelegate;
    id<BufferDelegate>  _bufferDelegate;
    
    NSString*           _trackId;
    NSString*           _trackStream;    
}

@property (nonatomic, assign) id<PlayerDelegate>  playerDelegate;
@property (nonatomic, assign) id<BufferDelegate>  bufferDelegate;

@property (nonatomic, retain) NSString*         trackId;
@property (nonatomic, retain) NSString*         trackStream;

@property (nonatomic, assign) float playerProgress;
@property (nonatomic, readonly) long playerTimePosition;
@property (nonatomic, readonly) long trackDuration;


/**
 * Create a player.
 * Default values are:
 *  - Network => NetWork_WIFI_AND_3G
 *  - ProgressInterval => 1.0f
 */
+ (PlayerFactory*)createPlayer;


/**
 * Create a player with custom values for network and progress interval
 *
 * @param network
 *        You can authorize a specific network for streaming. (see values with enum Network)
 *
 * @param progressInterval - A value between 0.0 and 100.0
 *        Define the progress interval you want.
 *        For example, if you set 10.0, delegate will be called every 10% of buffering.
 */
+ (PlayerFactory*)createPlayerWithNetworkType:(Network)network andBufferProgressInterval:(float)progressInterval;


/**
 * Method uses for initializing/preparing player to play a track.
 * 
 * @param trackid
 *        A NSString representing the track id of the song you want to play  
 *
 * @param stream
 *        A NSString representing the stream object (reveive with the request) 
 *        of the song you want to play
 *
 * @param dzConnect
 *        A DeezerConnect object.
 *
 */
- (void)preparePlayerForTrackWithDeezerId:(NSString*)trackid
                                   stream:(NSString*)stream
                         andDeezerConnect:(DeezerConnect*)dzConnect;


/**
 * Method uses for initializing/preparing player to play a preview (30 sec extract).
 *
 * @param urlString
 *        A NSString representing the URL of the preview yu want to play.
 *
 * @param trackID
 *        A NSString representing the track id of the preview yu want to play.
 *
 * @param dzConnect
 *        A DeezerConnect object.
 *
 */
- (void)preparePlayerForPreviewWithURL:(NSString*)urlString
                               trackID:(NSString*)trackID
                      andDeezerConnect:(DeezerConnect*)dzConnect;


/**
 * Return the current player's state.
 * Check the DeezerPlayerState enum for more information.
 */
- (DeezerPlayerState)getCurrentPlayerState;


/**
 * Use this method to launch the player.
 */
- (void)play;


/**
 * Use this method to pause the player.
 */
- (void)pause;


/**
 * Use this method to stop the player.
 */
- (void)stop;

@end
