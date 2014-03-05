//
//  GNSoftwareUpdateViewController.m
//  HeadsetExplorer
//
//  Created by Michael Bech Hansen on 6/20/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import "GNSoftwareUpdateViewController.h"
#import "GNAppDelegate.h"

@interface GNSoftwareUpdateViewController () <UIAlertViewDelegate, IHSSoftwareUpdateDelegate>

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


#pragma mark - GNSoftwareUpdateViewController

@implementation GNSoftwareUpdateViewController {
    UIAlertView*                _softwareUpdateAlert;
    UIActivityIndicatorView*    _waitActivityIndicator;
}


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
    
    if (self.previousSoftwareUpdateDelegate != self) {
        self.previousSoftwareUpdateDelegate = APP_DELEGATE.ihsDevice.softwareUpdateDelegate;
        APP_DELEGATE.ihsDevice.softwareUpdateDelegate = self;
    }
    
    [self updateUI:APP_DELEGATE.ihsDevice];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_softwareUpdateAlert dismissWithClickedButtonIndex:_softwareUpdateAlert.cancelButtonIndex animated:NO];
}


- (void)updateUI:(IHSDevice*)ihsDevice
{
    self.autoUpdateSwitch.on = ihsDevice.softwareUpdateConnectedDevicesAutomatically;
    
    self.softwareUpdateScheduleSegment.selectedSegmentIndex = ihsDevice.softwareUpdateSchedule;
    self.currentVersionLabel.text = [ihsDevice.currentBuildNumber stringValue];
    self.latestVersionLabel.text  = [ihsDevice.latestBuildNumber  stringValue];
    self.updateProgressSlider.enabled = ihsDevice.softwareUpdateAvailable;
    [self.updateProgressSlider setThumbImage:[UIImage new] forState:UIControlStateNormal];
    self.etaLabel.enabled = ihsDevice.softwareUpdateAvailable;
    self.etaLabel.text = @"";
    
    [self updateUpdateButtonTitle];
    self.performSoftwareUpdateButton.enabled = (self.updateProgressSlider.value < 100.0);
    
    self.softwareUpdateProgressBlock.hidden = ihsDevice.softwareUpdateAvailable ? NO : YES;
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
    if (APP_DELEGATE.ihsDevice.softwareUpdateInProgress) {
        [APP_DELEGATE.ihsDevice abortSoftwareUpdate];
    }
    else {
        [self startSoftwareUpload];
    }
    [self updateUI:APP_DELEGATE.ihsDevice];
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
    NSString*  title = NSLocalizedString(@"Perform software update", @"Button title for starting software update");
    
    if (APP_DELEGATE.ihsDevice.softwareUpdateInProgress) {
        title = self.updateProgressSlider.value < 100.0 ? NSLocalizedString(@"Cancel software update", @"Button title for canceling software update") : NSLocalizedString(@"Please wait - finalizing", @"Button title when finalizing software update");
    }
    
    [self.performSoftwareUpdateButton setTitle:title forState:UIControlStateNormal];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView == _softwareUpdateAlert) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            if (!APP_DELEGATE.ihsDevice.softwareUpdateInProgress) {
                [self startSoftwareUpload];
                [self updateUI:APP_DELEGATE.ihsDevice];
            }
        }
        _softwareUpdateAlert = nil;
    }
}


#pragma mark - IHSSoftwareUpdateDelegate

- (BOOL)ihsDeviceShouldCheckForSoftwareUpdateNow:(id)ihs
{
    return [APP_DELEGATE ihsDeviceShouldCheckForSoftwareUpdateNow:ihs];
}


- (void)ihsDevice:(id)ihs willBeginSoftwareUpdateWithInfo:(NSDictionary *)info
{
    [_waitActivityIndicator removeFromSuperview];
    _waitActivityIndicator = nil;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.checkForUpdateButton.userInteractionEnabled = NO;
    self.updateProgressSlider.value = 0;
    [self updateUpdateButtonTitle];
    self.softwareUpdateProgressBlock.hidden = NO;
}


