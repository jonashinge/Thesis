//
//  Track.h
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 10/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@interface Track : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *itemId;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSURL *preview;
@property (nonatomic, copy, readonly) NSString *stream;
@property (nonatomic, copy, readonly) NSString *albumId;

@end
