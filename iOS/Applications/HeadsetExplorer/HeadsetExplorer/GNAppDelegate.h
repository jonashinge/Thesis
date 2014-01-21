//
//  GNAppDelegate.h
//  HeadsetExplorer
//
//  Created by Lars Johansen on 03/06/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IHS/IHS.h>
#import "CocoaLibSpotify.h"

@class CLLocation;
@class MixerCoreAudioController;

@interface GNAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) IHSDevice* ihsDevice;
@property (strong, nonatomic) NSString* preferredDevice;
@property (strong, nonatomic) CLLocation* lastKnownLocation;
@property (nonatomic) int mapType;
@property (nonatomic) BOOL hideNorthAnnotation;
@property (nonatomic) BOOL hideSouthAnnotation;
@property (nonatomic) BOOL playNorthSound;
@property (nonatomic) BOOL playSouthSound;
@property (nonatomic) BOOL automaticSoftwareUpdate;
@property (nonatomic) int softwareUpdateCheckSchedule;

@property (nonatomic, readwrite, strong) MixerCoreAudioController *audioController;

- (void) resetDeviceConnection;

- (BOOL)ihsDeviceShouldCheckForSoftwareUpdateNow:(id)ihs;
- (void)ihsDevice:(id)ihs didFinishSoftwareUpdateWithResult:(BOOL)success;

@end


// Convenience getter for app delegate:
#define APP_DELEGATE    ((GNAppDelegate*)[[UIApplication sharedApplication] delegate])