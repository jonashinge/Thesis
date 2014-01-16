//
//  GNMainViewController.m
//  HeadsetExplorer
//
//  Created by Lars Johansen on 03/06/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import "GNMainViewController.h"
#import "GNAppDelegate.h"
#import "Constants.h"
#import "NSString+IHSDeviceConnectionState.h"

#import <AVFoundation/AVFoundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <IHS/IHS.h>

@interface GNMainViewController () <IHSDeviceDelegate, IHSSensorsDelegate, IHSButtonDelegate, IHS3DAudioDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView*     mapview;
@property (nonatomic) float                         lastHeading;
@property (strong, nonatomic) MKPointAnnotation*    userAnnotation;
@property (strong, nonatomic) MKPointAnnotation*    northAnnotation;
@property (strong, nonatomic) MKPointAnnotation*    southAnnotation;
@property (weak, nonatomic) IBOutlet UILabel*       statusLabel;
@property (strong, nonatomic) AVAudioPlayer*        audioPlayer;
@end

// Set the DEBUG_PRINTOUT define to '1' to enable printouts of the received values
#define DEBUG_PRINTOUT      0

#if !DEBUG_PRINTOUT
#define DEBUGLog(format, ...)
#else
#define DEBUGLog(format, ...) NSLog(format, ## __VA_ARGS__)
#endif

@implementation GNMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapview.mapType = APP_DELEGATE.mapType;
    
    // Register to get notified via 'appDidBecomeActive' when the app becomes active
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(GNFlipsideViewController *)controller
{
    self.mapview.mapType = APP_DELEGATE.mapType = controller.mapType;
    APP_DELEGATE.playNorthSound = controller.playNorthSound;
    APP_DELEGATE.playSouthSound = controller.playSouthSound;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}

