//
//  MainViewController.h
//  HeadsetExplorer
//
//  Created by Jonas Hinge on 20/01/2014.
//  Copyright (c) 2014 GN Store Nord A/S. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISlider *sliderPan;
@property (weak, nonatomic) IBOutlet UILabel *lblPan;
@property (weak, nonatomic) IBOutlet UILabel *lblConnStatus;

- (IBAction)sliderDidChange:(id)sender;

@end
