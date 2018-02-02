//
//  SetViewController.m
//  Openhapp
//
//  Created by Jesse on 16/5/7.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import "SetViewController.h"
#import "AppDelegate.h"
#import "DC_SettingService.h"
#import "DataBaseTool.h"
#import "MBProgressHUD.h"

@interface SetViewController () <DC_SetPrivacyModeDelegate,DC_ViewerAlertDelegate,DC_NotifyDelegate,DC_TimeZoneDelegate,DC_AlertDelegate>

@property (nonatomic,strong) UISwitch *privacySwitch;

@property (nonatomic,strong) UISwitch *viewerAlertSwitch;

@property (nonatomic,strong) UISwitch *noiseSwitch;

@property (nonatomic,strong) UISlider *noiseSlider;

@property (nonatomic,strong) UISwitch *motionSwitch;

@property (nonatomic,strong) UISlider *motionSlider;

@property (nonatomic,strong) UISegmentedControl *notifySegmentedControl;

@property (nonatomic,strong) UISegmentedControl *timeSegmentedControl;

@property (nonatomic,strong) MBProgressHUD *loadHUD;

@property (nonatomic,assign) BOOL currentNoiseOn;//NO
@property (nonatomic,assign) BOOL currentMotionOn;//MO
@property (nonatomic,assign) NSInteger currentNoiseValue;//NV
@property (nonatomic,assign) NSInteger currentMotionValue;//MV
@property (nonatomic,strong) NSString *modifyAlertType;// NO/MO/NV/MV

@property (nonatomic,assign) NSInteger currentNotifyIndex;
@property (nonatomic,assign) NSInteger setNotifyIndex;

@property (nonatomic,assign) NSInteger currentTimeZoneIndex;
@property (nonatomic,assign) NSInteger setTimeZoneIndex;

@end

@implementation SetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"系统配置";
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    
    //左菜单按钮
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 28, 25);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(openOrCloseLeftView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    
    UILabel *privacyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 100, 21)];
    privacyLabel.text = @"隐私模式";
    privacyLabel.textColor = [UIColor magentaColor];
    [self.view addSubview:privacyLabel];
    self.privacySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80, 100, 60, 30)];
    [self.privacySwitch setOnTintColor:[UIColor magentaColor]];
    [self.privacySwitch setThumbTintColor:[UIColor yellowColor]];
    [self.privacySwitch setOn:NO];
    [self.view addSubview:self.privacySwitch];
    [self.privacySwitch addTarget:self action:@selector(setPrivacy:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *viewerAlertLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, 100, 21)];
    viewerAlertLabel.text = @"视频警报";
    viewerAlertLabel.textColor = [UIColor redColor];
    [self.view addSubview:viewerAlertLabel];
    self.viewerAlertSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80, 150, 60, 30)];
    [self.viewerAlertSwitch setOnTintColor:[UIColor redColor]];
    [self.viewerAlertSwitch setThumbTintColor:[UIColor yellowColor]];
    [self.viewerAlertSwitch setOn:NO];
    [self.view addSubview:self.viewerAlertSwitch];
    [self.viewerAlertSwitch addTarget:self action:@selector(setViewerAlert:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *noiseAlertLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, 100, 21)];
    noiseAlertLabel.text = @"声音侦测";
    noiseAlertLabel.textColor = [UIColor purpleColor];
    [self.view addSubview:noiseAlertLabel];
    self.noiseSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80, 200, 60, 30)];
    [self.noiseSwitch setOnTintColor:[UIColor purpleColor]];
    [self.noiseSwitch setThumbTintColor:[UIColor yellowColor]];
    [self.noiseSwitch setOn:NO];
    [self.view addSubview:self.noiseSwitch];
    [self.noiseSwitch addTarget:self action:@selector(setNoise:) forControlEvents:UIControlEventValueChanged];
    
    self.noiseSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 250, self.view.bounds.size.width - 40, 21)];
    [self.noiseSlider setValue:0];
    [self.noiseSlider setMaximumValue:100];
    [self.noiseSlider setMinimumTrackTintColor:[UIColor purpleColor]];
    [self.view addSubview:self.noiseSlider];
    [self.noiseSlider addTarget:self action:@selector(setNoiseLevel:) forControlEvents:UIControlEventTouchUpInside];
    if (!self.noiseSwitch.on)
    {
        self.noiseSlider.userInteractionEnabled = NO;
    }
    
    UILabel *motionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 300, 100, 21)];
    motionLabel.text = @"移动侦测";
    motionLabel.textColor = [UIColor purpleColor];
    [self.view addSubview:motionLabel];
    self.motionSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 80, 300, 60, 30)];
    [self.motionSwitch setOnTintColor:[UIColor purpleColor]];
    [self.motionSwitch setThumbTintColor:[UIColor yellowColor]];
    [self.motionSwitch setOn:NO];
    [self.view addSubview:self.motionSwitch];
    [self.motionSwitch addTarget:self action:@selector(setMotion:) forControlEvents:UIControlEventValueChanged];
    
    self.motionSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 350, self.view.bounds.size.width - 40, 21)];
    [self.motionSlider setValue:0];
    [self.motionSlider setMaximumValue:100];
    [self.motionSlider setMinimumTrackTintColor:[UIColor purpleColor]];
    [self.view addSubview:self.motionSlider];
    [self.motionSlider addTarget:self action:@selector(setMotionLevel:) forControlEvents:UIControlEventTouchUpInside];
    if (!self.motionSwitch.on)
    {
        self.motionSlider.userInteractionEnabled = NO;
    }
    
    self.notifySegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"推送通知",@"短信",@"邮件",@"日志记录"]];
    self.notifySegmentedControl.frame = CGRectMake(40, 400, self.view.bounds.size.width - 80, 30);
    [self.notifySegmentedControl setTintColor:[UIColor magentaColor]];
    [self.notifySegmentedControl setSelectedSegmentIndex:0];
    [self.view addSubview:self.notifySegmentedControl];
    [self.notifySegmentedControl addTarget:self action:@selector(setNotify:) forControlEvents:UIControlEventValueChanged];
    
    self.timeSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"EST",@"CST",@"MST",@"PST",@"AKST",@"AZ",@"HST"]];
    self.timeSegmentedControl.frame = CGRectMake(5, 480, self.view.bounds.size.width - 10, 30);
    [self.timeSegmentedControl setTintColor:[UIColor orangeColor]];
    [self.timeSegmentedControl setSelectedSegmentIndex:0];
    [self.view addSubview:self.timeSegmentedControl];
    [self.timeSegmentedControl addTarget:self action:@selector(setTimeZone:) forControlEvents:UIControlEventValueChanged];
    
    [self loadSettingValues];
}

