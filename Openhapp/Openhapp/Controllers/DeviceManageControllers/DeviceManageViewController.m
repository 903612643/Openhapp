//
//  DeviceManageViewController.m
//  Openhapp
//
//  Created by Jesse on 16/2/24.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import "DeviceManageViewController.h"
#import "AppDelegate.h"
#import "DC_CameraManager.h"
#import "DataBaseTool.h"

@interface DeviceManageViewController () <DC_ModifyCameraNameDelegate,DC_DeleteCameraDelegate>

@property (nonatomic,assign) NSUInteger cameraCount;
@property (nonatomic,strong) UITextField *cameraTF;

@end

@implementation DeviceManageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"设备管理"];
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    //左菜单按钮
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 28, 25);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(openOrCloseLeftView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    
    UIButton *modifyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    modifyBtn.frame = CGRectMake((self.view.bounds.size.width - 80) / 2, self.view.bounds.size.height - 60, 80, 30);
    [modifyBtn setTitle:@"Modify" forState:UIControlStateNormal];
    [modifyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [modifyBtn setTitleColor:[UIColor colorWithRed:216/255.0 green:191/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    modifyBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [modifyBtn setBackgroundColor:[UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0]];
    [modifyBtn.layer setMasksToBounds:YES];
    [modifyBtn.layer setCornerRadius:3.0];
    [self.view addSubview:modifyBtn];
    [modifyBtn addTarget:self action:@selector(modifyCameraName) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    deleteBtn.frame = CGRectMake((self.view.bounds.size.width - 80) / 2, self.view.bounds.size.height - 110, 80, 30);
    [deleteBtn setTitle:@"Delete" forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor colorWithRed:216/255.0 green:191/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    deleteBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [deleteBtn setBackgroundColor:[UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0]];
    [deleteBtn.layer setMasksToBounds:YES];
    [deleteBtn.layer setCornerRadius:3.0];
    [self.view addSubview:deleteBtn];
    [deleteBtn addTarget:self action:@selector(deleteCamera) forControlEvents:UIControlEventTouchUpInside];
    
    self.cameraTF = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width - 40, 30)];
    self.cameraTF.borderStyle = UITextBorderStyleRoundedRect;
    self.cameraTF.clearButtonMode = UITextFieldViewModeAlways;
    self.cameraTF.keyboardType = UIKeyboardTypeDefault;
    self.cameraTF.placeholder = @"新摄像头名称";
    [self.view addSubview:self.cameraTF];
    
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    if (![[df objectForKey:@"macAddress"] length])
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width - 40, self.view.bounds.size.height - 200)];
        label.text = @"You Have No Any Camera";
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.textColor = [UIColor redColor];
        label.font = [UIFont systemFontOfSize:26];
        [self.view addSubview:label];
    }
    
    NSArray *allCameras = [DataBaseTool getCamerasFromDatabase];
    self.cameraCount = allCameras.count;
    NSMutableString *allName = [NSMutableString string];
    for (NSDictionary *cameraDict in allCameras)
    {
        if (allName.length == 0)
        {
            [allName appendString:[cameraDict objectForKey:@"name"]];
        }
        else
        {
            [allName appendString:[NSString stringWithFormat:@"/%@",[cameraDict objectForKey:@"name"]]];
        }
    }
    __block UITextField *tempTF = nil;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose Camera Name" message:allName preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        tempTF = textField;
    }];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        for (NSDictionary *cameraDict in allCameras)
        {
            if ([[cameraDict objectForKey:@"name"] isEqualToString:tempTF.text])
            {
                NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
                [df setObject:[cameraDict objectForKey:@"name"] forKey:@"name"];
                [df setObject:[cameraDict objectForKey:@"macAddress"] forKey:@"macAddress"];
                [df setObject:[cameraDict objectForKey:@"key"] forKey:@"key"];
                [df synchronize];
            }
        }
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)modifyCameraName
{
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *userGroup = [df objectForKey:@"userGroup"];
    NSString *mac = [df objectForKey:@"macAddress"];
    NSString *key = [df objectForKey:@"key"];
    
    NSString *name = self.cameraTF.text;
    DC_CameraManager *cameraManager = [DC_CameraManager new];
    cameraManager.DC_ModifyNameDelegate = self;
    [cameraManager DC_ModifyCameraNameWithUserGroup:userGroup WithCameraMac:mac WithCameraKey:key WithNewCameraName:name];
}

-(void)deleteCamera
{
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *userGroup = [df objectForKey:@"userGroup"];
    NSString *mac = [df objectForKey:@"macAddress"];
    NSString *key = [df objectForKey:@"key"];
    NSString *email = [df objectForKey:@"email"];
    NSString *password = [df objectForKey:@"password"];
    
    DC_CameraManager *cameraManager = [DC_CameraManager new];
    cameraManager.DC_DeleteDelegate = self;
    [cameraManager DC_DeleteCameraWithUserGroup:userGroup WithCameraMac:mac WithCameraKey:key WithUserEmail:email WithUserPassword:password];
}

#pragma mark -- DC_ModifyCameraNameDelegate
-(void)DC_ModifyCameraNameFinish:(BOOL)success WithMessageCode:(NSInteger)code WithErrorDescription:(NSString *)description
{
    if (success)
    {
        NSLog(@"Modify Camera Name Success");
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Modify Camera Name Success" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
                [df setObject:self.cameraTF.text forKey:@"name"];
                [df synchronize];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
    else
    {
        NSLog(@"Modify Camera Name Failure");
        NSString *title = @"";
        NSString *message = @"";
        if (code)
        {
            NSDictionary *messageDict = [DataBaseTool getMessagesFromDatabaseForCode:[NSString stringWithFormat:@"%ld",code]];
            if ([messageDict allKeys].count)
            {
                title = [messageDict objectForKey:@"title"];
                message = [messageDict objectForKey:@"body"];
            }
            else
            {
                title = @"修改摄像头名称失败";
                message = description;
            }
        }
        else
        {
            title = @"修改摄像头名称失败";
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

#pragma mark -- DC_DeleteCameraDelegate
-(void)DC_DeleteCameraFinish:(BOOL)success WithMessageCode:(NSInteger)code WithErrorDescription:(NSString *)description
{
    if (success)
    {
        NSLog(@"Delete Camera Name Success");
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Delete Camera Success" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ((self.cameraCount - 1) < 1)
                {
                    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
                    [df setObject:@"" forKey:@"macAddress"];
                    [df synchronize];
                }
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
    else
    {
        NSLog(@"Delete Camera Name Failure");
        NSString *title = @"";
        NSString *message = @"";
        if (code)
        {
            NSDictionary *messageDict = [DataBaseTool getMessagesFromDatabaseForCode:[NSString stringWithFormat:@"%ld",code]];
            if ([messageDict allKeys].count)
            {
                title = [messageDict objectForKey:@"title"];
                message = [messageDict objectForKey:@"body"];
            }
            else
            {
                title = @"删除摄像头失败";
                message = description;
            }
        }
        else
        {
            title = @"删除摄像头失败";
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
