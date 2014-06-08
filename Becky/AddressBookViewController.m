//
//  HomeViewController.m
//  Becky
//
//  Created by Geoffrey Woo on 6/4/14.
//  Copyright (c) 2014 Becky. All rights reserved.
//

#import <Parse/Parse.h>
#import "AddressBookViewController.h"
#import <AddressBook/AddressBook.h>

@interface AddressBookViewController ()

@property (nonatomic, weak) IBOutlet UIButton *continueButton;

@end

ABAddressBookRef addressBook;

@implementation AddressBookViewController

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
    self.continueButton.hidden = YES;
    self.navigationController.navigationBar.hidden = YES;
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
        self.continueButton.hidden = NO;
    } else {
        self.continueButton.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{

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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* phone = (NSString*)[defaults objectForKey:@"phone"];
    [PFCloud callFunctionInBackground:@"syncContacts"
                       withParameters:@{@"phone": phone, @"contacts": contacts}
                                block:^(NSString *response, NSError *error) {
                                    if (!error) {
                                        NSLog(@"%@", response);
                                    }
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
