//
//  BYViewController.m
//  Becky
//
//  Created by Geoffrey Woo on 6/4/14.
//  Copyright (c) 2014 Becky. All rights reserved.
//

#import <Parse/Parse.h>
#import "BYViewController.h"
#import "BYHomeViewController.h"

@interface BYViewController ()

@end

@implementation BYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *phone = [defaults objectForKey:@"phone"];
    
    if (phone) {
        BYHomeViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"BYHomeViewController"];
        self.navigationController.viewControllers = @[controller];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
