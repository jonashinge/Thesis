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
#import "Gesture.h"

@interface SMMDeviceManager () <IHSDeviceDelegate, IHSSensorsDelegate, IHSButtonDelegate>

@property (strong, nonatomic) IHSDevice *ihsDevice;
@property (strong, nonatomic) DTWRecognizer *recognizer;
@property (strong, nonatomic) NSMutableArray *accData;
@property NSMutableArray *recording;
@property int accDataCounter;
//@property float recentHeading;

// Set the DEBUG_PRINTOUT define to '1' to enable printouts of the received values
#define DEBUG_PRINTOUT      1

#if !DEBUG_PRINTOUT
#define DEBUGLog(format, ...)
#else
#define DEBUGLog(format, ...) NSLog(format, ## __VA_ARGS__)
#endif

@end

const int WINDOW_SIZE = 30;

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
        _ihsDevice.buttonDelegate = self;
        
        // Setup recognizer and recording array
        _recognizer = [[DTWRecognizer alloc] initWithDimension:3 GlobalThreshold:0.05 FirstThreshold:0.05 AndMaxSlope:2];
        _accData = [[NSMutableArray alloc] init];
        _recording = [[NSMutableArray alloc] init];
        
        //_recentHeading = _ihsDevice.fusedHeading;
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

- (void)playAudio
{
    [_ihsDevice play];
}

- (void)stopAudio
{
    [_ihsDevice stop];
}

- (void)addSound:(IHSAudio3DSound *)sound
{
    [_ihsDevice addSound:sound];
}

- (void)removeSound:(IHSAudio3DSound *)sound
{
    [_ihsDevice removeSound:sound];
}

- (void)setPlayerHeading:(float)playerHeading
{
    [_ihsDevice setPlayerHeading:playerHeading];
}

- (float)playerHeading
{
    //DEBUGLog(@"Fused heading: %f", _ihsDevice.fusedHeading);
    //return _ihsDevice.fusedHeading;
    return _ihsDevice.yaw;
}

- (void)startRecordingGesture
{
    _recording = [[NSMutableArray alloc] init];
    
    _isRecordingGesture = YES;
}

- (NSArray *)stopRecordingGesture
{
    _isRecordingGesture = NO;
    
    NSArray *cleanedData = [self cleanRecordingGesture:_recording];
    
    DEBUGLog(@"Not cleaned data (count %d): %@", [_recording count], _recording);
    DEBUGLog(@"Cleaned data (count %d): %@", [cleanedData count], cleanedData);
    
    return cleanedData;
}

- (NSArray *)cleanRecordingGesture:(NSMutableArray *)data
{
    NSMutableArray *cleanedData = [NSMutableArray arrayWithArray:data];
    
    float diff = 0.01;
    
    // Removing start noise
    NSArray *startObs = [data objectAtIndex:0];
    for (int i=1; i<[data count]; i++) {
        NSArray *obs = [data objectAtIndex:i];
        int equalItems = 0;
        for (int j=0; j<[obs count]; j++) {
            if( fabsf(([[startObs objectAtIndex:j] floatValue] - [[obs objectAtIndex:j] floatValue])) < diff)
            {
                equalItems += 1;
            }
        }
        if(equalItems == [obs count])
        {
            DEBUGLog(@"Removing object from start: %@ compaired to: %@", obs, startObs);
            [cleanedData removeObjectAtIndex:0];
        }
        else break;
    }
    
    // Removing end noise
    NSArray *endObs = [data objectAtIndex:[data count]-1];
    for (int i=[data count]-2; i>0; i--) {
        NSArray *obs = [data objectAtIndex:i];
        int equalItems = 0;
        for (int j=0; j<[obs count]; j++) {
            if( fabsf(([[endObs objectAtIndex:j] floatValue] - [[obs objectAtIndex:j] floatValue])) < diff)
            {
                equalItems += 1;
            }
        }
        if(equalItems == [obs count])
        {
            DEBUGLog(@"Removing object from end: %@ compaired to: %@", obs, endObs);
            [cleanedData removeObjectAtIndex:[cleanedData count]-1];
        }
        else break;
    }
    
    return cleanedData;
}

- (void)updateGestures:(NSArray *)gestures
{
    [_recognizer clearAllKnownSequences];
    
    for (Gesture *gest in gestures) {
        [_recognizer addKnownSequence:gest.data WithLabel:gest.label];
    }
    
    // TEMP, accuracy
    DEBUGLog(@"DTW Accuracy: %f",[_recognizer outputAccuracy]);
}


#pragma mark - IHSButtonDelegate

