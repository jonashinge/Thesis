//
//  ViewController.m
//  AuditoryMusicFinder
//
//  Created by Jonas Hinge on 02/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "ViewController.h"

#import "AppDelegate.h"
#import "NSString+IHSDeviceConnectionState.h"
#import "AudioSource.h"
#import "AudioSoundAnnotation.h"
#import "AudioListenerAnnotation.h"

#import <AVFoundation/AVFoundation.h>
#import <IHS/IHS.H>

@interface ViewController () <IHSDeviceDelegate, IHSSensorsDelegate, IHSButtonDelegate, IHS3DAudioDelegate, IHSAudio3DGridModelDelegate, IHSAudio3DGridViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblConnectionStatus;
@property (strong, nonatomic) IBOutlet IHSAudio3DGridView *view3DAudioGrid;
@property (strong, nonatomic) AVAudioPlayer* audioPlayer;

@end

// Set the DEBUG_PRINTOUT define to '1' to enable printouts of the received values
#define DEBUG_PRINTOUT      1

#if !DEBUG_PRINTOUT
#define DEBUGLog(format, ...)
#else
#define DEBUGLog(format, ...) NSLog(format, ## __VA_ARGS__)
#endif

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Register to get notified via 'appDidBecomeActive' when the app becomes active
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // Setup audio 3d grid view and model.
    // The gridBounds property is an expression for how big in a physical world
    // the gridview should be. This has nothing to do with how big the gridview is on screen.
    // In this example there are 20 meters from left to right. This has an effect on how
    // sounds are perceived over distance.
    self.view3DAudioGrid.delegate = self;
    self.view3DAudioGrid.gridBounds = CGRectMake(-10000, -10000, 20000, 20000); // 20x20 meters - center @ 0,0
    self.view3DAudioGrid.listenerAnnotation = [[AudioListenerAnnotation alloc] init];
    self.view3DAudioGrid.audioModel = [[IHSAudio3DGridModel alloc] init];
    self.view3DAudioGrid.audioModel.delegate = self;
    [self loadSounds];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Misc

- (void)connectIHSDevice
{
    // Setup delegates to receive various kinds of information from the IHS:
    APP_DELEGATE.ihsDevice.deviceDelegate = self;   // ... connection information
    APP_DELEGATE.ihsDevice.sensorsDelegate = self;  // ... receive data from the IHS sensors
    APP_DELEGATE.ihsDevice.buttonDelegate = self;   // ... receive button presses
    APP_DELEGATE.ihsDevice.audioDelegate = self;    // ... receive 3daudio notifications.
    
    // Establish connection to the physical IHS
    if (APP_DELEGATE.ihsDevice.connectionState != IHSDeviceConnectionStateConnected) {
        //_allowDeviceSelectionToBeShown = APP_DELEGATE.ihsDevice.connectionState != IHSDeviceConnectionStateNone;
        [APP_DELEGATE.ihsDevice connect];
    }
}

- (void)appDidBecomeActive:(NSNotification *)notification
{
    [self connectIHSDevice];
}

- (void)loadSounds
{
    AudioSource* audioSource;
    
    audioSource = [[AudioSource alloc] initWithSound:@"test@44100" andImage:@"daftpunk.jpg"];
    audioSource.position = CGPointMake(0, 3500);
    audioSource.sound.repeats = YES;
    [self.view3DAudioGrid.audioModel addSource:audioSource];
    
    audioSource = [[AudioSource alloc] initWithSound:@"test2@44100" andImage:@"daftpunk.jpg"];
    audioSource.position = CGPointMake(0, -3500);
    audioSource.sound.repeats = YES;
    [self.view3DAudioGrid.audioModel addSource:audioSource];
    
    audioSource = [[AudioSource alloc] initWithSound:@"test3@44100" andImage:@"eminem.jpg"];
    audioSource.position = CGPointMake(3500, 0);
    audioSource.sound.repeats = YES;
    [self.view3DAudioGrid.audioModel addSource:audioSource];
    
    audioSource = [[AudioSource alloc] initWithSound:@"test4@44100" andImage:@"kingsofleon.jpg"];
    audioSource.position = CGPointMake(-3500, 0);
    audioSource.sound.repeats = YES;
    [self.view3DAudioGrid.audioModel addSource:audioSource];
}


