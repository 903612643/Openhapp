//
//  UserViewController.m
//  Openhapp
//
//  Created by Jesse on 16/5/7.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import "UserViewController.h"
#import "AppDelegate.h"
#import "ModifyEmailViewController.h"
#import "ModifyPasswordViewController.h"
#import "ModifyUserNameViewController.h"

@interface UserViewController ()

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"用户";
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    //左菜单按钮
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 28, 25);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(openOrCloseLeftView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    
    UIButton *emailBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    emailBtn.frame = CGRectMake((self.view.bounds.size.width - 160) / 2, (self.view.size.height - 160) / 3, 160, 60);
    [emailBtn setTitle:@"Email" forState:UIControlStateNormal];
    [emailBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [emailBtn setTitleColor:[UIColor colorWithRed:216/255.0 green:191/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    emailBtn.titleLabel.font = [UIFont systemFontOfSize:28];
    [emailBtn setBackgroundColor:[UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0]];
    [emailBtn.layer setMasksToBounds:YES];
    [emailBtn.layer setCornerRadius:3.0];
    [self.view addSubview:emailBtn];
    [emailBtn addTarget:self action:@selector(enterEmail) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *pwBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    pwBtn.frame = CGRectMake((self.view.bounds.size.width - 160) / 2, (self.view.size.height - 160) / 3 * 2, 160, 60);
    [pwBtn setTitle:@"Password" forState:UIControlStateNormal];
    [pwBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [pwBtn setTitleColor:[UIColor colorWithRed:216/255.0 green:191/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    pwBtn.titleLabel.font = [UIFont systemFontOfSize:28];
    [pwBtn setBackgroundColor:[UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0]];
    [pwBtn.layer setMasksToBounds:YES];
    [pwBtn.layer setCornerRadius:3.0];
    [self.view addSubview:pwBtn];
    [pwBtn addTarget:self action:@selector(enterPassword) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *nameBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    nameBtn.frame = CGRectMake((self.view.bounds.size.width - 160) / 2, self.view.size.height - 160, 160, 60);
    [nameBtn setTitle:@"Name" forState:UIControlStateNormal];
    [nameBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nameBtn setTitleColor:[UIColor colorWithRed:216/255.0 green:191/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    nameBtn.titleLabel.font = [UIFont systemFontOfSize:28];
    [nameBtn setBackgroundColor:[UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0]];
    [nameBtn.layer setMasksToBounds:YES];
    [nameBtn.layer setCornerRadius:3.0];
    [self.view addSubview:nameBtn];
    [nameBtn addTarget:self action:@selector(enterName) forControlEvents:UIControlEventTouchUpInside];
    
    
}

-(void)enterEmail
{
    ModifyEmailViewController *meVC = [ModifyEmailViewController new];
    [self.navigationController pushViewController:meVC animated:YES];
}

-(void)enterPassword
{
    ModifyPasswordViewController *mpVC = [ModifyPasswordViewController new];
    [self.navigationController pushViewController:mpVC animated:YES];
}

-(void)enterName
{
    ModifyUserNameViewController *mnVC = [ModifyUserNameViewController new];
    [self.navigationController pushViewController:mnVC animated:YES];
}

//打开左菜单
-(void)openOrCloseLeftView
{
    AppDelegate *mainAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (mainAppDelegate.leftSlideVC.closed)
    {
        [mainAppDelegate.leftSlideVC openLeftView];
    }
    else
    {
        [mainAppDelegate.leftSlideVC closeLeftView];
    }
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
