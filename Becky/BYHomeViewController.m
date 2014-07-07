//
//  BYHomeViewController.m
//  Becky
//
//  Created by Geoffrey Woo on 6/4/14.
//  Copyright (c) 2014 Becky. All rights reserved.
//

#import "BYHomeViewController.h"
#import "BYMainViewCell.h"
#import "BYInviteMenuViewCell.h"
#import <AFNetworking.h>
#import "BYFriend.h"
#import <Parse/Parse.h>

@interface BYHomeViewController ()

@property (nonatomic, strong) NSArray *beckyColors;
@property (nonatomic) float originalOrigin;
@property (nonatomic) bool pooToggle;
@property (nonatomic) bool pooTimeout;
@property (nonatomic) double lastPooTimestamp;
@property (nonatomic, strong) NSTimer *timer;
//@property (nonatomic, strong) UIProgressView *pooProgressBar;
@property (nonatomic, strong) UILabel *pooProgressTimeLabel;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) NSString *score;
@property (nonatomic, strong) NSString *phone;

@property (nonatomic) double timeoutPeriod;

@end


@implementation BYHomeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    
    _beckyColors = [[NSArray alloc] initWithObjects:
     [UIColor colorWithRed:255/255.0 green:127/255.0 blue:183/255.0 alpha:1],
     [UIColor colorWithRed:127/255.0 green:219/255.0 blue:255/255.0 alpha:1],
     [UIColor colorWithRed:255/255.0 green:246/255.0 blue:127/255.0 alpha:1],
     [UIColor colorWithRed:204/255.0 green:255/255.0 blue:128/255.0 alpha:1],
     [UIColor colorWithRed:255/255.0 green:157/255.0 blue:128/255.0 alpha:1],
     [UIColor colorWithRed:198/255.0 green:128/255.0 blue:255/255.0 alpha:1],
     [UIColor colorWithRed:127/255.0 green:255/255.0 blue:196/255.0 alpha:1],
     [UIColor colorWithRed:255/255.0 green:232/255.0 blue:128/255.0 alpha:1],nil];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"food_pink@2x.png"]];
    self.navigationController.viewControllers = @[self];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    
   // self.timeoutPeriod = 24*60*60;
    self.timeoutPeriod = 20;
    self.score = @"???";
}

-(void) tick:(NSTimer*)timer
{
    double currTime = [[NSDate date] timeIntervalSince1970];
    double diffTime = currTime - self.lastPooTimestamp;

    if ((int)currTime%10 ==0) [self updateFriends:self.phone];
    
    if ( diffTime > self.timeoutPeriod) {//60*60*24) {
        self.pooTimeout = NO;
//        self.pooProgressBar.hidden = YES;
        self.pooProgressTimeLabel.hidden = YES;
        self.pooToggleButton.enabled = YES;
    } else {
        self.pooTimeout = YES;
 //       [self.pooProgressBar setProgress:(diffTime/self.timeoutPeriod)animated:YES];
        [self.pooProgressTimeLabel setText:[self displayTimeWithSecond:(self.timeoutPeriod - diffTime)]];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.edgesForExtendedLayout=UIRectEdgeNone;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.phone = [defaults objectForKey:@"phone"];
    
    NSLog(@"phone on file: %@", self.phone);
    
    self.lastPooTimestamp = [[defaults objectForKey:@"lastPooTimestamp"] doubleValue];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                                selector:@selector(tick:) userInfo:nil repeats:YES];
    
    [self getScore:self.phone];
    [self getFriends:self.phone];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    NSString *channelName = [NSString stringWithFormat:@"a%@",self.phone];
    [currentInstallation addUniqueObject:channelName forKey:@"channels"];
    [currentInstallation saveInBackground];
    
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:@"ScorePush"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification) {
                        NSLog(@"%@", notification.name);
                        [self getScore:self.phone];

                    }];
    [center addObserverForName:@"FriendsPush"
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification) {
                        NSLog(@"%@", notification.name);
                        [self getFriends:self.phone];
                    }];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver: self];
    [self.timer invalidate];
}



