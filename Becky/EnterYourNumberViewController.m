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
@property (weak, nonatomic) IBOutlet UIButton *countryCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *countryNameButton;
@property (weak, nonatomic) IBOutlet CountryPicker *countryPicker;

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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"triangular_pink@2x.png"]];
    
    UIColor *color = [UIColor whiteColor];
    self.phoneField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"(XXX) XXX-XXXX" attributes:@{NSForegroundColorAttributeName: color}];
    
    [self.countryPicker setSelectedCountryCode:@"US"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.phoneField setTintColor:[UIColor whiteColor]];
//    [self.phoneField becomeFirstResponder];
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
    NSLog(@"textFieldDidChange: %d", textField.text.length);
    if (textField.text.length > 9) {
        self.goButton.hidden = NO;
    } else if (textField.text.length > 10) {
        [textField resignFirstResponder];
    } else {
        self.goButton.hidden = YES;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldBeginEditing");
    self.goButton.hidden = YES;
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
    NSLog(@"%@ %@", name, code);
    [self.countryNameButton setTitle:name forState:UIControlStateNormal];
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
