//
//  GesturesViewController.m
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 15/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "GesturesViewController.h"

#import "AppDelegate.h"

@interface GesturesViewController () <SMMDeviceManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property UIButton *btnRecordGesture;

@property UITableView *tableRecordedGestures;
@property UITableView *tableChooseGesture;
@property int gestureSelected;

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
    
    [self.view setBackgroundColor:UIColorFromRGB(0x3a424c)];
    
    // Setup button
    _btnRecordGesture = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btnRecordGesture.frame = CGRectMake(100, 280, 200, 200);
    _btnRecordGesture.layer.cornerRadius = 100;
    [_btnRecordGesture setTitle:@"Start" forState:UIControlStateNormal];
    [_btnRecordGesture.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:30]];
    [_btnRecordGesture setBackgroundColor:UIColorFromRGB(0xff5335)];
    [_btnRecordGesture setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnRecordGesture addTarget:self
                          action:@selector(recordButtonPressed)
                forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnRecordGesture];
    
    
    // Setup tableviews
    _tableChooseGesture = [[UITableView alloc] initWithFrame:CGRectMake(100, 60, 200, 180) style:UITableViewStyleGrouped];
    _tableChooseGesture.delegate = self;
    _tableChooseGesture.dataSource = self;
    _tableChooseGesture.backgroundView = nil;
    [_tableChooseGesture setBackgroundColor:[UIColor clearColor]];
    [_tableChooseGesture setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableChooseGesture selectRowAtIndexPath:[NSIndexPath indexPathForRow:_gestureSelected inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    [_tableChooseGesture setBounces:NO];
    [self.view addSubview:_tableChooseGesture];
    
    _tableRecordedGestures = [[UITableView alloc] initWithFrame:CGRectMake(0, 600, 400, 600) style:UITableViewStylePlain];
    _tableRecordedGestures.delegate = self;
    _tableRecordedGestures.dataSource = self;
    _tableRecordedGestures.backgroundView = nil;
    [_tableRecordedGestures setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    [self.view addSubview:_tableRecordedGestures];
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
        [_btnRecordGesture setBackgroundColor:UIColorFromRGB(0xff3535)];
    }
    else
    {
        [APP_DELEGATE.smmDeviceManager stopRecordingGesture];
        
        [_btnRecordGesture setTitle:@"Start" forState:UIControlStateNormal];
        [_btnRecordGesture setBackgroundColor:UIColorFromRGB(0xff5335)];
    }
}


#pragma mark - TableView delegate implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == _tableChooseGesture)
    {
        return 3;
    }
    else
    {
        return 10;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if(tableView == _tableChooseGesture)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        }
        
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:24]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell setBackgroundColor:[UIColor clearColor]];
        UIView *selBg = [[UIView alloc] initWithFrame:cell.frame];
        [selBg setBackgroundColor:UIColorFromRGB(0xff5335)];
        [cell setSelectedBackgroundView:selBg];
        
        if([indexPath row] == 0)
        {
            [cell.textLabel setText:@"Activate"];
        }
        else if([indexPath row] == 1)
        {
            [cell.textLabel setText:@"Nod"];
        }
        else if([indexPath row] == 2)
        {
            [cell.textLabel setText:@"Shake"];
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        }
        
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:20]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [cell.textLabel setText:@"Item"];
    }
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _tableRecordedGestures)
    {
        return UITableViewCellEditingStyleDelete;
    }
    else
    {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