- (void) getFriends:(NSString *)phone
{
    
    NSDictionary *parameters = @{@"phone": phone};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://beckyapp.herokuapp.com/getFriendList" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        if (! jsonData) {
            NSLog(@"Got an error: %@", error);
        } else {
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:jsonData //1
                                  
                                  options:kNilOptions
                                  error:&error];
            NSArray *friendsArray = [json objectForKey:@"friendList"];
            NSMutableArray *tempFriends = [[NSMutableArray alloc] init];
            for (id object in friendsArray) {
                BYFriend *f = [[BYFriend alloc] initWithJSON:object];
                [tempFriends addObject:f];
            }
            //  _friends = @[@"GW",@"MB",@"SS",@"CK",@"LO",@"OB",@"GW",@"MB",@"SS",@"CK",@"LO",@"OB"];
            _friends = [NSArray arrayWithArray:tempFriends];
            
            NSLog(@"friends count: %i", [self.friends count]);
            NSLog(@"friends: %@", self.friends);
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (BYFriend *) findFriend: (NSString *)phone {
    for (BYFriend *f in self.friends) {
        if ([phone isEqualToString:f.phoneNumber]) {
            return f;
        }
    }
    return nil;
}

- (void) updateFriends:(NSString *)phone
{
    
    NSDictionary *parameters = @{@"phone": phone};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://beckyapp.herokuapp.com/getFriendList" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        if (! jsonData) {
            NSLog(@"Got an error: %@", error);
        } else {
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:jsonData //1
                                  
                                  options:kNilOptions
                                  error:&error];
            NSArray *friendsArray = [json objectForKey:@"friendList"];
            NSMutableArray *tempFriends = [NSMutableArray arrayWithArray:self.friends];
            for (id object in friendsArray) {
                BYFriend *tempFriend = [[BYFriend alloc] initWithJSON:object];
                BYFriend *existingFriend = [self findFriend:tempFriend.phoneNumber];
                if (existingFriend) {
                    [existingFriend update:tempFriend];
                } else {
                    [tempFriends addObject:tempFriend];
                }
            }
            //  _friends = @[@"GW",@"MB",@"SS",@"CK",@"LO",@"OB",@"GW",@"MB",@"SS",@"CK",@"LO",@"OB"];
            _friends = [NSArray arrayWithArray:tempFriends];
            
            NSLog(@"friends count: %i", [self.friends count]);
            NSLog(@"friends: %@", self.friends);
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


- (void) getScore:(NSString *)phone
{
    NSDictionary *parameters = @{@"phone": phone};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://beckyapp.herokuapp.com/getScore" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        if (! jsonData) {
            NSLog(@"Got an error: %@", error);
        } else {
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:jsonData //1
                                  
                                  options:kNilOptions
                                  error:&error];
            NSLog(@"json: %@",json);
            self.score = [[json objectForKey:@"score"] stringValue];
            NSLog(@"score: %@",self.score);
            
            [self.headerLabel setText:self.score];
 
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,110)];
    
    self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, headerView.frame.size.width, headerView.frame.size.height)];

    headerView.backgroundColor = [UIColor colorWithRed:239/255.0 green:166/255.0 blue:229/255.0 alpha:1],

    self.headerLabel.textAlignment = NSTextAlignmentLeft;
    self.headerLabel.font = [UIFont boldSystemFontOfSize:70];
    self.headerLabel.textColor = [UIColor whiteColor];
    [self.headerLabel setText:self.score];

    [headerView addSubview:self.headerLabel];
    
    self.pooToggleButton = [[UIButton alloc] initWithFrame:CGRectMake(220, 0, 100, 100)];
    
    self.pooToggleButton.backgroundColor = [UIColor clearColor];
    [self.pooToggleButton setImage:[UIImage imageNamed:@"poo.png"] forState:UIControlStateNormal];
    [self.pooToggleButton setImage:[UIImage imageNamed:@"poo_dark.png"] forState:UIControlStateDisabled];
    [self.pooToggleButton addTarget:self action:@selector(pooToggleSelected:) forControlEvents:UIControlEventTouchDown];
    [headerView insertSubview:self.pooToggleButton aboveSubview:self.view];
    /*
    self.pooProgressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(230,60,80,80)];
    
    UIImage *track = [[UIImage imageNamed:@"track"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UIImage *load = [[UIImage imageNamed:@"load"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [self.pooProgressBar setTrackImage:track];
    [self.pooProgressBar setProgressImage:load];
    
    [headerView insertSubview:self.pooProgressBar aboveSubview:self.view];
    */
    double currTime = [[NSDate date] timeIntervalSince1970];
    double diffTime = currTime - self.lastPooTimestamp;
    
    //NSLog(@"%d",self.timeoutPeriod - diffTime);
    
    self.pooProgressTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(237,80,80,23)];
    [self.pooProgressTimeLabel setText:[self displayTimeWithSecond:(self.timeoutPeriod - diffTime)]];
    [self.pooProgressTimeLabel setTextColor: [UIColor whiteColor]];
    
    [headerView insertSubview:self.pooProgressTimeLabel aboveSubview:self.view];
    
    if ( diffTime > self.timeoutPeriod) {//60*60*24) {
        self.pooTimeout = NO;
 //       self.pooProgressBar.hidden = YES;
        self.pooProgressTimeLabel.hidden = YES;
        self.pooToggleButton.enabled = YES;
    } else {
        self.pooTimeout = YES;
//        self.pooProgressBar.hidden = NO;
        self.pooProgressTimeLabel.hidden = NO;
        self.pooToggleButton.enabled = NO;
    }
    
    return headerView;
}

