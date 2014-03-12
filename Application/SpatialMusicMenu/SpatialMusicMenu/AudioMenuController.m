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

#import <AVFoundation/AVFoundation.h>
#import <IHS/IHS.H>
#import <TSMessages/TSMessage.h>

@interface AudioMenuController () <IHSDeviceDelegate, IHSSensorsDelegate, IHS3DAudioDelegate, IHSAudio3DGridModelDelegate, IHSAudio3DGridViewDelegate>

@property (nonatomic, strong) IHSDevice* ihsDevice;

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
    
    // Create an instance of IHSDevice, set it up and provide API Key
    // The API Key can be obtained from https://developer.intelligentheadset.com
    NSString* preferredDevice = [[NSUserDefaults standardUserDefaults] stringForKey:@"preferredDevice"];
    self.ihsDevice = [[IHSDevice alloc] initWithPreferredDevice:preferredDevice];
    self.ihsDevice.deviceDelegate = self;
    self.ihsDevice.sensorsDelegate = self;
    [self.ihsDevice provideAPIKey:@"3tXvpy2WbqLIkaxaiEtYt2DF8sjf8rt0lOGqjDNesGG+/gFDZ6Rpjs19KFRZALrvzMWJQuJfdjtNI//k0Gl2cA=="];
    [self.ihsDevice connect];
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


#pragma mark - IHSDeviceDelegate

- (void)ihsDevice:(IHSDevice*)ihs connectedStateChanged:(IHSDeviceConnectionState)connectionState
{
    NSString* connectionString = [NSString stringFromIHSDeviceConnectionState:connectionState];
    NSString* deviceName = self.ihsDevice.name ?: @"Headset X";
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


#pragma mark - IHSAudio3DGridModelDelegate

- (void)audioModel:(IHSAudio3DGridModel*)audioModel didAddSource:(id<IHSAudio3DGridModelSource>)source
{
    // An audio source was added to the audio grid model.
    // We will add it to the IHS Device now, but we could wait
    // if we e.g. do not want to playback sounds from this model yet.
    [self.ihsDevice addSound:source.sound];
}


- (void)audioModel:(IHSAudio3DGridModel*)audioModel willRemoveSource:(id<IHSAudio3DGridModelSource>)source
{
    // An audio source was removed from the model.
    // Remove it from the IHS Device. The IHS Device accepts
    // removing sounds that was never added or previously removed.
    [self.ihsDevice removeSound:source.sound];
}


- (void)audioModel:(IHSAudio3DGridModel *)audioModel didUpdateListenerHeading:(CGFloat)heading
{
    // The audio grid model changed heading.
    // Update the IHS Device player heading accordingly.
    // We adjust the player heading based on the audio grid model,
    // instead of the fused heading. That way we decouple the headset
    // and the audio grid model, if the model was to be manipulated by
    // another source than the fused heading.
    self.ihsDevice.playerHeading = heading;
}


#pragma mark - IHSAudio3DGridViewDelegate

- (IHSAudio3DGridSoundAnnotation*)audioGridView:(IHSAudio3DGridView*)audioGridView audioAnnotationForAudioSource:(id<IHSAudio3DGridModelSource>)audioSource
{
    // The audio grid view need an annotation to represent the audioSource
    AudioSoundAnnotation* annotation = [[AudioSoundAnnotation alloc] initWithAudioSource:audioSource];
    return annotation;
}



@end
