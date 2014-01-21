//
//  GNAppDelegate.m
//  HeadsetExplorer
//
//  Created by Lars Johansen on 03/06/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import "GNAppDelegate.h"
#import "Constants.h"
#import "MixerCoreAudioController.h"


#define DEBUG_PRINTOUT      0

#if !DEBUG_PRINTOUT
#define DEBUGLog(format, ...)
#else
#define DEBUGLog(format, ...) NSLog(format, ## __VA_ARGS__)
#endif

//#error Please get an appkey.c file from developer.spotify.com and remove this error before building.
#include "appkey.c"


@interface GNAppDelegate () <IHSSoftwareUpdateDelegate, SPSessionDelegate, SPSessionPlaybackDelegate>
@property UIBackgroundTaskIdentifier bgTask;

@property (nonatomic, strong) SPTrack *currentTrack;
@property (nonatomic, strong) SPPlaybackManager *playbackManager;

@end;


@implementation GNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Read some stored configuration:
    _preferredDevice    = [[NSUserDefaults standardUserDefaults] stringForKey:kStandardUserDefaultsLastConnectedDevice];
    double lastKnownLatitude  = [[NSUserDefaults standardUserDefaults] doubleForKey:kStandardUserDefaultsLastKnownLatitudeKey];
    double lastKnownLongitude = [[NSUserDefaults standardUserDefaults] doubleForKey:kStandardUserDefaultsLastKnownLongitudeKey];
    if ( lastKnownLongitude && lastKnownLatitude ) {
        self.lastKnownLocation = [[CLLocation alloc] initWithLatitude:lastKnownLatitude longitude:lastKnownLongitude];
    }
    self.mapType = [[NSUserDefaults standardUserDefaults] integerForKey:kStandardUserDefaultsMapType];
    self.hideNorthAnnotation = [[NSUserDefaults standardUserDefaults] boolForKey:kStandardUserDefaultsHideNorthAnnotation];
    self.hideSouthAnnotation = [[NSUserDefaults standardUserDefaults] boolForKey:kStandardUserDefaultsHideSouthAnnotation];
    self.hideSouthAnnotation = self.hideNorthAnnotation = NO;
    if ( nil == [[NSUserDefaults standardUserDefaults] objectForKey:kStandardUserDefaultsPlayNorthSound] ) {
        self.playNorthSound = self.playSouthSound = YES;
    } else {
        self.playNorthSound  = [[NSUserDefaults standardUserDefaults] boolForKey:kStandardUserDefaultsPlayNorthSound];
        self.playSouthSound  = [[NSUserDefaults standardUserDefaults] boolForKey:kStandardUserDefaultsPlaySouthSound];
    }
    self.automaticSoftwareUpdate = [[NSUserDefaults standardUserDefaults] boolForKey:kStandardUserDefaultsAutomaticSoftwareUpdate];
    self.softwareUpdateCheckSchedule = [[NSUserDefaults standardUserDefaults] integerForKey:kStandardUserDefaultsSoftwareUpdateCheckSchedule];
    
    
    // Spotify
    NSError *error = nil;
	[SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size]
											   userAgent:@"dk.creuna.jonas.thesis.Headset-X"
										   loadingPolicy:SPAsyncLoadingManual
												   error:&error];
	if (error != nil) {
		NSLog(@"CocoaLibSpotify init failed: %@", error);
		abort();
	}
    
	//self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
    self.audioController = [[MixerCoreAudioController alloc] init];
    self.playbackManager = [[SPPlaybackManager alloc] initWithAudioController:self.audioController playbackSession:[SPSession sharedSession]];
	[[SPSession sharedSession] setDelegate:self];
    
    [self performSelector:@selector(showLogin) withObject:nil afterDelay:0.0];
    

    return YES;
}

