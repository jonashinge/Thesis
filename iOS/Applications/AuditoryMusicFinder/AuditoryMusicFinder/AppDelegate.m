//
//  AppDelegate.m
//  AuditoryMusicFinder
//
//  Created by Jonas Hinge on 02/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //self.preferredDevice = [[NSUserDefaults standardUserDefaults] stringForKey:kStandardUserDefaultsLastConnectedDevice];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[NSUserDefaults standardUserDefaults] setObject:self.ihsDevice.preferredDevice forKey:kStandardUserDefaultsLastConnectedDevice];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - IHS device
- (IHSDevice *)ihsDevice
{
    if(_ihsDevice == nil)
    {
        NSString *preferredDevice = [[NSUserDefaults standardUserDefaults] stringForKey:kStandardUserDefaultsLastConnectedDevice];
        _ihsDevice = [[IHSDevice alloc] initWithPreferredDevice:preferredDevice];
        [_ihsDevice provideAPIKey:@"3tXvpy2WbqLIkaxaiEtYt2DF8sjf8rt0lOGqjDNesGG+/gFDZ6Rpjs19KFRZALrvzMWJQuJfdjtNI//k0Gl2cA=="];
    }
    return _ihsDevice;
}

@end
