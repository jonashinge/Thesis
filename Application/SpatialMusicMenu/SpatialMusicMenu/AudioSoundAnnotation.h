//
//  AudioSoundAnnotation.h
//  AudioGrid 3D
//
//  Created by Martin Lobger on 13/02/14.
//  Copyright (c) 2014 GN Store Nord A/S. All rights reserved.
//

#import <IHS/IHS.h>
#import "AudioSource.h"

// Implement a sound annotation for custom drawing.
// The standard sound annotation does not draw anything - it is empty.
@interface AudioSoundAnnotation : IHSAudio3DGridSoundAnnotation

@property (nonatomic, strong) AudioSource* audioSource;
@property (nonatomic) BOOL selected;

- (instancetype)initWithAudioSource:(AudioSource*)audioSource;

@end
