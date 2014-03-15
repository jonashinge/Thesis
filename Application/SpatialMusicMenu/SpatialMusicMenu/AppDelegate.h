//
//  AppDelegate.h
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 07/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMMDeviceManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SMMDeviceManager *smmDeviceManager;

// Convenience getter for app delegate:
#define APP_DELEGATE ((AppDelegate*)[[UIApplication sharedApplication] delegate])

@end
