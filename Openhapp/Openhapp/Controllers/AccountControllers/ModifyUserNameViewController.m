//
//  ModifyUserNameViewController.m
//  Openhapp
//
//  Created by Jesse on 16/5/7.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import "ModifyUserNameViewController.h"
#import "DC_AccountService.h"
#import "DataBaseTool.h"

@interface ModifyUserNameViewController ()<DC_ModifyAccountUserNameDelegate>

@property (nonatomic,strong) UITextField *fTF;

@property (nonatomic,strong) UITextField *lTF;

@end

@implementation ModifyUserNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改用户名";
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    
    self.fTF = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width - 40, 30)];
    self.fTF.borderStyle = UITextBorderStyleRoundedRect;
    self.fTF.clearButtonMode = UITextFieldViewModeAlways;
    self.fTF.keyboardType = UIKeyboardTypeDefault;
    self.fTF.placeholder = @"First Name";
    [self.view addSubview:self.fTF];
    
    self.lTF = [[UITextField alloc] initWithFrame:CGRectMake(20, 160, self.view.bounds.size.width - 40, 30)];
    self.lTF.borderStyle = UITextBorderStyleRoundedRect;
    self.lTF.clearButtonMode = UITextFieldViewModeAlways;
    self.lTF.keyboardType = UIKeyboardTypeDefault;
    self.lTF.placeholder = @"Last Name";
    [self.view addSubview:self.lTF];
    
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
    accountService.DC_ModifyUserNameDelegate = self;
    [accountService DC_ModifyAccountUserNameWithUserID:userID WithFirstName:self.fTF.text WithLastName:self.lTF.text];
}

-(void)DC_ModifyAccountUserNameDelegateFinish:(BOOL)success WithMessageCode:(NSString *)code WithErrorDescription:(NSString *)description
{
    if (success)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改用户名成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
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
                title = @"修改用户名失败";
                message = description;
            }
        }
        else
        {
            title = @"修改用户名失败";
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
