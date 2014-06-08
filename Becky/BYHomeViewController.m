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

@interface BYHomeViewController ()

@property (nonatomic, strong) NSArray *beckyColors;

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
    
    _beckyColors = [[NSArray alloc] initWithObjects:
     [UIColor colorWithRed:255/255.0 green:127/255.0 blue:183/255.0 alpha:1],
     [UIColor colorWithRed:127/255.0 green:219/255.0 blue:255/255.0 alpha:1],
     [UIColor colorWithRed:255/255.0 green:246/255.0 blue:127/255.0 alpha:1],
     [UIColor colorWithRed:204/255.0 green:255/255.0 blue:128/255.0 alpha:1],
     [UIColor colorWithRed:255/255.0 green:157/255.0 blue:128/255.0 alpha:1],
     [UIColor colorWithRed:198/255.0 green:128/255.0 blue:255/255.0 alpha:1],
     [UIColor colorWithRed:127/255.0 green:255/255.0 blue:196/255.0 alpha:1],
     [UIColor colorWithRed:255/255.0 green:232/255.0 blue:128/255.0 alpha:1],nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.edgesForExtendedLayout=UIRectEdgeNone;
    _friends = @[@"GW",@"MB",@"SS",@"CK",@"LO",@"OB"];
    NSLog(@"viewWillAppear");
    NSLog(@"friends: %i", [self.friends count]);
    [self.tableView reloadData];
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
    [cell initialsField].text = [self.friends objectAtIndex:[indexPath row]];
    NSUInteger colorIndex = [indexPath row]%[_beckyColors count];
    cell.contentView.backgroundColor=[_beckyColors objectAtIndex:colorIndex];
   // cell.backgroundColor=[_beckyColors objectAtIndex:colorIndex];
    
    [cell.beckyButton addTarget:self
            action:@selector(beckyButtonSelected:)
  forControlEvents:UIControlEventTouchUpInside];
    [cell.beckyButton setEnabled:true];
    
    [cell.bballButton addTarget:self
                         action:@selector(ballButtonSelected:)
               forControlEvents:UIControlEventTouchUpInside];
    [cell.bballButton setEnabled:true];
    
    [cell.pizzaButton addTarget:self
                         action:@selector(pizzaButtonSelected:)
               forControlEvents:UIControlEventTouchUpInside];
    [cell.pizzaButton setEnabled:true];
    
    return cell;
}

- (void) ballButtonSelected:(id)button
{
    NSLog(@"ball");
}

- (void) beckyButtonSelected:(id)button
{
    NSLog(@"becky");
}

- (void) pizzaButtonSelected:(id)button
{
    NSLog(@"pizza");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
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
