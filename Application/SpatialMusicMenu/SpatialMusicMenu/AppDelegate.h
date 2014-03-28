//
//  AppDelegate.h
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 07/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMMDeviceManager.h"
#import "MusicManager.h"
#import "PersistencyManager.h"
#import "DeezerClient.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SMMDeviceManager *smmDeviceManager;
//@property (strong, nonatomic) MusicManager *musicManager;
@property (strong, nonatomic) PersistencyManager *persistencyManager;
@property (strong, nonatomic) DeezerClient *deezerClient;

// Convenience getter for app delegate:
#define APP_DELEGATE ((AppDelegate*)[[UIApplication sharedApplication] delegate])

// Smart hex color macro
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@end
