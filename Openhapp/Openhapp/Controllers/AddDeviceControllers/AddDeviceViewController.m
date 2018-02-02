//
//  AddDeviceViewController.m
//  Openhapp
//
//  Created by Jesse on 16/5/5.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import "AddDeviceViewController.h"
#import "DC_CameraManager.h"
#import <systemconfiguration/captivenetwork.h>
#import "AppDelegate.h"
#import "DataBaseTool.h"
#import "MainViewController.h"
#import "DeepCam_SDK.h"

static NSString *homeNetworkName;

@interface AddDeviceViewController () <DC_AddCameraDelegate,DC_DeleteCameraDelegate,DC_CameraDiscoveryDelegate>

@property (nonatomic,strong) UIView *informationView;

@property (nonatomic,strong) UILabel *informationNetwork;

@property DC_CameraType cameraType;

@property (nonatomic,assign) NSInteger scanTimes;

@property DeepCam_SDK *DCSDK;

@property (nonatomic,strong) NSTimer *scanTimer;

@end

static DC_CameraManager *cameraManager;
static NSString *cameraSSID = @"";
static NSTimer *checkTimer;
static NSInteger step = 0;
static BOOL isCameraWiFi = NO;

@implementation AddDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"添加摄像头";
    self.navigationItem.hidesBackButton = YES;
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    homeNetworkName = [df objectForKey:@"homeNetworkName"];
    
    self.informationView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.informationView.backgroundColor = [UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    [self.view addSubview:self.informationView];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Camera Type" message:@"Please Choose Your Camera Type" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"H210" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.cameraType = DC_CameraTypeH210;
        [self startRegisterCamera];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"AH8704" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.cameraType = DC_CameraTypeAH8074;
        [self startRegisterCamera];
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)updateInformationView
{
    if (step == 0)
    {
        UILabel *informationLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280) / 2, 100, 280, 60)];
        informationLabel.text = @"Register Camera To Server Success";
        informationLabel.textColor = [UIColor greenColor];
        informationLabel.font = [UIFont systemFontOfSize:16];
        informationLabel.numberOfLines = 0;
        [self.informationView addSubview:informationLabel];
    }
    if (step == 1)
    {
        UILabel *informationLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280) / 2, 180, 280, 60)];
        informationLabel.text = @"Register Camera To Account Success";
        informationLabel.textColor = [UIColor purpleColor];
        informationLabel.font = [UIFont systemFontOfSize:16];
        informationLabel.numberOfLines = 0;
        [self.informationView addSubview:informationLabel];
    }
    if (step == 2)
    {
        if (isCameraWiFi)
        {
            [self.informationNetwork removeFromSuperview];
            self.informationNetwork = nil;
            self.informationNetwork = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280) / 2, 260, 280, 60)];
            NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
            NSString *mac = [df objectForKey:@"TEMPMAC"];
            cameraSSID = [NSString stringWithFormat:@"Msc-%@",[mac substringFromIndex:6]];
            self.informationNetwork.text = [NSString stringWithFormat:@"Have Connected '%@' Camera WiFi",cameraSSID];//Camera SSID
            self.informationNetwork.textColor = [UIColor orangeColor];
            self.informationNetwork.font = [UIFont systemFontOfSize:16];
            self.informationNetwork.numberOfLines = 0;
            [self.informationView addSubview:self.informationNetwork];
            
            cameraManager = [DC_CameraManager new];
            cameraManager.DC_AddDelegate = self;
            [cameraManager DC_SetCamera];
            NSLog(@"cameraManager DC_SetCamera");
                                                                                                                                                                                                                                                                      }
        else
        {
            [self.informationNetwork removeFromSuperview];
            self.informationNetwork = nil;
            self.informationNetwork = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280) / 2, 260, 280, 100)];
            NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
            NSString *mac = [df objectForKey:@"TEMPMAC"];
            cameraSSID = [NSString stringWithFormat:@"Msc-%@",[mac substringFromIndex:6]];
            self.informationNetwork.text = [NSString stringWithFormat:@"Please Connect '%@' Camera WiFi",cameraSSID];//Camera SSID
            self.informationNetwork.textColor = [UIColor yellowColor];
            self.informationNetwork.font = [UIFont systemFontOfSize:16];
            self.informationNetwork.numberOfLines = 0;
            [self.informationView addSubview:self.informationNetwork];
        }
    }
    if (step == 3)
    {
        UILabel *informationLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280) / 2, 340, 280, 60)];
        informationLabel.text = @"Set Camera Success";
        informationLabel.textColor = [UIColor cyanColor];
        informationLabel.font = [UIFont systemFontOfSize:16];
        informationLabel.numberOfLines = 0;
        [self.informationView addSubview:informationLabel];
    }
    if (step == 4)
    {
        UILabel *informationLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280) / 2, 420, 280, 60)];
        informationLabel.text = [NSString stringWithFormat:@"Have Connected Home WiFi '%@'",homeNetworkName];
        informationLabel.textColor = [UIColor redColor];
        informationLabel.font = [UIFont systemFontOfSize:16];
        informationLabel.numberOfLines = 0;
        [self.informationView addSubview:informationLabel];
        
        [self testCameraInLocalNetwork];
    }
    if (step == 5)
    {
        UILabel *informationLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280) / 2, 500, 280, 60)];
        informationLabel.text = @"Checking Camera......";
        informationLabel.textColor = [UIColor magentaColor];
        informationLabel.font = [UIFont systemFontOfSize:16];
        informationLabel.numberOfLines = 0;
        [self.informationView addSubview:informationLabel];
    }
}

