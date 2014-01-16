///
///  @file IHSDevice.h
///  IHS API
///
///  Created by Lars Johansen (GN) on 29/5/13.
///  Copyright (c) 2012 GN Store Nord A/S. All rights reserved.
///
#import <CoreLocation/CoreLocation.h>

@class IHSAudio3DSound;
@class IHSDevice;


/**
 @brief                 IHS device connection states
 */
typedef enum {
    IHSDeviceConnectionStateNone,
    IHSDeviceConnectionStateBluetoothOff,           ///< Bluetooth is turned off. It should be turned on in order to connect.
    IHSDeviceConnectionStateDiscovering,            ///< The SDK are looking for available headsets in the near proximity.
    IHSDeviceConnectionStateDisconnected,           ///< The headset disconnected. Could be because it was turned off or got out of range.
    IHSDeviceConnectionStateLingering,              ///< If we have not received data from the headset for a while even though we are still conncted.\n If this state occurs, it is typically a preliminary state to disconnecting.
    IHSDeviceConnectionStateConnecting,             ///< The from when a connection to a headset has been initiated until it is fully connected.
    IHSDeviceConnectionStateConnected,              ///< The state when the heaset is connected and ready to use.
    IHSDeviceConnectionStateConnectionFailed = -1,  ///< The connection to the headset failed. This is different from disconnected.
} IHSDeviceConnectionState;

/**
 @brief                 IHS buttons
 */
typedef enum {
    IHSButtonRight,                                 ///< Identifying the right button
    IHSButtonLeft,                                  ///< Identifying the left button
    IHSButtonNoButton                   = -1
} IHSButton;

/**
 @brief                 IHS button events
 @note                  IHSButtonEventTap, IHSButtonEventPress and IHSButtonEventDoubleTap are available on IHSButtonRight
                        IHSButtonEventTap is available on IHSButtonLeft
 */
typedef enum {
    IHSButtonEventTap,                              ///< A button was tapped
    IHSButtonEventPress,                            ///< A button was pressed
    IHSButtonEventDoubleTap,                        ///< A button was double tabbed
    IHSButtonEventNoEvent               = -1
} IHSButtonEvent;


/**
 @brief                 Structure used when handling 3 axis data (x, y, z)
 */
typedef struct IHSAHRS3AxisStruct {
    double x;           ///< The x value of the 3 axis (X, y, z)
    double y;           ///< The y value of the 3 axis (x, Y, z)
    double z;           ///< The z value of the 3 axis (x, y, Z)
} IHSAHRS3AxisStruct;


/**
 @brief                 The schedule which the software update site is checked for new headset firmware.
 */
typedef enum {
    IHSSoftwareUpdateCheckLatestVersionScheduleManual,     ///< Application controls schedule by callin checkForSoftwareUpdate.
    IHSSoftwareUpdateCheckLatestVersionScheduleAlways,     ///< Always check if a new sw update is available.
    IHSSoftwareUpdateCheckLatestVersionScheduleDaily,      ///< Only check sw update site once a day.
} IHSSoftwareUpdateCheckLatestVersionSchedule;


/**
 @brief                 The reverb preset to be added to all sound sources
 */
typedef enum {
    // Reverb off preset
    IHSAudioReverbPresetOff = 0,
    // Environmental presets
    IHSAudioReverbPresetAlley = 1,
    IHSAudioReverbPresetArena,
    IHSAudioReverbPresetAuditorium,
    IHSAudioReverbPresetBathroom,
    IHSAudioReverbPresetCave,
    IHSAudioReverbPresetHallway,
    IHSAudioReverbPresetHangar,
    IHSAudioReverbPresetLivingroom,
    IHSAudioReverbPresetMountains,
    IHSAudioReverbPresetRoom,
    IHSAudioReverbPresetUnderwater,
    // Musical presets
    IHSAudioReverbPresetSmallRoom,
    IHSAudioReverbPresetMediumRoom,
    IHSAudioReverbPresetLargeRoom,
    IHSAudioReverbPresetMediumHall,
    IHSAudioReverbPresetLargeHall,
    IHSAudioReverbPresetPlate,
    // Additional environmental presets
    IHSAudioReverbPresetCarpetedHallway,
    IHSAudioReverbPresetCity,
    IHSAudioReverbPresetConcertHall,
    IHSAudioReverbPresetForrest,
    IHSAudioReverbPresetPaddedCell,
    IHSAudioReverbPresetParkingLot,
    IHSAudioReverbPresetPlain,
    IHSAudioReverbPresetQuarry,
    IHSAudioReverbPresetSewerPipe,
    IHSAudioReverbPresetStoneCorridor,
    IHSAudioReverbPresetStoneRoom
} IHSAudioReverbPreset;


