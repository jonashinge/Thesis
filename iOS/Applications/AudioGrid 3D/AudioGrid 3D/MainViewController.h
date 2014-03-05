//
//  MainViewController.h
//  AudioGrid 3D
//
//  Created by Martin Lobger on 13/02/14.
//  Copyright (c) 2014 GN Store Nord A/S. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IHS/IHS.h>

@interface MainViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton* ihsLogo;
@property (nonatomic, weak) IBOutlet IHSAudio3DGridView* audioGrid;

@property (nonatomic, strong) IHSDevice* ihsDevice;

@end
