///
///  @file IHSAudio3D.h
///  IHS API
///
///  Created by Martin Lobger on 30/01/14.
///  Copyright (c) 2012 GN Store Nord. All rights reserved.
///


/**
 @brief                 The reverb preset to be added to all sound sources
 */
typedef NS_ENUM(NSInteger, IHSAudio3DReverbPreset) {
    // Reverb off preset
    IHSAudio3DReverbPresetOff = 0,
    // Environmental presets
    IHSAudio3DReverbPresetAlley = 1,
    IHSAudio3DReverbPresetArena,
    IHSAudio3DReverbPresetAuditorium,
    IHSAudio3DReverbPresetBathroom,
    IHSAudio3DReverbPresetCave,
    IHSAudio3DReverbPresetHallway,
    IHSAudio3DReverbPresetHangar,
    IHSAudio3DReverbPresetLivingroom,
    IHSAudio3DReverbPresetMountains,
    IHSAudio3DReverbPresetRoom,
    IHSAudio3DReverbPresetUnderwater,
    // Musical presets
    IHSAudio3DReverbPresetSmallRoom,
    IHSAudio3DReverbPresetMediumRoom,
    IHSAudio3DReverbPresetLargeRoom,
    IHSAudio3DReverbPresetMediumHall,
    IHSAudio3DReverbPresetLargeHall,
    IHSAudio3DReverbPresetPlate,
    // Additional environmental presets
    IHSAudio3DReverbPresetCarpetedHallway,
    IHSAudio3DReverbPresetCity,
    IHSAudio3DReverbPresetConcertHall,
    IHSAudio3DReverbPresetForest,
    IHSAudio3DReverbPresetPaddedCell,
    IHSAudio3DReverbPresetParkingLot,
    IHSAudio3DReverbPresetPlain,
    IHSAudio3DReverbPresetQuarry,
    IHSAudio3DReverbPresetSewerPipe,
    IHSAudio3DReverbPresetStoneCorridor,
    IHSAudio3DReverbPresetStoneRoom
};


/**
 @brief                 Deprecated! See IHSAudio3DReverbPreset
 @deprecated            These values have been renamed and are deprecated.
 */
typedef NS_ENUM(NSUInteger, IHSAudioReverbPresetDepricated) {
    // Reverb off preset
    IHSAudioReverbPresetOff                 = IHSAudio3DReverbPresetOff,
    // Environmental presets
    IHSAudioReverbPresetAlley               = IHSAudio3DReverbPresetAlley,
    IHSAudioReverbPresetArena               = IHSAudio3DReverbPresetArena,
    IHSAudioReverbPresetAuditorium          = IHSAudio3DReverbPresetAuditorium,
    IHSAudioReverbPresetBathroom            = IHSAudio3DReverbPresetBathroom,
    IHSAudioReverbPresetCave                = IHSAudio3DReverbPresetCave,
    IHSAudioReverbPresetHallway             = IHSAudio3DReverbPresetHallway,
    IHSAudioReverbPresetHangar              = IHSAudio3DReverbPresetHangar,
    IHSAudioReverbPresetLivingroom          = IHSAudio3DReverbPresetLivingroom,
    IHSAudioReverbPresetMountains           = IHSAudio3DReverbPresetMountains,
    IHSAudioReverbPresetRoom                = IHSAudio3DReverbPresetRoom,
    IHSAudioReverbPresetUnderwater          = IHSAudio3DReverbPresetUnderwater,
    // Musical presets
    IHSAudioReverbPresetSmallRoom           = IHSAudio3DReverbPresetSmallRoom,
    IHSAudioReverbPresetMediumRoom          = IHSAudio3DReverbPresetMediumRoom,
    IHSAudioReverbPresetLargeRoom           = IHSAudio3DReverbPresetLargeRoom,
    IHSAudioReverbPresetMediumHall          = IHSAudio3DReverbPresetMediumHall,
    IHSAudioReverbPresetLargeHall           = IHSAudio3DReverbPresetLargeHall,
    IHSAudioReverbPresetPlate               = IHSAudio3DReverbPresetPlate,
    // Additional environmental presets
    IHSAudioReverbPresetCarpetedHallway     = IHSAudio3DReverbPresetCarpetedHallway,
    IHSAudioReverbPresetCity                = IHSAudio3DReverbPresetCity,
    IHSAudioReverbPresetConcertHall         = IHSAudio3DReverbPresetConcertHall,
    IHSAudioReverbPresetForest              = IHSAudio3DReverbPresetForest,
    IHSAudioReverbPresetPaddedCell          = IHSAudio3DReverbPresetPaddedCell,
    IHSAudioReverbPresetParkingLot          = IHSAudio3DReverbPresetParkingLot,
    IHSAudioReverbPresetPlain               = IHSAudio3DReverbPresetPlain,
    IHSAudioReverbPresetQuarry              = IHSAudio3DReverbPresetQuarry,
    IHSAudioReverbPresetSewerPipe           = IHSAudio3DReverbPresetSewerPipe,
    IHSAudioReverbPresetStoneCorridor       = IHSAudio3DReverbPresetStoneCorridor,
    IHSAudioReverbPresetStoneRoom           = IHSAudio3DReverbPresetStoneRoom,
};


/**
 @brief                 Distance Attenuation Models to be applied to each sound
 */
typedef NS_ENUM(NSUInteger, IHSAudio3DDistanceAttenuationModel) {
    /**
     @brief             Inverse Distance Model     /// @par
     @details           gain = @p mindistance / (@p mindistance + @p rolloff * (@p distance - @p mindistance))
     */
    IHSAudio3DDistanceAttenuationModelInverse       = 0,
    /**
     @brief             Linear Distance Model
     @details           gain = max(0, 1 - @p rolloff * (@p distance - @p mindistance) / (@p maxdistance - @p mindistance))
     */
    IHSAudio3DDistanceAttenuationModelLinear        = 1,
    /**
     @brief             Exponential Distance Model
     @details           gain = (@p distance / @p mindistance) ^ (- @p rolloff)
     */
    IHSAudio3DDistanceAttenuationModelExponential   = 2,
};



