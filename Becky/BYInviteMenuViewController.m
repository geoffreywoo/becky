//
//  BYInviteMenuViewController.m
//  Becky
//
//  Created by Geoffrey Woo on 6/9/14.
//  Copyright (c) 2014 Becky. All rights reserved.
//

#import "BYInviteMenuViewController.h"
#import "BYInviteViewCell.h"
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <Parse/Parse.h>
#import <AFNetworking.h>

@interface BYInviteMenuViewController () <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSArray *inviteOptions;
@property (nonatomic, strong) NSArray *beckyColors;

@end

ABAddressBookRef addressBook;

@implementation BYInviteMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,110)];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, headerView.frame.size.height)];
    
    headerView.backgroundColor = [UIColor colorWithRed:239/255.0 green:166/255.0 blue:229/255.0 alpha:1],
    
    //button.textAlignment = NSTextAlignmentCenter;
    [button setTitle:@"+" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:80];
    button.titleLabel.textColor = [UIColor whiteColor];

    [button addTarget:self action:@selector(plusButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [button setEnabled:true];
    [headerView addSubview:button];
    return headerView;
}

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return  110.0;
}


- (void)viewWillAppear:(BOOL)animated
{
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.inviteOptions = @[@"PHONEBOOK",@"SMS",@"EMAIL"];
    NSLog(@"viewWillAppear");
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
    return [self.inviteOptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BYInviteViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kBYInviteCellIdentifier];
    if (!cell) {
        cell = [[BYInviteViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kBYInviteCellIdentifier];
    }
    
    NSLog(@"invite option: %@",[self.inviteOptions objectAtIndex:[indexPath row]]);
    [[cell inviteOptionButton] setTitle:[self.inviteOptions objectAtIndex:[indexPath row]] forState:UIControlStateNormal];
    NSUInteger colorIndex = [indexPath row]%[_beckyColors count];
    cell.contentView.backgroundColor=[_beckyColors objectAtIndex:colorIndex];
    // cell.backgroundColor=[_beckyColors objectAtIndex:colorIndex];
    
    if ( [((NSString*)[self.inviteOptions objectAtIndex:[indexPath row]]) isEqualToString:@"PHONEBOOK"]) {
        [[cell inviteOptionButton] addTarget:self
                                      action:@selector(phonebookButtonSelected:)
                            forControlEvents:UIControlEventTouchUpInside];
        [[cell inviteOptionButton] setEnabled:true];
        [cell inviteOptionButton].tag = [indexPath row];
    } else if ( [((NSString*)[self.inviteOptions objectAtIndex:[indexPath row]]) isEqualToString:@"SMS"]) {
        [[cell inviteOptionButton] addTarget:self
                                      action:@selector(smsButtonSelected:)
                            forControlEvents:UIControlEventTouchUpInside];
        [[cell inviteOptionButton] setEnabled:true];
        [cell inviteOptionButton].tag = [indexPath row];
    } else if ( [((NSString*)[self.inviteOptions objectAtIndex:[indexPath row]]) isEqualToString:@"EMAIL"]) {
        [[cell inviteOptionButton] addTarget:self
                                      action:@selector(emailButtonSelected:)
                            forControlEvents:UIControlEventTouchUpInside];
        [[cell inviteOptionButton] setEnabled:true];
        [cell inviteOptionButton].tag = [indexPath row];
    }
    
    [cell label].hidden = YES;
    [cell activityIndicator].hidden = YES;
    
    return cell;
}

- (void) turnOffSpinners
{
    for (NSInteger j = 0; j < [self.tableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:j]; ++i)
        {
            BYInviteViewCell *cell = (BYInviteViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
            [[cell activityIndicator] startAnimating];
            [cell activityIndicator].hidden = YES;
            [cell inviteOptionButton].hidden = NO;
        }
    }
}

- (void)plusButtonSelected:(id)button
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)phonebookButtonSelected:(UIButton*)button
{
    BYInviteViewCell *cell = (BYInviteViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
    [[cell activityIndicator] startAnimating];
    [cell activityIndicator].hidden = NO;
    [cell inviteOptionButton].hidden = YES;
    
    NSLog(@"phonebook button");
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted) {
        [self uploadAddressBook];
    } else {
        [self turnOffSpinners];
    }
}

