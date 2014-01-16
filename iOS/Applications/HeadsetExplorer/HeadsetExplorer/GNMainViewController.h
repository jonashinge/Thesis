//
//  GNMainViewController.h
//  HeadsetExplorer
//
//  Created by Lars Johansen on 03/06/13.
//  Copyright (c) 2013 GN Store Nord A/S. All rights reserved.
//

#import "GNFlipsideViewController.h"

@interface GNMainViewController : UIViewController <GNFlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@end