-(void)startRegisterCamera
{
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *mac = [df objectForKey:@"TEMPMAC"];
    NSString *key = [df objectForKey:@"TEMPKEY"];
    NSString *name = [df objectForKey:@"name"];
    NSString *userGroup = [df objectForKey:@"userGroup"];
    NSString *userEmail = [df objectForKey:@"email"];
    NSString *userPassword = [df objectForKey:@"password"];
    NSString *homeNetworkPW = [df objectForKey:@"homeNetworkPassword"];
    
    cameraManager = [DC_CameraManager new];
    cameraManager.DC_AddDelegate = self;
    [cameraManager DC_InitWithCameraType:self.cameraType WithCameraMac:mac WithCameraKey:key WithCameraName:name WithHomeNetworkSSID:homeNetworkName WithHomeNetworkPassword:homeNetworkPW];//SSID & Password For Your Home WiFi
    [cameraManager DC_RegisterCameraWithUserGroup:userGroup WithUserEmail:userEmail WithUserPassword:userPassword];//register camera
}

#pragma mark -- DC_AddCameraDelegate
-(void)DC_RegisterCameraToServerFinish:(BOOL)success WithResult:(NSDictionary *)resultDict WithMessageCode:(NSString *)code WithErrorDescription:(NSString *)description
{
    if (success)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            step = 0;
            [self updateInformationView];//0
        });
        NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
        [df setObject:[resultDict objectForKey:@"deviceID"] forKey:@"deviceID"];
        [df setObject:[resultDict objectForKey:@"deviceType"] forKey:@"deviceType"];
        [df setObject:[resultDict objectForKey:@"unitType"] forKey:@"unitType"];
        [df synchronize];
        NSLog(@"Register Camera To Server Success --> %@",resultDict);
    }
    else
    {
        NSString *title = @"";
        NSString *message = @"";
        if (code.length)
        {
            NSLog(@"摄像头注册失败 Code -- %@",code);
            NSDictionary *messageDict = [DataBaseTool getMessagesFromDatabaseForCode:code];
            if ([messageDict allKeys].count)
            {
                title = [messageDict objectForKey:@"title"];
                message = [messageDict objectForKey:@"body"];
            }
            else
            {
                title = @"摄像头注册失败";
                message = description;
            }
        }
        else
        {
            title = @"摄像头注册失败";
            message = description;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                AppDelegate *mainAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                [mainAppDelegate.mainNVC popToRootViewControllerAnimated:YES];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        });
        NSLog(@"Register Camera To Server Failure");
    }
}

