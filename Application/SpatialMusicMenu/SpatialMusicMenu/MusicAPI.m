//
//  MusicAPI.m
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 09/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "MusicAPI.h"

#import "DeezerClient.h"

@interface MusicAPI ()

@property (strong, nonatomic) DeezerClient *client;

@end

// Set the DEBUG_PRINTOUT define to '1' to enable printouts of the received values
#define DEBUG_PRINTOUT      1

#if !DEBUG_PRINTOUT
#define DEBUGLog(format, ...)
#else
#define DEBUGLog(format, ...) NSLog(format, ## __VA_ARGS__)
#endif

@implementation MusicAPI

+ (MusicAPI*)sharedInstance
{
    static MusicAPI *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[MusicAPI alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        self.client = [[DeezerClient alloc] init];
    }
    return self;
}

- (void)downloadTrack
{
    
}

@end