- (void)ihsDevice:(IHSDevice *)ihs didPressIHSButton:(IHSButton)button withEvent:(IHSButtonEvent)event fromSource:(IHSButtonSource)source
{
    if(button == IHSButtonRight)
    {
        if([_delegate respondsToSelector:@selector(smmDeviceManager:rightButtonPressed:)])
        {
            [_delegate smmDeviceManager:self rightButtonPressed:event];
        }
    }
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

- (void)ihsDevice:(IHSDevice *)ihs yawChanged:(float)yaw
{
    //DEBUGLog(@"GYRO: Rotation value: %f",yaw);
    if([_delegate respondsToSelector:@selector(smmDeviceManager:gyroHeadingChanged:)])
    {
        [_delegate smmDeviceManager:self gyroHeadingChanged:yaw];
    }
}

- (void)ihsDevice:(IHSDevice *)ihs accelerometer3AxisDataChanged:(IHSAHRS3AxisStruct)data
{
    if(_ihsDevice.connectionState == IHSDeviceConnectionStateConnected)
    {
        // Need rotation parameter
        // Idea: Take the difference between new and last input
        // E.g. (using fused heading) 100-99=1, 99-98=1, 99-100=-1 -> time interval 1, 1, -1
        //float diffHeading = _recentHeading - ihs.fusedHeading;
        //_recentHeading = ihs.fusedHeading;
        
        // Pseudo sensor fusion
        /*NSArray *obs = [NSArray arrayWithObjects:
                        [NSNumber numberWithFloat:_ihsDevice.accelerometerData.x],
                        [NSNumber numberWithFloat:_ihsDevice.accelerometerData.y],
                        [NSNumber numberWithFloat:_ihsDevice.accelerometerData.z],
                        [NSNumber numberWithFloat:_ihsDevice.pitch/90], // values from -1 to 1
                        [NSNumber numberWithFloat:_ihsDevice.roll/90], // values from -1 to 1
                        [NSNumber numberWithFloat:diffHeading/360], nil]; // values from 0 to 1*/
        
        // Only gyro
        /*NSArray *obs = [NSArray arrayWithObjects:
                        [NSNumber numberWithFloat:_ihsDevice.pitch/90], // values from -1 to 1
                        [NSNumber numberWithFloat:_ihsDevice.roll/90], // values from -1 to 1
                        [NSNumber numberWithFloat:diffHeading/360], nil]; // values from 0 to 1*/
        
        // Only pitch,roll
        /*NSArray *obs = [NSArray arrayWithObjects:
                        [NSNumber numberWithFloat:_ihsDevice.pitch/90], // values from -1 to 1
                        [NSNumber numberWithFloat:_ihsDevice.roll/90], nil]; // values from 0 to 1*/
        
        // Only acc. data
        NSArray *obs = [NSArray arrayWithObjects:
         [NSNumber numberWithFloat:_ihsDevice.accelerometerData.x],
         [NSNumber numberWithFloat:_ihsDevice.accelerometerData.y],
         [NSNumber numberWithFloat:_ihsDevice.accelerometerData.z], nil];
        
        //DEBUGLog(@"Fusion data: %@",obs);
        _accDataCounter += 1;
        
        // Record gesture
        if(_isRecordingGesture)
        {
            _accDataCounter = 0;
            DEBUGLog(@"Fusion data: %@",obs);
            [_recording addObject:obs];
        }
        // Recognize gesture
        else if(_accDataCounter > 0)
        {
            [_accData addObject:obs];
            // Remove the oldest observation
            if([_accData count] > 100)
            {
                [_accData removeObjectAtIndex:0];
            }
            if(_accDataCounter == WINDOW_SIZE)
            {
                DEBUGLog(@"WINDOW_SIZE reached and acc data count:%d - now recognizing...",[_accData count]);
                NSDictionary *result = [_recognizer recognizeSequence:_accData];
                NSString *classResult = [result objectForKey:@"class"];
                if(![classResult isEqual: @"__UNKNOWN"])
                {
                    int idx = [[[_recognizer recognizeSequence:_accData] objectForKey:@"id"] intValue];
                    DEBUGLog(@"Recognized gesture: %@ with id:%d",result, idx);
                    
                    if([_delegate respondsToSelector:@selector(smmDeviceManager:gestureRecognized:)])
                    {
                        [_delegate smmDeviceManager:self gestureRecognized:result];
                    }
                    
                    [_accData removeAllObjects];
                    
                    // Longer interval before trying to recognize again, e.g. avoiding a "double nod"
                    _accDataCounter = -50;
                    return;
                }
                _accDataCounter = 0;
            }
            
        }
    }
}


@end
