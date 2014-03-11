///
///  @file IHSAudio3DSound+DistanceParameters.h
///  IHS API
///
///  Created by Martin Lobger on 31/01/14.
///  Copyright (c) 2014 GN Store Nord A/S. All rights reserved.
///


#import "IHSAudio3D.h"
#import "IHSAudio3DSound.h"


/**
 @brief                 Category exposing Distance Attenuation Parameters
 */
@interface IHSAudio3DSound (DistanceParameters)

/**
 @brief                 The used distance attenuation model.
 @see                   IHSAudio3DDistanceAttenuationModel enum.
 */
@property (nonatomic, assign) IHSAudio3DDistanceAttenuationModel distanceAttenuationModel;

/**
 @brief                 Minimum distance, in millimeters. Attenuation starts at this distance.
 */
@property (nonatomic, assign) NSInteger minimumDistance;

/**
 @brief                 Maximum distance, in millimeters. After maximum distance, the volume does not decrease further.
 */
@property (nonatomic, assign) NSInteger maximumDistance;

/**
 @brief                 Rolloff factor, specified in thousandths.
 @see                   IHSAudio3DDistanceAttenuationModel values for details on how roll off factor is used.
*/
@property (nonatomic, assign) NSInteger distanceRollOffFactor;

/**
 @brief                 Mute at maximum distance setting. 0 is disabled (default), 1 is enabled.
*/
@property (nonatomic, assign) BOOL muteAtMaximumDistance;

@end
