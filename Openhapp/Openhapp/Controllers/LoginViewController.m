//
//  LoginViewController.m
//  Openhapp
//
//  Created by Jesse on 16/2/24.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import "DataTool.h"
#import "Switch.h"
#import "AppDelegate.h"
#import "RegisterViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
#import "FMDB.h"
#import "DataBaseTool.h"
#import "DeepCam_SDK.h"
#import "DC_AccountService.h"
#import "DC_CameraManager.h"
#import "ForgetViewController.h"

@interface LoginViewController ()<UITextFieldDelegate,DC_BasicMessagesDelegate,DC_RegisterAccountDelegate,DC_AuthenticateAccountDelegate,DC_ForgetAccountDelegate,DC_GetViewerCameraDelegate>
@property (nonatomic,strong) UITextField *userAccount;
@property (nonatomic,strong) UITextField *userPassword;
@property (nonatomic,strong) UIButton *loginBtn;
@property (nonatomic,strong) UIButton *registerBtn;
@property (nonatomic,strong) Switch *remindSwitch;
@property (nonatomic,strong) UILabel *remindLabel;
@property (nonatomic,strong) MBProgressHUD *introHUD;
@property (nonatomic,strong) NSTimer *introTimer;
@property (nonatomic,strong) NSTimer *loginTimer;
@property NSString *lastSyncDate;
@property NSInteger cameraCount;
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    [self.view setBackgroundColor:[UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
    
    CGFloat maxWidth = self.view.bounds.size.width;
    CGFloat distanceWidth = self.view.bounds.size.width - 320;//与基准宽差值
    CGFloat distanceHeight = (self.view.bounds.size.height - 480) / 2;//与基准高差值
    if (distanceHeight == 0)
    {
        distanceHeight = 20;
    }
    //Logo
    CGFloat logoWidth = 40 * 8 + distanceWidth;
    CGFloat logoHeight = logoWidth * 19 / 40;
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake((maxWidth - logoWidth) / 2, 0, logoWidth, logoHeight)];
    logoView.image = [UIImage imageNamed:@"logo"];
    [self.view addSubview:logoView];
    //用户名
    UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, logoHeight + distanceHeight, 40, 30)];
    userLabel.text = @"账号";
    userLabel.textColor = [UIColor blackColor];
    [self.view addSubview:userLabel];
    
    self.userAccount = [[UITextField alloc] initWithFrame:CGRectMake(65, logoHeight + distanceHeight, maxWidth - 85, 30)];
    NSString *inAccount = [DataTool getAccount];
    if (inAccount.length)//判断存在账号记录
    {
        self.userAccount.text = inAccount;
    }
    else
    {
        self.userAccount.placeholder = @"请输入电子邮件";
    }
    self.userAccount.borderStyle = UITextBorderStyleRoundedRect;
    self.userAccount.clearButtonMode = UITextFieldViewModeAlways;
    self.userAccount.keyboardType = UIKeyboardTypeDefault;
    self.userAccount.delegate = self;
    self.userAccount.returnKeyType = UIReturnKeyNext;
    [self.view addSubview:self.userAccount];
    //密码
    UILabel *pwLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, logoHeight + distanceHeight + 40, 40, 30)];
    pwLabel.text = @"密码";
    pwLabel.textColor = [UIColor blackColor];
    [self.view addSubview:pwLabel];
    
    self.userPassword = [[UITextField alloc] initWithFrame:CGRectMake(65, logoHeight + distanceHeight + 40, maxWidth - 85, 30)];
    if ([DataTool getRemindState])//记住密码模式
    {
        NSString *inPassword = [DataTool getPassword];
        if (inPassword.length)//判断存在密码记录
        {
            self.userPassword.text = inPassword;
        }
        else
        {
            self.userPassword.placeholder = @"请输入密码";
        }
    }
    else
    {
        self.userPassword.placeholder = @"请输入密码";
    }
    self.userPassword.borderStyle = UITextBorderStyleRoundedRect;
    self.userPassword.clearButtonMode = UITextFieldViewModeAlways;
    self.userPassword.clearsOnBeginEditing = YES;
    self.userPassword.secureTextEntry = YES;
    self.userPassword.keyboardType = UIKeyboardTypeASCIICapable;
    self.userPassword.delegate = self;
    self.userPassword.returnKeyType = UIReturnKeyGo;
    [self.view addSubview:self.userPassword];
    //登录
    if (![DataTool getLoginState])//判断注册登录记录
    {
        //登录
        self.loginBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        self.loginBtn.frame = CGRectMake((maxWidth - 160) / 3, logoHeight + distanceHeight + 100, 80, 30);
        [self.loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        self.loginBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        [self.loginBtn setTitleColor:[UIColor colorWithRed:220/255.0 green:20/255.0 blue:60/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.loginBtn setTitleColor:[UIColor colorWithRed:216/255.0 green:191/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateHighlighted];
        [self.loginBtn setBackgroundColor:[UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0]];
        [self.loginBtn.layer setMasksToBounds:YES];
        [self.loginBtn.layer setCornerRadius:3.0];
        [self.view addSubview:self.loginBtn];
        [self.loginBtn addTarget:self action:@selector(loginAccount) forControlEvents:UIControlEventTouchUpInside];
        //注册
        self.registerBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        self.registerBtn.frame = CGRectMake((maxWidth - 160) / 3 * 2 + 80, logoHeight + distanceHeight + 100, 80, 30);
        [self.registerBtn setTitle:@"注册" forState:UIControlStateNormal];
        self.registerBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        [self.registerBtn setTitleColor:[UIColor colorWithRed:138/255.0 green:43/255.0 blue:226/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.registerBtn setTitleColor:[UIColor colorWithRed:216/255.0 green:191/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateHighlighted];
        [self.registerBtn setBackgroundColor:[UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0]];
        [self.registerBtn.layer setMasksToBounds:YES];
        [self.registerBtn.layer setCornerRadius:3.0];
        [self.view addSubview:self.registerBtn];
        [self.registerBtn addTarget:self action:@selector(registerAccount) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        self.loginBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        self.loginBtn.frame = CGRectMake((maxWidth - 160) / 2, logoHeight + distanceHeight + 100, 160, 40);
        [self.loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        self.loginBtn.titleLabel.font = [UIFont systemFontOfSize:24];
        [self.loginBtn setTitleColor:[UIColor colorWithRed:220/255.0 green:20/255.0 blue:60/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.loginBtn setTitleColor:[UIColor colorWithRed:216/255.0 green:191/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateHighlighted];
        [self.loginBtn setBackgroundColor:[UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0]];
        [self.loginBtn.layer setMasksToBounds:YES];
        [self.loginBtn.layer setCornerRadius:6.0];
        [self.view addSubview:self.loginBtn];
        [self.loginBtn addTarget:self action:@selector(loginAccount) forControlEvents:UIControlEventTouchUpInside];
    }
    //忘记密码
    UIButton *forgetBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    forgetBtn.frame = CGRectMake(maxWidth - 80, logoHeight + distanceHeight + 160, 60, 20);
    [forgetBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
    [forgetBtn setTitleColor:[UIColor colorWithRed:30/255.0 green:144/255.0 blue:255/255.0 alpha:0.6] forState:UIControlStateNormal];
    [forgetBtn setTitleColor:[UIColor colorWithRed:100/255.0 green:149/255.0 blue:237/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    [forgetBtn addTarget:self action:@selector(forgetPassword) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forgetBtn];
    //记住密码
    self.remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, logoHeight + distanceHeight + 160, 60, 20)];
    self.remindLabel.text = @"记住密码";
    if ((![DataTool getLoginState]) || [self.userAccount.text isEqualToString:[DataTool getAccount]])//初次登录/用户
    {
        self.remindLabel.textColor = [UIColor colorWithRed:30/255.0 green:144/255.0 blue:255/255.0 alpha:0.6];
    }
    else
    {
        self.remindLabel.textColor = [UIColor colorWithRed:105/255.0 green:105/255.0 blue:105/255.0 alpha:0.8];
    }
    self.remindLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:self.remindLabel];
    
    UIImage *switchImage = [UIImage imageNamed:@"switch"];
    self.remindSwitch = [Switch switchWithImage:switchImage visibleWidth:switchImage.size.width / [UIScreen mainScreen].scale * 0.5];
    self.remindSwitch.origin = CGPointMake(85, logoHeight + distanceHeight + 160 - (switchImage.size.height / [UIScreen mainScreen].scale - 20) / 2);
    if ([DataTool getRemindState])//获取模式
    {
        [self.remindSwitch setOn:YES];
    }
    else
    {
        [self.remindSwitch setOn:NO];
    }
    [self.remindSwitch addTarget:self action:@selector(remindState:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.remindSwitch];
    //键盘收起通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRemindEnabled) name:UIKeyboardDidHideNotification object:nil];
    //初始化
    [self getUserInformationAndUpdate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    if ([[DataTool getAccount] length])//存在用户
    {
        self.userAccount.text = [DataTool getAccount];
    }
    else
    {
        self.userAccount.text = @"";
    }
    if ([[DataTool getPassword] length])//存在密码记录
    {
        self.userPassword.text = [DataTool getPassword];
    }
    else
    {
        self.userPassword.text = @"";
    }
    self.remindSwitch.userInteractionEnabled = YES;
    self.remindLabel.textColor = [UIColor colorWithRed:30/255.0 green:144/255.0 blue:255/255.0 alpha:0.6];
    
    if ([DataTool getLoginState])
    {
        [self.loginBtn removeFromSuperview];
        [self.registerBtn removeFromSuperview];
        CGFloat maxWidth = self.view.bounds.size.width;
        CGFloat distanceWidth = self.view.bounds.size.width - 320;
        CGFloat distanceHeight = (self.view.bounds.size.height - 480) / 2;
        if (distanceHeight == 0)
        {
            distanceHeight = 20;
        }
        CGFloat logoWidth = 40 * 8 + distanceWidth;
        CGFloat logoHeight = logoWidth * 19 / 40;
        self.loginBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        self.loginBtn.frame = CGRectMake((maxWidth - 160) / 2, logoHeight + distanceHeight + 100, 160, 40);
        [self.loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        self.loginBtn.titleLabel.font = [UIFont systemFontOfSize:24];
        [self.loginBtn setTitleColor:[UIColor colorWithRed:220/255.0 green:20/255.0 blue:60/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.loginBtn setTitleColor:[UIColor colorWithRed:216/255.0 green:191/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateHighlighted];
        [self.loginBtn setBackgroundColor:[UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0]];
        [self.loginBtn.layer setMasksToBounds:YES];
        [self.loginBtn.layer setCornerRadius:6.0];
        [self.view addSubview:self.loginBtn];
        [self.loginBtn addTarget:self action:@selector(loginAccount) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //监测网络
    __block LoginViewController *blockSelf = self;
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown:
                [blockSelf showNetStatus:@"未知网络状态"];
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                [blockSelf showNetStatus:@"当前无连接"];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                //[self showNetStatus:@"正在使用流量连接网络"];
                [blockSelf showNetStatus:@"正在加载数据"];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                //[self showNetStatus:@"正在使用WiFi连接网络"];
                [blockSelf showNetStatus:@"正在加载数据"];
                break;
                
            default:
                break;
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

-(void)showNetStatus:(NSString*)status
{
    self.introHUD.labelText = status;
}

//键盘return
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.userAccount])//切换输入框
    {
        [self.userAccount resignFirstResponder];
        [self.userPassword becomeFirstResponder];
        if ([self.userAccount.text isEqualToString:[DataTool getAccount]])//用户
        {
            self.remindSwitch.userInteractionEnabled = YES;
            self.remindLabel.textColor = [UIColor colorWithRed:30/255.0 green:144/255.0 blue:255/255.0 alpha:0.6];
        }
        else
        {
            self.remindSwitch.userInteractionEnabled = NO;
            self.remindLabel.textColor = [UIColor colorWithRed:105/255.0 green:105/255.0 blue:105/255.0 alpha:0.8];
        }
    }
    if ([textField isEqual:self.userPassword])//登录操作
    {
        if ([DataTool getLoginState])//判断登录记录
        {
            [self loginAccount];//登录
        }
        else
        {
            [self.userAccount resignFirstResponder];
            [self.userPassword resignFirstResponder];
            if ([self.userAccount.text isEqualToString:[DataTool getAccount]])//用户
            {
                self.remindSwitch.userInteractionEnabled = YES;
                self.remindLabel.textColor = [UIColor colorWithRed:30/255.0 green:144/255.0 blue:255/255.0 alpha:0.6];
            }
            else
            {
                self.remindSwitch.userInteractionEnabled = NO;
                self.remindLabel.textColor = [UIColor colorWithRed:105/255.0 green:105/255.0 blue:105/255.0 alpha:0.8];
            }
        }
    }
    return YES;
}

//触摸视图收起键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.userAccount resignFirstResponder];
    [self.userPassword resignFirstResponder];
    if ([self.userAccount.text isEqualToString:[DataTool getAccount]] || (![DataTool getLoginState]))//用户
    {
        self.remindSwitch.userInteractionEnabled = YES;
        self.remindLabel.textColor = [UIColor colorWithRed:30/255.0 green:144/255.0 blue:255/255.0 alpha:0.6];
    }
    else
    {
        self.remindSwitch.userInteractionEnabled = NO;
        self.remindLabel.textColor = [UIColor colorWithRed:105/255.0 green:105/255.0 blue:105/255.0 alpha:0.8];
    }
}

//改变可选状态
-(void)changeRemindEnabled
{
    if ([self.userAccount.text isEqualToString:[DataTool getAccount]] || (![DataTool getLoginState]))//用户
    {
        self.remindSwitch.userInteractionEnabled = YES;
        self.remindLabel.textColor = [UIColor colorWithRed:30/255.0 green:144/255.0 blue:255/255.0 alpha:0.6];
    }
    else
    {
        self.remindSwitch.userInteractionEnabled = NO;
        self.remindLabel.textColor = [UIColor colorWithRed:105/255.0 green:105/255.0 blue:105/255.0 alpha:0.8];
    }
}

//记住密码模式切换
-(void)remindState:(Switch*)remindSwitch
{
    if ([self.userAccount.text isEqualToString:[DataTool getAccount]] || ![DataTool getLoginState])//用户
    {
        [DataTool saveRemindState:remindSwitch.on];//保存模式
    }
}

//登录
-(void)loginAccount
{
    if ((self.userAccount.text.length == 0) || (self.userPassword.text.length == 0))
    {
        UIAlertController *missAlert = [UIAlertController alertControllerWithTitle:@"邮箱或密码不能为空" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [missAlert addAction:action];
        [self presentViewController:missAlert animated:YES completion:nil];
    }
    else
    {
        self.introHUD = nil;
        self.introHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.introHUD.labelText = @"正在登录";
        self.loginTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(loginOutTime) userInfo:nil repeats:NO];
        
        NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
        NSString *userID = [df objectForKey:@"userID"];
        
        NSData *pwData = [self.userPassword.text dataUsingEncoding:NSUTF8StringEncoding];
        NSString *pwBase64 = [pwData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        if (![DataTool getLoginState])//初次登录
        {
            NSLog(@"Register Account -- %@",pwBase64);
            DC_AccountService *accountService = [DC_AccountService new];
            accountService.DC_RegisterDelegate = self;
            [accountService DC_RegisterAccountWithFirstName:@"" WithLastName:@"" WithEmail:self.userAccount.text WithPassword:pwBase64];
        }
        else
        {
            NSLog(@"Authenticate Account -- %@",pwBase64);
            DC_AccountService *accountService = [DC_AccountService new];
            accountService.DC_AuthenticateDelegate = self;
            [accountService DC_AuthenticateAccountWithEmail:self.userAccount.text WithPassword:pwBase64 WithUserID:userID];
        }
    }
}

#pragma mark -- DC_RegisterAccountDelegate
-(void)DC_RegisterAccountDelegateFinish:(BOOL)success WithResult:(NSDictionary *)resultDict WithAccountType:(BOOL)newAccount WithErrorDescription:(NSString *)description
{
    if (success)
    {
        NSLog(@"Register %@ Account Success Result --> %@",newAccount ? @"New" : @"Old",resultDict);
        NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
        [df setObject:[resultDict objectForKey:@"userGroup"] forKey:@"userGroup"];
        [df setObject:[resultDict objectForKey:@"userLastName"] forKey:@"userLastName"];
        [df setObject:[resultDict objectForKey:@"userFirstName"] forKey:@"userFirstName"];
        [df setObject:[resultDict objectForKey:@"userID"] forKey:@"userID"];
        [df setObject:[resultDict objectForKey:@"userType"] forKey:@"userType"];
        [df setObject:[resultDict objectForKey:@"token"] forKey:@"token"];//deal
        [df setObject:self.userAccount.text forKey:@"email"];
        [df setObject:self.userPassword.text forKey:@"password"];
        [df synchronize];
        NSString *title = @"验证成功";
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
                NSString *ac = [df objectForKey:@"email"];
                NSString *pw = [df objectForKey:@"password"];
                NSString *userID = [df objectForKey:@"userID"];
                NSData *pwData = [pw dataUsingEncoding:NSUTF8StringEncoding];
                NSString *pwBase64 = [pwData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
                DC_AccountService *accountService = [DC_AccountService new];
                accountService.DC_AuthenticateDelegate = self;
                NSLog(@"Enter Password: TF:%@ DF:%@ Encr Password: %@",self.userPassword.text,pw,pwBase64);
                [accountService DC_AuthenticateAccountWithEmail:ac WithPassword:pwBase64 WithUserID:userID];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
    else
    {
        NSLog(@"Register Account Failure Error --> %@",description);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"验证失败" message:description preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.introHUD hide:YES];
                [self.loginTimer invalidate];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
}
#pragma mark -- DC_AuthenticateAccountDelegate
-(void)DC_AuthenticateAccountDelegateFinish:(BOOL)success WithResult:(NSDictionary *)resultDict WithErrorDescription:(NSString *)description
{
    if (success)
    {
        NSLog(@"Authenticate Account Success Result --> %@",resultDict);
        NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
        [df setObject:[resultDict objectForKey:@"userGroup"] forKey:@"userGroup"];
        [df setObject:[resultDict objectForKey:@"userType"] forKey:@"userType"];
        [df setObject:[resultDict objectForKey:@"userID"] forKey:@"userID"];
        [df setObject:[resultDict objectForKey:@"planType"] forKey:@"planType"];
        [df setObject:[resultDict objectForKey:@"token"] forKey:@"token"];//deal
        [df setObject:[resultDict objectForKey:@"termsDate"] forKey:@"termsDate"];
        [df setObject:[resultDict objectForKey:@"privacyMode"] forKey:@"privacyMode"];
        [df setObject:[resultDict objectForKey:@"videoWifiTimeout"] forKey:@"videoWifiTimeout"];
        [df setObject:[resultDict objectForKey:@"videoCellTimeout"] forKey:@"videoCellTimeout"];
        [df setObject:[resultDict objectForKey:@"showHome"] forKey:@"showHome"];
        [df setObject:([resultDict objectForKey:@"siteUrl"] ?:@"秘密") forKey:@"siteUrl"];
        [df setObject:([resultDict objectForKey:@"serviceUrl"] ?:@"秘密") forKey:@"serviceUrl"];
        [df setObject:[resultDict objectForKey:@"homeNetworkName"] forKey:@"homeNetworkName"];
        [df setObject:[resultDict objectForKey:@"offer"] forKey:@"offer"];
        NSDictionary *lists = [resultDict objectForKey:@"lists"];
        NSArray *items = [lists objectForKey:@"items"];
        NSDictionary *cameraDict = [items firstObject];
        [df setObject:[cameraDict objectForKey:@"name"] forKey:@"name"];
        [df setObject:[cameraDict objectForKey:@"deviceID"] forKey:@"deviceID"];
        [df setObject:[cameraDict objectForKey:@"mac"] forKey:@"macAddress"];
        [df setObject:[cameraDict objectForKey:@"key"] forKey:@"key"];
        [df setObject:[cameraDict objectForKey:@"deviceType"] forKey:@"deviceType"];
        [df setObject:[cameraDict objectForKey:@"unitType"] forKey:@"unitType"];
        [df setObject:[cameraDict objectForKey:@"online"] forKey:@"online"];
        [df setObject:[cameraDict objectForKey:@"localIP"] forKey:@"localIP"];
        [df synchronize];
        self.cameraCount = items.count;
        [DataBaseTool saveCamerasToDatabase:items];//Save All Cameras To Database
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self getViewerCameraReload];
        });
    }
    else
    {
        NSLog(@"Authenticate Account Failure Error --> %@",description);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"验证账户失败" message:description preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.introHUD hide:YES];
                [self.loginTimer invalidate];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
}

-(void)getViewerCameraReload
{
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *email = [df objectForKey:@"email"];
    NSString *password = [df objectForKey:@"password"];
    if ([[DataBaseTool getCamerasFromDatabase] count])
    {
        for (NSDictionary *cameraDict in [DataBaseTool getCamerasFromDatabase])
        {
            NSString *deviceID = [cameraDict objectForKey:@"deviceID"];
            
            DC_CameraManager *cameraManager = [DC_CameraManager new];
            cameraManager.DC_GetViewerDelegate = self;
            [cameraManager DC_GetViewerCameraWithDeviceID:deviceID WithUserEmail:email WithUserPassword:password];
        }
    }
    else
    {
        [self loginSuccessToSaveAndIntoMainView];
    }
}

#pragma mark -- DC_GetViewerCameraDelegate
-(void)DC_GetViewerCameraFinish:(BOOL)success ForResult:(NSDictionary *)resultDict WithErrorDescription:(NSString *)description
{
    if (success)
    {
        NSLog(@"Get Viewer Camera Success --> %@",resultDict);
        NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithDictionary:resultDict];
        [resultDic removeObjectForKey:@"code"];
        [DataBaseTool saveCameraToDatabase:(NSDictionary*)resultDic WithMACAddress:[resultDic objectForKey:@"macAddress"]];
        /*
        NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
        [df setObject:[resultDict objectForKey:@"macAddress"] forKey:@"macAddress"];
        [df setObject:[resultDict objectForKey:@"key"] forKey:@"key"];
        [df setObject:[resultDict objectForKey:@"aspectRatio"] forKey:@"aspectRatio"];
        [df setObject:[resultDict objectForKey:@"remoteAspectRatio"] forKey:@"remoteAspectRatio"];
        [df setObject:[resultDict objectForKey:@"cellAspectRatio"] forKey:@"cellAspectRatio"];
        [df setObject:[resultDict objectForKey:@"panTilt"] forKey:@"panTilt"];
        [df setObject:[resultDict objectForKey:@"rtspPort"] forKey:@"rtspPort"];
        [df setObject:[resultDict objectForKey:@"httpUserName"] forKey:@"httpUserName"];
        [df setObject:[resultDict objectForKey:@"rtspUserName"] forKey:@"rtspUserName"];
        [df setObject:[resultDict objectForKey:@"vgRegistrar"] forKey:@"vgRegistrar"];
        [df setObject:[resultDict objectForKey:@"localPath"] forKey:@"localPath"];
        [df setObject:[resultDict objectForKey:@"remotePath"] forKey:@"remotePath"];
        [df setObject:[resultDict objectForKey:@"cellPath"] forKey:@"cellPath"];
        [df setObject:[resultDict objectForKey:@"vgLogLevel"] forKey:@"vgLogLevel"];
        [df synchronize];
        */
        self.cameraCount--;
        if (self.cameraCount == 0)
        {
            [self loginSuccessToSaveAndIntoMainView];
        }
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"获取摄像头状态失败" message:description preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.introHUD hide:YES];
            [self.loginTimer invalidate];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

//登录成功保存进入主界面
-(void)loginSuccessToSaveAndIntoMainView
{
    if (![DataTool getLoginState])//初次登录
    {
        [DataTool saveAccount:self.userAccount.text];//记住账号
        if ([DataTool getRemindState])
        {
            [DataTool savePassword:self.userPassword.text];
        }
    }
    [DataTool saveLoginState:YES];
    if ([DataTool getRemindState] && [self.userAccount.text isEqualToString:[DataTool getAccount]])//记住密码模式&&用户
    {
        [DataTool savePassword:self.userPassword.text];//记住密码
    }
    if ([self.userAccount.text isEqualToString:[DataTool getAccount]])//用户
    {
        if (![DataTool getRemindState])
        {
            [DataTool savePassword:@""];//清除密码记录
        }
    }
    [self.introHUD hide:YES];
    [self.loginTimer invalidate];
    //带左菜单界面
    AppDelegate *mainAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self presentViewController:mainAppDelegate.leftSlideVC animated:YES completion:nil];
}
-(void)loginFailure
{
    self.introHUD.labelText = @"登录失败";
    [self.loginTimer invalidate];
    sleep(2);
    [self.introHUD hide:YES];
}
-(void)loginOutTime
{
    self.introHUD.labelText = @"登录失败";
    sleep(2);
    [self.introHUD hide:YES];
}

//注册账号
-(void)registerAccount
{
    RegisterViewController *registerVC = [RegisterViewController new];
    registerVC.backLoginBlock = ^(){
        self.userAccount.text = [DataTool getAccount];
        self.userPassword.text = [DataTool getPassword];
        [self loginAccount];//登录
    };
    UINavigationController *registerNVC = [[UINavigationController alloc] initWithRootViewController:registerVC];
    [self presentViewController:registerNVC animated:YES completion:nil];
}

//忘记密码
-(void)forgetPassword
{
    ForgetViewController *fVC = [ForgetViewController new];
    UINavigationController *fNVC = [[UINavigationController alloc] initWithRootViewController:fVC];
    [self presentViewController:fNVC animated:YES completion:nil];
}

//初始化获取Messages更新
-(void)getUserInformationAndUpdate
{
    self.lastSyncDate = @"01/01/2013";
    if (![DataTool getLoginState])//初次进入
    {
        self.introHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.introHUD.labelText = @"正在加载数据";
        [self getBasicInformation];
        self.introTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(introOutTime) userInfo:nil repeats:NO];
    }
    else
    {
        //self.lastSyncDate = termsDate
        if (self.lastSyncDate.length != 0)
        {
            NSDate *date = [NSDate date];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
            NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:date];
            NSString *dateString = [NSString stringWithFormat:@"%02d/%02d/%d",(int)[dateComponent month],(int)[dateComponent day],(int)[dateComponent year]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
            NSDate *currentDate = [dateFormatter dateFromString:dateString];
            NSDate *lastDate = [dateFormatter dateFromString:self.lastSyncDate];
            NSLog(@"Current Date: %@ | Last Date: %@",dateString,self.lastSyncDate);
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            unsigned int dayCalendarUnit = NSCalendarUnitDay;
            NSDateComponents *components = [gregorian components:dayCalendarUnit fromDate:lastDate  toDate:currentDate  options:0];
            NSInteger days = [components day];
            if (days > 7)//超过一星期
            {
                //self.introHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                //self.introHUD.labelText = @"正在加载数据";
                //[self getBasicInformation];
                //self.introTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(introOutTime) userInfo:nil repeats:NO];
            }
        }
    }
}
//获取初始Messages
-(void)getBasicInformation
{
    DeepCam_SDK *DCS = [DeepCam_SDK new];
    DCS.DC_MessageDelegate = self;
    [DCS DC_GetBasicMessagesWithLastSyncDate:self.lastSyncDate];
    NSLog(@"Get Basic Messages Date: %@",self.lastSyncDate);
}

#pragma mark -- DC_BasicMessagesDelegate
-(void)DC_DidReceiveBasicMessagesComplete:(BOOL)success WithMessages:(NSArray *)messages WithErrorDescription:(NSString *)description
{
    [self.introTimer invalidate];
    if (success)
    {
        NSLog(@"Get Messages Success");
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.introHUD hide:YES];
        });
        if (messages.count)
        {
            [DataBaseTool saveMessagesToDatabase:messages];//保存Messages到数据库
        }
    }
    else
    {
        NSLog(@"Get Messages Failure --> %@",description);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Get Basic Messages Failure" message:description preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.introHUD hide:YES];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
}

//初始化超时
-(void)introOutTime
{
    self.introHUD.labelText = @"加载数据失败";
    sleep(2);
    [self.introHUD hide:YES];
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