#pragma mark IHSDeviceDelegate

@protocol IHSDeviceDelegate <NSObject>
@optional

/**
 @brief                 Notify that the connection state has changed
 @details               Called everytime the connection state of the IHS changes
 @param ihs             The IHS device the connection state was changed on
 @param connectionState The new connection state the IHS device changed to
 */
- (void)ihsDevice:(IHSDevice*)ihs connectedStateChanged:(IHSDeviceConnectionState)connectionState;

@end


#pragma mark IHSSensorsDelegate

@protocol IHSSensorsDelegate <NSObject>
@optional

/**
 @brief                 Notify that the fused heading has changed
 @details               Called everytime the fused heading reported by the IHS changes
 @param ihs             The IHS device the fused heading was changed on
 @param heading         Fused heading (gyro and magnetometer)
 */
- (void)ihsDevice:(IHSDevice*)ihs fusedHeadingChanged:(float)heading;


/**
 @brief                 Notify that the compass heading has changed
 @details               Called everytime the compass heading reported by the IHS changes
 @param ihs             The IHS device the compass heading was changed on
 @param heading         Heading (magnetometer)
 */
- (void)ihsDevice:(IHSDevice*)ihs compassHeadingChanged:(float)heading;


/**
 @brief                 Notify that the yaw (gyro heading) has changed
 @details               Called everytime the yaw (gyro heading) reported by the IHS changes
 @param ihs             The IHS device the yaw (gyro heading) was changed on
 @param yaw             Yaw (gyro)
 */
- (void)ihsDevice:(IHSDevice*)ihs yawChanged:(float)yaw;


/**
 @brief                 Notify that the pitch has changed
 @details               Called everytime the pitch reported by the IHS changes
 @param ihs             The IHS device the pitch was changed on
 @param pitch           Pitch (gyro)
 */
- (void)ihsDevice:(IHSDevice*)ihs pitchChanged:(float)pitch;


/**
 @brief                 Notify that the roll has changed
 @details               Called everytime the roll reported by the IHS changes
 @param ihs             The IHS device the roll was changed on
 @param roll            Roll (gyro)
 */
- (void)ihsDevice:(IHSDevice*)ihs rollChanged:(float)roll;


/**
 @brief                 Notify that the horizontal accuracy has changed
 @details               Called everytime the horizontal accuracy reported by the IHS changes
 @param ihs             The IHS device the horizontal accuracy was changed on
 @param horAccuracy     Horizontal accuracy (GPS)
 */
- (void)ihsDevice:(IHSDevice*)ihs accuracyChangedForHorizontal:(double)horAccuracy;


/**
 @brief                 Notify that the GPS position has changed
 @details               Called everytime the GPS position reported by the IHS changes
 @param ihs             The IHS device the GPS position was changed on
 @param latitude        Latitude (GPS)
 @param longitude       Longitude (GPS)
 */
- (void)ihsDevice:(IHSDevice*)ihs locationChangedToLatitude:(double)latitude andLogitude:(double)longitude;


/**
 @brief                 Notify that the accelerometer data has changed
 @details               Called everytime the accelerometer data reported by the IHS changes
 @param ihs             The IHS device which the accelerometer data was changed on
 @param data            3 axis accelerometer data (accelerometer)
 */
- (void)ihsDevice:(IHSDevice*)ihs accelerometer3AxisDataChanged:(IHSAHRS3AxisStruct) data;

@end


#pragma mark IHSButtonDelegate