- (void)flipsideViewControllerDidResetConnection:(GNFlipsideViewController *)controller
{
    [self connectIHSDevice];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"])
    {
        GNFlipsideViewController*   vc = segue.destinationViewController;
        vc.playNorthSound = APP_DELEGATE.playNorthSound;
        vc.playSouthSound = APP_DELEGATE.playSouthSound;
        vc.mapType = self.mapview.mapType;
        vc.delegate = self;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}


#pragma mark - IHSDeviceDelegate implementation

- (void)ihsDevice:(IHSDevice*)ihsDevice connectedStateChanged:(IHSDeviceConnectionState)connectionState
{    
    DEBUGLog( @"IHS Device:connectedStateChanged:  %d", connectionState );
    
    NSString* connectionString = [NSString stringFromIHSDeviceConnectionState:connectionState];
    NSString* deviceName = APP_DELEGATE.ihsDevice.name ?: @"Headset X";
    NSString* statusText = [NSString stringWithFormat:@"%@ (%@)", deviceName, connectionString ];
    
    self.statusLabel.text = statusText;
    
    switch ( connectionState )
    {
        case IHSDeviceConnectionStateConnected:
            // Save the name of the connected IHS device to automatically connect to it next time the app starts
            APP_DELEGATE.preferredDevice = ihsDevice.preferredDevice;

            [self moveMapCenterToLocation: APP_DELEGATE.lastKnownLocation];

            // Play a sound through the standard player to indicate that the IHS is connected
            [self playSystemSoundWithName:@"TestConnectSound"];
            break;
            
        case IHSDeviceConnectionStateNone:
        case IHSDeviceConnectionStateBluetoothOff:
        case IHSDeviceConnectionStateDiscovering:
        case IHSDeviceConnectionStateDisconnected:
        case IHSDeviceConnectionStateLingering:
        case IHSDeviceConnectionStateConnecting:
        case IHSDeviceConnectionStateConnectionFailed:
            break;
    }
}

#pragma mark - Map and coordinate handling

- (void)moveMapCenterToLocation:(CLLocation*)location {
    
    if ( location && (CLLocationCoordinate2DIsValid(location.coordinate)) )
    {
        // Store the last known location, so we can go there one the app is started from fresh again
        APP_DELEGATE.lastKnownLocation = location;
        
        MKCoordinateRegion region;
        region.center = location.coordinate;
        
        MKCoordinateSpan span;
        span.latitudeDelta  = 0.01;
        span.longitudeDelta = 0.01;
        region.span = span;
        
        [self.mapview setRegion:region animated:YES];
        [self updateMapAnnotations:location];
    }
}

- (void) updateMapRotation:(float)heading
{
    // Find rotation delta between wanted and current direction
    float deltaHeading = heading - self.lastHeading;
    
    // Adjust for discontinuity at 0/360
    if (deltaHeading < -180.0)
    {
        self.lastHeading -= 360.0;
        deltaHeading = heading - self.lastHeading;
    }
    else if (deltaHeading > 180.0)
    {
        self.lastHeading += 360.0;
        deltaHeading = heading - self.lastHeading;
    }
    
    // Filter out small changes
    if (fabs(deltaHeading) >= 1.0)
    {
        self.lastHeading = heading;
        
        // Rotate map
        [self.mapview setTransform:CGAffineTransformMakeRotation(heading * M_PI / -180.0)];
        
        // rotate user annotation back so it appears non-rotated:
        CGAffineTransform counterRotateTransform = CGAffineTransformMakeRotation(heading * M_PI / 180.0);
        [[self.mapview viewForAnnotation:self.userAnnotation] setTransform:counterRotateTransform];
        
    }
}

#pragma mark - Map annotations

- (MKPointAnnotation *)userAnnotation
{
    if ( ! _userAnnotation )
    {
        _userAnnotation = [MKPointAnnotation new];
        _userAnnotation.title = @"UserAnnotation";
        [self.mapview addAnnotation:self.userAnnotation];
    }
    
    return _userAnnotation;
}

- (MKPointAnnotation *)northAnnotation
{
    if ( ! _northAnnotation && ! APP_DELEGATE.hideNorthAnnotation )
    {
        _northAnnotation = [MKPointAnnotation new];
        _northAnnotation.title = @"North";
        [self.mapview addAnnotation:_northAnnotation];
    }
    return _northAnnotation;
}

- (MKPointAnnotation *)southAnnotation
{
    if ( ! _southAnnotation && ! APP_DELEGATE.hideSouthAnnotation )
    {
        _southAnnotation = [MKPointAnnotation new];
        _southAnnotation.title = @"South";
        [self.mapview addAnnotation:_southAnnotation];
    }
    return _southAnnotation;
}

- (void) updateMapAnnotations:(CLLocation*)userLocation
{
    self.userAnnotation.coordinate = userLocation.coordinate;

    CLLocationDegrees   lat = userLocation.coordinate.latitude;
    CLLocationDegrees   lon = userLocation.coordinate.longitude;
    
    self.northAnnotation.coordinate = [[CLLocation alloc] initWithLatitude:lat +0.0015 longitude:lon].coordinate;
    self.southAnnotation.coordinate = [[CLLocation alloc] initWithLatitude:lat -0.0015 longitude:lon].coordinate;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString*  viewId = @"AnnotationId";
    MKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:viewId];
    
    if ( annotationView == nil )
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:viewId];
    }
    
    UIImage*    img = [UIImage imageNamed:((MKPointAnnotation*)annotation).title];
    annotationView.image = img;
    
    // Add a very small transform to annotations; without this the userAnnotation would lose it's
    // transform when the map area/center is changed.
    // The userAnnotation image would then appear north/south aligned (instead of vertically on the screen),
    // until the next heading change would arrive and the map-rotatin and userAnnotation transform changed.
    //
    // The source of this workaround is:
    // http://stackoverflow.com/questions/12729509/ios-6-mapkit-annotation-rotation
    //
    [annotationView setTransform:CGAffineTransformMakeRotation(.001)]; //iOS6 BUG WORKAROUND !!!!!!!

    return annotationView;
}

#pragma mark - IHSSensorsDelegate implementation

- (void)ihsDevice:(IHSDevice*)ihs fusedHeadingChanged:(float)heading
{
    DEBUGLog(@"1: Fused Heading changed: %.1f", heading);

    [self updateMapRotation:heading];
    // Use the fused heading as reference for the 3D audio player in the IHS
    ihs.playerHeading = heading;
}


- (void)ihsDevice:(IHSDevice*)ihs compassHeadingChanged:(float)heading
{
    DEBUGLog(@"2: Compass Heading changed: %.1f", heading);
}


- (void)ihsDevice:(IHSDevice*)ihs yawChanged:(float)yaw
{
    DEBUGLog(@"3: Yaw: %.1f", yaw);
}


- (void)ihsDevice:(IHSDevice*)ihs pitchChanged:(float)pitch
{
    DEBUGLog(@"4: Pitch: %.1f", pitch);
}


- (void)ihsDevice:(IHSDevice*)ihs rollChanged:(float)roll
{
    DEBUGLog(@"5: Roll: %.1f", roll);
}


- (void)ihsDevice:(IHSDevice*)ihs accelerometer3AxisDataChanged:(IHSAHRS3AxisStruct) data
{
    DEBUGLog(@"6: Accelerometer data: (%f, %f, %f)", data.x, data.y, data.z);
}


- (void)ihsDevice:(IHSDevice*)ihs accuracyChangedForHorizontal:(double)horizontalAccuracy
{
    DEBUGLog(@"7: Horizontal accuracy: %.1f", horizontalAccuracy);
}


