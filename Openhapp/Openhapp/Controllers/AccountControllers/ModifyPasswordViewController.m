//
//  ModifyPasswordViewController.m
//  Openhapp
//
//  Created by Jesse on 16/5/7.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import "ModifyPasswordViewController.h"
#import "DC_AccountService.h"
#import "DataBaseTool.h"

@interface ModifyPasswordViewController ()<DC_ModifyAccountPasswordDelegate>

@property (nonatomic,strong) UITextField *oldTF;

@property (nonatomic,strong) UITextField *updateTF;

@end

@implementation ModifyPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改密码";
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    
    self.oldTF = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width - 40, 30)];
    self.oldTF.borderStyle = UITextBorderStyleRoundedRect;
    self.oldTF.clearButtonMode = UITextFieldViewModeAlways;
    self.oldTF.keyboardType = UIKeyboardTypeDefault;
    self.oldTF.placeholder = @"Old Password";
    [self.view addSubview:self.oldTF];
    
    self.updateTF = [[UITextField alloc] initWithFrame:CGRectMake(20, 160, self.view.bounds.size.width - 40, 30)];
    self.updateTF.borderStyle = UITextBorderStyleRoundedRect;
    self.updateTF.clearButtonMode = UITextFieldViewModeAlways;
    self.updateTF.keyboardType = UIKeyboardTypeDefault;
    self.updateTF.placeholder = @"New Password";
    [self.view addSubview:self.updateTF];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    saveBtn.frame = CGRectMake((self.view.bounds.size.width - 160) / 2, self.view.bounds.size.height - 100, 160, 50);
    [saveBtn setTitle:@"Confirm" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor colorWithRed:216/255.0 green:191/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:21];
    [saveBtn setBackgroundColor:[UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0]];
    [saveBtn.layer setMasksToBounds:YES];
    [saveBtn.layer setCornerRadius:3.0];
    [self.view addSubview:saveBtn];
    [saveBtn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
}

-(void)save
{
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *userID = [df objectForKey:@"userID"];
    
    DC_AccountService *accountService = [DC_AccountService new];
    accountService.DC_ModifyPasswordDelegate = self;
    [accountService DC_ModifyAccountPasswordWithUserID:userID WithOldPassword:self.oldTF.text WithNewPassword:self.updateTF.text];
}

-(void)DC_ModifyAccountPasswordDelegateFinish:(BOOL)success WithMessageCode:(NSString *)code WithErrorDescription:(NSString *)description
{
    if (success)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改密码成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
    else
    {
        NSString *title = @"";
        NSString *message = @"";
        if (code.length)
        {
            NSDictionary *messageDict = [DataBaseTool getMessagesFromDatabaseForCode:code];
            if ([messageDict allKeys].count)
            {
                title = [messageDict objectForKey:@"title"];
                message = [messageDict objectForKey:@"body"];
            }
            else
            {
                title = @"修改密码失败";
                message = description;
            }
        }
        else
        {
            title = @"修改密码失败";
            message = description;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        });
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
