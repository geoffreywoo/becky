//
//  VerifyYourNumberViewController.m
//  Becky
//
//  Created by Geoffrey Woo on 6/4/14.
//  Copyright (c) 2014 Becky. All rights reserved.
//

#import <Parse/Parse.h>
#import "VerifyYourNumberViewController.h"

@interface VerifyYourNumberViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *verifyField;
@property (nonatomic, weak) IBOutlet UIButton *goButton;

@end

@implementation VerifyYourNumberViewController

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
    [self.verifyField addTarget:self
                        action:@selector(textFieldDidChange:)
              forControlEvents:UIControlEventEditingChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.goButton.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signUp {
    NSString *code = self.verifyField.text;
    NSString *phone = self.phone;
    NSLog(@"%@, %@",code,phone);
    
    [PFCloud callFunctionInBackground:@"verify"
                       withParameters:@{@"phone": phone, @"code": code}
                                block:^(NSString *response, NSError *error) {
                                    if (!error) {
                                        NSLog(@"%@", response);
                                
                                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                        [defaults setObject:phone forKey:@"phone"];
                                        [defaults synchronize];
                                        [self performSegueWithIdentifier:@"HomeViewSegue" sender:self];
                                        
                                    } else {
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Verification Failed" message:@"Retry your code, or re-enter your phone number!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                                        [alert show];
                                    }
                                }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"HomeViewSegue"]) {
    }
}

- (void)textFieldDidChange:(UITextField*)textField
{
    NSLog(@"textFieldDidChange");
    if (textField.text.length > 3) {
        [textField resignFirstResponder];
        self.goButton.hidden = NO;
    } else {
        
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldBeginEditing");
    self.verifyField.text = @"";
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
