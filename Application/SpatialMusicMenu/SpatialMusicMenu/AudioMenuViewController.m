//
//  SMMViewController.m
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 07/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "AudioMenuViewController.h"

#import "AudioMenuView.h"
#import "AppDelegate.h"
#import "NSString+IHSDeviceConnectionState.h"
#import "AudioSource.h"
#import "AudioSoundAnnotation.h"
#import "AudioListenerAnnotation.h"
#import "MusicAPI.h"
#import "DTWRecognizer.h"
#import "SMMDeviceManager.h"

#import <AVFoundation/AVFoundation.h>
#import <IHS/IHS.H>
#import <TSMessages/TSMessage.h>

@interface AudioMenuViewController () <SMMDeviceManagerDelegate, IHS3DAudioDelegate, IHSAudio3DGridModelDelegate, IHSAudio3DGridViewDelegate>

@property (nonatomic, strong) IHSDevice* ihsDevice;
@property BOOL recordingGesture;
@property UIButton *btnRecordGesture;
@property NSMutableArray *recording;
@property NSMutableArray *accData;
@property (strong, nonatomic) DTWRecognizer *recognizer;

@end

// Set the DEBUG_PRINTOUT define to '1' to enable printouts of the received values
#define DEBUG_PRINTOUT      1

#if !DEBUG_PRINTOUT
#define DEBUGLog(format, ...)
#else
#define DEBUGLog(format, ...) NSLog(format, ## __VA_ARGS__)
#endif

@implementation AudioMenuViewController

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
    
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Menu" image:nil tag:0];
	
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
    
    // Device manager
    SMMDeviceManager *manager = APP_DELEGATE.smmDeviceManager;
    manager.delegate = self;
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
        
        [_recognizer addSequence:_recording WithLabel:@"NOD_TEST"];
        
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


#pragma mark - SMMDeviceManagerDelegate

- (void)smmDeviceManager:(SMMDeviceManager *)manager fusedHeadingChanged:(float)heading
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
