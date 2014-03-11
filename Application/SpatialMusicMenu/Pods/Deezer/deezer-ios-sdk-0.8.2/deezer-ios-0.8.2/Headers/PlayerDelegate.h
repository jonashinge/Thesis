#import <Foundation/Foundation.h>

@class PlayerFactory;

/**
 *  Desfribes all states the player can have.
 */
typedef enum {
	DeezerPlayerState_Initialized       = 0, //Player is init.
    DeezerPlayerState_Ready             = 1, //Player is ready and can starts playing.
	DeezerPlayerState_Playing           = 2, //Player is actually playing music.
	DeezerPlayerState_Paused            = 3, //Player is paused.
    DeezerPlayerState_WaitingForData    = 4, //Player is waiting for new datas.
    DeezerPlayerState_Finished          = 5, //Player finishs to play a track.
    DeezerPlayerState_Stopped           = 6, //Player stops playing (for example, when an error occured).
} DeezerPlayerState;



/**
 * Your application should implement this delegate to receive player callbacks.
 */
@protocol PlayerDelegate <NSObject>

@optional

/**
 * Called when player changed state.
 * Check the DeezerPlayerState enum for more information.
 */
- (void)player:(PlayerFactory*)player stateChanged:(DeezerPlayerState)playerState;


/**
 * Called every time (every seconds) the playing is progressing.
 * @param timeChanged
 *        Value (in seconds) of the listening time.
 */
- (void)player:(PlayerFactory*)player timeChanged:(long)time;


/**
 * Called when an error occured while playing.
 */
- (void)player:(PlayerFactory*)player didFailWithError:(NSError*)error;

@end



