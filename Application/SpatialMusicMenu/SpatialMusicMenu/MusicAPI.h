//
//  MusicAPI.h
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 09/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicAPI : NSObject

+ (MusicAPI*)sharedInstance;

- (void)downloadTrack;

@end
