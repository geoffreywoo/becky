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
@property (nonatomic) float originalOrigin;

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
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"food@2x.png"]];
    self.navigationController.viewControllers = @[self];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,110)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, headerView.frame.size.width, headerView.frame.size.height)];

    headerView.backgroundColor = [UIColor colorWithRed:239/255.0 green:166/255.0 blue:229/255.0 alpha:1],

    headerLabel.textAlignment = NSTextAlignmentLeft;
    headerLabel.font = [UIFont systemFontOfSize:70];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.text = @"1210";
    [headerView addSubview:headerLabel];
    
    self.pooToggleButton = [[UIButton alloc] initWithFrame:CGRectMake(200, 10, 100, 100)];
    
    self.pooToggleButton.backgroundColor = [UIColor clearColor];
    [self.pooToggleButton setImage:[UIImage imageNamed:@"poo.png"] forState:UIControlStateNormal];
    [self.pooToggleButton addTarget:self action:@selector(pooToggleSelected:) forControlEvents:UIControlEventTouchDown];
    [headerView insertSubview:self.pooToggleButton aboveSubview:self.view];
    
    return headerView;
    
}

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return  110.0;
}

bool pooToggle = false;

- (void) pooToggleSelected:(UIButton *)button
{
    pooToggle = !pooToggle;
    NSLog(@"poo toggle selected");
    [self checkPooToggleState];
}

- (void) checkPooToggleState
{
    NSLog(@"checkPooToggleState");
    for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]-1; ++i)
        {
            NSLog(@"for row: %d", i);
            ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]).beckyButton.hidden = pooToggle;
            ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]).bballButton.hidden = pooToggle;
            ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]).pizzaButton.hidden = pooToggle;
            ((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]).pooButton.hidden = !pooToggle;
        }
    }
    
    NSLog(@"checkPooToggleState");
    for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]-1; ++i)
        {
            NSLog(@"for row: %d", i);
            NSLog(@"becky: %d",((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]).beckyButton.hidden);
            NSLog(@"bball: %d",((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]).bballButton.hidden);
            NSLog(@"pizza: %d",((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]).pizzaButton.hidden);
            NSLog(@"poo: %d",((BYMainViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]]).pooButton.hidden);
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.edgesForExtendedLayout=UIRectEdgeNone;
    _friends = @[@"GW",@"MB",@"SS",@"CK",@"LO",@"OB",@"GW",@"MB",@"SS",@"CK",@"LO",@"OB"];
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
    
    [cell initialsField].text = [self.friends objectAtIndex:[indexPath row]];
    NSUInteger colorIndex = [indexPath row]%[_beckyColors count];
    cell.contentView.backgroundColor=[_beckyColors objectAtIndex:colorIndex];
   // cell.backgroundColor=[_beckyColors objectAtIndex:colorIndex];
    
    [cell.beckyButton addTarget:self
            action:@selector(beckyButtonSelected:)
  forControlEvents:UIControlEventTouchUpInside];
    [cell.beckyButton setEnabled:true];
    cell.beckyButton.tag=[indexPath row];
    if (pooToggle) cell.beckyButton.hidden = YES;
    
    [cell.bballButton addTarget:self
                         action:@selector(ballButtonSelected:)
               forControlEvents:UIControlEventTouchUpInside];
    [cell.bballButton setEnabled:true];
    cell.bballButton.tag=[indexPath row];
    if (pooToggle) cell.bballButton.hidden = YES;
    
    [cell.pizzaButton addTarget:self
                         action:@selector(pizzaButtonSelected:)
               forControlEvents:UIControlEventTouchUpInside];
    [cell.pizzaButton setEnabled:true];
    cell.pizzaButton.tag=[indexPath row];
    if (pooToggle) cell.pizzaButton.hidden = YES;
    
    [cell.pooButton addTarget:self
                         action:@selector(pooButtonSelected:)
               forControlEvents:UIControlEventTouchUpInside];
    [cell.pooButton setEnabled:true];
    cell.pooButton.tag=[indexPath row];
    if (pooToggle) cell.pooButton.hidden = NO;
    
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

- (void) ballButtonSelected:(UIButton*)button
{
    NSLog(@"ball %d",button.tag);
    [self emojiSent:button];
}

- (void) beckyButtonSelected:(UIButton*)button
{
    NSLog(@"becky %d",button.tag);
    [self emojiSent:button];

}

- (void) pizzaButtonSelected:(UIButton*)button
{
    NSLog(@"pizza %d",button.tag);
    [self emojiSent:button];

}

- (void) pooButtonSelected:(UIButton*)button
{
    NSLog(@"poo %d",button.tag);
    [self emojiSent:button];
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