@protocol IHSButtonDelegate <NSObject>
@required
/**
 @brief                 Notify that an IHS button was pressed
 @details               Called everytime an IHS button is pressed
 @param ihs             The IHS device which the IHS button was pressed on
 @param button          The IHS button that was pressed
 @param event           The IHS button event on the pressed button
 */
- (void)ihsDevice:(id)ihs didPressIHSButton:(IHSButton)button withEvent:(IHSButtonEvent)event;

@end


#pragma mark IHS3DAudioDelegate

@protocol IHS3DAudioDelegate <NSObject>
@optional

/**
 @brief                 Sent as a result of a call to the play method
 @param ihs             The IHS device instance the playback is requested started on
 @param success         YES if playback has started, else NO
 */
- (void)ihsDevice:(id)ihs playerDidStartSuccessfully:(BOOL)success;


/**
 @brief                 Sent as a result of a call to the pause method
 @param ihs             The IHS device instance the playback is requested paused on
 @param success         YES if playback was paused, else NO
 */
- (void)ihsDevice:(id)ihs playerDidPauseSuccessfully:(BOOL)success;


/**
 @brief                 Sent as a result of a call to the stop method
 @param ihs             The IHS device instance the playback is requested stopped on
 @param success         YES if playback was stopped, else NO
 */
- (void)ihsDevice:(id)ihs playerDidStopSuccessfully:(BOOL)success;


/**
 @brief                 Sent during playback as progress moves forward
 @details               This message is sent twice a second
 @param ihs             The IHS device instance playing the audio
 @param currentTime     The current time in seconds
 @param duration        The duration of the sound resource
 */
- (void)ihsDevice:(id)ihs playerCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration;


/**
 @brief                 Sent if an error occured during sound rendering
 @details               A typical error that can occur is an unsupported file or data format.
                        E.g. 32bit samples are not supported
 @param ihs             The IHS device instance
 @param status          Error status '0x3dee' indicates that 3D audio playback was attempted started
                        before the IHS device was connected.
 */
- (void)ihsDevice:(id)ihs playerRenderError:(OSStatus)status;

@end


#pragma mark - Software update delegate

@protocol IHSSoftwareUpdateDelegate <NSObject>
@required

/**
 @brief                 Called by ihs to see if it is allowed to check for new software from the update server.
 @details               Can be used by the applciation to for example allow IHSDevice network access only when WiFi is present.
                        (It is up to the application to detect WiFi presence).
                        If the IHSDevice has no associated IHSSoftwareUpdateDelegate, the default value is to always allow
                        check for software update
                        If the application needs to ask the user for permission, it should return NO from this method,
                        and once the user has allowed a check for new software to be performed call IHSDvice:checkForSoftwareUpdate.
 @param ihs             The IHS device instance requesting network access.
 @return YES            If the application allows the IHSDevice to access the software update server.
 @return NO             If network access is not permitted.
 */
- (BOOL)ihsDeviceShouldCheckForSoftwareUpdateNow:(id)ihs;

@optional

/**
 @brief                 Called when ihs build or latest build number is detected.
 @param ihs             The IHS device instance the buildnumber corresponds to.
 @param deviceBuildNumber Build number of the currently connected device, may be nil of the build number is not yet available.
 @param latestBuildNumber Build number of the latest sowftare available, may be nil of the build number is not yet available.
 */
- (void)ihsDevice:(id)ihs didFindDeviceWithBuildNumber:(NSNumber*)deviceBuildNumber latestBuildNumber:(NSNumber*)latestBuildNumber;

/**
 @brief                 Called by ihs to see if the application allows the currently connected headset to be updated now.
                        If the IHSDevice has no associated IHSSoftwareUpdateDelegate or the delegate does not implement
                        shouldBeginSoftwareUpdateWithInfo, the default value is to always allow a software update to be performed.
                        If the application needs to ask the user for permission, it should return NO from this method,
                        and once the user has allowed the software update to be performed call IHSDvice:beginSoftwareUpdate.
 @param ihs             The IHS device instance requesting permission to software update a connected headset.
 @param info            Dictionary with information about software update. For future use, currently always nil.
 @return YES            If the application allows the IHSDevice to update the software in the connected headset.
 @return NO             If software update is not permitted now.
 */