-(void)loadSettingValues
{
    self.loadHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.loadHUD];
    self.loadHUD.labelText = @"Loading...";
    self.loadHUD.removeFromSuperViewOnHide = YES;
    [self.loadHUD show:YES];
    
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    
    NSInteger privacyMode = [[df objectForKey:@"privacyMode"] integerValue];
    if (!privacyMode)
    {
        [self.privacySwitch setOn:NO];
    }
    else
    {
        [self.privacySwitch setOn:YES];
    }
    
    NSString *userGroup = [df objectForKey:@"userGroup"];
    NSString *userID = [df objectForKey:@"userID"];
    NSString *deviceID = [df objectForKey:@"deviceID"];
    
    DC_SettingService *settingService = [DC_SettingService new];
    settingService.DC_ViewerAlertDelegate = self;
    [settingService DC_GetViewerAlertsForUserGroup:userGroup];
    
    settingService.DC_NotifyDelegate = self;
    [settingService DC_GetNotifyTypeWithUserID:userID WithUserGroup:userGroup];
    
    if (deviceID.length)//choose a device and get alert
    {
        settingService.DC_AlertDelegat = self;
        [settingService DC_GetAlertForUserGroup:userGroup AndDeviceID:deviceID];
    }
    else
    {
        [self.noiseSwitch setOn:NO animated:YES];
        [self.noiseSlider setValue:0 animated:YES];
        [self.motionSwitch setOn:NO animated:YES];
        [self.motionSlider setValue:0 animated:YES];
        self.noiseSlider.userInteractionEnabled = NO;
        self.motionSlider.userInteractionEnabled = NO;
    }
    
    settingService.DC_TimeZoneDelegate = self;
    [settingService DC_GetTimeZoneWithUserGroup:userGroup];
}

