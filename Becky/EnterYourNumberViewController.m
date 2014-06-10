//
//  EnterYourNumberViewController.m
//  Becky
//
//  Created by Geoffrey Woo on 6/4/14.
//  Copyright (c) 2014 Becky. All rights reserved.
//

#import <Parse/Parse.h>
#import <AFNetworking.h>
#import "EnterYourNumberViewController.h"
#import "VerifyYourNumberViewController.h"

@interface EnterYourNumberViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *phoneField;
@property (nonatomic, weak) IBOutlet UIButton *goButton;

@end

@implementation EnterYourNumberViewController

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
    [self.phoneField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
    self.navigationController.navigationBar.hidden = NO;
    self.goButton.hidden = YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"VerifySegue"]) {
        VerifyYourNumberViewController *destination = (VerifyYourNumberViewController *)segue.destinationViewController;
        destination.phone = self.phoneField.text;
    }
}

- (IBAction)sendPhoneNumber {
    NSString *phone = self.phoneField.text;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"phone": phone};
    [manager POST:@"http://beckyapp.herokuapp.com/signup" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidChange:(UITextField*)textField
{
    NSLog(@"textFieldDidChange");
    if (textField.text.length > 9) {
        self.goButton.hidden = NO;
    } if (textField.text.length > 10) {
        [textField resignFirstResponder];
    } else {
        
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldBeginEditing");
    textField.text = @"";
    self.goButton.hidden = YES;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textFieldDidEndEditing");
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