-(void)DC_RegisterCameraToAccountFinish:(BOOL)success WithResult:(NSDictionary *)resultDict WithMessageCode:(NSString *)code WithErrorDescription:(NSString *)description
{
    if (success)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            step = 1;
            [self updateInformationView];//1
        });
        NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
        [df setObject:[resultDict objectForKey:@"macAddress"] forKey:@"macAddress"];
        [df setObject:[resultDict objectForKey:@"key"] forKey:@"key"];
        [df setObject:[resultDict objectForKey:@"aspectRatio"] forKey:@"aspectRatio"];
        [df setObject:[resultDict objectForKey:@"remoteAspectRatio"] forKey:@"remoteAspectRatio"];
        [df setObject:[resultDict objectForKey:@"cellAspectRatio"] forKey:@"cellAspectRatio"];
        [df setObject:[resultDict objectForKey:@"httpUserName"] forKey:@"httpUserName"];
        [df setObject:[resultDict objectForKey:@"rtspUserName"] forKey:@"rtspUserName"];
        [df setObject:[resultDict objectForKey:@"rtspPort"] forKey:@"rtspPort"];
        [df setObject:[resultDict objectForKey:@"panTilt"] forKey:@"panTilt"];
        [df setObject:[resultDict objectForKey:@"localPath"] forKey:@"localPath"];
        [df setObject:[resultDict objectForKey:@"remotePath"] forKey:@"remotePath"];
        [df setObject:[resultDict objectForKey:@"cellPath"] forKey:@"cellPath"];
        [df setObject:[resultDict objectForKey:@"vgRegistrar"] forKey:@"vgRegistrar"];
        [df setObject:[resultDict objectForKey:@"vgLogLevel"] forKey:@"vgLogLevel"];
        [df synchronize];
        NSLog(@"Register Camera To Account Success --> %@",resultDict);
        checkTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checkNetwork) userInfo:nil repeats:YES];
    }
    else
    {
        NSString *title = @"";
        NSString *message = @"";
        if (code.length)
        {
            NSLog(@"摄像头注册到账户失败 Code -- %@",code);
            NSDictionary *messageDict = [DataBaseTool getMessagesFromDatabaseForCode:code];
            if ([messageDict allKeys].count)
            {
                title = [messageDict objectForKey:@"title"];
                message = [messageDict objectForKey:@"body"];
            }
            else
            {
                title = @"摄像头注册到账户失败";
                message = description;
            }
        }
        else
        {
            title = @"摄像头注册到账户失败";
            message = description;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                AppDelegate *mainAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                [mainAppDelegate.mainNVC popToRootViewControllerAnimated:YES];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        });
        NSLog(@"Register Camera To Account Failure");
    }
}

-(void)checkNetwork
{
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
    NSLog(@"Current WiFi --> %@ Camera WiFi --> %@",currentSSID,cameraSSID);
    if ([currentSSID isEqualToString:cameraSSID])//Camera SSID
    {
        if (checkTimer)
        {
            [checkTimer invalidate];
            checkTimer = nil;
        }
        NSLog(@"Have Connected '%@' Camera WiFi",cameraSSID);
        isCameraWiFi = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            step = 2;
            [self updateInformationView];//2
        });
    }
    else
    {
        isCameraWiFi = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            step = 2;
            [self updateInformationView];//2
        });
    }
}

-(void)DC_SetCameraFinish:(BOOL)success WithErrorDescription:(NSString *)description
{
    if (success)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            step = 3;
            [self updateInformationView];//3
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            
            checkTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checkHomeNetwork) userInfo:nil repeats:YES];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Set Camera Failure" message:description preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
                [df removeObjectForKey:@"macAddress"];
                [df synchronize];
                AppDelegate *mainAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                [mainAppDelegate.mainNVC popToRootViewControllerAnimated:YES];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        });
        NSLog(@"Set Camera Failure");
    }
}