-(void)setPrivacy:(UISwitch*)privacySwitch
{
    if (privacySwitch.on)
    {
        NSLog(@"Set Privacy On");
    }
    else
    {
        NSLog(@"Set Privacy Off");
    }
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *userGroup = [df objectForKey:@"userGroup"];
    
    DC_SettingService *settingService = [DC_SettingService new];
    settingService.DC_PrivacyModeDelegate = self;
    [settingService DC_SetPrivacyModeForUserGroup:userGroup];
}

-(void)setViewerAlert:(UISwitch*)viewerAlertSwitch
{
    if (viewerAlertSwitch.on)
    {
        NSLog(@"Set Viewer Alert On");
    }
    else
    {
        NSLog(@"Set Viewer Alert Off");
    }
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *userGroup = [df objectForKey:@"userGroup"];
    
    DC_SettingService *settingService = [DC_SettingService new];
    settingService.DC_ViewerAlertDelegate = self;
    [settingService DC_SetViewerAlertsForUserGroup:userGroup Status:viewerAlertSwitch.on];
}

-(void)setNoise:(UISwitch*)noiseSwitch
{
    if (noiseSwitch.on)
    {
        NSLog(@"Set Noise On");
        //self.noiseSlider.userInteractionEnabled = YES;
    }
    else
    {
        NSLog(@"Set Noise Off");
        //self.noiseSlider.userInteractionEnabled = NO;
        //[self.noiseSlider setValue:0 animated:YES];
    }
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *userGroup = [df objectForKey:@"userGroup"];
    NSString *deviceID = [df objectForKey:@"deviceID"];
    
    if (!deviceID.length)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Have No Camera" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.noiseSwitch setOn:NO animated:YES];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    self.modifyAlertType = @"NO";
    DC_SettingService *settingService = [DC_SettingService new];
    settingService.DC_AlertDelegat = self;
    [settingService DC_SetAlertForUserGroup:userGroup AndDeviceID:deviceID WithNoiseEnable:noiseSwitch.on WithNoiseLevel:self.currentNoiseValue WithMotionEnable:self.currentMotionOn WithMotionLevel:self.currentMotionValue];
}

-(void)setNoiseLevel:(UISlider*)noiseLevelSlider
{
    NSLog(@"Set Noise Level --> %d",(int)noiseLevelSlider.value);
    
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *userGroup = [df objectForKey:@"userGroup"];
    NSString *deviceID = [df objectForKey:@"deviceID"];
    
    if (!deviceID.length)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Have No Camera" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    self.modifyAlertType = @"NV";
    DC_SettingService *settingService = [DC_SettingService new];
    settingService.DC_AlertDelegat = self;
    [settingService DC_SetAlertForUserGroup:userGroup AndDeviceID:deviceID WithNoiseEnable:self.currentNoiseOn WithNoiseLevel:(NSInteger)noiseLevelSlider.value WithMotionEnable:self.currentMotionOn WithMotionLevel:self.currentMotionValue];
}

-(void)setMotion:(UISwitch*)motionSwitch
{
    if (motionSwitch.on)
    {
        NSLog(@"Set Motion On");
        //self.motionSlider.userInteractionEnabled = YES;
    }
    else
    {
        NSLog(@"Set Motion Off");
        //self.motionSlider.userInteractionEnabled = NO;
        //[self.motionSlider setValue:0 animated:YES];
    }
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *userGroup = [df objectForKey:@"userGroup"];
    NSString *deviceID = [df objectForKey:@"deviceID"];
    
    if (!deviceID.length)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Have No Camera" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.motionSwitch setOn:NO animated:YES];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    self.modifyAlertType = @"MO";
    DC_SettingService *settingService = [DC_SettingService new];
    settingService.DC_AlertDelegat = self;
    [settingService DC_SetAlertForUserGroup:userGroup AndDeviceID:deviceID WithNoiseEnable:self.currentNoiseOn WithNoiseLevel:self.currentNoiseValue WithMotionEnable:motionSwitch.on WithMotionLevel:self.currentMotionValue];
}

