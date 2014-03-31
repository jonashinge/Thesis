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
#import "DTWRecognizer.h"
#import "AudioListenerAnnotation.h"
#import "PersistencyManager.h"
#import "Playlist.h"
#import "Track.h"

#import <AVFoundation/AVFoundation.h>
#import <IHS/IHS.H>
#import <TSMessages/TSMessage.h>
#import <MMDrawerController/MMDrawerController.h>
#import <MMDrawerController/MMDrawerBarButtonItem.h>
#import <MMDrawerController/UIViewController+MMDrawerController.h>

@interface AudioMenuViewController () <SMMDeviceManagerDelegate, IHS3DAudioDelegate, IHSAudio3DGridModelDelegate, IHSAudio3DGridViewDelegate>

/*@property BOOL recordingGesture;
@property UIButton *btnRecordGesture;
@property NSMutableArray *recording;
@property NSMutableArray *accData;*/
@property (strong, nonatomic) DTWRecognizer *recognizer;
@property (strong, nonatomic) IHSAudio3DGridView *view3DAudioGrid;
@property (strong, nonatomic) UILabel *lblGestureStatus;

@property (readonly) int audioMenuState;

enum{ MENU_ACTIVATED, MENU_HOME, MENU_ALBUM, PLAYING_TRACK };

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAudioMenu) name:TRACK_NUMBER_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAudioMenu) name:ACTIVE_PLAYLIST_UPDATED object:nil];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Setup audio 3d grid view and model.
    // The gridBounds property is an expression for how big in a physical world
    // the gridview should be. This has nothing to do with how big the gridview is on screen.
    // In this example there are 20 meters from left to right. This has an effect on how
    // sounds are perceived over distance.
    _view3DAudioGrid = [[IHSAudio3DGridView alloc] initWithFrame:CGRectMake(0, 0, 800, 800)];
    [self.view addSubview:_view3DAudioGrid];
    _view3DAudioGrid.delegate = self;
    _view3DAudioGrid.gridBounds = CGRectMake(-10000, -10000, 20000, 20000); // 20x20 meters - center @ 0,0
    _view3DAudioGrid.listenerAnnotation = [[AudioListenerAnnotation alloc] init];
    _view3DAudioGrid.audioModel = [[IHSAudio3DGridModel alloc] init];
    _view3DAudioGrid.audioModel.delegate = self;
    [self loadSounds];
    
    // Navigation setup
    /*[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIFont fontWithName:@"Helvetica-Light" size:20], NSFontAttributeName, nil]];
    [self.navigationController.navigationBar.topItem setTitle:@"Spatial Music Menu"];*/
    [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0x306e73)];
    [self.navigationController.navigationBar setTranslucent:NO];
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(rightDrawerButtonPress:)]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    // Setup controls (bottom menu)
    UIView *controls = [[UIView alloc] initWithFrame:CGRectMake(0, 800, 800, 400)];
    [controls setBackgroundColor:UIColorFromRGB(0x306e73)];
    
    UILabel *lblMoving = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, 280, 50)];
    [lblMoving setFont:[UIFont fontWithName:@"Helvetica-Light" size:20]];
    [lblMoving setTextColor:[UIColor whiteColor]];
    [lblMoving setText:@"Moving head while rotating"];
    [controls addSubview:lblMoving];
    
    UISwitch *switchMoving = [[UISwitch alloc] initWithFrame:CGRectMake(290, 30, 80, 30)];
    [controls addSubview:switchMoving];
    
    UIButton *btnReset = [[UIButton alloc] initWithFrame:CGRectMake(30, 80, 200, 50)];
    [btnReset setTitle:@"Reset positions" forState:UIControlStateNormal];
    [btnReset setBackgroundColor:UIColorFromRGB(0xff5335)];
    [btnReset.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:20]];
    [controls addSubview:btnReset];
    
    _lblGestureStatus = [[UILabel alloc] initWithFrame:CGRectMake(410, 35, 325, 95)];
    [_lblGestureStatus setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.1]];
    [_lblGestureStatus setTextAlignment:NSTextAlignmentCenter];
    [_lblGestureStatus setFont:[UIFont fontWithName:@"Helvetica-Light" size:30]];
    [_lblGestureStatus setTextColor:[UIColor whiteColor]];
    [_lblGestureStatus setText:@"__"];
    [controls addSubview:_lblGestureStatus];
    
    [self.view addSubview:controls];
    
    // Device manager
    SMMDeviceManager *manager = APP_DELEGATE.smmDeviceManager;
    manager.delegate = self;
    
    // Init audio menu
    [self resetAudioMenu];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetAudioMenu
{
    [self changeAudioMenuState:MENU_HOME];
}

