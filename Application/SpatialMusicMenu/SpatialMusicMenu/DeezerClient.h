//
//  SMMClient.h
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 08/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeezerClient : NSObject

- (void)connect;
- (void)sync;
- (void)playTrackWithId:(NSString* )trackId andStream:(NSString*)stream;
- (void)pausePlayback;
- (void)continuePlayback;
- (void)stopPlayback;

// Notifications constants
#define DEEZER_CONNECTION_STATUS_CHANGED @"DeezerConnnectionStatusChanged"

@end
