//
//  SMMViewController.m
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 07/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "AudioMenuController.h"

#import "AudioMenuView.h"
#import "AppDelegate.h"
#import "NSString+IHSDeviceConnectionState.h"
#import "AudioSource.h"
#import "AudioSoundAnnotation.h"
#import "AudioListenerAnnotation.h"
#import "MusicAPI.h"
#import "DTWGestureRecognizer.h"

#import <AVFoundation/AVFoundation.h>
#import <IHS/IHS.H>
#import <TSMessages/TSMessage.h>

@interface AudioMenuController () <IHSDeviceDelegate, IHSSensorsDelegate, IHS3DAudioDelegate, IHSAudio3DGridModelDelegate, IHSAudio3DGridViewDelegate>

@property (nonatomic, strong) IHSDevice* ihsDevice;
@property BOOL recordingGesture;
@property UIButton *btnRecordGesture;
@property NSMutableArray *recording;
@property NSMutableArray *accData;
@property (strong, nonatomic) DTWGestureRecognizer *recognizer;

@end

// Set the DEBUG_PRINTOUT define to '1' to enable printouts of the received values
#define DEBUG_PRINTOUT      1

#if !DEBUG_PRINTOUT
#define DEBUGLog(format, ...)
#else
#define DEBUGLog(format, ...) NSLog(format, ## __VA_ARGS__)
#endif

@implementation AudioMenuController

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
	
    AudioMenuView *gridView = [[AudioMenuView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [gridView setBackgroundColor:[UIColor redColor]];
    //[self.view addSubview:gridView];
    
    _btnRecordGesture = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btnRecordGesture.frame = CGRectMake(100, 100, 200, 50);
    [_btnRecordGesture setTitle:@"Start Recording Gesture" forState:UIControlStateNormal];
    [_btnRecordGesture setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:1 alpha:0.8]];
    [_btnRecordGesture setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnRecordGesture addTarget:self
                         action:@selector(btnRecordDown)
               forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_btnRecordGesture];
    
    // Create an instance of IHSDevice, set it up and provide API Key
    // The API Key can be obtained from https://developer.intelligentheadset.com
    NSString* preferredDevice = [[NSUserDefaults standardUserDefaults] stringForKey:@"preferredDevice"];
    _ihsDevice = [[IHSDevice alloc] initWithPreferredDevice:preferredDevice];
    _ihsDevice.deviceDelegate = self;
    _ihsDevice.sensorsDelegate = self;
    [_ihsDevice provideAPIKey:@"3tXvpy2WbqLIkaxaiEtYt2DF8sjf8rt0lOGqjDNesGG+/gFDZ6Rpjs19KFRZALrvzMWJQuJfdjtNI//k0Gl2cA=="];
    [_ihsDevice connect];
    
    // Test recognizer
    /*NSArray *testSequence = [NSArray arrayWithObjects:
                             [NSArray arrayWithObject:[NSNumber numberWithDouble:4000]],
                             [NSArray arrayWithObject:[NSNumber numberWithDouble:5000]],
                             [NSArray arrayWithObject:[NSNumber numberWithDouble:6000]],
                             [NSArray arrayWithObject:[NSNumber numberWithDouble:10]],
                             [NSArray arrayWithObject:[NSNumber numberWithDouble:20]],
                             [NSArray arrayWithObject:[NSNumber numberWithDouble:30]],
                             [NSArray arrayWithObject:[NSNumber numberWithDouble:100]],
                             [NSArray arrayWithObject:[NSNumber numberWithDouble:200]],
                             [NSArray arrayWithObject:[NSNumber numberWithDouble:300]],
                             [NSArray arrayWithObject:[NSNumber numberWithDouble:1000]],
                             [NSArray arrayWithObject:[NSNumber numberWithDouble:2000]],
                             [NSArray arrayWithObject:[NSNumber numberWithDouble:3000]], nil];
    _recognizer = [[DTWGestureRecognizer alloc] initWithDimension:1 GlobalThreshold:10 FirstThreshold:20 AndMaxSlope:10];
    NSString *result = [_recognizer recognizeSequence:testSequence];
    DEBUGLog(@"Sequence recognized with class: %@",result);*/
    
    _recognizer = [[DTWGestureRecognizer alloc] initWithDimension:6 GlobalThreshold:0.1 FirstThreshold:0.05 AndMaxSlope:2];
    _accData = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //MusicAPI *musicAPI = [MusicAPI sharedInstance];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnRecordDown
{
    // Stop recording
    if(_recordingGesture)
    {
        [_btnRecordGesture setTitle:@"Start Recording Gesture" forState:UIControlStateNormal];
        [_btnRecordGesture setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:1 alpha:0.8]];
        _recordingGesture = NO;
        
        [_recognizer addKnownSequence:_recording WithLabel:@"NOD_TEST"];
        
        DEBUGLog(@"Adding a sequence with size: %d", [_recording count]);
    }
    // Start recording
    else
    {
        [_btnRecordGesture setTitle:@"Stop Recording Gesture" forState:UIControlStateNormal];
        [_btnRecordGesture setBackgroundColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.8]];
        _recordingGesture = YES;
        
        _recording = [[NSMutableArray alloc] init];
    }
}


#pragma mark - IHSDeviceDelegate