- (void)smsButtonSelected:(UIButton*)button
{
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    BYInviteViewCell *cell = (BYInviteViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
    [[cell activityIndicator] startAnimating];
    [cell activityIndicator].hidden = NO;
    [cell inviteOptionButton].hidden = YES;
    
    NSArray *recipents = @[];
    NSString *message = [NSString stringWithFormat:@"I want to BECKY with you! Download here: LINK"];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    [self turnOffSpinners];
    
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)emailButtonSelected:(UIButton*)button
{
    if(![MFMailComposeViewController canSendMail]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support EMAIL!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    BYInviteViewCell *cell = (BYInviteViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
    [[cell activityIndicator] startAnimating];
    [cell activityIndicator].hidden = NO;
    [cell inviteOptionButton].hidden = YES;
    
    NSArray *recipents = @[];
    NSString *message = [NSString stringWithFormat:@"I want to BECKY with you! Download here: LINK"];
    
    MFMailComposeViewController *messageController = [[MFMailComposeViewController alloc] init];
    messageController.mailComposeDelegate = self;
    [messageController setToRecipients:recipents];
    [messageController setMessageBody:message isHTML:NO];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self turnOffSpinners];
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
            
        case MFMailComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send Email!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MFMailComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (void)uploadAddressBook {
    NSLog(@"upload address book");
    addressBook = ABAddressBookCreateWithOptions(nil,nil);
    if (addressBook == NULL) return;
    NSLog(@"addressbook not nil");
    CFArrayRef all = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex n = ABAddressBookGetPersonCount(addressBook);
    NSLog(@"%ld",n);
    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    for( int i = 0 ; i < n ; i++ )
    {
        ABRecordRef ref = CFArrayGetValueAtIndex(all, i);
        NSDictionary *contact = [self shortDictionaryRepresentationForABPerson:ref];
        [contacts addObject:contact];
    }
    
    NSDate *date = [NSDate date];
    NSTimeInterval ti = [date timeIntervalSince1970];
    NSNumber *unixTimestamp = [NSNumber numberWithInt:ti];
    
    NSLog(@"contacts: %@",contacts);
    
    NSData *contactsData = [NSJSONSerialization dataWithJSONObject:contacts options:0 error:nil];
    NSString *contactsJson = [[NSString alloc] initWithData:contactsData encoding:NSUTF8StringEncoding];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* phone = (NSString*)[defaults objectForKey:@"phone"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"phone": phone, @"contacts": contactsJson};
    [manager POST:@"http://beckyapp.herokuapp.com/syncContacts" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [self turnOffSpinners];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Phonebook Upload Failed." message:@"Try again!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
        [self turnOffSpinners];
    }];
}

- (NSMutableArray *) phoneNumbersForABPerson:(ABRecordRef) person
{
    NSMutableArray *phoneNumbersArray = [[NSMutableArray alloc] init];
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    for (int i=0; i < ABMultiValueGetCount(phoneNumbers); i++) {
        NSString *phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
        [phoneNumbersArray addObject:phoneNumber];
    }
    return phoneNumbersArray;
}

- (NSMutableArray *) emailsForABPerson:(ABRecordRef) person
{
    NSMutableArray *emailsArray = [[NSMutableArray alloc] init];
    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    for (int i=0; i < ABMultiValueGetCount(emails); i++) {
        NSString *email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, i);
        [emailsArray addObject:email];
    }
    return emailsArray;
}

- (NSDictionary *) shortDictionaryRepresentationForABPerson:(ABRecordRef) person
{
    NSLog(@"short dictionary representation for ABPerson");
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person,kABPersonFirstNameProperty);
    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person,kABPersonLastNameProperty);
    if (firstName == nil) {
        [dictionary setObject:@"" forKey:@"firstName"];
    } else {
        [dictionary setObject:firstName forKey:@"firstName"];
    }
    
    if (lastName == nil) {
        [dictionary setObject:@"" forKey:@"lastName"];
    } else {
        [dictionary setObject:lastName forKey:@"lastName"];
    }
    
    NSMutableArray *phoneNumbersArray = [self phoneNumbersForABPerson:person];
    [dictionary setObject:phoneNumbersArray forKey:@"phone"];
    
    //NSMutableArray *emailsArray = [self emailsForABPerson:person];
    // [dictionary setObject:emailsArray forKey:@"email"];
    
    return dictionary;
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