- (BOOL)ihsDevice:(id)ihs shouldBeginSoftwareUpdateWithInfo:(NSDictionary*)info;

/**
 @brief                 Called by ihs is about to start the software update of the connected headset.
 @param ihs             The IHS device about to software update the connected headset.
 @param info            Metadata about the update.  (currently always nil or empty dictionary)
 */
- (void)ihsDevice:(id)ihs willBeginSoftwareUpdateWithInfo:(NSDictionary*)info;

/**
 @brief                 Called by ihs to inform about.
 @param ihs             The IHS device updating the connected headset.
 @param percent         The current progress of the update. 0..100.
 @param eta             The expected point in time the update will finish.
 */
- (void)ihsDevice:(id)ihs softwareUpdateProgressedTo:(float)percent ETA:(NSDate*)eta;

/**
 @brief                 Called by ihs when the software update has finished.
 @param ihs             The IHS device performing the software update of the connected headset.
 @param success         YES or NO.
 */
- (void)ihsDevice:(id)ihs didFinishSoftwareUpdateWithResult:(BOOL)success;

@end


#pragma mark - IHSDevice interface

@interface IHSDevice: NSObject

#pragma mark Delegates

/**
 @brief                 The object to receive device notifications on
 */
@property (weak, nonatomic) id<IHSDeviceDelegate> deviceDelegate;

/**
 @brief                 The object to receive sensor data notifications on
 */
@property (weak, nonatomic) id<IHSSensorsDelegate> sensorsDelegate;

/**
 @brief                 The object to receive 3D audio notifications on
 */
@property (nonatomic, weak) id<IHS3DAudioDelegate> audioDelegate;

/**
 @brief                 The object to receive button notifications on
 */
@property (weak, nonatomic) id<IHSButtonDelegate> buttonDelegate;

/**
 @brief                 The object to receive software update notifications on
 */
@property (weak, nonatomic) id<IHSSoftwareUpdateDelegate> softwareUpdateDelegate;

/**
 @brief                 IHS API version
 */
@property (readonly, nonatomic) NSString* apiVersion;

/**
 @brief                 Name of the preferred physical IHS device
 */
@property (readonly, nonatomic) NSString* preferredDevice;

/**
 @brief                 YES when a valid API key has been provided through provideAPIKey:, NO otherwise
 */
@property (readonly, nonatomic) BOOL validAPIKeyProvided;

/**
 @brief                 Last known latitude
 */
@property (readonly, nonatomic) double latitude;

/**
 @brief                 Last known longitude
 */
@property (readonly, nonatomic) double longitude;

/**
 @brief                 Last known GPS location
 */
@property (readonly, nonatomic) CLLocation* location;

/**
 @brief                 Last known GPS signal indicator
 @details               0.00:   No signal
                        0.25:   2D fix
                        0.50:   2D fix and SBAS fix
                        0.75:   3D fix
                        1.00:   3D fix and SBAS fix
 */
@property (readonly, nonatomic) float GPSSignalIndicator;

/**
 @brief                 Last known horizontal accuracy
 @details               A value of '-1' indicates that the GPS position is not valid
 */
@property (readonly, nonatomic) double horizontalAccuracy;

/**
 @brief                 Last known fused heading (gyro and magnetometer)
 @details               The range goes from 0 -> 359.9
 */
@property (readonly, nonatomic) float fusedHeading;

/**
 @brief                 Last known compass heading (magnetometer)
 @details               The range goes from 0 -> 359.9
 */
@property (readonly, nonatomic) float compassHeading;

/**
 @brief                 Last known yaw (gyro heading)
 @details               The range goes from 0 -> 359.9
 */
@property (readonly, nonatomic) float yaw;

/**
 @brief                 Last known roll (gyro)
 @details               The range goes from -180.0 -> +180.0
 */
@property (readonly, nonatomic) float roll;

/**
 @brief                 Last known pitch (gyro)
 @details               The range goes from -90.0 -> +90.0
 */
@property (readonly, nonatomic) float pitch;