- (void)ihsDevice:(id)ihs softwareUpdateProgressedTo:(float)percent ETA:(NSDate *)eta
{
    self.updateProgressSlider.value = MAX(percent,3.5);    //3.5: else the slider will look empty in the beginning.
    
    if (percent >= 100.0) {
        self.etaLabel.text = NSLocalizedString(@"Download complete, finalizing...", @"Label when finalizing software update");
        self.performSoftwareUpdateButton.enabled = NO;
        [self updateUpdateButtonTitle];
    }
    else if (percent <= 0.5) {
        self.etaLabel.text = NSLocalizedString(@"Initializing...", @"Label for initializing software update");
    }
    else {
        self.etaLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%.1f%% done, finish ~ %@", @"Software update progress label"), percent, [NSDateFormatter localizedStringFromDate:eta dateStyle:kCFDateFormatterNoStyle timeStyle:kCFDateFormatterMediumStyle] ];
    }
}


- (void)ihsDevice:(id)ihs didFinishSoftwareUpdateWithResult:(BOOL)success
{
    [_waitActivityIndicator removeFromSuperview];
    _waitActivityIndicator = nil;

    [UIApplication sharedApplication].idleTimerDisabled = NO;
    self.etaLabel.text = success ? NSLocalizedString(@"Update succeeded", @"Text when software update succeeded") :  NSLocalizedString(@"Update failed", @"Text when software update failed");
    self.checkForUpdateButton.userInteractionEnabled = YES;
    self.performSoftwareUpdateButton.enabled = YES;
    self.updateProgressSlider.value = 0;
    [self updateUpdateButtonTitle];
    
    [APP_DELEGATE ihsDevice:ihs didFinishSoftwareUpdateWithResult:success];
}


- (void)ihsDevice:(id)ihs didFindDeviceWithBuildNumber:(NSNumber *)deviceBuildNumber latestBuildNumber:(NSNumber *)latestBuildNumber
{
    [self updateUI:ihs];
}


- (void)ihsDevice:(id)ihs didFailSoftwareUpdateWithError:(NSError *)error
{
    [_waitActivityIndicator removeFromSuperview];
    _waitActivityIndicator = nil;

    NSString* message = error.localizedDescription;
    if (error.localizedRecoverySuggestion != nil) {
        message = [message stringByAppendingFormat:@"\n\n%@", error.localizedRecoverySuggestion];
    }

    _softwareUpdateAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Software Update Failure", @"Title for software update error")
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"Cancel", @"Generic cancel button text")
                                            otherButtonTitles:NSLocalizedString(@"Retry", @"Generic retry button text"), nil];
    [_softwareUpdateAlert show];
}


#pragma mark - app state handling

- (void)appDidEnterBackground:(NSNotification *)notification
{
    APP_DELEGATE.ihsDevice.softwareUpdateDelegate = self.previousSoftwareUpdateDelegate;
}

- (void)appDidBecomeActive:(NSNotification *)notification
{
    if (self.previousSoftwareUpdateDelegate != self) {
        self.previousSoftwareUpdateDelegate = APP_DELEGATE.ihsDevice.softwareUpdateDelegate;
        APP_DELEGATE.ihsDevice.softwareUpdateDelegate = self;
    }
    
    [self updateUI:APP_DELEGATE.ihsDevice];
}


#pragma mark - Internal Helper Methods

- (void)startSoftwareUpload
{
    [_waitActivityIndicator removeFromSuperview];
    _waitActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _waitActivityIndicator.frame = self.view.bounds;
    _waitActivityIndicator.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [_waitActivityIndicator startAnimating];
    [self.view addSubview:_waitActivityIndicator];
    [APP_DELEGATE.ihsDevice beginSoftwareUpdate];
}

@end
