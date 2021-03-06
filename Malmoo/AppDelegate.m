//
//  AppDelegate.m
//  Malmoo
//
//  Created by folse on 3/5/14.
//  Copyright (c) 2014 Folse. All rights reserved.
//

#import "AppDelegate.h"
#import "TSMainController.h"
#import "JDMenuViewController.h"
#import "UMFeedback.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:APP_COLOR];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Light" size:20.0],NSFontAttributeName,nil]];
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    [application setStatusBarHidden:NO];

    [Parse setApplicationId:@"MQRrReTdb9c82PETy0BfUoL0ck6xGpwaZqelPWX5" clientKey:@"tocPd69YNtJQkzpuSY73pWA3O0f9HxA6K57mgubS"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [UMFeedback setAppkey:UMENG_APP_KEY];
    [UMFeedback setLogEnabled:YES];
    [MobClick startWithAppkey:UMENG_APP_KEY reportPolicy:SEND_INTERVAL channelId:@"AppStore"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    UIViewController *menuController = [[JDMenuViewController alloc] init];
    UINavigationController *navController = [MAIN_STORYBOARD instantiateViewControllerWithIdentifier:@"mainNav"];
    JDSideMenu *sideMenu = [[JDSideMenu alloc] initWithContentController:navController menuController:menuController];
    [sideMenu setBackgroundImage:[UIImage imageNamed:@"bg_menu"]];
    self.window.rootViewController = sideMenu;
    
    return YES;
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
