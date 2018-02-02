//
//  PromptViewController.m
//  Openhapp
//
//  Created by Jesse on 16/3/2.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import "PromptViewController.h"
#import "AppDelegate.h"
#import "ScanViewController.h"
#import <systemconfiguration/captivenetwork.h>

@interface PromptViewController ()

@property (nonatomic,strong) NSString *currentssid;

@end

@implementation PromptViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"扫描二维码";
    self.navigationItem.hidesBackButton = YES;
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    
    CGFloat maxWidth = self.view.bounds.size.width;
    
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, maxWidth, 30)];
    promptLabel.text = @"点击扫描开始扫描二维码";
    promptLabel.textColor = [UIColor grayColor];
    promptLabel.font = [UIFont systemFontOfSize:14];
    promptLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:promptLabel];
    
    UIImageView *promptView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qr_info_graphic"]];
    promptView.frame = CGRectMake(20, 130, maxWidth - 40, maxWidth - 40);
    [self.view addSubview:promptView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame = CGRectMake(40, 130 + (maxWidth - 40) + 20, 80, 30);
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor colorWithRed:216/255.0 green:191/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [backBtn setBackgroundColor:[UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0]];
    [backBtn.layer setMasksToBounds:YES];
    [backBtn.layer setCornerRadius:3.0];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UIButton *scanBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    scanBtn.frame = CGRectMake(maxWidth - 120, 130 + (maxWidth - 40) + 20, 80, 30);
    [scanBtn setTitle:@"扫描" forState:UIControlStateNormal];
    [scanBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [scanBtn setTitleColor:[UIColor colorWithRed:216/255.0 green:191/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    scanBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [scanBtn setBackgroundColor:[UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0]];
    [scanBtn.layer setMasksToBounds:YES];
    [scanBtn.layer setCornerRadius:3.0];
    [scanBtn addTarget:self action:@selector(scanCamera) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanBtn];
    
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    if ((![[df objectForKey:@"homeNetworkName"] length]) || (![df objectForKey:@"homeNetworkName"]))
    {
        /*
        __block UITextField *tempTF = nil;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Home Network" message:@"Please Enter Home Network SSID" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            tempTF = textField;
        }];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [df setObject:tempTF.text forKey:@"homeNetworkName"];
            [df synchronize];
            [self promptPassword];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        */
        [self checkHomeNetwork];
    }
}

-(void)promptPassword
{
    NSString *ssid = [NSString stringWithFormat:@"Please Enter '%@' Home Network Password",self.currentssid];
    __block UITextField *tempTF = nil;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Home Network" message:ssid preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        tempTF = textField;
    }];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
        [df setObject:self.currentssid forKey:@"homeNetworkName"];
        [df setObject:tempTF.text forKey:@"homeNetworkPassword"];
        [df synchronize];
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)back
{
    AppDelegate *mainAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [mainAppDelegate.mainNVC popToRootViewControllerAnimated:YES];
}

-(void)scanCamera
{
    ScanViewController *scanVC = [ScanViewController new];
    [self.navigationController pushViewController:scanVC animated:YES];
}

-(void)checkHomeNetwork
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSArray* ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
        id info = nil;
        for (NSString* ifnam in ifs)
        {
            info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
            if (info && [info count])
            {
                break;
            }
        }
        NSString *currentSSID = info[@"SSID"];
        NSLog(@"Current SSID --> %@",currentSSID);
        self.currentssid = currentSSID;
        [self promptPassword];
    });
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
