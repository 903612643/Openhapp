//
//  AlertViewController.m
//  Openhapp
//
//  Created by Jesse on 16/5/8.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import "AlertViewController.h"
#import "AppDelegate.h"

@interface AlertViewController ()

@end

@implementation AlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Alert Log";
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    
    UIWebView *alertWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [alertWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.alertUrl]]];
    [self.view addSubview:alertWebView];
}

-(void)back
{
    AppDelegate *mainAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [mainAppDelegate.mainNVC popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
