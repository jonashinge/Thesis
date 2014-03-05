///
///  @file IHSAudio3DSound.h
///  IHS API
///
///  Created by Lars Johansen on 10/06/13.
///  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
///

#import "IHSAudio3D.h"

/**
 @brief                 Class representing one sound to playback
 */
@interface IHSAudio3DSound : NSObject

/**
 @brief                 URL of the sound to load and playback
 @details               Only local files of uncompressed .wav with 16 bit/ 44.1 kHz or lower resolution and bitrate are supported
 */
@property (nonatomic, strong) NSURL* url;

/**
 @brief                 The title of the sound
 */
@property (nonatomic, readonly) NSString* title;

/**
 @brief                 The local heading of the sound.
 @details               This heading is combined with the global heading of the IHSAudio3DPlayer to get the final heading of the sound.
 */
@property (nonatomic, assign) float heading;

/**
 @brief                 The local distance of the sound (in millimeters)
 @details               This distance is combined with the global distance of the IHSAudio3DPlayer to get the final distance of the sound.
 */
@property (nonatomic, assign) UInt32 distance;

/**
 @brief                 The local altitude of the sound (in millimeters)
 @details               This altitude is combined with the global altitude of the IHSAudio3DPlayer to get the final altitude of the sound.
 */
@property (nonatomic, assign) SInt32 altitude;

/**
 @brief                 An user defined object to be associated with the sound.
 */
@property (nonatomic, strong) id userObject;

/**
 @brief                 Offset of the sound in fractions of a second.
 */
@property (nonatomic, assign) NSTimeInterval offset;

/**
 @brief                 The duration of the sound loaded.
 */
@property (nonatomic, readonly) NSTimeInterval duration;

/**
 @brief                 The current time of the playback.
 @details               Use this property to read the current position of the playback, or change it to skip in the sound.
 */
@property (nonatomic, assign) NSTimeInterval currentTime;

/**
 @brief                 If set to YES, the sound will repeat infinite.
 */
@property (nonatomic, assign) BOOL repeats;

/**
 @brief                 The local volume of the sound from 0 to 1.
 @details               This is combined with the volume of th IHSAudio3DPlayer volume to get the final volume.
                        Use this to e.g. make the volume lower of this sound if it is a background sound.
 */
@property (nonatomic, assign) float volume;


/**
 @brief                 The url of the sound file to load
 @details               For now only local file URLs are supported.
                        Also the sound file must be in wave format with max 16 bit pr sample
 */
- (id)initWithURL:(NSURL*)url;

@end