-(void)setMotionLevel:(UISlider*)motionLevelSlider
{
    NSLog(@"Set Noise Level --> %d",(int)motionLevelSlider.value);
    
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *userGroup = [df objectForKey:@"userGroup"];
    NSString *deviceID = [df objectForKey:@"deviceID"];
    
    if (!deviceID.length)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Have No Camera" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    self.modifyAlertType = @"MV";
    DC_SettingService *settingService = [DC_SettingService new];
    settingService.DC_AlertDelegat = self;
    [settingService DC_SetAlertForUserGroup:userGroup AndDeviceID:deviceID WithNoiseEnable:self.currentNoiseOn WithNoiseLevel:self.currentNoiseValue WithMotionEnable:self.currentMotionOn WithMotionLevel:(NSInteger)motionLevelSlider.value];
}

-(void)setNotify:(UISegmentedControl*)notifySegmentedControl
{
    NSLog(@"Select Notify Segment -->%d",(int)notifySegmentedControl.selectedSegmentIndex);
    self.setNotifyIndex = notifySegmentedControl.selectedSegmentIndex;
    
    if (notifySegmentedControl.selectedSegmentIndex == 1)
    {
        __block UITextField *currentTF = nil;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please Enter Your Phone Number" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            currentTF = textField;
        }];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
            NSString *userGroup = [df objectForKey:@"userGroup"];
            NSString *userID = [df objectForKey:@"userID"];
            
            DC_SettingService *settingService = [DC_SettingService new];
            settingService.DC_NotifyDelegate = self;
            [settingService DC_SetNotifyTypeWithUserID:userID WithUserGroup:userGroup WithDelivery:currentTF.text ForNotityType:DC_NotityTypeText];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    if (notifySegmentedControl.selectedSegmentIndex == 2)
    {
        __block UITextField *currentTF = nil;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please Enter Your Email" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            currentTF = textField;
        }];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
            NSString *userGroup = [df objectForKey:@"userGroup"];
            NSString *userID = [df objectForKey:@"userID"];
            
            DC_SettingService *settingService = [DC_SettingService new];
            settingService.DC_NotifyDelegate = self;
            [settingService DC_SetNotifyTypeWithUserID:userID WithUserGroup:userGroup WithDelivery:@"" ForNotityType:DC_NotityTypeEmail];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    if (notifySegmentedControl.selectedSegmentIndex == 0)
    {
        NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
        NSString *userGroup = [df objectForKey:@"userGroup"];
        NSString *userID = [df objectForKey:@"userID"];
        
        DC_SettingService *settingService = [DC_SettingService new];
        settingService.DC_NotifyDelegate = self;
        [settingService DC_SetNotifyTypeWithUserID:userID WithUserGroup:userGroup WithDelivery:@"" ForNotityType:DC_NotityTypePush];
    }
    if (notifySegmentedControl.selectedSegmentIndex == 3)
    {
        NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
        NSString *userGroup = [df objectForKey:@"userGroup"];
        NSString *userID = [df objectForKey:@"userID"];
        
        DC_SettingService *settingService = [DC_SettingService new];
        settingService.DC_NotifyDelegate = self;
        [settingService DC_SetNotifyTypeWithUserID:userID WithUserGroup:userGroup WithDelivery:@"" ForNotityType:DC_NotityTypeLog];
    }
}

-(void)setTimeZone:(UISegmentedControl*)timeSegmentedControl
{
    NSLog(@"Select TimeZone Segment -->%d",(int)timeSegmentedControl.selectedSegmentIndex);
    self.setTimeZoneIndex = timeSegmentedControl.selectedSegmentIndex;
    
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *userGroup = [df objectForKey:@"userGroup"];
    
    DC_SettingService *settingService = [DC_SettingService new];
    settingService.DC_TimeZoneDelegate = self;
    [settingService DC_SetTimeZoneWithUserGroup:userGroup ForTimeZone:(NSUInteger)timeSegmentedControl.selectedSegmentIndex];
}

#pragma mark -- All DC_SettingService Delegate
-(void)DC_SetPrivacyModeFinish:(BOOL)success WithMessageCode:(NSString *)code WithErrorDescription:(NSString *)description
{
    if (success)
    {
        if (self.privacySwitch.on)
        {
            NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
            [df setObject:@1 forKey:@"privacyMode"];
            [df synchronize];
        }
        else
        {
            NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
            [df setObject:@0 forKey:@"privacyMode"];
            [df synchronize];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Set Privacy Mode Success" message:nil preferredStyle:UIAlertControllerStyleAlert];
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
                title = @"Set Privacy Mode Failure";
                message = description;
            }
        }
        else
        {
            title = @"Set Privacy Mode Failure";
            message = description;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.privacySwitch setOn:(!self.privacySwitch.on) animated:YES];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
}

