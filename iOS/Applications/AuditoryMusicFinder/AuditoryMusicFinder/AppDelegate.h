//
//  AppDelegate.h
//  AuditoryMusicFinder
//
//  Created by Jonas Hinge on 02/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IHS/IHS.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) IHSDevice *ihsDevice;


// Convenience getter for app delegate:
#define APP_DELEGATE ((AppDelegate*)[[UIApplication sharedApplication] delegate])

@end
