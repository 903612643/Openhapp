//
//  AppDelegate.h
//  Openhapp
//
//  Created by Jesse on 16/2/24.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftSlideViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//左菜单
@property (strong, nonatomic) LeftSlideViewController *leftSlideVC;
//主界面导航
@property (strong, nonatomic) UINavigationController *mainNVC;

@end