/**
 @brief                 Last known accelerometer data (accelerometer)
 @details               The range goes from -2g -> 2g for each axis
 */
@property (readonly, nonatomic) IHSAHRS3AxisStruct accelerometerData;

/**
 @brief                 Set to YES if sensors detect magnetic disturbance, else NO
 */
@property (readonly, assign) BOOL magneticDisturbance;

/**
 @brief                 The last known magnetic field strength for the IHS device
 @details               Field strength is reported in milligauss.
 */
@property (readonly, assign) NSInteger magneticFieldStrength;

/**
 @brief                 Set to NO if no movement detected for at least 10s after startup,
                        i.e., the gyro can be assumed autocalibrated.
                        Otherwise YES
 */
@property (readonly, assign) BOOL gyroUncalibrated;

/**
 @brief                 Name of the connected IHS device
 */
@property (readonly, nonatomic) NSString* name;

/**
 @brief                 Firmware revision of the connected IHS device
 */
@property (readonly, nonatomic) NSString* firmwareRevision;

/**
 @brief                 Software revision of the connected IHS device
 */
@property (readonly, nonatomic) NSString* softwareRevision;

/**
 @brief                 Connection state of the IHSDevice
 */
@property (readonly, nonatomic) IHSDeviceConnectionState connectionState;

/**
 @brief                 The sounds currently in the playback pool.
 @details               A sound being present here does not mean that it is nessesary being played back.
                        It can be paused, or have an offset in the future or have finished already.
 */
@property (nonatomic, readonly) NSArray* sounds;

/**
 @brief                 Flag controlling the order of how sounds are played back.
 @details               If YES, all sounds are played back in sequence and new sounds added are played last.
                        If NO, all sounds are played simultaniously taking sound offset etc. into account.
 */
@property (nonatomic, assign) BOOL sequentialSounds;

/**
 @brief                 The total duration of the loaded sound resources including offsets
 */
@property (nonatomic, readonly) NSTimeInterval playerDuration;

/**
 @brief                 The current time of the sound resource
 */
@property (nonatomic) NSTimeInterval playerCurrentTime;

/**
 @brief                 Update the 3D audio player with the direction the user is looking
 @details               The 3D audio player will rotate all the loaded sounds based on the heading set here
                        without manipulating the individual sound's heading
 */
@property (nonatomic, assign) float playerHeading;

/**
 @brief                 Update the 3D audio player with the altitude of the user (in millimeters)
 @details               The 3D audio player will adjust all the loaded sounds based on the altitude set here
                        without manipulating the individual sound's altitude
 */
@property (nonatomic, assign) SInt32 playerAltitude;

/**
 @brief                 The reverb level in millibels (1/100 dB)
 @details               The reverb level goes from -infinit to 0 where 0 is full reverb.
                        A value of INT_MIN will disable reverb
 */
@property (nonatomic, assign) SInt32 playerReverbLevel;

/**
 @brief                 The reverb preset. @see IHSAudioReverbPreset
 @details               Each reverb preset also has a default reverberation time when selected. When selecting a 
                        new preset, the reverb time parameter is changed to the default value for that preset.
 */
@property (nonatomic, assign) IHSAudioReverbPreset playerReverbPreset;

/**
 @brief                 The reverb time
 @details               The reverberation time is the time it takes for the reverberant sound to attenuate by 60 dB
                        from its initial level. Typical values are in the range from 100 to 10000 milliseconds.
                        Note that each reverb preset has a default reverberation time when selected. After selecting
                        a reverb preset, this property can be used to further tweak the sound of the reverberation.
 */
@property (nonatomic, assign) SInt32 playerReverbTime;

/**
 @brief                 Is the 3D audio player playing?
 */
@property (nonatomic, readonly) BOOL isPlaying;

/**
 @brief                 Is the 3D audio player paused?
 */
@property (nonatomic, readonly) BOOL isPaused;

/**
 @brief                 Check if the 3D audio player is able to play sound
 */
@property (nonatomic, readonly) BOOL canPlay;


/**
 @brief                 Set the preferred device upon initializing the IHSDevice
 @details               The API will attempt to connect to the preferred set here, when connect is called
 @param preferredDevice Name of the preferred device to connect to
 */
