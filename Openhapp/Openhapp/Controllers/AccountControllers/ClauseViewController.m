//
//  ClauseViewController.m
//  Openhapp
//
//  Created by Jesse on 16/2/26.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import "ClauseViewController.h"
#import "AppDelegate.h"
#import "DataTool.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "DC_AccountService.h"
#import "DeepCam_SDK.h"

@interface ClauseViewController () <UIWebViewDelegate,DC_RegisterAccountDelegate>
@property (nonatomic,strong) UIButton *acceptBtn;
@property (nonatomic,strong) MBProgressHUD *registerHUD;
@end

@implementation ClauseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    self.title = @"许可条款";
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    
    CGFloat maxWidth = self.view.bounds.size.width;
    CGFloat maxHeight = self.view.bounds.size.height;
    
    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 80, maxWidth - 40, 30)];
    topLabel.text = @"点击接受按钮接受许可条款和隐私政策。";
    topLabel.textColor = [UIColor grayColor];
    topLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:topLabel];
    //许可条款页面
    UIWebView *clauseView = [[UIWebView alloc] initWithFrame:CGRectMake(20, 120, maxWidth - 40, maxHeight - 190)];
    
    NSString *urlStr = [DeepCam_SDK DC_TermsSite];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];//DeepCam_SDK Terms Site
    [self.view addSubview:clauseView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [clauseView loadRequest:request];
    });
    clauseView.delegate = self;
    
    self.acceptBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.acceptBtn.frame = CGRectMake(maxWidth - 110, maxHeight - 50, 80, 30);
    [self.acceptBtn setTitle:@"接受" forState:UIControlStateNormal];
    self.acceptBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.acceptBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.acceptBtn setTitleColor:[UIColor colorWithRed:216/255.0 green:191/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    [self.acceptBtn setBackgroundColor:[UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0]];
    [self.acceptBtn.layer setMasksToBounds:YES];
    [self.acceptBtn.layer setCornerRadius:3.0];
    [self.view addSubview:self.acceptBtn];
    [self.acceptBtn addTarget:self action:@selector(acceptGo) forControlEvents:UIControlEventTouchUpInside];
    self.acceptBtn.userInteractionEnabled = NO;
}

//完成加载
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.acceptBtn.userInteractionEnabled = YES;
}
//接受
-(void)acceptGo
{
    //弹出提示
    UIAlertController *acceptAlert = [UIAlertController alertControllerWithTitle:@"条款和条件" message:@"我同意条款和隐私权政策。" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self doRegister];//注册操作
    }];
    [acceptAlert addAction:action];
    [self presentViewController:acceptAlert animated:YES completion:nil];
}
//注册
-(void)doRegister
{
    NSDictionary *tempDic = [DataTool getTempAccount];
    NSString *lastname = [tempDic objectForKey:@"lastname"];
    NSString *firstname = [tempDic objectForKey:@"firstname"];
    NSString *email = [tempDic objectForKey:@"email"];
    NSString *password = [tempDic objectForKey:@"password"];
    
    DC_AccountService *service = [DC_AccountService new];
    service.DC_RegisterDelegate = self;
    NSData *pwData = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSString *pwBase64 = [pwData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    [service DC_RegisterAccountWithFirstName:firstname WithLastName:lastname WithEmail:email WithPassword:pwBase64];
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
        [df synchronize];
        NSString *title = [NSString stringWithFormat:@"%@",newAccount ? @"注册成功" : @"已存在用户"];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self enterMainView];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
    else
    {
        NSLog(@"Register Account Failure Error --> %@",description);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"注册失败" message:description preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self registerFailure:description];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
}

//注册成功进入主页
-(void)enterMainView
{
    NSDictionary *tempDic = [DataTool getTempAccount];
    NSString *email = [tempDic objectForKey:@"email"];
    NSString *password = [tempDic objectForKey:@"password"];
    [DataTool saveAccount:email];
    [DataTool savePassword:password];
    
    self.registerHUD.labelText = @"注册成功";
    sleep(2);
    [self.registerHUD hide:YES];
    [self dismissViewControllerAnimated:NO completion:nil];
    self.backLoginBlock ();
}
//注册失败退出注册
-(void)registerFailure:(NSString*)msg
{
    self.registerHUD.labelText = msg;
    sleep(2);
    [self.registerHUD hide:YES];
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.hidesBackButton = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationItem.hidesBackButton = NO;
    self.acceptBtn.userInteractionEnabled = NO;
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