- (NSString *)displayTimeWithSecond:(NSInteger)diffTimeSeconds
{
    NSInteger remindMinute = diffTimeSeconds / 60;
    NSInteger remindHours = remindMinute / 60;
    
    NSInteger remindMinutes = diffTimeSeconds - (remindHours * 3600);
    NSInteger remindMinuteNew = remindMinutes / 60;
    
    NSInteger remindSecond = diffTimeSeconds - (remindMinuteNew * 60) - (remindHours * 3600);
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",remindHours,remindMinuteNew,remindSecond];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return  114.0;
}

- (void) setPooTimestamp {
    double currTime = [[NSDate date] timeIntervalSince1970];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:currTime forKey:@"lastPooTimestamp"];
    [defaults synchronize];
    self.lastPooTimestamp = currTime;
    [self pooToggleSelected:nil];
    self.pooTimeout = YES;
//    self.pooProgressBar.hidden = NO;
    self.pooProgressTimeLabel.hidden = NO;
    self.pooToggleButton.enabled = NO;
    [self.pooProgressTimeLabel setText:[self displayTimeWithSecond:(self.timeoutPeriod)]];
}

- (void) pooToggleSelected:(UIButton *)button
{
    if (self.pooTimeout) {//
        
    } else {
        self.pooToggle = !self.pooToggle;
        NSLog(@"poo toggle selected");
        [self checkPooToggleState];
    }
}

- (void) checkPooToggleState
{
    NSLog(@"checkPooToggleState");
    for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]-1; ++i)
        {
            ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]).beckyButton.hidden = self.pooToggle;
            ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]).bballButton.hidden = self.pooToggle;
            ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]).pizzaButton.hidden = self.pooToggle;
            ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]).pooButton.hidden = !self.pooToggle;
            
            ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]).scoreField.hidden = YES;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friends count] + 1;
}

