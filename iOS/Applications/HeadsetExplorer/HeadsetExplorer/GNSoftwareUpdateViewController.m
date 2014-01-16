//
//  GNSoftwareUpdateViewController.m
//  HeadsetExplorer
//
//  Created by Michael Bech Hansen on 6/20/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import "GNSoftwareUpdateViewController.h"
#import "GNAppDelegate.h"

@interface GNSoftwareUpdateViewController () <IHSSoftwareUpdateDelegate>

@property (weak, nonatomic) IBOutlet UISwitch*  autoUpdateSwitch;
@property (weak, nonatomic) IBOutlet UILabel*   currentVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel*   latestVersionLabel;
@property (weak, nonatomic) IBOutlet UIButton*  performSoftwareUpdateButton;
@property (weak, nonatomic) IBOutlet UISlider*  updateProgressSlider;
@property (weak, nonatomic) IBOutlet UIProgressView*  updateProgressView;
@property (weak, nonatomic) IBOutlet UILabel*   etaLabel;
@property (weak, nonatomic) IBOutlet UIView *softwareUpdateProgressBlock;
@property (weak, nonatomic) IBOutlet UISegmentedControl *softwareUpdateScheduleSegment;
@property (weak, nonatomic) IBOutlet UIButton *checkForUpdateButton;
@property (weak, nonatomic) id<IHSSoftwareUpdateDelegate> previousSoftwareUpdateDelegate;
@end

@implementation GNSoftwareUpdateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ( self.previousSoftwareUpdateDelegate != self ) {
        self.previousSoftwareUpdateDelegate = APP_DELEGATE.ihsDevice.softwareUpdateDelegate;
        APP_DELEGATE.ihsDevice.softwareUpdateDelegate = self;
    }
    
    [self updateUI];
}


- (void)updateUI
{
    self.autoUpdateSwitch.on = APP_DELEGATE.ihsDevice.softwareUpdateConnectedDevicesAutomatically;
    
    self.softwareUpdateScheduleSegment.selectedSegmentIndex = APP_DELEGATE.ihsDevice.softwareUpdateSchedule;
    self.currentVersionLabel.text = [APP_DELEGATE.ihsDevice.currentBuildNumber stringValue];
    self.latestVersionLabel.text  = [APP_DELEGATE.ihsDevice.latestBuildNumber  stringValue];
    self.updateProgressSlider.enabled = APP_DELEGATE.ihsDevice.softwareUpdateAvailable;
    [self.updateProgressSlider setThumbImage:[UIImage new] forState:UIControlStateNormal];
    self.etaLabel.enabled = APP_DELEGATE.ihsDevice.softwareUpdateAvailable;
    self.etaLabel.text = @"";
    
    [self updateUpdateButtonTitle];
    self.performSoftwareUpdateButton.enabled = (self.updateProgressSlider.value < 100.0);
    
    self.softwareUpdateProgressBlock.hidden = APP_DELEGATE.ihsDevice.softwareUpdateAvailable ? NO : YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    APP_DELEGATE.ihsDevice.softwareUpdateDelegate = self.previousSoftwareUpdateDelegate;
}

- (IBAction)checkForUpdateButtonClicked:(id)sender {
    [APP_DELEGATE.ihsDevice checkForSoftwareUpdate];
}

- (IBAction)softwareUpdateCheckScheduleChanged:(id)sender {
    APP_DELEGATE.softwareUpdateCheckSchedule = self.softwareUpdateScheduleSegment.selectedSegmentIndex;
}

- (IBAction)performSoftwareUpdateButtonClicked:(id)sender {
    if ( APP_DELEGATE.ihsDevice.softwareUpdateInProgress ) {
        [APP_DELEGATE.ihsDevice abortSoftwareUpdate];
    }
    else {
        [APP_DELEGATE.ihsDevice beginSoftwareUpdate];
    }

    [self updateUI];
}

- (IBAction)doneClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    [self.delegate softwareUpdateViewControllerDidFinish:self];
}

- (IBAction)autoUpdateSwitchClicked:(id)sender {
    APP_DELEGATE.automaticSoftwareUpdate = self.autoUpdateSwitch.on;
}

- (void)updateUpdateButtonTitle
{
    NSString*  title = @"Perform software update";
    
    if ( APP_DELEGATE.ihsDevice.softwareUpdateInProgress ) {
        title = (self.updateProgressSlider.value < 100.0) ? @"Cancel software update" : @"Please wait - finalizing";
    }
    
    [self.performSoftwareUpdateButton setTitle:title forState:UIControlStateNormal];
}


#pragma mark - IHSSoftwareUpdateDelegate

- (BOOL)ihsDeviceShouldCheckForSoftwareUpdateNow:(id)ihs
{
    return [APP_DELEGATE ihsDeviceShouldCheckForSoftwareUpdateNow:ihs];
}

- (void)ihsDevice:(id)ihs willBeginSoftwareUpdateWithInfo:(NSDictionary *)info
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.checkForUpdateButton.userInteractionEnabled = NO;
    self.updateProgressSlider.value = 0;
    [self updateUpdateButtonTitle];
    self.softwareUpdateProgressBlock.hidden = NO;
}

- (void)ihsDevice:(id)ihs softwareUpdateProgressedTo:(float)percent ETA:(NSDate *)eta
{
    self.updateProgressSlider.value = MAX(percent,3.5);    //3.5: else the slider will look empty in the beginning.
    
    if ( percent >= 100.0 ) {
        self.etaLabel.text = @"Download complete, finalizing...";
        self.performSoftwareUpdateButton.enabled = NO;
        [self updateUpdateButtonTitle];
    }
    else if ( percent <= 0.5 ) {
        self.etaLabel.text = @"Initializing...";
    }
    else {
        self.etaLabel.text = [NSString stringWithFormat:@"%.1f%% done, finish ~ %@", percent, [NSDateFormatter localizedStringFromDate:eta dateStyle:kCFDateFormatterNoStyle timeStyle:kCFDateFormatterMediumStyle] ];
    }
}

- (void)ihsDevice:(id)ihs didFinishSoftwareUpdateWithResult:(BOOL)success
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    self.etaLabel.text = success ? @"Update succeeded" :  @"Update failed";
    self.checkForUpdateButton.userInteractionEnabled = YES;
    self.performSoftwareUpdateButton.enabled = YES;
    self.updateProgressSlider.value = 0;
    [self updateUpdateButtonTitle];
    
    [APP_DELEGATE ihsDevice:ihs didFinishSoftwareUpdateWithResult:success];
}

- (void)ihsDevice:(id)ihs didFindDeviceWithBuildNumber:(NSNumber *)deviceBuildNumber latestBuildNumber:(NSNumber *)latestBuildNumber
{
    [self updateUI];
}

#pragma mark - app state handling
- (void)appDidEnterBackground:(NSNotification *)notification
{
    APP_DELEGATE.ihsDevice.softwareUpdateDelegate = self.previousSoftwareUpdateDelegate;
}

- (void)appDidBecomeActive:(NSNotification *)notification
{
    if ( self.previousSoftwareUpdateDelegate != self ) {
        self.previousSoftwareUpdateDelegate = APP_DELEGATE.ihsDevice.softwareUpdateDelegate;
        APP_DELEGATE.ihsDevice.softwareUpdateDelegate = self;
    }
    
    [self updateUI];
}

@end