- (id)initWithPreferredDevice:(NSString*)preferredDevice;

/**
 @brief                 Provide the API key unique to your app to unlock the functionality of the IHS API
 @details               Register your app at https://developer.intelligentheadset.com to get an API key for your app
                        The validity of the provided API key can be retreived via the validAPIKeyProvided property
 @param apiKey          The API key unique to your app
 */
- (void)provideAPIKey:(NSString*)apiKey;

/**
 @brief                 Establish connection to the physical IHS
 @details               If no preferred device has previously been set, a list of available devices will be shown
                        Calling connect while the IHSDevice is in IHSDeviceConnectionStateConnected state will result
                        in a disconnect followed by a (re)connect
 */
- (void)connect;


/**
 @brief                 Close the connection to the physical IHS and pause all 3D audio playback
 */
- (void)disconnect;


#pragma mark 3D audio handling

/**
 @brief                 Adds a sound to playback along with other sounds.
 @details               Currently only files on the local file system is supported.
 @param sound           The sound resource to load and playback
 */
- (void)addSound:(IHSAudio3DSound*)sound;

/**
 @brief                 Removes a sound from the playback pool.
 @param sound           The sound to remove. This sound will stop playing and then be removed.
 */
- (void)removeSound:(IHSAudio3DSound*)sound;

/**
 @brief                 Removes all sounds from the player.
 */
- (void)clearSounds;

/**
 @brief                 Start the playback of the sound resource
 @details               The sound resource to playback must have been set with loadURL: before calling this method.
 @note                  Playback can only be started when the IHS device is connected. If the play method is called
                        while the IHS device is not connected, error status '0x3dee' will be returned through the delegate via
                        ihsDevice:playerRenderError:
 */
- (void)play;

/**
 @brief                 Pauses playback.
 @details               Playback can be resumed with a call to the play method and will resume at the point where it was paused.
 */
- (void)pause;

/**
 @brief                 Stops playback.
 @details               Playback can be resumed with a call to the play method and will resume from the beginning of the sound resource.
 */
- (void)stop;

#pragma mark Software update related properties and methods

/**
 @brief                 The current schedule that checks for new software availability runs with.
 */
@property (nonatomic) IHSSoftwareUpdateCheckLatestVersionSchedule   softwareUpdateSchedule;

/**
 @brief                 Controls whether connected devices are automatically updated.
 */
@property (nonatomic) BOOL softwareUpdateConnectedDevicesAutomatically;

/**
 @brief                 Determine if a software update is in progress.
 */
@property (nonatomic, readonly) BOOL softwareUpdateInProgress;

/**
 @brief                 Progress of a running software update.  Only valid/useful when softwareUpdateInProgress == YES.
 */
@property (nonatomic, readonly) float softwareUpdateProgressPercentage;

/**
 @brief                 Start time of a running software update.  nil when no update is in progress.
 */
@property (nonatomic, readonly, strong) NSDate* softwareUpdateStartTime;

/**
 @brief                 End time of a running software update. Nil when no update is in progress.
 */
@property (nonatomic, readonly, strong) NSDate* softwareUpdateEndTime;

/**
 @brief                 Expected end time of a running software update.  Nil when no update is in progress.
 */
@property (nonatomic, readonly, strong) NSDate* softwareUpdateExpectedEndTime;

/**
 @brief                 Determine if a software update is available for the currently connected headset.
 */
@property (nonatomic, readonly) BOOL softwareUpdateAvailable;

/**
 @brief                 The currently active build number of the software in the headset.
 */
@property (nonatomic, readonly) NSNumber* currentBuildNumber;

/**
 @brief                 The currently active build number of the software in the headset.
 */
@property (nonatomic, readonly) NSNumber* latestBuildNumber;

/**
 @brief                 Manually trigger a check for new software.
 */
- (void)checkForSoftwareUpdate;

/**
 @brief                 Manually trigger a software update
 @return                YES if a software update was started.
 */
- (BOOL)beginSoftwareUpdate;

/**
 @brief                 Abort any running software update.
 */
- (void)abortSoftwareUpdate;

@end