- (UITableViewCell *) cellForInviteMenuCell:(UITableView *)tableView
{
    BYMainViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBYInviteMenuCellIdentifier];
    if (!cell) {
        cell = [[BYMainViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kBYInviteMenuCellIdentifier];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSLog(@"moveRowAtIndexPath");
    
    NSMutableArray *tempFriends = [NSMutableArray arrayWithArray:_friends];
    NSString *selected = (NSString*)[tempFriends objectAtIndex:fromIndexPath.row];
    [tempFriends removeObjectAtIndex:fromIndexPath.row];
    [tempFriends insertObject:selected atIndex:toIndexPath.row];
    _friends = [NSArray arrayWithArray:tempFriends];
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForRowAtIndexPath: %i",[indexPath row]);
    if ([indexPath row] == [self.friends count]) {
        return [self cellForInviteMenuCell:tableView];
    }
    
    BYMainViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBYMainViewCellIdentifier];
    if (!cell) {
        cell = [[BYMainViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kBYMainViewCellIdentifier];
    }
    
    BYFriend *friend = [self.friends objectAtIndex:[indexPath row]];
    
    [[cell initialsButton] setTitle:[friend initials] forState:UIControlStateNormal];
    [[cell initialsButton] addTarget:self action:@selector(initialsButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [cell.beckyButton setEnabled:true];
    [cell initialsButton].tag = [indexPath row];
    
    NSUInteger colorIndex = [indexPath row]%[_beckyColors count];
    cell.contentView.backgroundColor=[_beckyColors objectAtIndex:colorIndex];
    
    [cell.beckyButton addTarget:self
            action:@selector(beckyButtonSelected:)
               forControlEvents:UIControlEventTouchUpInside];
    [cell.beckyButton setEnabled:true];
    cell.beckyButton.tag=[indexPath row];
    cell.beckyButton.hidden = self.pooToggle;
    
    [cell.bballButton addTarget:self
                         action:@selector(ballButtonSelected:)
               forControlEvents:UIControlEventTouchUpInside];
    [cell.bballButton setEnabled:true];
    cell.bballButton.tag=[indexPath row];
    cell.bballButton.hidden = self.pooToggle;
    
    [cell.pizzaButton addTarget:self
                         action:@selector(pizzaButtonSelected:)
               forControlEvents:UIControlEventTouchUpInside];
    [cell.pizzaButton setEnabled:true];
    cell.pizzaButton.tag=[indexPath row];
    cell.pizzaButton.hidden = self.pooToggle;
    
    [cell.pooButton addTarget:self
                         action:@selector(pooButtonSelected:)
               forControlEvents:UIControlEventTouchUpInside];
    [cell.pooButton setEnabled:true];
    cell.pooButton.tag=[indexPath row];
    cell.pooButton.hidden = !self.pooToggle;
    
    [cell.scoreField setText:[NSString stringWithFormat:@"%d",[friend score]]];
    cell.scoreField.hidden = YES;
    
    cell.activity.hidden = YES;
    
    return cell;
}

- (void) refreshView
{
    for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]-1; ++i)
        {
            ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]).beckyButton.tag = i;
            ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]).bballButton.tag = i;
            ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]).pizzaButton.tag = i;
            ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]).pooButton.tag = i;
            [((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]) initialsButton].tag = i;
            NSUInteger colorIndex = i%[_beckyColors count];
            ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]).contentView.backgroundColor=[_beckyColors objectAtIndex:colorIndex];
        }
    }
}

- (void) emojiSent:(UIButton*)button
{
    NSLog(@"emoji sent %d", button.tag);
    NSIndexPath *oldPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [[self tableView] moveRowAtIndexPath:oldPath toIndexPath:newPath];

    NSMutableArray *tempFriends = [NSMutableArray arrayWithArray:_friends];
    NSString *selected = (NSString*)[tempFriends objectAtIndex:oldPath.row];
    [tempFriends removeObjectAtIndex:oldPath.row];
    [tempFriends insertObject:selected atIndex:newPath.row];
    _friends = [NSArray arrayWithArray:tempFriends];
    
    [self refreshView];
    
    NSLog(@"%@",_friends);
/*
    NSMutableArray *tempFriends = [NSMutableArray arrayWithArray:_friends];
    NSString *selected = (NSString*)[tempFriends objectAtIndex:button.tag];
    [tempFriends removeObjectAtIndex:button.tag];
    [tempFriends insertObject:selected atIndex:0];
    _friends = [NSArray arrayWithArray:tempFriends];
    [self.tableView reloadData];
 */
}

- (void) initialsButtonSelected:(UIButton*)button
{
    NSLog(@"initials button %d",button.tag);
    bool scoreShowing = !((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]]).scoreField.hidden;
    
    if (self.pooToggle) {
        ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]]).pooButton.hidden = !scoreShowing;
    } else {
        ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]]).beckyButton.hidden = !scoreShowing;
        ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]]).bballButton.hidden = !scoreShowing;
        ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]]).pizzaButton.hidden = !scoreShowing;

    }
    ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]]).scoreField.hidden = scoreShowing;
}

