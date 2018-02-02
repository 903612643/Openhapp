//
//  RegisterViewController.m
//  Openhapp
//
//  Created by Jesse on 16/2/26.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import "RegisterViewController.h"
#import "BackLineView.h"
#import "ClauseViewController.h"
#import "DataTool.h"

@interface RegisterViewController () <UITextFieldDelegate>

@property (nonatomic,strong) UIView *backView;//输入背景
@property (nonatomic,strong) UITextField *lastnameTF;
@property (nonatomic,strong) UITextField *firstnameTF;
@property (nonatomic,strong) UITextField *emailTF1;
@property (nonatomic,strong) UITextField *emailTF2;
@property (nonatomic,strong) UITextField *password1;
@property (nonatomic,strong) UITextField *password2;
@property (nonatomic,assign) CGFloat dh;//调节高度
@property (nonatomic,assign) CGFloat uph;//键盘高度
@property (nonatomic,assign) BOOL shouldUp;//可上移

@end

@implementation RegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"注册";
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    self.navigationItem.hidesBackButton = YES;
    
    CGFloat maxWidth = self.view.bounds.size.width;
    CGFloat distanceHeight = (self.view.bounds.size.height - 480) / 10;
    self.dh = distanceHeight;
    self.shouldUp = NO;
    //输入背景线
    BackLineView *backlineView = [[BackLineView alloc] initWithFrame:self.view.bounds];
    self.backView = [backlineView makeBackgroundLineView];
    self.backView.frame = CGRectMake(0, 80 + distanceHeight, self.view.bounds.size.width, self.view.bounds.size.height - (80 + distanceHeight));
    [self.view addSubview:self.backView];
    
    CGFloat lineHeight = backlineView.lineHeight;
    CGFloat bottomY = backlineView.bottomY;
    
    self.lastnameTF = [[UITextField alloc] initWithFrame:CGRectMake(25, 6, self.view.bounds.size.width - 25, lineHeight - 10)];
    self.lastnameTF.placeholder = @"名字";
    self.lastnameTF.borderStyle = UITextBorderStyleNone;
    [self.backView addSubview:self.lastnameTF];
    
    self.firstnameTF = [[UITextField alloc] initWithFrame:CGRectMake(25, 6 + lineHeight, self.view.bounds.size.width - 25, lineHeight - 10)];
    self.firstnameTF.placeholder = @"姓氏";
    self.firstnameTF.borderStyle = UITextBorderStyleNone;
    [self.backView addSubview:self.firstnameTF];
    
    self.emailTF1 = [[UITextField alloc] initWithFrame:CGRectMake(25, 6 + lineHeight * 2, self.view.bounds.size.width - 25, lineHeight - 10)];
    self.emailTF1.placeholder = @"电子邮件";
    self.emailTF1.borderStyle = UITextBorderStyleNone;
    [self.backView addSubview:self.emailTF1];
    
    self.emailTF2 = [[UITextField alloc] initWithFrame:CGRectMake(25, 6 + lineHeight * 3, self.view.bounds.size.width - 25, lineHeight - 10)];
    self.emailTF2.placeholder = @"再次输入邮件";
    self.emailTF2.borderStyle = UITextBorderStyleNone;
    [self.backView addSubview:self.emailTF2];
    
    self.password1 = [[UITextField alloc] initWithFrame:CGRectMake(25, 6 + lineHeight * 4, self.view.bounds.size.width - 25, lineHeight - 10)];
    self.password1.placeholder = @"密码";
    self.password1.borderStyle = UITextBorderStyleNone;
    self.password1.secureTextEntry = YES;
    self.password1.keyboardType = UIKeyboardTypeASCIICapable;
    [self.backView addSubview:self.password1];
    self.password1.delegate = self;
    
    self.password2 = [[UITextField alloc] initWithFrame:CGRectMake(25, 6 + lineHeight * 5, self.view.bounds.size.width - 25, lineHeight - 10)];
    self.password2.placeholder = @"确认密码";
    self.password2.borderStyle = UITextBorderStyleNone;
    self.password2.secureTextEntry = YES;
    self.password2.keyboardType = UIKeyboardTypeASCIICapable;
    [self.backView addSubview:self.password2];
    self.password2.delegate = self;
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    nextBtn.frame = CGRectMake((maxWidth - 160) / 3, bottomY + self.dh + 20, 80, 30);
    [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor colorWithRed:216/255.0 green:191/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    [nextBtn setBackgroundColor:[UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0]];
    [nextBtn.layer setMasksToBounds:YES];
    [nextBtn.layer setCornerRadius:3.0];
    [self.backView addSubview:nextBtn];
    [nextBtn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame = CGRectMake((maxWidth - 160) / 3 * 2 + 80, bottomY + self.dh + 20, 80, 30);
    [backBtn setTitle:@"返回登录" forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor colorWithRed:216/255.0 green:191/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    [backBtn setBackgroundColor:[UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0]];
    [backBtn.layer setMasksToBounds:YES];
    [backBtn.layer setCornerRadius:3.0];
    [self.backView addSubview:backBtn];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    //键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upTextField:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downTextField) name:UIKeyboardWillHideNotification object:nil];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.lastnameTF resignFirstResponder];
    [self.firstnameTF resignFirstResponder];
    [self.emailTF1 resignFirstResponder];
    [self.emailTF2 resignFirstResponder];
    [self.password1 resignFirstResponder];
    [self.password2 resignFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.shouldUp = YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.shouldUp = NO;
}
//键盘出现
-(void)upTextField:(NSNotification*)notification
{
    CGSize keySize = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//键盘高度
    self.uph = keySize.height / 2;
    
    if (self.shouldUp)//可上移
    {
        self.backView.frame = CGRectMake(0, 80 + self.dh - self.uph, self.view.bounds.size.width, self.view.bounds.size.height - (80 + self.dh));
    }
    else
    {
        self.backView.frame = CGRectMake(0, 80 + self.dh, self.view.bounds.size.width, self.view.bounds.size.height - (80 + self.dh));
    }
}
//键盘收起
-(void)downTextField
{
    self.backView.frame = CGRectMake(0, 80 + self.dh, self.view.bounds.size.width, self.view.bounds.size.height - (80 + self.dh));
}

-(void)next
{
    if ((self.lastnameTF.text.length != 0) && (self.firstnameTF.text.length != 0) && (self.emailTF1.text.length != 0) && [self.emailTF1.text isEqualToString:self.emailTF2.text] && (self.password1.text.length != 0) && [self.password1.text isEqualToString:self.password2.text])
    {
        ClauseViewController *clauseVC = [ClauseViewController new];
        clauseVC.backLoginBlock = ^(){
            self.backLoginBlock ();
        };
        //保存临时账号
        NSDictionary *tempDic = [NSDictionary dictionaryWithObjectsAndKeys:self.lastnameTF.text, @"lastname", self.firstnameTF.text, @"firstname", self.emailTF2.text, @"email", self.password2.text, @"password", nil];
        [DataTool saveTempAccount:tempDic];
        
        [self.navigationController pushViewController:clauseVC animated:NO];
    }
    if ((self.lastnameTF.text.length == 0) || (self.firstnameTF.text.length == 0) || (self.emailTF1.text.length == 0) || (self.emailTF2.text.length == 0) || (self.password1.text.length == 0) || (self.password2.text.length == 0))
    {
        UIAlertController *missAlert = [UIAlertController alertControllerWithTitle:@"信息填写不全" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [missAlert addAction:action];
        [self presentViewController:missAlert animated:YES completion:nil];
    }
    if (![self.emailTF1.text isEqualToString:self.emailTF2.text])
    {
        UIAlertController *missAlert = [UIAlertController alertControllerWithTitle:@"输入邮箱不一致" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [missAlert addAction:action];
        [self presentViewController:missAlert animated:YES completion:nil];
    }
    if (![self.password1.text isEqualToString:self.password2.text])
    {
        UIAlertController *missAlert = [UIAlertController alertControllerWithTitle:@"输入密码不一致" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [missAlert addAction:action];
        [self presentViewController:missAlert animated:YES completion:nil];
    }
}

-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
