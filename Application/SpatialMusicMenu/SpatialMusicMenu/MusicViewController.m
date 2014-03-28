//
//  MusicViewController.m
//  SpatialMusicMenu
//
//  Created by Jonas Hinge on 15/03/2014.
//  Copyright (c) 2014 Jonas Hinge. All rights reserved.
//

#import "MusicViewController.h"

#import "AppDelegate.h"
#import "Playlist.h"

@interface MusicViewController () <UITableViewDataSource, UITableViewDelegate>

@property UITableView *tablePlaylists;
@property UILabel *lblTrackCounter;


// Set the DEBUG_PRINTOUT define to '1' to enable printouts of the received values
#define DEBUG_PRINTOUT      1

#if !DEBUG_PRINTOUT
#define DEBUGLog(format, ...)
#else
#define DEBUGLog(format, ...) NSLog(format, ## __VA_ARGS__)
#endif


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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable) name:DEEZER_PLAYLIST_INFO_UPDATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable) name:DEEZER_PLAYLIST_DATA_UPDATED object:nil];
    
    [self.view setBackgroundColor:UIColorFromRGB(0x3a424c)];
    
    // Setup sync button
    UIButton *btnSync = [[UIButton alloc] initWithFrame:CGRectMake(20, 65, 100, 50)];
    [btnSync setTitle:@"Sync" forState:UIControlStateNormal];
    [btnSync setBackgroundColor:UIColorFromRGB(0xff5335)];
    [btnSync.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:20]];
    [btnSync addTarget:self action:@selector(btnSyncPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSync];
    
    // Setup track counter
    _lblTrackCounter = [[UILabel alloc] initWithFrame:CGRectMake(150, 140, 100, 80)];
    [_lblTrackCounter setFont:[UIFont fontWithName:@"Helvetica" size:48]];
    [_lblTrackCounter setTextColor:[UIColor whiteColor]];
    [_lblTrackCounter setText:@"3"];
    [_lblTrackCounter setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_lblTrackCounter];
    
    UIStepper *stepperTracks = [[UIStepper alloc] initWithFrame:CGRectMake(150, 230, 160, 60)];
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
    [_tablePlaylists setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    [self.view addSubview:_tablePlaylists];
    
    [self refreshTable];
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

- (void)btnSyncPressed:(id)btn
{
    [APP_DELEGATE.deezerClient connectAndStartSync];
}

- (void)refreshTable
{
    [_tablePlaylists reloadData];
    DEBUGLog(@"%@",[APP_DELEGATE.persistencyManager getPlaylists]);
}


#pragma mark - TableView delegate implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[APP_DELEGATE.persistencyManager getPlaylists] count];
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
    
    Playlist *pl = (Playlist *)[[APP_DELEGATE.persistencyManager getPlaylists] objectAtIndex:indexPath.row];
    [cell.textLabel setText:pl.title];
    
    if(pl.isReadyForSpatialAudioUse)
    {
        [cell.detailTextLabel setText:@"Ready"];
    }
    else
    {
        [cell.detailTextLabel setText:@"Not synced yet..."];
    }
    
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
