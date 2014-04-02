//
//  AudioSoundAnnotation.m
//  AudioGrid 3D
//
//  Created by Martin Lobger on 13/02/14.
//  Copyright (c) 2014 GN Store Nord A/S. All rights reserved.
//

#import "AudioSoundAnnotation.h"

@implementation AudioSoundAnnotation
{
    UIImageView*    _imageView;
}


- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectMake(0, 0, 60, 60);
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageView];
    }
    return self;
}


- (instancetype)initWithAudioSource:(AudioSource*)audioSource
{
    if (self = [super initWithAudioSource:audioSource]) {
        _imageView.image = [UIImage imageNamed:audioSource.imageName];
    }
    return self;
}

- (void)dealloc
{
    _imageView = nil;
}

@end
