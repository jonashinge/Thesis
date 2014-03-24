//
//  GesturesViewController.m
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 15/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "GesturesViewController.h"

#import "AppDelegate.h"

@interface GesturesViewController () <SMMDeviceManagerDelegate>

@property UIButton *btnRecordGesture;

@end

@implementation GesturesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:UIColorFromRGB(0x333745)];
    
    _btnRecordGesture = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btnRecordGesture.frame = CGRectMake(100, 100, 200, 200);
    _btnRecordGesture.layer.cornerRadius = 100;
    [_btnRecordGesture setTitle:@"Start" forState:UIControlStateNormal];
    [_btnRecordGesture.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:30]];
    [_btnRecordGesture setBackgroundColor:UIColorFromRGB(0x77c4d3)];
    [_btnRecordGesture setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnRecordGesture addTarget:self
                          action:@selector(recordButtonPressed)
                forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnRecordGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)recordButtonPressed
{
    if(!APP_DELEGATE.smmDeviceManager.isRecordingGesture)
    {
        [APP_DELEGATE.smmDeviceManager startRecordingGesture];
        
        [_btnRecordGesture setTitle:@"Stop" forState:UIControlStateNormal];
        [_btnRecordGesture setBackgroundColor:UIColorFromRGB(0xea2e49)];
    }
    else
    {
        [APP_DELEGATE.smmDeviceManager stopRecordingGesture];
        
        [_btnRecordGesture setTitle:@"Start" forState:UIControlStateNormal];
        [_btnRecordGesture setBackgroundColor:UIColorFromRGB(0x77c4d3)];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
