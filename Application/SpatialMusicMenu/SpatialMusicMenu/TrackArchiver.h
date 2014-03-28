//
//  TrackArchiver.h
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 28/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Track;

@interface TrackArchiver : NSObject

- (void)archiveTrack:(Track *)track;

@end
