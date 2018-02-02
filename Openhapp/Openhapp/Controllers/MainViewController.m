//
//  MainViewController.m
//  Openhapp
//
//  Created by Jesse on 16/2/24.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "DataBaseTool.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "PromptViewController.h"
#import "DC_CameraManager.h"
#import <systemconfiguration/captivenetwork.h>
#import "VideoPlayViewController.h"
#import "DeepCam_SDK.h"
#import "AlertViewController.h"

static NSString *homeNetworkName;

@interface MainViewController () <DC_PlayVideoDelegate,DC_CameraDiscoveryDelegate,DC_GetAlertLogDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic,strong) UIView *backView;
@property (nonatomic,assign) BOOL isIntro;
@property (nonatomic,assign) NSInteger cameraNum;
@property (nonatomic,strong) NSString *network;
@property (nonatomic,strong) MBProgressHUD *videoHUD;
@property (nonatomic,strong) UIButton *cameraBtn;
@property DeepCam_SDK *DCSDK;
@property (nonatomic,strong) NSArray *allCameras;
@property (nonatomic,strong) UICollectionView *cameraView;
@property (nonatomic,strong) NSDictionary *findCameraDict;
@property (nonatomic,strong) NSDictionary *loseCameraDict;
@end

static NSTimer *checkTimer;

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"主界面"];
    //[self.navigationItem setHidesBackButton:YES];
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    CGFloat maxWidth = self.view.bounds.size.width;
    //左菜单按钮
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 28, 25);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(openOrCloseLeftView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    //添加按钮
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(0, 0, 20, 20);
    [addBtn setBackgroundImage:[UIImage imageNamed:@"add_icon"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addCamera) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    
    self.isIntro = YES;
    self.backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.backView.backgroundColor = [UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    [self.view addSubview:self.backView];
    //判断数据库摄像头数量
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *cameraMac = [df objectForKey:@"macAddress"];//暂用
    if (cameraMac.length == 0)
    {
        self.cameraNum = 0;
        UILabel *noCameraLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, maxWidth - 40, 60)];
        noCameraLabel.text = @"请选择+号将设备添加到您的账户。";
        noCameraLabel.font = [UIFont systemFontOfSize:18];
        noCameraLabel.textColor = [UIColor grayColor];
        noCameraLabel.numberOfLines = 0;
        noCameraLabel.textAlignment = NSTextAlignmentCenter;
        [self.backView addSubview:noCameraLabel];
        
        /*
        NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
        if (![[df objectForKey:@"homeNetworkName"] length])
        {
            __block UITextField *tempTF = nil;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Home Network" message:@"Please Enter Home Network SSID" preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                tempTF = textField;
            }];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [df setObject:tempTF.text forKey:@"homeNetworkName"];
                [df synchronize];
                homeNetworkName = tempTF.text;
                [self promptPassword];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        */
    }
    else
    {
        homeNetworkName = [df objectForKey:@"homeNetworkName"];
        
        self.cameraNum = 1;
        CGFloat iconWidth = (maxWidth - 40) / 4;
        UIView *cameraView = [[UIView alloc] initWithFrame:CGRectMake(iconWidth, 80, iconWidth, iconWidth * 5 / 4)];
        cameraView.backgroundColor = [UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        
        self.cameraBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        self.cameraBtn.frame = CGRectMake(0, 0, iconWidth, iconWidth);
        [self.cameraBtn setBackgroundImage:[UIImage imageNamed:@"camera_on"] forState:UIControlStateNormal];
        [self.cameraBtn setBackgroundImage:[UIImage imageNamed:@"camera_off"] forState:UIControlStateHighlighted];
        [cameraView addSubview:self.cameraBtn];
        [self.cameraBtn addTarget:self action:@selector(connectVideo) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *cameraName = [[UILabel alloc] initWithFrame:CGRectMake(0, iconWidth, iconWidth, iconWidth / 4)];
        cameraName.text = [df objectForKey:@"name"];
        cameraName.textColor = [UIColor grayColor];
        cameraName.textAlignment = NSTextAlignmentCenter;
        cameraName.font = [UIFont systemFontOfSize:12];
        [cameraView addSubview:cameraName];
        
        [self.backView addSubview:cameraView];

        UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(iconWidth * 2 + 40, 80, iconWidth, iconWidth * 5 / 4)];
        alertView.backgroundColor = [UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        
        UIButton *alertBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        alertBtn.frame = CGRectMake(0, 0, iconWidth, iconWidth);
        [alertBtn setBackgroundImage:[UIImage imageNamed:@"alert_on"] forState:UIControlStateNormal];
        [alertBtn setBackgroundImage:[UIImage imageNamed:@"alert_off"] forState:UIControlStateHighlighted];
        [alertView addSubview:alertBtn];
        [alertBtn addTarget:self action:@selector(connectAlert) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *alertName = [[UILabel alloc] initWithFrame:CGRectMake(0, iconWidth, iconWidth, iconWidth / 4)];
        alertName.text = @"警告通知";
        alertName.textColor = [UIColor grayColor];
        alertName.textAlignment = NSTextAlignmentCenter;
        alertName.font = [UIFont systemFontOfSize:12];
        [alertView addSubview:alertName];
        
        [self.backView addSubview:alertView];
        
        if ([[df objectForKey:@"online"] integerValue])
        {
            self.cameraBtn.userInteractionEnabled = YES;
            [self.cameraBtn setHighlighted:NO];
        }
        else
        {
            self.cameraBtn.userInteractionEnabled = NO;
            [self.cameraBtn setHighlighted:YES];
        }
        
        self.allCameras = [DataBaseTool getCamerasFromDatabase];
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        self.cameraView=[[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        self.cameraView.contentInset = UIEdgeInsetsMake(60, 0, 60, 0);
        self.cameraView.dataSource = self;
        self.cameraView.delegate = self;
        [self.cameraView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CameraCell"];
        [self.cameraView setBackgroundColor:[UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
        [self.view addSubview:self.cameraView];
    }
    /*
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width - 40, self.view.bounds.size.height - 200)];
    label.text = @"Support Only One Camera Test DeepCam_SDK";
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.textColor = [UIColor redColor];
    label.font = [UIFont systemFontOfSize:26];
    [self.backView addSubview:label];
    */
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addSuccessReload) name:@"AddCameraSuccess" object:nil];
}

-(void)addSuccessReload
{
    AppDelegate *mainAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [mainAppDelegate.leftSlideVC dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- UICollectionViewDataSource & UICollectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[DataBaseTool getCamerasFromDatabase] count] + 1;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [[DataBaseTool getCamerasFromDatabase] count])
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CameraCell" forIndexPath:indexPath];
        [cell.contentView removeAllSubviews];
        
        if ([[self.allCameras[indexPath.row] objectForKey:@"online"] integerValue])
        {
            UIImageView *cameraView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_on"]];
            cameraView.frame = CGRectMake(0, 0, (self.view.bounds.size.width - 60) / 2, (self.view.bounds.size.width - 60) / 2);
            [cell.contentView addSubview:cameraView];
            
            UILabel *cameraName = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.width - 60) / 2 + 5, (self.view.bounds.size.width - 60) / 2, 15)];
            cameraName.text = [self.allCameras[indexPath.row] objectForKey:@"name"];
            cameraName.textColor = [UIColor grayColor];
            cameraName.textAlignment = NSTextAlignmentCenter;
            cameraName.font = [UIFont systemFontOfSize:12];
            [cell.contentView addSubview:cameraName];
        }
        else
        {
            UIImageView *cameraView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_off"]];
            cameraView.frame = CGRectMake(0, 0, (self.view.bounds.size.width - 60) / 2, (self.view.bounds.size.width - 60) / 2);
            [cell.contentView addSubview:cameraView];
            UILabel *cameraName = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.width - 60) / 2 + 5, (self.view.bounds.size.width - 60) / 2, 15)];
            cameraName.text = [self.allCameras[indexPath.row] objectForKey:@"name"];
            cameraName.textColor = [UIColor lightGrayColor];
            cameraName.textAlignment = NSTextAlignmentCenter;
            cameraName.font = [UIFont systemFontOfSize:12];
            [cell.contentView addSubview:cameraName];
        }
        
        if ([[self.findCameraDict objectForKey:@"MAC"] isEqualToString:[self.allCameras[indexPath.row] objectForKey:@"macAddress"]])
        {
            UIImageView *cameraView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_on"]];
            cameraView.frame = CGRectMake(0, 0, (self.view.bounds.size.width - 60) / 2, (self.view.bounds.size.width - 60) / 2);
            [cell.contentView addSubview:cameraView];
            
            UILabel *cameraName = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.width - 60) / 2 + 5, (self.view.bounds.size.width - 60) / 2, 15)];
            cameraName.text = [self.allCameras[indexPath.row] objectForKey:@"name"];
            cameraName.textColor = [UIColor grayColor];
            cameraName.textAlignment = NSTextAlignmentCenter;
            cameraName.font = [UIFont systemFontOfSize:12];
            [cell.contentView addSubview:cameraName];
        }
        if ([[self.loseCameraDict objectForKey:@"MAC"] isEqualToString:[self.allCameras[indexPath.row] objectForKey:@"macAddress"]])
        {
            UIImageView *cameraView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_off"]];
            cameraView.frame = CGRectMake(0, 0, (self.view.bounds.size.width - 60) / 2, (self.view.bounds.size.width - 60) / 2);
            [cell.contentView addSubview:cameraView];
            UILabel *cameraName = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.width - 60) / 2 + 5, (self.view.bounds.size.width - 60) / 2, 15)];
            cameraName.text = [self.allCameras[indexPath.row] objectForKey:@"name"];
            cameraName.textColor = [UIColor lightGrayColor];
            cameraName.textAlignment = NSTextAlignmentCenter;
            cameraName.font = [UIFont systemFontOfSize:12];
            [cell.contentView addSubview:cameraName];
        }
        
        return cell;
    }
    else
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CameraCell" forIndexPath:indexPath];
        [cell.contentView removeAllSubviews];
        
        UIImageView *alertView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alert_on"]];
        alertView.frame = CGRectMake(0, 0, (self.view.bounds.size.width - 60) / 2, (self.view.bounds.size.width - 60) / 2);
        [cell.contentView addSubview:alertView];
        
        UILabel *alert = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.width - 60) / 2 + 5, (self.view.bounds.size.width - 60) / 2, 15)];
        alert.text = @"警告通知";
        alert.textColor = [UIColor grayColor];
        alert.textAlignment = NSTextAlignmentCenter;
        alert.font = [UIFont systemFontOfSize:12];
        [cell.contentView addSubview:alert];
        return cell;
    }
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((self.view.bounds.size.width - 60) / 2, (self.view.bounds.size.width - 60) / 2 + 20);
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(20, 20, 20, 20);
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.allCameras.count)
    {
        if ([[self.loseCameraDict objectForKey:@"MAC"] isEqualToString:[self.allCameras[indexPath.row] objectForKey:@"macAddress"]])
        {
            return;
        }
        NSDictionary *resultDict = self.allCameras[indexPath.row];
        NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
        [df setObject:[resultDict objectForKey:@"name"] forKey:@"name"];
        [df setObject:[resultDict objectForKey:@"deviceID"] forKey:@"deviceID"];
        [df setObject:[resultDict objectForKey:@"deviceType"] forKey:@"deviceType"];
        [df setObject:[resultDict objectForKey:@"unitType"] forKey:@"unitType"];
        [df setObject:[resultDict objectForKey:@"online"] forKey:@"online"];
        [df setObject:[resultDict objectForKey:@"localIP"] forKey:@"localIP"];
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
        [self connectVideo];
    }
    else
    {
        [self connectAlert];
    }
}
-(BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.allCameras.count)
    {
        if ([[self.allCameras[indexPath.row] objectForKey:@"online"] integerValue])
        {
            if ([[self.findCameraDict objectForKey:@"MAC"] isEqualToString:[self.allCameras[indexPath.row] objectForKey:@"macAddress"]])
            {
                return YES;
            }
            if ([[self.loseCameraDict objectForKey:@"MAC"] isEqualToString:[self.allCameras[indexPath.row] objectForKey:@"macAddress"]])
            {
                return NO;
            }
            return YES;
        }
        else
        {
            if ([[self.findCameraDict objectForKey:@"MAC"] isEqualToString:[self.allCameras[indexPath.row] objectForKey:@"macAddress"]])
            {
                return YES;
            }
            if ([[self.loseCameraDict objectForKey:@"MAC"] isEqualToString:[self.allCameras[indexPath.row] objectForKey:@"macAddress"]])
            {
                return NO;
            }
            return NO;
        }
    }
    else
    {
        return YES;
    }
}
-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.allCameras.count)
    {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        [cell.contentView removeAllSubviews];
        UIImageView *cameraView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_off"]];
        cameraView.frame = CGRectMake(0, 0, (self.view.bounds.size.width - 60) / 2, (self.view.bounds.size.width - 60) / 2);
        [cell.contentView addSubview:cameraView];
        UILabel *cameraName = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.width - 60) / 2 + 5, (self.view.bounds.size.width - 60) / 2, 15)];
        cameraName.text = [self.allCameras[indexPath.row] objectForKey:@"name"];
        cameraName.textColor = [UIColor lightGrayColor];
        cameraName.textAlignment = NSTextAlignmentCenter;
        cameraName.font = [UIFont systemFontOfSize:12];
        [cell.contentView addSubview:cameraName];
    }
    else
    {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        [cell.contentView removeAllSubviews];
        UIImageView *alertView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alert_off"]];
        alertView.frame = CGRectMake(0, 0, (self.view.bounds.size.width - 60) / 2, (self.view.bounds.size.width - 60) / 2);
        [cell.contentView addSubview:alertView];
        UILabel *alert = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.width - 60) / 2 + 5, (self.view.bounds.size.width - 60) / 2, 15)];
        alert.text = @"警告通知";
        alert.textColor = [UIColor lightGrayColor];
        alert.textAlignment = NSTextAlignmentCenter;
        alert.font = [UIFont systemFontOfSize:12];
        [cell.contentView addSubview:alert];
    }
}
-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.allCameras.count)
    {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        [cell.contentView removeAllSubviews];
        UIImageView *cameraView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_on"]];
        cameraView.frame = CGRectMake(0, 0, (self.view.bounds.size.width - 60) / 2, (self.view.bounds.size.width - 60) / 2);
        [cell.contentView addSubview:cameraView];
        UILabel *cameraName = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.width - 60) / 2 + 5, (self.view.bounds.size.width - 60) / 2, 15)];
        cameraName.text = [self.allCameras[indexPath.row] objectForKey:@"name"];
        cameraName.textColor = [UIColor grayColor];
        cameraName.textAlignment = NSTextAlignmentCenter;
        cameraName.font = [UIFont systemFontOfSize:12];
        [cell.contentView addSubview:cameraName];
    }
    else
    {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        [cell.contentView removeAllSubviews];
        UIImageView *alertView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alert_on"]];
        alertView.frame = CGRectMake(0, 0, (self.view.bounds.size.width - 60) / 2, (self.view.bounds.size.width - 60) / 2);
        [cell.contentView addSubview:alertView];
        UILabel *alert = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.width - 60) / 2 + 5, (self.view.bounds.size.width - 60) / 2, 15)];
        alert.text = @"警告通知";
        alert.textColor = [UIColor grayColor];
        alert.textAlignment = NSTextAlignmentCenter;
        alert.font = [UIFont systemFontOfSize:12];
        [cell.contentView addSubview:alert];
    }
}