#pragma mark - IHSDeviceDelegate implementation

- (void)ihsDevice:(IHSDevice*)ihsDevice connectedStateChanged:(IHSDeviceConnectionState)connectionState
{
    DEBUGLog(@"IHS Device:connectedStateChanged:  %@", [NSString stringFromIHSDeviceConnectionState:connectionState]);
    
    NSString* connectionString = [NSString stringFromIHSDeviceConnectionState:connectionState];
    NSString* deviceName = APP_DELEGATE.ihsDevice.name ?: @"Headset X";
    NSString* statusText = [NSString stringWithFormat:@"%@ (%@)", deviceName, connectionString];
    
    self.lblConnectionStatus.text = statusText;
    
    switch (connectionState)
    {
        case IHSDeviceConnectionStateConnected: {
            // Save the name of the connected IHS device to automatically connect to it next time the app starts
            //APP_DELEGATE.preferredDevice = ihsDevice.preferredDevice;
            
            // Play a sound through the standard player to indicate that the IHS is connected
            [self playSystemSoundWithName:@"TestConnectSound"];
            break;
        }
            
        case IHSDeviceConnectionStateDisconnected: {
            if (self.presentedViewController != nil) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            break;
        }
            
        case IHSDeviceConnectionStateDiscovering: {
            [self connectIHSDevice];
            break;
        }
            
        case IHSDeviceConnectionStateNone:
        case IHSDeviceConnectionStateBluetoothOff:
        case IHSDeviceConnectionStateLingering:
        case IHSDeviceConnectionStateConnecting:
        case IHSDeviceConnectionStateConnectionFailed:
            break;
    }
}


- (void)ihsDeviceFoundAmbiguousDevices:(IHSDevice *)ihs
{
    // If you want the IHS device selection UI to be presented if the
    // SDK does not have a preferred device to connect to, remove
    // the if-statement around [ihs showDeviceSelection:self]
    // Just make sure the main view is in the window hierarchy before
    // showDeviceSelection: is called
    
    [ihs showDeviceSelection:self];
}


#pragma mark - Sound handling

- (void)playSystemSoundWithName:(NSString*)name {
    NSError *error;
    NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:@"wav"];
    
    [self.audioPlayer stop];
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) {
        NSLog(@"Error playing sound '%@': %@", name, error);
        self.audioPlayer = nil;
    }
    else {
        self.audioPlayer.volume = 1.0;
        
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
    }
}


#pragma mark - IHSButtonDelegate implementation