- (void) sentFrom:(NSString*) from to:(NSString*)to cell:(BYMainViewCell*)cell withEmoji:(NSString*)emoji
{
    NSDictionary *parameters = @{@"from": from, @"to":to, @"emoji":emoji};
    cell.activity.hidden = NO;
    
    [cell beckyButton].hidden = YES;
    [cell bballButton].hidden = YES;
    [cell pizzaButton].hidden = YES;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://beckyapp.herokuapp.com/send" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        
        if (! jsonData) {
            NSLog(@"Got an error: %@", error);
            
        } else {
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:jsonData //1
                                  
                                  options:kNilOptions
                                  error:&error];
            NSLog(@"json: %@",json);
            NSString *score = [[json objectForKey:@"score"] stringValue];
            NSLog(@"score: %@",score);
            
            [self.headerLabel setText:score];
            
        }
        cell.activity.hidden = YES;
        [cell beckyButton].hidden = NO;
        [cell bballButton].hidden = NO;
        [cell pizzaButton].hidden = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        cell.activity.hidden = YES;
        [cell beckyButton].hidden = NO;
        [cell bballButton].hidden = NO;
        [cell pizzaButton].hidden = NO;
    }];
}

- (void) ballButtonSelected:(UIButton*)button
{
    NSLog(@"ball %d",button.tag);
    [self emojiSent:button];
    
    BYFriend *friend = [self.friends objectAtIndex:button.tag];
    
    BYMainViewCell *cell = ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]]);
    
    NSLog(@"friend #: %@",[friend phoneNumber]);
    [self sentFrom:self.phone to:[friend phoneNumber] cell:cell withEmoji:@"🏀"];
    NSDictionary *dimensions = @{
                                 // Define ranges to bucket data points into meaningful segments
                                 @"from": self.phone,
                                 // Did the user filter the query?
                                 @"to": [friend phoneNumber]
                                 };
    [PFAnalytics trackEvent:@"ball" dimensions:dimensions];
}

- (void) beckyButtonSelected:(UIButton*)button
{
    NSLog(@"becky %d",button.tag);
    [self emojiSent:button];
    
    BYFriend *friend = [self.friends objectAtIndex:button.tag];
    
    BYMainViewCell *cell = ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]]);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *phone = [defaults objectForKey:@"phone"];
    
    NSLog(@"friend #: %@",[friend phoneNumber]);
    [self sentFrom:phone to:[friend phoneNumber] cell:cell withEmoji:@"🙆"];
    NSDictionary *dimensions = @{
                                 // Define ranges to bucket data points into meaningful segments
                                 @"from": self.phone,
                                 // Did the user filter the query?
                                 @"to": [friend phoneNumber]
                                 };
    [PFAnalytics trackEvent:@"becky" dimensions:dimensions];

}

- (void) pizzaButtonSelected:(UIButton*)button
{
    NSLog(@"pizza %d",button.tag);
    [self emojiSent:button];
    
    BYFriend *friend = [self.friends objectAtIndex:button.tag];
    
    BYMainViewCell *cell = ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]]);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *phone = [defaults objectForKey:@"phone"];
    
    NSLog(@"friend #: %@",[friend phoneNumber]);
    [self sentFrom:phone to:[friend phoneNumber] cell:cell withEmoji:@"🍕"];
    NSDictionary *dimensions = @{
                                 // Define ranges to bucket data points into meaningful segments
                                 @"from": self.phone,
                                 // Did the user filter the query?
                                 @"to": [friend phoneNumber]
                                 };
    [PFAnalytics trackEvent:@"pizza" dimensions:dimensions];
}

- (void) pooButtonSelected:(UIButton*)button
{
    NSLog(@"poo %d",button.tag);
    [self emojiSent:button];
    [self setPooTimestamp];
    
    BYFriend *friend = [self.friends objectAtIndex:button.tag];
    
    BYMainViewCell *cell = ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]]);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *phone = [defaults objectForKey:@"phone"];
    
    NSLog(@"friend #: %@",[friend phoneNumber]);
    [self sentFrom:phone to:[friend phoneNumber] cell:cell withEmoji:@"💩"];
    NSDictionary *dimensions = @{
                                 // Define ranges to bucket data points into meaningful segments
                                 @"from": self.phone,
                                 // Did the user filter the query?
                                 @"to": [friend phoneNumber]
                                 };
    [PFAnalytics trackEvent:@"poo" dimensions:dimensions];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 113;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
