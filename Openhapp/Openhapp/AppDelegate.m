//
//  AppDelegate.m
//  Openhapp
//
//  Created by Jesse on 16/2/24.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "LeftViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
/************************************************************************************/
/*
ALL NSUserDefaults Just For Testing SDK, It's Not Good Method, You Should Use Database To Save Them.
*/
/************************************************************************************/

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [NSThread sleepForTimeInterval:2.0f];
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [_window makeKeyAndVisible];
    LoginViewController *loginVC = [LoginViewController new];
    _window.rootViewController = loginVC;
    _window.backgroundColor = [UIColor whiteColor];
    //左菜单创建
    MainViewController *mainVC = [[MainViewController alloc] init];
    self.mainNVC = [[UINavigationController alloc] initWithRootViewController:mainVC];
    LeftViewController *leftVC = [[LeftViewController alloc] init];
    self.leftSlideVC = [[LeftSlideViewController alloc] initWithLeftView:leftVC andMainView:self.mainNVC];
    //导航栏设置
    [[UINavigationBar appearance]setBarTintColor:[UIColor colorWithRed:0/255.0 green:191/255.0 blue:255/255.0 alpha:1.0]];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:20],NSFontAttributeName,nil]];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