- (void)ihsDevice:(id)ihs didPressIHSButton:(IHSButton)button withEvent:(IHSButtonEvent)event fromSource:(IHSButtonSource)source
{
    IHSDevice*  ihsDevice = ihs;
    
    switch (button) {
        case IHSButtonRight: {
            
            /*[ihsDevice stop];
            [ihsDevice clearSounds];
            
            //ihsDevice.sequentialSounds = YES;
            
            // Create north and south IHSAudio3DSound objects from embedded sound resources:
            NSURL* testUrl = [[NSBundle mainBundle] URLForResource:@"test@44100" withExtension:@"wav"];
            IHSAudio3DSound* testSound = [[IHSAudio3DSound alloc] initWithURL:testUrl];
            
            testSound.heading  = 0;        // Place the "north" sound straight north
            testSound.volume   = 1.0;      // Set the volume to the maximum level
            testSound.distance = 5000;     // Set the distance of the sound
            
            [ihsDevice addSound:testSound];
            
            NSURL* test2Url = [[NSBundle mainBundle] URLForResource:@"test2@44100" withExtension:@"wav"];
            IHSAudio3DSound* test2Sound = [[IHSAudio3DSound alloc] initWithURL:test2Url];
            
            test2Sound.heading  = 40;        // Place the "north" sound straight north
            test2Sound.volume   = 1.0;      // Set the volume to the maximum level
            test2Sound.distance = 5000;     // Set the distance of the sound
            
            [ihsDevice addSound:test2Sound];
            
            NSURL* test3Url = [[NSBundle mainBundle] URLForResource:@"test3@44100" withExtension:@"wav"];
            IHSAudio3DSound* test3Sound = [[IHSAudio3DSound alloc] initWithURL:test3Url];
            
            test3Sound.heading  = 80;        // Place the "north" sound straight north
            test3Sound.volume   = 1.0;      // Set the volume to the maximum level
            test3Sound.distance = 1000;     // Set the distance of the sound
            
            [ihsDevice addSound:test3Sound];
            
            NSURL* test4Url = [[NSBundle mainBundle] URLForResource:@"test4@44100" withExtension:@"wav"];
            IHSAudio3DSound* test4Sound = [[IHSAudio3DSound alloc] initWithURL:test4Url];
            
            test4Sound.heading  = 120;        // Place the "north" sound straight north
            test4Sound.volume   = 1.0;      // Set the volume to the maximum level
            test4Sound.distance = 5000;     // Set the distance of the sound
            
            [ihsDevice addSound:test4Sound];*/
            
            // Start the playback
            [ihsDevice play];
            
            break;
        }
            
        case IHSButtonLeft: {
            // Stop the playback
            [ihsDevice stop];
            // Clear the list of sounds
            [ihsDevice clearSounds];
            break;
        }
            
        default:
            break;
    }
}


#pragma mark - IHSAudio3DGridModelDelegate

- (void)audioModel:(IHSAudio3DGridModel*)audioModel didAddSource:(id<IHSAudio3DGridModelSource>)source
{
    // An audio source was added to the audio grid model.
    // We will add it to the IHS Device now, but we could wait
    // if we e.g. do not want to playback sounds from this model yet.
    [APP_DELEGATE.ihsDevice addSound:source.sound];
}


- (void)audioModel:(IHSAudio3DGridModel*)audioModel willRemoveSource:(id<IHSAudio3DGridModelSource>)source
{
    // An audio source was removed from the model.
    // Remove it from the IHS Device. The IHS Device accepts
    // removing sounds that was never added or previously removed.
    [APP_DELEGATE.ihsDevice removeSound:source.sound];
}


- (void)audioModel:(IHSAudio3DGridModel *)audioModel didUpdateListenerHeading:(CGFloat)heading
{
    // The audio grid model changed heading.
    // Update the IHS Device player heading accordingly.
    // We adjust the player heading based on the audio grid model,
    // instead of the fused heading. That way we decouple the headset
    // and the audio grid model, if the model was to be manipulated by
    // another source than the fused heading.
    APP_DELEGATE.ihsDevice.playerHeading = heading;
}


#pragma mark - IHSAudio3DGridViewDelegate

- (IHSAudio3DGridSoundAnnotation*)audioGridView:(IHSAudio3DGridView*)audioGridView audioAnnotationForAudioSource:(id<IHSAudio3DGridModelSource>)audioSource
{
    // The audio grid view need an annotation to represent the audioSource
    AudioSoundAnnotation* annotation = [[AudioSoundAnnotation alloc] initWithAudioSource:audioSource];
    return annotation;
}


#pragma mark - IHSSensorDelegate implementation

- (void)ihsDevice:(IHSDevice*)ihs fusedHeadingChanged:(float)heading
{
    DEBUGLog(@"1: Fused Heading changed: %.1f", heading);

    // Use the fused heading as reference for the 3D audio player in the IHS
    //ihs.playerHeading = heading;
    
    // Apply the heading to our audio grid model.
    // See IHSDevice.fusedHeading for more info.
    self.view3DAudioGrid.audioModel.listenerHeading = heading + 90;
    
    // setting position
    float x = 0 + (3000*cos((heading*M_PI)/180));
    float y = 0 - (3000*sin((heading*M_PI)/180));
    self.view3DAudioGrid.audioModel.listenerPosition = CGPointMake(x, y);
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

@end