-(void)showLogin {
    
	SPLoginViewController *controller = [SPLoginViewController loginControllerForSession:[SPSession sharedSession]];
	controller.allowsCancel = NO;
    
    [self.window setRootViewController:controller];
	
	/*[self.window.rootViewController presentModalViewController:controller
											   animated:NO];*/
    
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] setValue:self.preferredDevice forKey:kStandardUserDefaultsLastConnectedDevice];
    if ( self.lastKnownLocation ) {
        [[NSUserDefaults standardUserDefaults] setDouble:self.lastKnownLocation.coordinate.latitude forKey:kStandardUserDefaultsLastKnownLatitudeKey];
        [[NSUserDefaults standardUserDefaults] setDouble:self.lastKnownLocation.coordinate.longitude forKey:kStandardUserDefaultsLastKnownLongitudeKey];
    }
    [[NSUserDefaults standardUserDefaults] setInteger:self.mapType forKey:kStandardUserDefaultsMapType];
    [[NSUserDefaults standardUserDefaults] setBool:self.hideNorthAnnotation forKey:kStandardUserDefaultsHideNorthAnnotation];
    [[NSUserDefaults standardUserDefaults] setBool:self.hideSouthAnnotation forKey:kStandardUserDefaultsHideSouthAnnotation];
    [[NSUserDefaults standardUserDefaults] setBool:self.playNorthSound forKey:kStandardUserDefaultsPlayNorthSound];
    [[NSUserDefaults standardUserDefaults] setBool:self.playSouthSound forKey:kStandardUserDefaultsPlaySouthSound];
    [[NSUserDefaults standardUserDefaults] setBool:self.automaticSoftwareUpdate forKey:kStandardUserDefaultsAutomaticSoftwareUpdate];
    [[NSUserDefaults standardUserDefaults] setInteger:self.softwareUpdateCheckSchedule forKey:kStandardUserDefaultsSoftwareUpdateCheckSchedule];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if ( _ihsDevice ) {
        if ( self.ihsDevice.softwareUpdateInProgress ) {
            DEBUGLog( @"APP: launching background task to finish sw update" );
            
            self.bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
                // Clean up any unfinished task business by marking where you
                // stopped or ending the task outright.
                [application endBackgroundTask:self.bgTask];
                self.bgTask = UIBackgroundTaskInvalid;
            }];
        }
        else {
            // Remove these lines if you want the connection to the IHS device to stay open while the app is in the background
            [self.ihsDevice disconnect];
            _ihsDevice = nil;
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if ( self.bgTask != UIBackgroundTaskInvalid ) {
        DEBUGLog( @"APP: Entering foreground, clearing background task" );
        
        [application endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }
}

#pragma mark - Property Access Methods

- (void)setPreferredDevice:(NSString *)preferredDevice
{
    _preferredDevice = preferredDevice;
    [[NSUserDefaults standardUserDefaults] setValue:_preferredDevice forKey:kStandardUserDefaultsLastConnectedDevice];
    [[NSUserDefaults standardUserDefaults] synchronize]; // Make sure it is stored for next time
}

#pragma mark - IHSDevice

- (IHSDevice *)ihsDevice
{
    if ( _ihsDevice == nil ) {
        // Initialize with the name of the IHS device the app was most recently connected to
        _ihsDevice = [[IHSDevice alloc] initWithPreferredDevice:self.preferredDevice];
        // Provide the API key for this app. NOTE! The API key is unique for each app
        // Go to https://developer.intelligentheadset.com to get an API key for your app
        [_ihsDevice provideAPIKey:@"bCgVZ5DuB7sKOXo5xgn/HWU13spfzvoUyPBPiI0CVNLVvfLctMTt+Fs7s897y1Fx"];
        _ihsDevice.softwareUpdateSchedule = _softwareUpdateCheckSchedule;
        _ihsDevice.softwareUpdateConnectedDevicesAutomatically = self.automaticSoftwareUpdate;
        _ihsDevice.softwareUpdateDelegate = self;
    }
    return _ihsDevice;
}

- (void)resetDeviceConnection
{
    self.preferredDevice = nil;
    [self.ihsDevice disconnect];
    self.ihsDevice = nil;
    [self.ihsDevice connect];
}

- (void)setSoftwareUpdateCheckSchedule:(int)softwareUpdateCheckSchedule
{
    if ( _softwareUpdateCheckSchedule != softwareUpdateCheckSchedule ) {
        _softwareUpdateCheckSchedule = softwareUpdateCheckSchedule;
        self.ihsDevice.softwareUpdateSchedule = _softwareUpdateCheckSchedule;
    }
}

#pragma mark - IHSSoftwareUpdateDelegate

- (BOOL)ihsDeviceShouldCheckForSoftwareUpdateNow:(id)ihs
{
    if ( self.ihsDevice.softwareUpdateInProgress == NO ) {
        IHSSoftwareUpdateCheckLatestVersionSchedule sched = APP_DELEGATE.softwareUpdateCheckSchedule;
        switch ( sched ) {
            case IHSSoftwareUpdateCheckLatestVersionScheduleManual:
                return NO;
            case IHSSoftwareUpdateCheckLatestVersionScheduleAlways:
            case IHSSoftwareUpdateCheckLatestVersionScheduleDaily:
                return YES;
        }
    }
    
    return NO;
}

- (void)ihsDevice:(id)ihs didFinishSoftwareUpdateWithResult:(BOOL)success
{
    if ( self.bgTask == UIBackgroundTaskInvalid ) {
        // Must be in foreground then...
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        UIAlertView*    alert = [UIAlertView alloc];
        NSString*       msg = (success) ? @"completed successfully\nplease restart headset to use new software" : @"Failed";
        [[alert initWithTitle:@"IHS software update" message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
    }
    else {
        DEBUGLog( @"APP: sw update finished, clearing background task" );
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }
}

#pragma mark - Spotify methods/callbacks

/*-(UIViewController *)viewControllerToPresentLoginViewForSession:(SPSession *)aSession {
	return self.window.rootViewController;
}*/

-(void)sessionDidLoginSuccessfully:(SPSession *)aSession; {
	// Invoked by SPSession after a successful login.
    
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"MainStoryBoard_iPhone" bundle:nil];
    UIViewController *controller = [mainStoryBoard instantiateViewControllerWithIdentifier:@"vcMain"];
    [self.window setRootViewController:controller];
    
    // testing playback
    /*NSString *songUrl = @"spotify:track:1gDUBjhXOTd7iQhwIk7rln";
    NSURL *trackURL = [NSURL URLWithString:songUrl];
    [[SPSession sharedSession] trackForURL:trackURL callback:^(SPTrack *track) {
        
        if (track != nil) {
            
            [SPAsyncLoading waitUntilLoaded:track timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *tracks, NSArray *notLoadedTracks) {
                [self.playbackManager playTrack:track callback:^(NSError *error) {
                    
                    if (error) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Play Track"
                                                                        message:[error localizedDescription]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                    } else {
                        self.currentTrack = track;
                        
                        // test panning
                        //[self.audioController applyPanningToMixer:10];
                    }
                    
                }];
            }];
        }
    }];*/
    
}

-(void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error; {
	// Invoked by SPSession after a failed login.
}

-(void)sessionDidLogOut:(SPSession *)aSession {
	
	/*SPLoginViewController *controller = [SPLoginViewController loginControllerForSession:[SPSession sharedSession]];
	
	if (self.mainViewController.presentedViewController != nil) return;
	
	controller.allowsCancel = NO;
	
	[self.mainViewController presentModalViewController:controller
											   animated:YES];*/
}

-(void)session:(SPSession *)aSession didEncounterNetworkError:(NSError *)error; {}
-(void)session:(SPSession *)aSession didLogMessage:(NSString *)aMessage; {}
-(void)sessionDidChangeMetadata:(SPSession *)aSession; {}

-(void)session:(SPSession *)aSession recievedMessageForUser:(NSString *)aMessage; {
	return;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message from Spotify"
													message:aMessage
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}


- (void)dealloc {
	
	/*[self removeObserver:self forKeyPath:@"currentTrack.name"];
	[self removeObserver:self forKeyPath:@"currentTrack.artists"];
	[self removeObserver:self forKeyPath:@"currentTrack.album.cover.image"];
	[self removeObserver:self forKeyPath:@"playbackManager.trackPosition"];*/
	
}



@end