- (void)ihsDevice:(IHSDevice*)ihs locationChangedToLatitude:(double)latitude andLogitude:(double)longitude
{
    DEBUGLog(@"8: Position: (%.4g, %.4g)", latitude, longitude);
    DEBUGLog(@"   %@", APP_DELEGATE.ihsDevice.location );
    
    [self moveMapCenterToLocation:APP_DELEGATE.ihsDevice.location];
}


#pragma mark - IHSButtonDelegate implementation

- (void)ihsDevice:(id)ihs didPressIHSButton:(IHSButton)button withEvent:(IHSButtonEvent)event
{
    IHSDevice*  ihsDevice = ihs;
    
    switch (button) {
        case IHSButtonLeft: {
            [ihsDevice stop];
            [ihsDevice clearSounds];

            if ( APP_DELEGATE.playNorthSound || APP_DELEGATE.playSouthSound ) {
                ihsDevice.sequentialSounds = YES;
                
                if ( APP_DELEGATE.playNorthSound ) {
                    // Create north and south IHSAudio3DSound objects from embedded sound resources:
                    NSURL* northUrl = [[NSBundle mainBundle] URLForResource:@"ThisIsNorth" withExtension:@"wav"];
                    IHSAudio3DSound* northSound = [[IHSAudio3DSound alloc] initWithURL:northUrl];
                    
                    northSound.heading  = 0;        // Place the "north" sound straight north
                    northSound.volume   = 1.0;      // Set the volume to the maximum level
                    northSound.distance = 1000;     // Set the distance of the sound
                    
                    [ihsDevice addSound:northSound];
                }
                
                if ( APP_DELEGATE.playSouthSound ) {
                    NSURL *southUrl = [[NSBundle mainBundle] URLForResource:@"ThisIsSouth" withExtension:@"wav"];
                    IHSAudio3DSound* southSound = [[IHSAudio3DSound alloc] initWithURL:southUrl];
                    
                    southSound.heading  = 180;      // Place the "south" sound straight south
                    southSound.volume   = 1.0;      // Set the volume to the maximum level
                    southSound.distance = 1000;     // Set the distance of the sound
                    
                    [ihsDevice addSound:southSound];
                }
                // Start the playback
                [ihsDevice play];
            }
            break;
        }
            
        case IHSButtonRight: {
            // Stop the playback
            [ihsDevice stop];
            // Clear the list of sounds
            [ihsDevice clearSounds];
            break;
        }
            
        default:
            break;
    }
}


#pragma mark - Misc

- (void)connectIHSDevice
{
    // Setup delegates to receive various kinds of information from the IHS:
    APP_DELEGATE.ihsDevice.deviceDelegate = self;   // ... connection information
    APP_DELEGATE.ihsDevice.sensorsDelegate = self;  // ... receive data from the IHS sensors
    APP_DELEGATE.ihsDevice.buttonDelegate = self;   // ... receive button presses
    APP_DELEGATE.ihsDevice.audioDelegate = self;    // ... receive 3daudio notifications.
    
    // Establish connection to the physical IHS
    if ( APP_DELEGATE.ihsDevice.connectionState != IHSDeviceConnectionStateConnected ) {
        [APP_DELEGATE.ihsDevice connect];
    }
}

- (void)appDidBecomeActive:(NSNotification *)notification
{
    [self connectIHSDevice];
}

#pragma mark - Sound handling

- (void)playSystemSoundWithName:(NSString*)name {
    NSError *error;
    NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:@"wav"];
    
    [self.audioPlayer stop];
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) {
        NSLog(@"Error playing sound '%@': %@", name, error);
        self.audioPlayer = nil;
    }
    else {
        self.audioPlayer.volume = 1.0;
        
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
    }
}

#pragma mark - IHS3DAudioDelegate implementation

- (void)ihsDevice:(id)ihs playerDidStartSuccessfully:(BOOL)success {
    DEBUGLog(@"playerDidStartSuccessfully? %s", success ? "YES" : "NO");
}


- (void)ihsDevice:(id)ihs playerDidPauseSuccessfully:(BOOL)success {
    DEBUGLog(@"playerDidPauseSuccessfully? %s", success ? "YES" : "NO");
}


- (void)ihsDevice:(id)ihs playerDidStopSuccessfully:(BOOL)success {
    IHSDevice*  ihsDevice = ihs;
    
    DEBUGLog(@"playerDidStopSuccessfully? %s", success ? "YES" : "NO");

    // Restart playback (until right button press).
    [ihsDevice play];
}


- (void)ihsDevice:(id)ihs playerCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    DEBUGLog(@"playerCurrentTime: %f, duration: %f", currentTime, duration);
}


- (void)ihsDevice:(id)ihs playerRenderError:(OSStatus)status {
    NSLog(@"playerRenderError? %li", status);
}

@end