-(void)DC_GetViewerAlertsFinish:(BOOL)success ForStatus:(BOOL)open WithMessageCode:(NSString *)code WithErrorDescription:(NSString *)description
{
    if (success)
    {
        if (open)
        {
            [self.viewerAlertSwitch setOn:YES animated:YES];
        }
        else
        {
            [self.viewerAlertSwitch setOn:NO animated:YES];
        }
    }
}

-(void)DC_SetViewerAlertsFinish:(BOOL)success WithMessageCode:(NSString *)code WithErrorDescription:(NSString *)description
{
    if (success)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Set Viewer Alerts Success" message:nil preferredStyle:UIAlertControllerStyleAlert];
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
                title = @"Set Viewer Alerts Failure";
                message = description;
            }
        }
        else
        {
            title = @"Set Viewer Alerts Failure";
            message = description;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.viewerAlertSwitch setOn:(!self.viewerAlertSwitch.on) animated:YES];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
}

-(void)DC_GetNotifyTypeFinish:(BOOL)success ForType:(DC_NotityType)type WithMessageCode:(NSString *)code WithErrorDescription:(NSString *)description
{
    if (success)
    {
        //推送通知/短信/邮件/日志记录
        if (type == DC_NotityTypePush)
        {
            [self.notifySegmentedControl setSelectedSegmentIndex:0];
            self.currentNotifyIndex = 0;
        }
        if (type == DC_NotityTypeText)
        {
            [self.notifySegmentedControl setSelectedSegmentIndex:1];
            self.currentNotifyIndex = 1;
        }
        if (type == DC_NotityTypeEmail)
        {
            [self.notifySegmentedControl setSelectedSegmentIndex:2];
            self.currentNotifyIndex = 2;
        }
        if (type == DC_NotityTypeLog)
        {
            [self.notifySegmentedControl setSelectedSegmentIndex:3];
            self.currentNotifyIndex = 3;
        }
    }
}

-(void)DC_SetNotifyTypeFinish:(BOOL)success WithMessageCode:(NSString *)code WithErrorDescription:(NSString *)description
{
    if (success)
    {
        self.currentNotifyIndex = self.setNotifyIndex;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Set Notify Type Success" message:nil preferredStyle:UIAlertControllerStyleAlert];
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
                title = @"Set Notify Type Failure";
                message = description;
            }
        }
        else
        {
            title = @"Set Notify Type Failure";
            message = description;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.notifySegmentedControl setSelectedSegmentIndex:self.currentNotifyIndex];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
}

-(void)DC_GetTimeZoneFinish:(BOOL)success ForTimeZone:(DC_TimeZone)timeZone WithMessageCode:(NSString *)code WithErrorDescription:(NSString *)description
{
    [self.loadHUD hide:YES];
    if (success)
    {
        // EST/CST/MST/PST/AKST/AZ/HST
        if (timeZone == DC_TimeZoneEastern)
        {
            [self.timeSegmentedControl setSelectedSegmentIndex:0];
        }
        if (timeZone == DC_TimeZoneCentral)
        {
            [self.timeSegmentedControl setSelectedSegmentIndex:1];
        }
        if (timeZone == DC_TimeZoneMountain)
        {
            [self.timeSegmentedControl setSelectedSegmentIndex:2];
        }
        if (timeZone == DC_TimeZonePacific)
        {
            [self.timeSegmentedControl setSelectedSegmentIndex:3];
        }
        if (timeZone == DC_TimeZoneAlaska)
        {
            [self.timeSegmentedControl setSelectedSegmentIndex:4];
        }
        if (timeZone == DC_TimeZoneArizona)
        {
            [self.timeSegmentedControl setSelectedSegmentIndex:5];
        }
        if (timeZone == DC_TimeZoneHawaii)
        {
            [self.timeSegmentedControl setSelectedSegmentIndex:6];
        }
        self.currentTimeZoneIndex = (NSInteger)timeZone;
    }
}

