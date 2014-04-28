//
//  GesturesViewController.m
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 15/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "GesturesViewController.h"

#import "AppDelegate.h"
#import "Gesture.h"

#import <MMDrawerController/UIViewController+MMDrawerController.h>

@interface GesturesViewController () <UITableViewDataSource, UITableViewDelegate>

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
    
    _tableRecordedGestures = [[UITableView alloc] initWithFrame:CGRectMake(0, 600, 400, 424) style:UITableViewStylePlain];
    _tableRecordedGestures.delegate = self;
    _tableRecordedGestures.dataSource = self;
    _tableRecordedGestures.backgroundView = nil;
    [_tableRecordedGestures setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    [self.view addSubview:_tableRecordedGestures];
    
    // Add persisted gestures
    NSArray *gestures = [APP_DELEGATE.persistencyManager getGestures];
    [APP_DELEGATE.smmDeviceManager updateGestures:gestures];
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
        [_btnRecordGesture setBackgroundColor:UIColorFromRGB(0xff0000)];
    }
    else
    {
        NSArray *gestureData = [APP_DELEGATE.smmDeviceManager stopRecordingGesture];
        
        [_btnRecordGesture setTitle:@"Start" forState:UIControlStateNormal];
        [_btnRecordGesture setBackgroundColor:UIColorFromRGB(0xff5335)];
        
        if([gestureData count] > 5)
        {
            Gesture *gesture = [[Gesture alloc] init];
            [gesture setLabel:[self gestureLabel:_gestureSelected]];
            [gesture setData:gestureData];
            [gesture setTimestamp:[NSDate date]];
            [APP_DELEGATE.persistencyManager addGesture:gesture];
            [APP_DELEGATE.smmDeviceManager updateGestures:[APP_DELEGATE.persistencyManager getGestures]];
            [_tableRecordedGestures reloadData];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [APP_DELEGATE makeAudioMenuViewControllerDeviceDelegate:NO];
    
    [APP_DELEGATE.smmDeviceManager stopAudio];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [APP_DELEGATE makeAudioMenuViewControllerDeviceDelegate:YES];
    
    [APP_DELEGATE.smmDeviceManager playAudio];
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
        return [[APP_DELEGATE.persistencyManager getGestures] count];
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
        
        [cell.textLabel setText:[APP_DELEGATE translatedLabel:[self gestureLabel:[indexPath row]]]];
        
        /*if([indexPath row] == 0)
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
        }*/
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
        [cell setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        Gesture *gest = [[APP_DELEGATE.persistencyManager getGestures] objectAtIndex:indexPath.row];
        [cell.textLabel setText:[APP_DELEGATE translatedLabel:gest.label]];
        NSString *dateString = [NSDateFormatter localizedStringFromDate:gest.timestamp
                                                              dateStyle:NSDateFormatterShortStyle
                                                              timeStyle:NSDateFormatterMediumStyle];
        [cell.detailTextLabel setText:dateString];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        _gestureSelected = indexPath.row;
    }
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
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        Gesture *gest = [[APP_DELEGATE.persistencyManager getGestures] objectAtIndex:indexPath.row];
        [APP_DELEGATE.persistencyManager removeGesture:gest];
        [APP_DELEGATE.smmDeviceManager updateGestures:[APP_DELEGATE.persistencyManager getGestures]];
        [_tableRecordedGestures reloadData];
    }
}


- (void)smmDeviceManager:(SMMDeviceManager *)manager gestureRecognized:(NSDictionary *)result
{
    // select new
    NSIndexPath *idxPath = [NSIndexPath indexPathForRow:[[result objectForKey:@"id"] intValue] inSection:0];
    UITableViewCell *cell = [_tableRecordedGestures cellForRowAtIndexPath:idxPath];
    
    [_tableRecordedGestures scrollToRowAtIndexPath:idxPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    
    [UIView animateWithDuration:0.5 animations:^{
        [cell setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.8]];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            [cell setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0]];
        }];
    }];
}

- (NSString *)gestureLabel:(int)gestureNr
{
    switch (gestureNr) {
        case 0:
            return @"ACTIVATE";
            break;
        case 1:
            return @"NOD";
            break;
        case 2:
            return @"SHAKE";
            break;
            
        default:
            return @"__UNKNOWN";
            break;
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
