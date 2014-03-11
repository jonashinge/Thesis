#import <Foundation/Foundation.h>

/**
 * A type  describing the state of the buffer
 */
typedef enum {
	BufferState_Started,    // Buffering starts (we're receiving datas) 
	BufferState_Paused,     // Buffering pauses (i.e. when there is no connection)
	BufferState_Stopped,    // Buffering stops (an error occurs)
	BufferState_Ended,      // Buffering ends (all data are received)
} BufferState;


/**
 * Your application should implement this delegate to receive all
 * update information about track buffering.
 */
@protocol BufferDelegate <NSObject>

@optional


/**
 * Called when buffer changes state.
 */
- (void)bufferStateChanged:(BufferState)bufferState;

/**
 * Called for following the buffering progress of a track.
 */
- (void)bufferProgressChanged:(float)bufferProgress;

/**
 * Called when an error occurs.
 */
- (void)bufferDidFailWithError:(NSError*)error;

@end