-(void)checkHomeNetwork
{
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
    NSLog(@"Current WiFi --> %@",currentSSID);
    if ([currentSSID isEqualToString:homeNetworkName])//SSID For Your Home WiFi
    {
        if (checkTimer)
        {
            [checkTimer invalidate];
            checkTimer = nil;
        }
        NSLog(@"Have Connected '%@' Home WiFi",homeNetworkName);
        dispatch_async(dispatch_get_main_queue(), ^{
            step = 4;
            [self updateInformationView];//4
        });
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"WiFi Connection" message:[NSString stringWithFormat:@"Please Connect Your Home WiFi '%@'",homeNetworkName] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)testCameraInLocalNetwork
{
    step = 5;
    [self updateInformationView];
    self.scanTimes = 0;
    
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *addMAC = [df objectForKey:@"macAddress"];
    NSArray *adds = @[addMAC];
    
    self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:21.0 target:self selector:@selector(addTimes) userInfo:nil repeats:YES];
    
    self.DCSDK = [[DeepCam_SDK alloc] DC_InitBroadcastCameraDiscoveryWithLocalCamerasMac:adds ForStartServer:YES AndTimeInterval:20.0];
    self.DCSDK.DC_CameraDiscoveryDelegate = self;
    [self.DCSDK DC_BroadcastCameraStartPolling];
}

-(void)addTimes
{
    self.scanTimes++;
}

#pragma mark -- DC_CameraDiscoveryDelegate
-(void)DC_BroadcastCameraDiscoveryResult:(NSDictionary *)cameraDict
{
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *addMAC = [df objectForKey:@"macAddress"];
    
    NSLog(@"Add Discover Camera MAC  --> %@ (%@)",[[[cameraDict objectForKey:@"CameraDiscoveredAttributesKey"] objectForKey:@"mac"] uppercaseString],addMAC);
    
    if ([[[[cameraDict objectForKey:@"CameraDiscoveredAttributesKey"] objectForKey:@"mac"] uppercaseString] isEqualToString:addMAC])
    {
        NSLog(@"Add Wait Find Camera MAC --> %@",[df objectForKey:@"macAddress"]);
        
        if (self.scanTimer)
        {
            [self.scanTimer invalidate];
            self.scanTimer = nil;
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"You Can Go To Main View Test Camera" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self.DCSDK DC_BroadcastCameraStopPolling];
            [self.DCSDK setDC_CameraDiscoveryDelegate:nil];
            self.DCSDK = nil;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AddCameraSuccess" object:nil];
            AppDelegate *mainAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [mainAppDelegate.mainNVC popToRootViewControllerAnimated:YES];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        if (self.scanTimes == 4)
        {
            if (self.scanTimer)
            {
                [self.scanTimer invalidate];
                self.scanTimer = nil;
            }
            
            [self.DCSDK DC_BroadcastCameraStopPolling];
            [self.DCSDK setDC_CameraDiscoveryDelegate:nil];
            self.DCSDK = nil;
            
            NSString *userGroup = [df objectForKey:@"userGroup"];
            NSString *cameraMac = [df objectForKey:@"macAddress"];
            NSString *cameraKey = [df objectForKey:@"key"];
            NSString *userEmail = [df objectForKey:@"email"];
            NSString *userPassword = [df objectForKey:@"PASSWORD"];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Failure" message:@"Add Camera Faliure, Please Try Again" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                cameraManager.DC_DeleteDelegate = self;
                [cameraManager DC_DeleteCameraWithUserGroup:userGroup WithCameraMac:cameraMac WithCameraKey:cameraKey WithUserEmail:userEmail WithUserPassword:userPassword];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}
-(void)DC_BroadcastCameraStatusOfflineForCameraMac:(NSString *)mac
{
    NSLog(@"Not Find MAC --> %@",mac);
}

#pragma mark -- DC_DeleteCameraDelegate
-(void)DC_DeleteCameraFinish:(BOOL)success WithMessageCode:(NSInteger)code WithErrorDescription:(NSString *)description
{
    if (success)
    {
        NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
        [df removeObjectForKey:@"macAddress"];
        [df synchronize];
        AppDelegate *mainAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [mainAppDelegate.mainNVC popToRootViewControllerAnimated:YES];
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Camera Failure" message:@"Please Call For Webmaster" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            AppDelegate *mainAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [mainAppDelegate.mainNVC popToRootViewControllerAnimated:YES];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
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
