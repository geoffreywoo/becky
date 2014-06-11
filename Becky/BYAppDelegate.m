//
//  BYAppDelegate.m
//  Becky
//
//  Created by Geoffrey Woo on 6/4/14.
//  Copyright (c) 2014 Becky. All rights reserved.
//

#import <Parse/Parse.h>
#import "BYAppDelegate.h"

//@interface BYAppDelegate () <UIViewControllerAnimatedTransitioning>
//@end

@implementation BYAppDelegate

/*
-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // boilerplate
    UIViewController* vc1 =
    [transitionContext
     viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController* vc2 =
    [transitionContext
     viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView* con = [transitionContext containerView];
    CGRect r1start = [transitionContext initialFrameForViewController:vc1];
    CGRect r2end = [transitionContext finalFrameForViewController:vc2];
    UIView* v1 = vc1.view;
    UIView* v2 = vc2.view;
    // end boilerplate
    
    CGRect r = r2end;
    r.origin.y += r.size.height; // start at the bottom...
    v2.frame = r;
    [con addSubview:v2];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:0.4 animations:^{
        v2.frame = r2end; // ... and move up into place
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}
*/
- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
{
    [application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    // Override point for customization after application launch.
    [Parse setApplicationId:@"PDQyon3c2DBOu3VMzBlVOSSiW28vYmuTWiNquJIs"
                  clientKey:@"PIeYILJRXwVacmuxHz94BQNLcEDjjqNxalJ1J8fZ"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    return YES;
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    NSString *alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    if ([alert hasPrefix:@"From"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ScorePush" object:self];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FriendsPush" object:self];
    }
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
