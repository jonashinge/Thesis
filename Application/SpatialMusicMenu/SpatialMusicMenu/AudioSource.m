//
//  AudioSource.m
//  AudioGrid 3D
//
//  Created by Martin Lobger on 13/02/14.
//  Copyright (c) 2014 GN Store Nord A/S. All rights reserved.
//

#import "AudioSource.h"

@implementation AudioSource

@synthesize sound = _sound;
@synthesize position = _position;

- (instancetype)initWithSound:(NSString*)soundName andImage:(NSString*)imageName
{
    if (self = [super init]) {
        _imageName = imageName;
        
        NSArray *dirs = NSSearchPathForDirectoriesInDomains
        (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
        NSString *exportPath = [documentsDirectoryPath
                                stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav",soundName]];
        NSURL *urlSound = [NSURL fileURLWithPath:exportPath isDirectory:NO];
        _sound = [[IHSAudio3DSound alloc] initWithURL:urlSound];
    }

    return self;
}

- (void)dealloc
{
    _sound = nil;
}


@end
