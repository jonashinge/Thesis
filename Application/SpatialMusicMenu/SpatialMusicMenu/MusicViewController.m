//
//  MusicViewController.m
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 15/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "MusicViewController.h"

#import "AppDelegate.h"

@interface MusicViewController () <UITableViewDataSource, UITableViewDelegate>

@property UITableView *tablePlaylists;
@property UILabel *lblTrackCounter;

@end

@implementation MusicViewController

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
    
    // Setup track counter
    _lblTrackCounter = [[UILabel alloc] initWithFrame:CGRectMake(150, 110, 100, 80)];
    [_lblTrackCounter setFont:[UIFont fontWithName:@"Helvetica" size:48]];
    [_lblTrackCounter setTextColor:[UIColor whiteColor]];
    [_lblTrackCounter setText:@"3"];
    [_lblTrackCounter setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_lblTrackCounter];
    
    UIStepper *stepperTracks = [[UIStepper alloc] initWithFrame:CGRectMake(150, 200, 160, 60)];
    [stepperTracks setMaximumValue:10];
    [stepperTracks setMinimumValue:3];
    [stepperTracks setTintColor:[UIColor whiteColor]];
    [stepperTracks addTarget:self action:@selector(stepperTracksChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:stepperTracks];
    
    // Table setup
    _tablePlaylists = [[UITableView alloc] initWithFrame:CGRectMake(0, 300, 400, 900) style:UITableViewStylePlain];
    _tablePlaylists.delegate = self;
    _tablePlaylists.dataSource = self;
    _tablePlaylists.backgroundView = nil;
    [_tablePlaylists setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_tablePlaylists];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)stepperTracksChanged:(id)stepper
{
    UIStepper *step = stepper;
    _trackCount = [step value];
    
    // Update label
    [_lblTrackCounter setText:[NSString stringWithFormat:@"%d",_trackCount]];
}


#pragma mark - TableView delegate implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:20]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [cell.textLabel setText:@"Item"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
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
