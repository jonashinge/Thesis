//
//  Playlist.h
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 27/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@interface Playlist : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *itemId;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSArray *tracks;

- (BOOL)isReadyForSpatialAudioUse;

@end
