//
//  MainViewController.m
//  HeadsetExplorer
//
//  Created by Jonas Hinge on 20/01/2014.
//  Copyright (c) 2014 GN Store Nord A/S. All rights reserved.
//

#import "MainViewController.h"
#import "GNAppDelegate.h"
#import "Constants.h"
#import "NSString+IHSDeviceConnectionState.h"
#import "MixerCoreAudioController.h"

@interface MainViewController () <IHSDeviceDelegate, IHSSensorsDelegate, IHSButtonDelegate>

@end

// Set the DEBUG_PRINTOUT define to '1' to enable printouts of the received values
#define DEBUG_PRINTOUT      1

#if !DEBUG_PRINTOUT
#define DEBUGLog(format, ...)
#else
#define DEBUGLog(format, ...) NSLog(format, ## __VA_ARGS__)
#endif

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sliderDidChange:(id)sender {
    
    [self.lblPan setText:[NSString stringWithFormat:@"%f",self.sliderPan.value]];
    
    [APP_DELEGATE.audioController applyPanningToMixer:self.sliderPan.value];
}

#pragma mark - IHSDeviceDelegate implementation

- (void)ihsDevice:(IHSDevice*)ihsDevice connectedStateChanged:(IHSDeviceConnectionState)connectionState
{
    DEBUGLog( @"IHS Device:connectedStateChanged:  %d", connectionState );
    
    NSString* connectionString = [NSString stringFromIHSDeviceConnectionState:connectionState];
    NSString* deviceName = APP_DELEGATE.ihsDevice.name ?: @"Headset X";
    NSString* statusText = [NSString stringWithFormat:@"%@ (%@)", deviceName, connectionString ];
    
    self.lblConnStatus.text = statusText;
    
    switch ( connectionState )
    {
        case IHSDeviceConnectionStateConnected:
            // Save the name of the connected IHS device to automatically connect to it next time the app starts
            APP_DELEGATE.preferredDevice = ihsDevice.preferredDevice;
            
            //[self moveMapCenterToLocation: APP_DELEGATE.lastKnownLocation];
            
            // Play a sound through the standard player to indicate that the IHS is connected
            //[self playSystemSoundWithName:@"TestConnectSound"];
            break;
            
        case IHSDeviceConnectionStateNone:
        case IHSDeviceConnectionStateBluetoothOff:
        case IHSDeviceConnectionStateDiscovering:
        case IHSDeviceConnectionStateDisconnected:
        case IHSDeviceConnectionStateLingering:
        case IHSDeviceConnectionStateConnecting:
        case IHSDeviceConnectionStateConnectionFailed:
            break;
    }
}

#pragma mark - IHSSensorsDelegate implementation

- (void)ihsDevice:(IHSDevice*)ihs fusedHeadingChanged:(float)heading
{
    DEBUGLog(@"1: Fused Heading changed: %.1f", heading);
    
    //[self updateMapRotation:heading];
    // Use the fused heading as reference for the 3D audio player in the IHS
    //ihs.playerHeading = heading;
}


- (void)ihsDevice:(IHSDevice*)ihs compassHeadingChanged:(float)heading
{
    DEBUGLog(@"2: Compass Heading changed: %.1f", heading);
}


- (void)ihsDevice:(IHSDevice*)ihs yawChanged:(float)yaw
{
    DEBUGLog(@"3: Yaw: %.1f", yaw);
}


- (void)ihsDevice:(IHSDevice*)ihs pitchChanged:(float)pitch
{
    DEBUGLog(@"4: Pitch: %.1f", pitch);
}


- (void)ihsDevice:(IHSDevice*)ihs rollChanged:(float)roll
{
    DEBUGLog(@"5: Roll: %.1f", roll);
}


- (void)ihsDevice:(IHSDevice*)ihs accelerometer3AxisDataChanged:(IHSAHRS3AxisStruct) data
{
    DEBUGLog(@"6: Accelerometer data: (%f, %f, %f)", data.x, data.y, data.z);
}


- (void)ihsDevice:(IHSDevice*)ihs accuracyChangedForHorizontal:(double)horizontalAccuracy
{
    DEBUGLog(@"7: Horizontal accuracy: %.1f", horizontalAccuracy);
}


- (void)ihsDevice:(IHSDevice*)ihs locationChangedToLatitude:(double)latitude andLogitude:(double)longitude
{
    DEBUGLog(@"8: Position: (%.4g, %.4g)", latitude, longitude);
    DEBUGLog(@"   %@", APP_DELEGATE.ihsDevice.location );
    
    //[self moveMapCenterToLocation:APP_DELEGATE.ihsDevice.location];
}


#pragma mark - IHSButtonDelegate implementation

- (void)ihsDevice:(id)ihs didPressIHSButton:(IHSButton)button withEvent:(IHSButtonEvent)event
{
    //IHSDevice*  ihsDevice = ihs;
    
    switch (button) {
        case IHSButtonLeft: {
            /*[ihsDevice stop];
            [ihsDevice clearSounds];
            
            if ( APP_DELEGATE.playNorthSound || APP_DELEGATE.playSouthSound ) {
                ihsDevice.sequentialSounds = YES;
                
                if ( APP_DELEGATE.playNorthSound ) {
                    // Create north and south IHSAudio3DSound objects from embedded sound resources:
                    NSURL* northUrl = [[NSBundle mainBundle] URLForResource:@"ThisIsNorth" withExtension:@"wav"];
                    IHSAudio3DSound* northSound = [[IHSAudio3DSound alloc] initWithURL:northUrl];
                    
                    northSound.heading  = 0;        // Place the "north" sound straight north
                    northSound.volume   = 1.0;      // Set the volume to the maximum level
                    northSound.distance = 1000;     // Set the distance of the sound
                    
                    [ihsDevice addSound:northSound];
                }
                
                if ( APP_DELEGATE.playSouthSound ) {
                    NSURL *southUrl = [[NSBundle mainBundle] URLForResource:@"ThisIsSouth" withExtension:@"wav"];
                    IHSAudio3DSound* southSound = [[IHSAudio3DSound alloc] initWithURL:southUrl];
                    
                    southSound.heading  = 180;      // Place the "south" sound straight south
                    southSound.volume   = 1.0;      // Set the volume to the maximum level
                    southSound.distance = 1000;     // Set the distance of the sound
                    
                    [ihsDevice addSound:southSound];
                }
                // Start the playback
                [ihsDevice play];
            }*/
            break;
        }
            
        case IHSButtonRight: {
            // Stop the playback
            /*[ihsDevice stop];
            // Clear the list of sounds
            [ihsDevice clearSounds];*/
            break;
        }
            
        default:
            break;
    }
}


#pragma mark - Misc

- (void)connectIHSDevice
{
    // Setup delegates to receive various kinds of information from the IHS:
    APP_DELEGATE.ihsDevice.deviceDelegate = self;   // ... connection information
    APP_DELEGATE.ihsDevice.sensorsDelegate = self;  // ... receive data from the IHS sensors
    APP_DELEGATE.ihsDevice.buttonDelegate = self;   // ... receive button presses
    
    // Establish connection to the physical IHS
    if ( APP_DELEGATE.ihsDevice.connectionState != IHSDeviceConnectionStateConnected ) {
        [APP_DELEGATE.ihsDevice connect];
    }
}



@end
