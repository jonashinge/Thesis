//
//  MainViewController.m
//  AudioGrid 3D
//
//  Created by Martin Lobger on 13/02/14.
//  Copyright (c) 2014 GN Store Nord A/S. All rights reserved.
//

#import "MainViewController.h"
#import "AudioSource.h"
#import "AudioSoundAnnotation.h"
#import "AudioListenerAnnotation.h"

#import <QuartzCore/QuartzCore.h>

@interface MainViewController () <IHSDeviceDelegate, IHSSensorsDelegate, IHSAudio3DGridModelDelegate, IHSAudio3DGridViewDelegate>

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Logo button will appear when we are connected to a headset
    self.ihsLogo.alpha = 0.0;

    // Create an instance of IHSDevice, set it up and provide API Key
    // The API Key can be obtained from https://developer.intelligentheadset.com
    NSString* preferredDevice = [[NSUserDefaults standardUserDefaults] stringForKey:@"preferredDevice"];
    self.ihsDevice = [[IHSDevice alloc] initWithPreferredDevice:preferredDevice];
    self.ihsDevice.deviceDelegate = self;
    self.ihsDevice.sensorsDelegate = self;
    [self.ihsDevice provideAPIKey:@"T+fbrp58/k/AUG/VnGbUQQCScTzMgKeWrrJ0pgH92W0="];
    [self.ihsDevice connect];

    // Setup audio 3d grid view and model.
    // The gridBounds property is an expression for how big in a physical world
    // the gridview should be. This has nothing to do with how big the gridview is on screen.
    // In this example there are 20 meters from left to right. This has an effect on how
    // sounds are perceived over distance.
    self.audioGrid.delegate = self;
    self.audioGrid.gridBounds = CGRectMake(-10000, -10000, 20000, 20000); // 20x20 meters - center @ 0,0
    self.audioGrid.listenerAnnotation = [[AudioListenerAnnotation alloc] init];
    self.audioGrid.audioModel = [[IHSAudio3DGridModel alloc] init];
    self.audioGrid.audioModel.delegate = self;
    [self loadSounds];
}


- (void)loadSounds
{
    AudioSource* audioSource;

    audioSource = [[AudioSource alloc] initWithSound:@"helicopter" andImage:@"helicopter.png"];
    audioSource.position = CGPointMake(-6000, 5000);
    audioSource.sound.repeats = YES;
    [self.audioGrid.audioModel addSource:audioSource];

    audioSource = [[AudioSource alloc] initWithSound:@"car" andImage:@"car.png"];
    audioSource.position = CGPointMake(6000, 5000);
    audioSource.sound.repeats = YES;
    [self.audioGrid.audioModel addSource:audioSource];

    audioSource = [[AudioSource alloc] initWithSound:@"running" andImage:@"running.png"];
    audioSource.position = CGPointMake(0000, -5500);
    audioSource.sound.repeats = YES;
    [self.audioGrid.audioModel addSource:audioSource];
}


#pragma mark - Interface Builder Action

- (IBAction)toggelPlayPause:(id)sender
{
    // Simple play/pause toggling
    if (self.ihsDevice.isPlaying) {
        [self.ihsDevice pause];
    }
    else {
        [self.ihsDevice play];
    }
}


#pragma mark - IHSDeviceDelegate

- (void)ihsDevice:(IHSDevice*)ihs connectedStateChanged:(IHSDeviceConnectionState)connectionState
{
    // Here we will get information about the connection state.
    switch (connectionState) {
        case IHSDeviceConnectionStateConnecting:
            // Once we have initiated a connection to a headset,
            // the state will change to "Connecting".
            // We will show a transparent logo while in this state.
            self.ihsLogo.alpha = 0.25;
            break;
        case IHSDeviceConnectionStateConnected:
            // When we are fully connected, we will show an opaque logo
            // and start playback of any loaded sounds.
            self.ihsLogo.alpha = 1.0;
            [self.ihsDevice play];
            // Save the preferred device, so we can connect to the same headset next time.
            [[NSUserDefaults standardUserDefaults] setObject:self.ihsDevice.preferredDevice forKey:@"preferredDevice"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        default:
            // In any other state, we will hide the logo.
            self.ihsLogo.alpha = 0.0;
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
    self.audioGrid.audioModel.listenerHeading = heading;
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
