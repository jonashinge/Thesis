//
//  GNSoftwareUpdateViewController.h
//  HeadsetExplorer
//
//  Created by Michael Bech Hansen on 6/20/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IHS/IHS.h>

@class GNSoftwareUpdateViewController;

@protocol GNSoftwareUpdateViewControllerDelegate <NSObject>
- (void)softwareUpdateViewControllerDidFinish:(GNSoftwareUpdateViewController *)controller;
@end

@interface GNSoftwareUpdateViewController : UIViewController

@property (weak, nonatomic) id <GNSoftwareUpdateViewControllerDelegate> delegate;

@end