/*
-(void)promptPassword
{
    __block UITextField *tempTF = nil;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Home Network" message:@"Please Enter Home Network Password" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        tempTF = textField;
    }];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
        [df setObject:tempTF.text forKey:@"homeNetworkPassword"];
        [df synchronize];
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}
*/

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

//添加摄像头
-(void)addCamera
{
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    if ([[df objectForKey:@"ISLOCAL"] integerValue] || (![df objectForKey:@"homeNetworkName"]))
    {
        PromptViewController *promptVC = [PromptViewController new];
        AppDelegate *mainAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [mainAppDelegate.mainNVC pushViewController:promptVC animated:YES];
    }
    else
    {
        NSString *homeNetworkSSID = [df objectForKey:@"homeNetworkName"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Home Network" message:[NSString stringWithFormat:@"Please Connect '%@' Home Network",homeNetworkSSID] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *mainAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [mainAppDelegate.leftSlideVC setPanEnabled:YES];
    
    //非初次刷新
    if (!self.isIntro)
    {
        CGFloat maxWidth = self.view.bounds.size.width;
        [self.backView removeFromSuperview];
        self.backView = nil;
        self.backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.backView.backgroundColor = [UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        [self.view addSubview:self.backView];
        //判断数据库摄像头数量
        NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
        NSString *cameraMac = [df objectForKey:@"macAddress"];
        if (cameraMac.length == 0)
        {
            self.cameraNum = 0;
            UILabel *noCameraLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, maxWidth - 40, 60)];
            noCameraLabel.text = @"请选择+号将设备添加到您的账户。";
            noCameraLabel.font = [UIFont systemFontOfSize:18];
            noCameraLabel.textColor = [UIColor grayColor];
            noCameraLabel.numberOfLines = 0;
            noCameraLabel.textAlignment = NSTextAlignmentCenter;
            [self.backView addSubview:noCameraLabel];
            
            /*
            if (![[df objectForKey:@"homeNetworkName"] length])
            {
                __block UITextField *tempTF = nil;
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Home Network" message:@"Please Enter Home Network SSID" preferredStyle:UIAlertControllerStyleAlert];
                [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    tempTF = textField;
                }];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [df setObject:tempTF.text forKey:@"homeNetworkName"];
                    [df synchronize];
                    homeNetworkName = tempTF.text;
                    [self promptPassword];
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
            */
        }
        else
        {
            homeNetworkName = [df objectForKey:@"homeNetworkName"];
            
            self.cameraNum = 1;
            CGFloat iconWidth = (maxWidth - 40) / 4;
            UIView *cameraView = [[UIView alloc] initWithFrame:CGRectMake(iconWidth, 80, iconWidth, iconWidth * 5 / 4)];
            cameraView.backgroundColor = [UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
            
            self.cameraBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            self.cameraBtn.frame = CGRectMake(0, 0, iconWidth, iconWidth);
            [self.cameraBtn setBackgroundImage:[UIImage imageNamed:@"camera_on"] forState:UIControlStateNormal];
            [self.cameraBtn setBackgroundImage:[UIImage imageNamed:@"camera_off"] forState:UIControlStateHighlighted];
            [cameraView addSubview:self.cameraBtn];
            [self.cameraBtn addTarget:self action:@selector(connectVideo) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel *cameraName = [[UILabel alloc] initWithFrame:CGRectMake(0, iconWidth, iconWidth, iconWidth / 4)];
            cameraName.text = [df objectForKey:@"name"];
            cameraName.textColor = [UIColor grayColor];
            cameraName.textAlignment = NSTextAlignmentCenter;
            cameraName.font = [UIFont systemFontOfSize:12];
            [cameraView addSubview:cameraName];
            
            [self.backView addSubview:cameraView];
            
            UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(iconWidth * 2 + 40, 80, iconWidth, iconWidth * 5 / 4)];
            alertView.backgroundColor = [UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
            
            UIButton *alertBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            alertBtn.frame = CGRectMake(0, 0, iconWidth, iconWidth);
            [alertBtn setBackgroundImage:[UIImage imageNamed:@"alert_on"] forState:UIControlStateNormal];
            [alertBtn setBackgroundImage:[UIImage imageNamed:@"alert_off"] forState:UIControlStateHighlighted];
            [alertView addSubview:alertBtn];
            [alertBtn addTarget:self action:@selector(connectAlert) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel *alertName = [[UILabel alloc] initWithFrame:CGRectMake(0, iconWidth, iconWidth, iconWidth / 4)];
            alertName.text = @"警告通知";
            alertName.textColor = [UIColor grayColor];
            alertName.textAlignment = NSTextAlignmentCenter;
            alertName.font = [UIFont systemFontOfSize:12];
            [alertView addSubview:alertName];
            
            [self.backView addSubview:alertView];
            
            if ([[df objectForKey:@"online"] integerValue])
            {
                self.cameraBtn.userInteractionEnabled = YES;
                [self.cameraBtn setHighlighted:NO];
            }
            else
            {
                self.cameraBtn.userInteractionEnabled = NO;
                [self.cameraBtn setHighlighted:YES];
            }
            
            self.allCameras = [DataBaseTool getCamerasFromDatabase];
            UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
            [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
            self.cameraView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
            self.cameraView.contentInset = UIEdgeInsetsMake(60, 0, 60, 0);
            self.cameraView.dataSource = self;
            self.cameraView.delegate = self;
            [self.cameraView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CameraCell"];
            [self.cameraView setBackgroundColor:[UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
            [self.view addSubview:self.cameraView];
        }
        self.isIntro = YES;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width - 40, self.view.bounds.size.height - 200)];
    label.text = @"Support Only One Camera Test DeepCam_SDK";
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.textColor = [UIColor redColor];
    label.font = [UIFont systemFontOfSize:26];
    [self.backView addSubview:label];
    
    //监测网络
    __block MainViewController *blockSelf = self;
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [self checkHomeNetwork];//network change check
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown:
                blockSelf.network = @"";
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                blockSelf.network = @"";
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                blockSelf.network = @"cell";
                [self setNetworkStatus:@"0"];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                blockSelf.network = @"wifi";
                [self setNetworkStatus:@"1"];
                //[self broadcastCamera];
                break;
                
            default:
                break;
        }
    }];
}

-(void)setNetworkStatus:(NSString*)status
{
    NSLog(@"Network Status HD --> %@",status);
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    [df setObject:status forKey:@"ISHD"];
    [df synchronize];
    if ([status integerValue])
    {
        if (checkTimer)
        {
            [checkTimer invalidate];
            checkTimer = nil;
        }
        checkTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(checkHomeNetwork) userInfo:nil repeats:YES];
    }
    else
    {
        if (checkTimer)
        {
            [checkTimer invalidate];
            checkTimer = nil;
        }
    }
}

-(void)broadcastCamera
{
    NSMutableArray *macs = [NSMutableArray array];
    for (NSDictionary *cameraDict in self.allCameras)
    {
        [macs addObject:[cameraDict objectForKey:@"macAddress"]];
    }
    if (!macs.count)
    {
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        self.DCSDK = [[DeepCam_SDK alloc] DC_InitBroadcastCameraDiscoveryWithLocalCamerasMac:macs ForStartServer:YES AndTimeInterval:60.0];//Only One Camera
        self.DCSDK.DC_CameraDiscoveryDelegate = self;
        [self.DCSDK DC_BroadcastCameraStartPolling];
        //[DCSDK DC_BroadcastCameraStopPolling];
        //[DCSDK DC_BroadcastCameraDiscoveryRequest];//offline
    });
}

#pragma mark -- DC_CameraDiscoveryDelegate
-(void)DC_BroadcastCameraDiscoveryResult:(NSDictionary *)cameraDict
{
    NSLog(@"Discover Camera --> %@",cameraDict);
    //key:CameraDiscoveredAttributesKey(category/mac/type) & key:CameraDiscoveredAddressKey(IP)
    /*
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *cameraMac = [df objectForKey:@"macAddress"];
    if ([[[[cameraDict objectForKey:@"CameraDiscoveredAttributesKey"] objectForKey:@"mac"] uppercaseString] isEqualToString:cameraMac])
    {
        NSLog(@"Find Camera MAC --> %@",cameraMac);
        self.cameraBtn.userInteractionEnabled = YES;
        [self.cameraBtn setHighlighted:NO];
        [df setObject:[NSNumber numberWithInteger:1] forKey:@"localOnline"];
        [df synchronize];
    }
    */
    self.findCameraDict = @{@"MAC":[[[cameraDict objectForKey:@"CameraDiscoveredAttributesKey"] objectForKey:@"mac"] uppercaseString]};
    [self.cameraView reloadData];
}
-(void)DC_BroadcastCameraStatusOfflineForCameraMac:(NSString *)mac
{
    NSLog(@"Broadcast Camera Status Offline --> %@",mac);
    /*
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *cameraMac = [df objectForKey:@"macAddress"];
    if ([mac isEqualToString:cameraMac])
    {
        self.cameraBtn.userInteractionEnabled = NO;
        [self.cameraBtn setHighlighted:YES];
        [df setObject:[NSNumber numberWithInteger:0] forKey:@"localOnline"];
        [df synchronize];
    }
    */
    self.loseCameraDict = @{@"MAC":mac};
    [self.cameraView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.videoHUD hide:YES];
    
    AppDelegate *mainAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [mainAppDelegate.leftSlideVC setPanEnabled:NO];
    
    self.isIntro = NO;
    
    if (checkTimer)
    {
        [checkTimer invalidate];
        checkTimer = nil;
    }
    [self.DCSDK DC_BroadcastCameraStopPolling];
}

-(void)startScanCamera
{
    [self.DCSDK DC_BroadcastCameraStartPolling];
}

-(void)stopScanCamera
{
    [self.DCSDK DC_BroadcastCameraStopPolling];
}

//连接视频 -- 唯一摄像头
-(void)connectVideo
{
    if (self.network.length == 0)
    {
        UIAlertController *netAlert = [UIAlertController alertControllerWithTitle:@"无法连接到网络" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [netAlert addAction:action];
        [self presentViewController:netAlert animated:YES completion:nil];
        return;
    }
    
    self.videoHUD  = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.videoHUD.labelText = @"连接视频中";
    
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    
//    if ([self.network isEqualToString:@"wifi"])
//    {
//        [df setObject:@"1" forKey:@"ISHD"];
//        [df synchronize];
//    }
//    if ([self.network isEqualToString:@"cell"])
//    {
//        [df setObject:@"0" forKey:@"ISHD"];
//        [df synchronize];
//    }
    
    if ([[df objectForKey:@"ISLOCAL"] integerValue])
    {
        VideoPlayViewController *videoVC = [VideoPlayViewController new];
        AppDelegate *mainAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [mainAppDelegate.mainNVC presentViewController:videoVC animated:YES completion:nil];
        return;
    }
    
    NSString *cameraMac = [df objectForKey:@"macAddress"];
    NSString *cameraKey = [df objectForKey:@"key"];
    NSString *userID = [df objectForKey:@"userID"];
    NSString *token = [df objectForKey:@"token"];
    NSString *userGroup = [df objectForKey:@"userGroup"];
    NSString *planType = [df objectForKey:@"planType"];//1
    NSString *pt = planType.length ? planType : @"1";
    
    DC_CameraManager *cameraManager = [DC_CameraManager new];
    cameraManager.DC_PlayVideoDelegate = self;
    if ([self.network isEqualToString:@"wifi"])
    {
        [cameraManager DC_GetVideoConnectionAddressWithVideoLevel:DC_VideoLevelHD WithCameraMac:cameraMac WithCameraKey:cameraKey WithAccountUserID:userID WithAccountToken:token WithAccountUserGroup:userGroup WithAccountPlanType:pt];
    }
    if ([self.network isEqualToString:@"cell"])
    {
        [cameraManager DC_GetVideoConnectionAddressWithVideoLevel:DC_VideoLevelNormal WithCameraMac:cameraMac WithCameraKey:cameraKey WithAccountUserID:userID WithAccountToken:token WithAccountUserGroup:userGroup WithAccountPlanType:pt];
    }
}

#pragma mark -- DC_PlayVideoDelegate
-(void)DC_GetVideoConnectionAddressFinish:(BOOL)success WithResult:(NSDictionary *)resultDict WithMessageCode:(NSInteger)code WithErrorDescription:(NSString *)description
{
    if (success)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.videoHUD hide:YES];
            VideoPlayViewController *videoVC = [VideoPlayViewController new];
            NSString *connectionstring = [resultDict objectForKey:@"connectionstring"];
            NSString *connectionhttp = [resultDict objectForKey:@"connectionhttp"];
            NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
            [df setObject:connectionstring forKey:@"connectionstring"];
            [df setObject:connectionhttp forKey:@"connectionhttp"];
            [df synchronize];
            AppDelegate *mainAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [mainAppDelegate.mainNVC presentViewController:videoVC animated:YES completion:nil];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.videoHUD hide:YES];
        });
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
                title = @"获取视频失败";
                message = description;
            }
        }
        else
        {
            title = @"获取视频失败";
            message = description;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:action];
            [self.parentViewController presentViewController:alert animated:YES completion:nil];
        });
    }
}

