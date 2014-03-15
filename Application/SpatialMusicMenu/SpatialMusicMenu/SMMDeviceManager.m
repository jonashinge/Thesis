//
//  DeviceManager.m
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 14/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "SMMDeviceManager.h"

#import "NSString+IHSDeviceConnectionState.h"
#import "DTWRecognizer.h"

@interface SMMDeviceManager () <IHSDeviceDelegate, IHSSensorsDelegate>

@property (strong, nonatomic) IHSDevice *ihsDevice;
@property (strong, nonatomic) DTWRecognizer *recognizer;
@property (strong, nonatomic) NSMutableArray *accData;
@property BOOL recordingGesture;
@property NSMutableArray *recording;

// Set the DEBUG_PRINTOUT define to '1' to enable printouts of the received values
#define DEBUG_PRINTOUT      1

#if !DEBUG_PRINTOUT
#define DEBUGLog(format, ...)
#else
#define DEBUGLog(format, ...) NSLog(format, ## __VA_ARGS__)
#endif

@end

@implementation SMMDeviceManager

- (id)init
{
    self = [super init];
    if(self)
    {
        // Create an instance of IHSDevice, set it up and provide API Key
        // The API Key can be obtained from https://developer.intelligentheadset.com
        NSString* preferredDevice = [[NSUserDefaults standardUserDefaults] stringForKey:@"preferredDevice"];
        _ihsDevice = [[IHSDevice alloc] initWithPreferredDevice:preferredDevice];
        [_ihsDevice provideAPIKey:@"3tXvpy2WbqLIkaxaiEtYt2DF8sjf8rt0lOGqjDNesGG+/gFDZ6Rpjs19KFRZALrvzMWJQuJfdjtNI//k0Gl2cA=="];
        _ihsDevice.deviceDelegate = self;
        _ihsDevice.sensorsDelegate = self;
    }
    return self;
}

#pragma mark - Manager methods

- (void)showDeviceSelection:(UIViewController *)parentViewController
{
    [_ihsDevice showDeviceSelection:parentViewController];
}

- (void)connectToDevice
{
    [_ihsDevice connect];
}

- (void)startRecordingGesture
{
    _recordingGesture = YES;
}

- (void)stopRecordingGesture
{
    _recordingGesture = NO;
}


#pragma mark - IHSDeviceDelegate

- (void)ihsDeviceFoundAmbiguousDevices:(IHSDevice *)ihs
{
    if([_connectionDelegate respondsToSelector:@selector(smmDeviceManagerFoundAmbiguousDevices:)])
    {
        [_connectionDelegate smmDeviceManagerFoundAmbiguousDevices:self];
    }
}

- (void)ihsDevice:(IHSDevice *)ihs connectedStateChanged:(IHSDeviceConnectionState)connectionState
{
    // Here we will get information about the connection state.
    switch (connectionState) {
        case IHSDeviceConnectionStateConnected:
            // Fully connected
            // Save the preferred device, so we can connect to the same headset next time.
            [[NSUserDefaults standardUserDefaults] setObject:_ihsDevice.preferredDevice forKey:@"preferredDevice"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // Setup recognizer and recording array
            _recognizer = [[DTWRecognizer alloc] initWithDimension:6 GlobalThreshold:0.1 FirstThreshold:0.05 AndMaxSlope:2];
            _accData = [[NSMutableArray alloc] init];
            break;
        default:
            break;
    }
    
    if([_connectionDelegate respondsToSelector:@selector(smmDeviceManager:connectedStateChanged:)])
    {
        [_connectionDelegate smmDeviceManager:self connectedStateChanged:connectionState];
    }
}


#pragma mark - IHSSensorsDelegate

-(void)ihsDevice:(IHSDevice *)ihs fusedHeadingChanged:(float)heading
{
    if([_delegate respondsToSelector:@selector(smmDeviceManager:fusedHeadingChanged:)])
    {
        [_delegate smmDeviceManager:self fusedHeadingChanged:heading];
    }
}

- (void)ihsDevice:(IHSDevice *)ihs accelerometer3AxisDataChanged:(IHSAHRS3AxisStruct)data
{
    if(_ihsDevice.connectionState == IHSDeviceConnectionStateConnected)
    {
        // Pseudo sensor fusion
        NSArray *obs = [NSArray arrayWithObjects:
                        [NSNumber numberWithFloat:_ihsDevice.accelerometerData.x],
                        [NSNumber numberWithFloat:_ihsDevice.accelerometerData.y],
                        [NSNumber numberWithFloat:_ihsDevice.accelerometerData.z],
                        [NSNumber numberWithFloat:_ihsDevice.pitch/90], // values from -1 to 1
                        [NSNumber numberWithFloat:_ihsDevice.yaw/360], // values from -1 to 1
                        [NSNumber numberWithFloat:_ihsDevice.roll/90], nil]; // values from -1 to 1
        
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
                
                [_delegate smmDeviceManager:self gestureRecognized:result];
                
                [_accData removeAllObjects];
            }
        }
    }
}


@end
