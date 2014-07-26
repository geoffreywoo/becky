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
#import "RMPhoneFormat.h"

@interface EnterYourNumberViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *phoneField;
@property (nonatomic, weak) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UIButton *countryCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *countryNameButton;
@property (weak, nonatomic) IBOutlet CountryPicker *countryPicker;
@property (nonatomic, strong) RMPhoneFormat *phoneFormat;

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
    
    self.phoneFormat = [[RMPhoneFormat alloc] initWithDefaultCountry:@"US"];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
    self.navigationController.navigationBar.hidden = NO;
    self.goButton.hidden = YES;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"triangular_pink@2x.png"]];
    
    UIColor *color = [UIColor whiteColor];
    self.phoneField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"(XXX) XXX-XXXX" attributes:@{NSForegroundColorAttributeName: color}];
    
    [self.countryPicker setSelectedCountryCode:@"US"];
    
    [self.phoneField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.phoneField setTintColor:[UIColor whiteColor]];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"VerifySegue"]) {
    }
}

- (IBAction)sendPhoneNumber {
    NSString *phone = self.phoneField.text;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"phone": phone, @"country_code": [self.phoneFormat defaultCallingCode]};
    [manager POST:@"https://beckyapp.herokuapp.com/v2/signup" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[responseObject objectForKey:@"phone"] forKey:@"phone"];
        [defaults synchronize];
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
    NSLog(@"textFieldDidChange: %d", textField.text.length);
    
    NSString *number = [NSString stringWithFormat:@"%@%@",self.countryCodeButton.titleLabel.text,textField.text];
    
    if (textField.text.length > 4 && [self.phoneFormat isPhoneNumberValid:number]) {
        self.goButton.hidden = NO;
    } else {
        self.goButton.hidden = YES;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldBeginEditing");
    self.countryPicker.hidden = YES;

    NSString *number = [NSString stringWithFormat:@"%@%@",self.countryCodeButton.titleLabel.text,textField.text];
    
    if (textField.text.length > 4 && [self.phoneFormat isPhoneNumberValid:number]) {
        self.goButton.hidden = NO;
    } else {
        self.goButton.hidden = YES;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textFieldDidEndEditing");
}

- (IBAction)pickCountry:(id)sender {
    [self.phoneField resignFirstResponder];
    self.goButton.hidden = YES;
    self.countryPicker.hidden = NO;
}

- (void)countryPicker:(CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code
{
    [self.countryNameButton setTitle:name forState:UIControlStateNormal];
    self.phoneFormat = [[RMPhoneFormat alloc] initWithDefaultCountry:code];
    
    NSString *callingCode = [self.phoneFormat defaultCallingCode];
    
    if (callingCode) {
        callingCode = [NSString stringWithFormat:@"+%@",callingCode];
    } else {
        callingCode = @"+1";
    }
    [self.countryCodeButton setTitle:callingCode forState:UIControlStateNormal];
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