- (void)initMenuWithTracks:(NSArray *)tracks AndLimit:(int)limit
{
    for (int i=0; i<[tracks count]; i++) {
        if(i < limit)
        {
            Track *track = [tracks objectAtIndex:i];
            DEBUGLog(@"Place audio source %@",track.title);
        }
    }
}

- (void)changeAudioMenuState:(int)state
{
    _audioMenuState = state;
    
    switch (state) {
        case MENU_ACTIVATED:
        {
            // 3 sec limbo
            break;
        }
        case MENU_HOME:
        {
            Playlist *pl = [APP_DELEGATE.persistencyManager getActivePlaylist];
            [self initMenuWithTracks:pl.tracks AndLimit:APP_DELEGATE.persistencyManager.trackNumber];
            break;
        }
        case MENU_ALBUM:
        {
            break;
        }
        case PLAYING_TRACK:
        {
            break;
        }
        default:
            break;
    }
}

- (void)loadSounds
{
    AudioSource* audioSource;
    
    audioSource = [[AudioSource alloc] initWithSound:@"track_converted" andImage:@"daftpunk.jpg"];
    audioSource.position = CGPointMake(0, 3500);
    audioSource.sound.repeats = YES;
    [_view3DAudioGrid.audioModel addSource:audioSource];
    
    audioSource = [[AudioSource alloc] initWithSound:@"test2@44100" andImage:@"daftpunk.jpg"];
    audioSource.position = CGPointMake(0, -3500);
    audioSource.sound.repeats = YES;
    [_view3DAudioGrid.audioModel addSource:audioSource];
    
    audioSource = [[AudioSource alloc] initWithSound:@"test3@44100" andImage:@"eminem.jpg"];
    audioSource.position = CGPointMake(3500, 0);
    audioSource.sound.repeats = YES;
    [_view3DAudioGrid.audioModel addSource:audioSource];
    
    audioSource = [[AudioSource alloc] initWithSound:@"test4@44100" andImage:@"kingsofleon.jpg"];
    audioSource.position = CGPointMake(-3500, 0);
    audioSource.sound.repeats = YES;
    [_view3DAudioGrid.audioModel addSource:audioSource];
}

/*- (void)btnRecordDown
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
}*/


#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)rightDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}


#pragma mark - SMMDeviceManagerDelegate

- (void)smmDeviceManager:(SMMDeviceManager *)manager fusedHeadingChanged:(float)heading
{
    // Apply the heading to our audio grid model.
    // See IHSDevice.fusedHeading for more info.
    _view3DAudioGrid.audioModel.listenerHeading = heading + 90;
    
    // setting position
    float x = 0 + (3000*cos((heading*M_PI)/180));
    float y = 0 - (3000*sin((heading*M_PI)/180));
    _view3DAudioGrid.audioModel.listenerPosition = CGPointMake(x, y);
}


#pragma mark - IHSAudio3DGridModelDelegate

- (void)audioModel:(IHSAudio3DGridModel*)audioModel didAddSource:(id<IHSAudio3DGridModelSource>)source
{
    // An audio source was added to the audio grid model.
    // We will add it to the IHS Device now, but we could wait
    // if we e.g. do not want to playback sounds from this model yet.
    [APP_DELEGATE.smmDeviceManager addSound:source.sound];
}

- (void)audioModel:(IHSAudio3DGridModel*)audioModel willRemoveSource:(id<IHSAudio3DGridModelSource>)source
{
    // An audio source was removed from the model.
    // Remove it from the IHS Device. The IHS Device accepts
    // removing sounds that was never added or previously removed.
    [APP_DELEGATE.smmDeviceManager removeSound:source.sound];
}

- (void)audioModel:(IHSAudio3DGridModel *)audioModel didUpdateListenerHeading:(CGFloat)heading
{
    // The audio grid model changed heading.
    // Update the IHS Device player heading accordingly.
    // We adjust the player heading based on the audio grid model,
    // instead of the fused heading. That way we decouple the headset
    // and the audio grid model, if the model was to be manipulated by
    // another source than the fused heading.
    APP_DELEGATE.smmDeviceManager.playerHeading = heading;
}


#pragma mark - IHSAudio3DGridViewDelegate

- (IHSAudio3DGridSoundAnnotation*)audioGridView:(IHSAudio3DGridView*)audioGridView audioAnnotationForAudioSource:(id<IHSAudio3DGridModelSource>)audioSource
{
    // The audio grid view need an annotation to represent the audioSource
    AudioSoundAnnotation* annotation = [[AudioSoundAnnotation alloc] initWithAudioSource:audioSource];
    return annotation;
}



@end