//警报通知
-(void)connectAlert
{
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *userGroup = [df objectForKey:@"userGroup"];
    NSString *userID = [df objectForKey:@"userID"];
    NSString *password = [df objectForKey:@"password"];
    
    DeepCam_SDK *DCSDK = [DeepCam_SDK new];
    DCSDK.DC_AlertLogDelegate = self;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose Alert Type" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Noise" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [DCSDK DC_GetAlertLogForType:DC_AlertsTypeNoise WithUserID:userID WithUserGroup:userGroup WithPassword:password];
    }];
    [alert addAction:action1];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Viewer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [DCSDK DC_GetAlertLogForType:DC_AlertsTypeViewer WithUserID:userID WithUserGroup:userGroup WithPassword:password];
    }];
    [alert addAction:action2];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"Motion" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [DCSDK DC_GetAlertLogForType:DC_AlertsTypeMotion WithUserID:userID WithUserGroup:userGroup WithPassword:password];
    }];
    [alert addAction:action3];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- DC_GetAlertLogDelegate
-(void)DC_GetAlertLogWithWebView:(NSString*)alertUrl
{
    AlertViewController *alertVC = [AlertViewController new];
    alertVC.alertUrl = alertUrl;
    AppDelegate *mainAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [mainAppDelegate.mainNVC pushViewController:alertVC animated:YES];
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
        NSLog(@"Current WiFi --> %@ -- Home:%@",currentSSID,homeNetworkName);
        if ([currentSSID isEqualToString:homeNetworkName])//SSID For Your Home WiFi
        {
            NSLog(@"Have Connected '%@' Home WiFi",homeNetworkName);
            NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
            [df setObject:@"1" forKey:@"ISLOCAL"];
            [df synchronize];
            [self broadcastCamera];//local check camera
        }
        else
        {
            NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
            [df setObject:@"0" forKey:@"ISLOCAL"];
            [df synchronize];
        }
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