-(void)DC_SetTimeZoneFinish:(BOOL)success WithMessageCode:(NSString *)code WithErrorDescription:(NSString *)description
{
    if (success)
    {
        self.currentTimeZoneIndex = self.setTimeZoneIndex;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Set Time Zone Success" message:nil preferredStyle:UIAlertControllerStyleAlert];
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
                title = @"Set Time Zone Failure";
                message = description;
            }
        }
        else
        {
            title = @"Set Time Zone Failure";
            message = description;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.timeSegmentedControl setSelectedSegmentIndex:self.currentTimeZoneIndex];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
}

-(void)DC_GetAlertFinish:(BOOL)success WithResult:(NSDictionary *)resultDict WithMessageCode:(NSString *)code WithErrorDescription:(NSString *)description
{
    if (success)
    {
        // enableNoise/noiseLevel  enableMotion/motionLevel
        BOOL noiseOn = [[resultDict objectForKey:@"enableNoise"] intValue] ? YES : NO;
        BOOL motionOn = [[resultDict objectForKey:@"enableMotion"] intValue] ? YES : NO;
        float noiseValue = [[resultDict objectForKey:@"noiseLevel"] intValue];
        float motionValue = [[resultDict objectForKey:@"motionLevel"] intValue];
        [self.noiseSwitch setOn:noiseOn animated:YES];
        [self.noiseSlider setValue:(float)noiseValue animated:YES];
        [self.motionSwitch setOn:motionOn animated:YES];
        [self.motionSlider setValue:(float)motionValue animated:YES];
        self.currentNoiseOn = noiseOn;
        self.currentMotionOn = motionOn;
        self.currentNoiseValue = noiseValue;
        self.currentMotionValue = motionValue;
        if (!noiseOn)
        {
            self.noiseSlider.userInteractionEnabled = NO;
        }
        else
        {
            self.noiseSlider.userInteractionEnabled = YES;
        }
        if (!motionOn)
        {
            self.motionSlider.userInteractionEnabled = NO;
        }
        else
        {
            self.motionSlider.userInteractionEnabled = YES;
        }
    }
}

-(void)DC_SetAlertFinish:(BOOL)success WithResult:(NSDictionary *)resultDict WithMessageCode:(NSString *)code WithErrorDescription:(NSString *)description
{
    if (success)
    {
        // enableNoise/noiseLevel  enableMotion/motionLevel
        BOOL noiseOn = [[resultDict objectForKey:@"enableNoise"] intValue] ? YES : NO;
        BOOL motionOn = [[resultDict objectForKey:@"enableMotion"] intValue] ? YES : NO;
        float noiseValue = [[resultDict objectForKey:@"noiseLevel"] intValue];
        float motionValue = [[resultDict objectForKey:@"motionLevel"] intValue];
        [self.noiseSwitch setOn:noiseOn animated:YES];
        [self.noiseSlider setValue:(float)noiseValue animated:YES];
        [self.motionSwitch setOn:motionOn animated:YES];
        [self.motionSlider setValue:(float)motionValue animated:YES];
        self.currentNoiseOn = noiseOn;
        self.currentMotionOn = motionOn;
        self.currentNoiseValue = noiseValue;
        self.currentMotionValue = motionValue;
        if (!noiseOn)
        {
            self.noiseSlider.userInteractionEnabled = NO;
        }
        else
        {
            self.noiseSlider.userInteractionEnabled = YES;
        }
        if (!motionOn)
        {
            self.motionSlider.userInteractionEnabled = NO;
        }
        else
        {
            self.motionSlider.userInteractionEnabled = YES;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Set Alert Success" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([self.modifyAlertType isEqualToString:@"NO"])
                {
                    [self.noiseSwitch setOn:self.currentNoiseOn animated:YES];
                }
                if ([self.modifyAlertType isEqualToString:@"MO"])
                {
                    [self.motionSwitch setOn:self.currentMotionOn animated:YES];
                }
                if ([self.modifyAlertType isEqualToString:@"NV"])
                {
                    [self.noiseSlider setValue:(float)self.currentNoiseValue animated:YES];
                }
                if ([self.modifyAlertType isEqualToString:@"MV"])
                {
                    [self.motionSlider setValue:(float)self.currentMotionValue animated:YES];
                }
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
                title = @"Set Alert Failure";
                message = description;
            }
        }
        else
        {
            title = @"Set Alert Failure";
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