- (void)ihsDevice:(IHSDevice*)ihs connectedStateChanged:(IHSDeviceConnectionState)connectionState
{
    NSString* connectionString = [NSString stringFromIHSDeviceConnectionState:connectionState];
    NSString* deviceName = _ihsDevice.name ?: @"Headset X";
    DEBUGLog(@"%@ (%@)", deviceName, connectionString);
    
    // Here we will get information about the connection state.
    switch (connectionState) {
        case IHSDeviceConnectionStateConnecting:
            // Once we have initiated a connection to a headset,
            // the state will change to "Connecting".
            [TSMessage showNotificationWithTitle:@"Intelligent Headset is trying to connect..." type:TSMessageNotificationTypeMessage];
            break;
        case IHSDeviceConnectionStateConnected:
            // Fully connected
            [TSMessage showNotificationWithTitle:@"Intelligent Headset is connected" type:TSMessageNotificationTypeSuccess];
            // Save the preferred device, so we can connect to the same headset next time.
            [[NSUserDefaults standardUserDefaults] setObject:self.ihsDevice.preferredDevice forKey:@"preferredDevice"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        case IHSDeviceConnectionStateConnectionFailed:
            [TSMessage showNotificationWithTitle:@"Intelligent Headset failed to connect" type:TSMessageNotificationTypeError];
            break;
        default:
            
            break;
    }
}


- (void)ihsDeviceFoundAmbiguousDevices:(IHSDevice*)ihs
{
    // Needed when running in simulator or
    // when headset is connected via wire.
    [ihs showDeviceSelection:self];
}


#pragma mark - IHSSensorsDelegate

-(void)ihsDevice:(IHSDevice *)ihs fusedHeadingChanged:(float)heading
{
    // Apply the heading to our audio grid model.
    // See IHSDevice.fusedHeading for more info.
    //self.audioGrid.audioModel.listenerHeading = heading;
}

- (void)ihsDevice:(IHSDevice *)ihs accelerometer3AxisDataChanged:(IHSAHRS3AxisStruct)data
{
    // Pseudo sensor fusion
    NSArray *obs = [NSArray arrayWithObjects:
                     [NSNumber numberWithFloat:_ihsDevice.accelerometerData.x],
                     [NSNumber numberWithFloat:_ihsDevice.accelerometerData.y],
                     [NSNumber numberWithFloat:_ihsDevice.accelerometerData.z],
                     [NSNumber numberWithFloat:_ihsDevice.pitch/90], // values from -1 to 1
                     [NSNumber numberWithFloat:_ihsDevice.yaw/360], // values from -1 to 1
                     [NSNumber numberWithFloat:_ihsDevice.roll/90], nil]; // values from -1 to 1
    
    // Acc data
    /*NSArray *obs = [NSArray arrayWithObjects:
                    [NSNumber numberWithDouble:data.x],
                    [NSNumber numberWithDouble:data.y],
                    [NSNumber numberWithDouble:data.z], nil];*/
    
    // Gyro data
    /*NSArray *obs = [NSArray arrayWithObjects:
                    [NSNumber numberWithFloat:_ihsDevice.pitch/90],
                    [NSNumber numberWithFloat:_ihsDevice.yaw/360],
                    [NSNumber numberWithFloat:_ihsDevice.roll/90], nil];*/
    
    //DEBUGLog(@"Fusion data: %@",obs);
    
    // Record gesture
    if(_recordingGesture)
    {
        DEBUGLog(@"Fusion data: %@",obs);
        [_recording addObject:obs];
    }
    // Recognize gesture
    else
    {
        [_accData addObject:obs];
        // Remove the oldest observation
        if([_accData count] > 100)
        {
            [_accData removeObjectAtIndex:0];
        }
        NSString *result = [_recognizer recognizeSequence:_accData];
        if(![result isEqual: @"__UNKNOWN"])
        {
            DEBUGLog(@"Recognized gesture: %@",result);
            [TSMessage showNotificationWithTitle:@"Gesture detected!" type:TSMessageNotificationTypeSuccess];
            [_accData removeAllObjects];
        }
    }
}

- (void)pseudoSensorFusionDidChange:(NSArray *)fusionData
{
    DEBUGLog(@"Pseudo fusion: %@", fusionData);
}


#pragma mark - IHSAudio3DGridModelDelegate

- (void)audioModel:(IHSAudio3DGridModel*)audioModel didAddSource:(id<IHSAudio3DGridModelSource>)source
{
    // An audio source was added to the audio grid model.
    // We will add it to the IHS Device now, but we could wait
    // if we e.g. do not want to playback sounds from this model yet.
    [_ihsDevice addSound:source.sound];
}


- (void)audioModel:(IHSAudio3DGridModel*)audioModel willRemoveSource:(id<IHSAudio3DGridModelSource>)source
{
    // An audio source was removed from the model.
    // Remove it from the IHS Device. The IHS Device accepts
    // removing sounds that was never added or previously removed.
    [_ihsDevice removeSound:source.sound];
}


- (void)audioModel:(IHSAudio3DGridModel *)audioModel didUpdateListenerHeading:(CGFloat)heading
{
    // The audio grid model changed heading.
    // Update the IHS Device player heading accordingly.
    // We adjust the player heading based on the audio grid model,
    // instead of the fused heading. That way we decouple the headset
    // and the audio grid model, if the model was to be manipulated by
    // another source than the fused heading.
    _ihsDevice.playerHeading = heading;
}


#pragma mark - IHSAudio3DGridViewDelegate

- (IHSAudio3DGridSoundAnnotation*)audioGridView:(IHSAudio3DGridView*)audioGridView audioAnnotationForAudioSource:(id<IHSAudio3DGridModelSource>)audioSource
{
    // The audio grid view need an annotation to represent the audioSource
    AudioSoundAnnotation* annotation = [[AudioSoundAnnotation alloc] initWithAudioSource:audioSource];
    return annotation;
}



@end
