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
#import "Album.h"

#import <AVFoundation/AVFoundation.h>
#import <IHS/IHS.H>
#import <TSMessages/TSMessage.h>
#import <MMDrawerController/MMDrawerController.h>
#import <MMDrawerController/MMDrawerBarButtonItem.h>
#import <MMDrawerController/UIViewController+MMDrawerController.h>

@interface AudioMenuViewController () <IHS3DAudioDelegate, IHSAudio3DGridModelDelegate, IHSAudio3DGridViewDelegate>

@property (strong, nonatomic) DTWRecognizer *recognizer;
@property (strong, nonatomic) IHSAudio3DGridView *view3DAudioGrid;
@property (strong, nonatomic) UIView *viewLblGestureBackground;
@property (strong, nonatomic) UILabel *lblGestureStatus;
@property (strong, nonatomic) UILabel *lblState;
@property (strong, nonatomic) UILabel *lblArea;
@property (strong, nonatomic) UILabel *lblDegreeSpan;
@property (strong, nonatomic) UILabel *lblFront;
@property (strong, nonatomic) UISwitch *switchMoving;

@property (nonatomic) float area;
@property (nonatomic) float degreeSpan;
@property (nonatomic) float front;

@property (readonly) int audioMenuState;
@property (nonatomic) float headingCorrection;
@property (strong, nonatomic) NSMutableArray *soundAnnotations;
@property (nonatomic) int selectedTrackIndex;
@property (strong, nonatomic) NSArray *selectedPlaylistTracks;
@property (strong, nonatomic) NSArray *selectedAlbumTracks;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headsetConnected) name:HEADSET_CONNECTED object:nil];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _soundAnnotations = [[NSMutableArray alloc] init];
    
    _area = 100000; // e.g. 20000 = 20x20m
    _degreeSpan = 100;
    _front = 7000; // e.g. 1000 = 1m in front of user
    
    // Setup audio 3d grid view and model.
    // The gridBounds property is an expression for how big in a physical world
    // the gridview should be. This has nothing to do with how big the gridview is on screen.
    // In this example there are 20 meters from left to right. This has an effect on how
    // sounds are perceived over distance.
    _view3DAudioGrid = [[IHSAudio3DGridView alloc] initWithFrame:CGRectMake(0, 0, 800, 800)];
    [self.view addSubview:_view3DAudioGrid];
    _view3DAudioGrid.delegate = self;
    _view3DAudioGrid.listenerAnnotation = [[AudioListenerAnnotation alloc] init];
    _view3DAudioGrid.audioModel = [[IHSAudio3DGridModel alloc] init];
    _view3DAudioGrid.audioModel.delegate = self;
    //[self loadSounds];
    
    _lblState = [[UILabel alloc] initWithFrame:CGRectMake(530, 730, 200, 50)];
    [_lblState setFont:[UIFont fontWithName:@"Helvetica-Light" size:26]];
    [_lblState setTextAlignment:NSTextAlignmentRight];
    [_lblState setTextColor:[UIColor darkTextColor]];
    [_lblState setText:@"__"];
    [self.view addSubview:_lblState];
    
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
    
    _switchMoving = [[UISwitch alloc] initWithFrame:CGRectMake(290, 30, 80, 30)];
    [controls addSubview:_switchMoving];
    [_switchMoving setOn:YES];
    
    UIButton *btnCalibrate = [[UIButton alloc] initWithFrame:CGRectMake(30, 80, 120, 50)];
    [btnCalibrate setTitle:@"Calibrate" forState:UIControlStateNormal];
    [btnCalibrate setBackgroundColor:UIColorFromRGB(0xff5335)];
    [btnCalibrate.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:20]];
    [controls addSubview:btnCalibrate];
    [btnCalibrate addTarget:self action:@selector(btnCalibratePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnHome = [[UIButton alloc] initWithFrame:CGRectMake(200, 80, 120, 50)];
    [btnHome setTitle:@"Home" forState:UIControlStateNormal];
    [btnHome setBackgroundColor:UIColorFromRGB(0xff5335)];
    [btnHome.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:20]];
    [controls addSubview:btnHome];
    [btnHome addTarget:self action:@selector(btnHomePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _viewLblGestureBackground = [[UIView alloc] initWithFrame:CGRectMake(410, 35, 325, 95)];
    [_viewLblGestureBackground setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.1]];
    _lblGestureStatus = [[UILabel alloc] initWithFrame:CGRectMake(410, 35, 325, 95)];
    [_lblGestureStatus setBackgroundColor:[UIColor clearColor]];
    [_lblGestureStatus setTextAlignment:NSTextAlignmentCenter];
    [_lblGestureStatus setFont:[UIFont fontWithName:@"Helvetica-Light" size:30]];
    [_lblGestureStatus setTextColor:[UIColor whiteColor]];
    [_lblGestureStatus setText:@"__"];
    [_lblGestureStatus setAlpha:0];
    [controls addSubview:_viewLblGestureBackground];
    [controls addSubview:_lblGestureStatus];
    
    [self.view addSubview:controls];
    
    // Steppers
    UIStepper *stepperArea = [[UIStepper alloc] initWithFrame:CGRectMake(20, 630, 100, 60)];
    [stepperArea setMaximumValue:1000000];
    [stepperArea setMinimumValue:10000];
    [stepperArea setStepValue:10000];
    [stepperArea setValue:_area];
    [stepperArea setTintColor:[UIColor darkGrayColor]];
    [stepperArea addTarget:self action:@selector(stepperAreaChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:stepperArea];
    
    _lblArea = [[UILabel alloc] initWithFrame:CGRectMake(125, 620, 280, 50)];
    [_lblArea setFont:[UIFont fontWithName:@"Helvetica-Light" size:18]];
    [_lblArea setTextColor:[UIColor darkTextColor]];
    int val = [self convertToMeters:_area];
    [_lblArea setText:[NSString stringWithFormat:@"Area: %dx%dm",val, val]];
    [self.view addSubview:_lblArea];
    
    UIStepper *stepperDegreeSpan = [[UIStepper alloc] initWithFrame:CGRectMake(20, 690, 100, 60)];
    [stepperDegreeSpan setMaximumValue:180];
    [stepperDegreeSpan setMinimumValue:40];
    [stepperDegreeSpan setStepValue:10];
    [stepperDegreeSpan setValue:_degreeSpan];
    [stepperDegreeSpan setTintColor:[UIColor darkGrayColor]];
    [stepperDegreeSpan addTarget:self action:@selector(stepperDegreeSpanChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:stepperDegreeSpan];
    
    _lblDegreeSpan = [[UILabel alloc] initWithFrame:CGRectMake(125, 680, 280, 50)];
    [_lblDegreeSpan setFont:[UIFont fontWithName:@"Helvetica-Light" size:18]];
    [_lblDegreeSpan setTextColor:[UIColor darkTextColor]];
    [_lblDegreeSpan setText:[NSString stringWithFormat:@"Degree span: %f",_degreeSpan]];
    [self.view addSubview:_lblDegreeSpan];
    
    UIStepper *stepperFront = [[UIStepper alloc] initWithFrame:CGRectMake(20, 750, 100, 60)];
    [stepperFront setMaximumValue:100000];
    [stepperFront setMinimumValue:1000];
    [stepperFront setStepValue:1000];
    [stepperFront setValue:_front];
    [stepperFront setTintColor:[UIColor darkGrayColor]];
    [stepperFront addTarget:self action:@selector(stepperFrontChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:stepperFront];
    
    _lblFront = [[UILabel alloc] initWithFrame:CGRectMake(125, 740, 280, 50)];
    [_lblFront setFont:[UIFont fontWithName:@"Helvetica-Light" size:18]];
    [_lblFront setTextColor:[UIColor darkTextColor]];
    int valFront = [self convertToMeters:_front];
    [_lblFront setText:[NSString stringWithFormat:@"User distance: %dm",valFront]];
    [self.view addSubview:_lblFront];
    
    // Init audio menu
    [self resetAudioMenu];
    
    APP_DELEGATE.smmDeviceManager.delegate = self;
    
    // Set init values
    _headingCorrection = 114;
    _selectedTrackIndex = 0;
    [self changeAudioMenuState:MENU_HOME];
}

- (void)btnCalibratePressed:(id)btn
{
    _headingCorrection = APP_DELEGATE.smmDeviceManager.playerHeading;
}

- (void)btnHomePressed:(id)btn
{
    [self changeAudioMenuState:MENU_HOME];
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

- (void)headsetConnected
{
    if(_audioMenuState == MENU_HOME || _audioMenuState == MENU_ALBUM)
    {
        [APP_DELEGATE.smmDeviceManager playAudio];
    }
}

- (void)resetAudioMenu
{
    if(_audioMenuState != PLAYING_TRACK)
    {
        [self changeAudioMenuState:MENU_HOME];
    }
}

- (void)initMenuWithTracks:(NSArray *)tracks AndLimit:(float)limit
{
    [APP_DELEGATE.smmDeviceManager stopAudio];
    
    for (AudioSoundAnnotation *anno in _view3DAudioGrid.soundAnnotations) {
        [_view3DAudioGrid removeAnnotation:anno];
        [anno.audioSource removeObserver:anno forKeyPath:@"position"];
    }
    [_view3DAudioGrid.audioModel removeAllSources];

    _view3DAudioGrid.gridBounds = CGRectMake(-_area/2, -_area/2, _area, _area); // 20x20 meters - center @ 0,0
    
    AudioSource* audioSource;
    for (int i=0; i<[tracks count]; i++)
    {
        if(i < limit)
        {
            float distance = [self correctedDistance];
            //float extra = DEGREE_SPAN/(limit*limit);
            float deg_pos = (270-_degreeSpan/2) + (_degreeSpan/limit)*i + _degreeSpan/limit/2;
            float x = 0 + (distance*cos((deg_pos*M_PI)/180));
            float y = 0 - (distance*sin((deg_pos*M_PI)/180));
            
            Track *track = [tracks objectAtIndex:i];
            
            audioSource = [[AudioSource alloc] initWithSound:track.itemId andImage:@"icon-music.png"];
            audioSource.position = CGPointMake(x, y);
            audioSource.sound.repeats = YES;
            [_view3DAudioGrid.audioModel addSource:audioSource];
            
            DEBUGLog(@"Place audio source %@",track.title);
        }
    }
    
    if(_audioMenuState == MENU_HOME || _audioMenuState == MENU_ALBUM)
    {
        [APP_DELEGATE.smmDeviceManager playAudio];
    }
}

- (void)changeAudioMenuState:(int)state
{
    _audioMenuState = state;
    
    DEBUGLog(@"Changing state to: %d", _audioMenuState);
    
    // Log
    NSString *logString = [NSString stringWithFormat:@"Change menu state: %@", [self translatedMenuState:state]];
    
    switch (state) {
        case MENU_ACTIVATED:
        {
            // 3 sec limbo getting the center direction, TODO
            _headingCorrection = APP_DELEGATE.smmDeviceManager.playerHeading;
            [APP_DELEGATE.deezerClient pausePlayback];
            [_lblState setText:@"Activated"];
            [self playSystemSoundWithName:@"activate"];
            break;
        }
        case MENU_HOME:
        {
            Playlist *pl = [APP_DELEGATE.persistencyManager getActivePlaylist];
            _selectedPlaylistTracks = [APP_DELEGATE.persistencyManager getAlbumdistinctRandomTracksFromPlaylist:pl];
            [self initMenuWithTracks:_selectedPlaylistTracks AndLimit:APP_DELEGATE.persistencyManager.trackNumber];
            [APP_DELEGATE.deezerClient pausePlayback];
            [_lblState setText:@"Home"];
            [self playSystemSoundWithName:@"home"];
            [APP_DELEGATE.smmDeviceManager playAudio];
            break;
        }
        case MENU_ALBUM:
        {
            Track *track = [_selectedPlaylistTracks objectAtIndex:_selectedTrackIndex];
            NSArray *tracks = [APP_DELEGATE.persistencyManager getRandomAlbumTracksForTrack:track];
            DEBUGLog(@"Album selected: %@", track.albumName);
            // Log
            logString = [NSString stringWithFormat:@"Change menu state: %@ (%@: %@)", [self translatedMenuState:state], track.artist, track.albumName];
            _selectedAlbumTracks = tracks;
            [self initMenuWithTracks:tracks AndLimit:APP_DELEGATE.persistencyManager.trackNumber];
            [_lblState setText:@"Album"];
            [self playSystemSoundWithName:@"album"];
            [APP_DELEGATE.smmDeviceManager playAudio];
            break;
        }
        case PLAYING_TRACK:
        {
            Track *track = [_selectedAlbumTracks objectAtIndex:_selectedTrackIndex];
            // Log
            logString = [NSString stringWithFormat:@"Change menu state: %@ (%@: %@)", [self translatedMenuState:state], track.artist, track.title];
            //[APP_DELEGATE.deezerClient playTrackWithId:track.itemId andStream:track.stream];
            [APP_DELEGATE.deezerClient playPreviewTrackWithId:track.itemId];
            [_lblState setText:@"Playing track"];
            [self playSystemSoundWithName:@"playing"];
            [APP_DELEGATE.smmDeviceManager stopAudio];
            break;
        }
        default:
            break;
    }
    
    [APP_DELEGATE.persistencyManager writeToLog:logString];
}

- (void)playSystemSoundWithName:(NSString*)name {
    NSError *error;
    NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:@"mp3"];
    
    [_audioPlayer stop];
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) {
        NSLog(@"Error playing sound '%@': %@", name, error);
        _audioPlayer = nil;
    }
    else {
        _audioPlayer.volume = 1.0;
        
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
    }
}

- (void)stepperAreaChanged:(id)stepper
{
    UIStepper *step = stepper;
    _area = [step value];
    int areaInMeters = [self convertToMeters:_area];
    
    // Update label
    [_lblArea setText:[NSString stringWithFormat:@"Area: %dx%dm",areaInMeters, areaInMeters]];
    
    Playlist *pl = [APP_DELEGATE.persistencyManager getActivePlaylist];
    [self initMenuWithTracks:pl.tracks AndLimit:APP_DELEGATE.persistencyManager.trackNumber];
}

- (void)stepperDegreeSpanChanged:(id)stepper
{
    UIStepper *step = stepper;
    _degreeSpan = [step value];
    
    // Update label
    [_lblDegreeSpan setText:[NSString stringWithFormat:@"Degree span: %f",_degreeSpan]];
    
    Playlist *pl = [APP_DELEGATE.persistencyManager getActivePlaylist];
    [self initMenuWithTracks:pl.tracks AndLimit:APP_DELEGATE.persistencyManager.trackNumber];
}

- (void)stepperFrontChanged:(id)stepper
{
    UIStepper *step = stepper;
    _front = [step value];
    int areaInMeters = [self convertToMeters:_front];
    
    // Update label
    [_lblFront setText:[NSString stringWithFormat:@"User distance: %dm",areaInMeters]];
}


#pragma mark - Button Handlers
-(void)leftDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)rightDrawerButtonPress:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}


#pragma mark - SMMDeviceManagerDelegate

- (void)smmDeviceManager:(SMMDeviceManager *)manager rightButtonPressed:(IHSButtonEvent)event
{
    [self changeAudioMenuState:MENU_HOME];
}

- (void)smmDeviceManager:(SMMDeviceManager *)manager gyroHeadingChanged:(float)heading
{
    float correctedHeading = heading - _headingCorrection;
    
    //DEBUGLog(@"Heading: %f",heading);
    //DEBUGLog(@"Heading correction: %f",_headingCorrection);
    
    // Apply the heading to our audio grid model.
    // See IHSDevice.fusedHeading for more info.
    correctedHeading = [self normalized360Degrees:correctedHeading];
    _view3DAudioGrid.audioModel.listenerHeading = correctedHeading;
    
    float listHeading = [self normalize180Degrees:correctedHeading];
    
    //float listHeading = _view3DAudioGrid.audioModel.listenerHeading;
    //listHeading = [self normalizedDegrees:listHeading];
    
    //DEBUGLog(@"List heading: %f",listHeading);
    
    // setting position
    if([_switchMoving isOn])
    {
        float front = [self correctedDistance]-_front;
        float x = 0 + (front*cos(((correctedHeading-90)*M_PI)/180));
        float y = 0 - (front*sin(((correctedHeading-90)*M_PI)/180));
        _view3DAudioGrid.audioModel.listenerPosition = CGPointMake(x, y);
    }
    else
    {
        _view3DAudioGrid.audioModel.listenerPosition = CGPointMake(0, 0);
    }
    
    // Updating current track "in focus" or selected
    float trackSpan = _degreeSpan / APP_DELEGATE.persistencyManager.trackNumber;
    float leftRange = 0 - _degreeSpan/2;
    if(_audioMenuState == MENU_HOME || _audioMenuState == MENU_ALBUM)
    {
        for (int i=0; i<APP_DELEGATE.persistencyManager.trackNumber; i++) {
            if(listHeading >= leftRange+(i*trackSpan) && listHeading < leftRange+((i+1)*trackSpan) &&
               i != _selectedTrackIndex)
            {
                _selectedTrackIndex = i;
                DEBUGLog(@"bigger than: %f, less than: %f", [self normalized360Degrees:leftRange+(i*trackSpan)], [self normalized360Degrees:leftRange+((i+1)*trackSpan)]);
                DEBUGLog(@"Playlist track index selected: %d", _selectedTrackIndex);
                for (int j=0; j<[_view3DAudioGrid.soundAnnotations count]; j++) {
                    AudioSoundAnnotation *anno = [_view3DAudioGrid.soundAnnotations objectAtIndex:j];
                    if(i == j)
                    {
                        [anno setSelected:YES];
                    }
                    else
                    {
                        [anno setSelected:NO];
                    }
                }
            }
        }
    }
}

- (void)smmDeviceManager:(SMMDeviceManager *)manager gestureRecognized:(NSDictionary *)result
{
    NSString *label = [result objectForKey:@"class"];
    
    // Log
    [APP_DELEGATE.persistencyManager writeToLog:[NSString stringWithFormat:@"Gesture recognized: %@", [APP_DELEGATE translatedLabel:label]]];
    
    [_lblGestureStatus setText:[APP_DELEGATE translatedLabel:label]];
    
    [UIView animateWithDuration:0.7 animations:^{
        _lblGestureStatus.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.7 animations:^{
            _lblGestureStatus.alpha = 0;
        }];
    }];
    
    // In limbo mode - go to home menu
    if(_audioMenuState == MENU_ACTIVATED)
    {
        if([label isEqualToString:@"NOD"])
        {
            [self changeAudioMenuState:MENU_HOME];
        }
        else if([label isEqualToString:@"SHAKE"])
        {
            [self changeAudioMenuState:PLAYING_TRACK];
        }
        else if([label isEqualToString:@"ACTIVATE"])
        {
            // calibrate direction
            _headingCorrection = APP_DELEGATE.smmDeviceManager.playerHeading;
        }
        
    }
    // Home - go to album
    else if(_audioMenuState == MENU_HOME)
    {
        if([label isEqualToString:@"NOD"])
        {
            [self changeAudioMenuState:MENU_ALBUM];
        }
        else if([label isEqualToString:@"ACTIVATE"])
        {
            // calibrate direction
            _headingCorrection = APP_DELEGATE.smmDeviceManager.playerHeading;
        }
    }
    // Album - go play that song
    else if(_audioMenuState == MENU_ALBUM)
    {
        if([label isEqualToString:@"NOD"])
        {
            [self changeAudioMenuState:PLAYING_TRACK];
        }
        else if([label isEqualToString:@"SHAKE"])
        {
            [self changeAudioMenuState:MENU_HOME];
        }
        else if([label isEqualToString:@"ACTIVATE"])
        {
            // calibrate direction
            _headingCorrection = APP_DELEGATE.smmDeviceManager.playerHeading;
        }
    }
    else if(_audioMenuState == PLAYING_TRACK)
    {
        if([label isEqualToString:@"ACTIVATE"])
        {
            [self changeAudioMenuState:MENU_ACTIVATED];
        }
    }
}

- (NSString *)translatedMenuState:(int)state
{
    NSString *returnVal = @"";
    
    switch (state) {
        case MENU_ACTIVATED:
        {
            returnVal = @"ACTIVATE";
            break;
        }
        case MENU_HOME:
        {
            returnVal = @"HOME";
            break;
        }
        case MENU_ALBUM:
        {
            returnVal = @"ALBUM";
            break;
        }
        case PLAYING_TRACK:
        {
            returnVal = @"PLAYING";
            break;
        }
        default:
            break;
    }
    
    return returnVal;
}

- (float)normalized360Degrees:(float)deg
{
    if(deg < 0)
    {
        return [self normalized360Degrees:(deg + 360)];
    }
    if(deg >= 360)
    {
        return [self normalized360Degrees:(deg - 360)];
    }
    return deg;
}

- (float)normalize180Degrees:(float)deg
{
    if(deg > 180)
    {
        return [self normalize180Degrees:deg - 360];
    }
    else if(deg <= -180)
    {
        return [self normalize180Degrees:deg + 360];
    }
    return deg;
}

- (int)convertToMeters:(float)val
{
    int returnVal = val/1000;
    return returnVal;
}

- (float)correctedDistance
{
    return 0.8 * (_area/2);
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
