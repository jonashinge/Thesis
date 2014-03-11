//
//  PersistencyManager.h
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 10/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Track;

@interface PersistencyManager : NSObject

- (void)saveTrack:(Track *)track;
- (void)decompressAndSaveTrackPreviews;

@end
