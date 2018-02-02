//
//  VideoPlayViewController.m
//  Openhapp
//
//  Created by Jesse on 16/5/6.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import "VideoPlayViewController.h"
#import "DC_CameraManager.h"
#import "AppDelegate.h"
#import "DataBaseTool.h"

@interface VideoPlayViewController () <DC_PlayVideoDelegate,DC_SendVoiceDelegate>

@property BOOL isLocal;

@property DC_CameraManager *cameraManager;

@property UIView *backView;

@property UIView *backVideoView;

@end

@implementation VideoPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backView = [[UIView alloc] initWithFrame:self.view.bounds];
    _backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backView];
    
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    self.isLocal = [[df objectForKey:@"ISLOCAL"] integerValue] ? YES : NO;
    
    self.backVideoView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, 250)];
    self.backVideoView.backgroundColor = [UIColor blackColor];
    [self.backView addSubview:self.backVideoView];
    
    NSString *networkStr = self.isLocal ? @"HomeNetwork" : @"Internet";
    NSString *videoStr = [[df objectForKey:@"ISHD"] integerValue] ? @"HD" : @"Normal";
    UILabel *networkLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 280) / 2, 25, 280, 30)];
    networkLabel.text = [NSString stringWithFormat:@"%@ %@",networkStr,videoStr];
    networkLabel.textColor = [UIColor redColor];
    networkLabel.textAlignment = NSTextAlignmentCenter;
    networkLabel.font = [UIFont systemFontOfSize:18];
    [self.backView addSubview:networkLabel];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake((self.view.bounds.size.width - 80) / 2, self.view.size.height - 160, 80, 30);
    [closeBtn setTitle:@"Close" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor colorWithRed:216/255.0 green:191/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [closeBtn setBackgroundColor:[UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0]];
    [closeBtn.layer setMasksToBounds:YES];
    [closeBtn.layer setCornerRadius:3.0];
    [self.backView addSubview:closeBtn];
    [closeBtn addTarget:self action:@selector(closeVideoBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *talkBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    talkBtn.frame = CGRectMake((self.view.bounds.size.width - 80) / 2, self.view.size.height - 60, 80, 30);
    [talkBtn setTitle:@"TalkBack" forState:UIControlStateNormal];
    [talkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [talkBtn setTitleColor:[UIColor colorWithRed:216/255.0 green:191/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    talkBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [talkBtn setBackgroundColor:[UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0]];
    [talkBtn.layer setMasksToBounds:YES];
    [talkBtn.layer setCornerRadius:3.0];
    [self.backView addSubview:talkBtn];
    [talkBtn addTarget:self action:@selector(talkRecord) forControlEvents:UIControlEventTouchDown];
    [talkBtn addTarget:self action:@selector(talkSend) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *snapBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    snapBtn.frame = CGRectMake((self.view.bounds.size.width - 80) / 2, self.view.size.height - 110, 80, 30);
    [snapBtn setTitle:@"Snapshot" forState:UIControlStateNormal];
    [snapBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [snapBtn setTitleColor:[UIColor colorWithRed:216/255.0 green:191/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    snapBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [snapBtn setBackgroundColor:[UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0]];
    [snapBtn.layer setMasksToBounds:YES];
    [snapBtn.layer setCornerRadius:3.0];
    [self.backView addSubview:snapBtn];
    [snapBtn addTarget:self action:@selector(takeSnapshot) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundStop) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)backgroundStop
{
    [self.cameraManager DC_CloseVideo];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *localIP = [df objectForKey:@"localIP"];
    NSString *rtspUserName = [df objectForKey:@"rtspUserName"];
    NSString *key = [df objectForKey:@"key"];
    NSString *rtspPort = [df objectForKey:@"rtspPort"];
    NSString *localPath = [df objectForKey:@"localPath"];
    NSString *aspectRatio = [df objectForKey:@"aspectRatio"];
    NSString *remoteURL = [df objectForKey:@"connectionstring"];
    NSString *remotePath = [df objectForKey:@"remotePath"];
    NSString *cellPath = [df objectForKey:@"cellPath"];
    NSNumber *videoWiFiTimeout = [NSNumber numberWithInteger:[[df objectForKey:@"videoWifiTimeout"] integerValue]];
    NSNumber *videoCellTimeout = [NSNumber numberWithInteger:[[df objectForKey:@"videoCellTimeout"] integerValue]];
    self.cameraManager = [DC_CameraManager new];
    self.cameraManager.DC_PlayVideoDelegate = self;
    if (self.isLocal)
    {
        [self.cameraManager DC_LoadVideoFromCameraLocalIP:localIP CameraRtspUserName:rtspUserName CameraKey:key CameraRtspPort:rtspPort CameraLocalPath:localPath AspectRatio:aspectRatio VideoTimeOut:videoWiFiTimeout ForViewFrame:self.backVideoView.bounds AndVideoSize:DC_VideoSizeSmall];
    }
    else
    {
        if ([[df objectForKey:@"ISHD"] integerValue])
        {
            NSLog(@"Video HD");
            [self.cameraManager DC_LoadVideoFromCameraRemoteURL:remoteURL CameraRtspUserName:rtspUserName CameraKey:key CameraRemotePath:remotePath CameraCellPath:cellPath AspectRatio:aspectRatio ForVideoLevel:DC_VideoLevelHD VideoTimeOut:videoWiFiTimeout ForViewFrame:self.backVideoView.bounds AndVideoSize:DC_VideoSizeSmall];
        }
        else
        {
            NSLog(@"Video Normal");
            [self.cameraManager DC_LoadVideoFromCameraRemoteURL:remoteURL CameraRtspUserName:rtspUserName CameraKey:key CameraRemotePath:remotePath CameraCellPath:cellPath AspectRatio:aspectRatio ForVideoLevel:DC_VideoLevelNormal VideoTimeOut:videoCellTimeout ForViewFrame:self.backVideoView.bounds AndVideoSize:DC_VideoSizeSmall];
        }
    }
}

-(void)talkRecord
{
    self.cameraManager.DC_VoiceSendDelegate = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [self.cameraManager DC_RecordVoice];
    });
}

-(void)talkSend
{
    DC_CameraType cameraType = 0;
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSInteger type = [[df objectForKey:@"unitType"] integerValue];
    NSString *localIP = [df objectForKey:@"localIP"];
    NSString *connectionhttp = [df objectForKey:@"connectionhttp"];
    NSString *httpUserName = [df objectForKey:@"httpUserName"];
    NSString *key = [df objectForKey:@"key"];
    if (type == 5)
    {
        cameraType = DC_CameraTypeH210;
    }
    if (type == 3)
    {
        cameraType = DC_CameraTypeAH8704;
    }
    if (self.isLocal)
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [self.cameraManager DC_SendVoiceForNetworkModel:DC_NetworkModelLocal WithCameraType:cameraType WithLocalIP:localIP WithConnectionHttp:connectionhttp WithHttpUserName:httpUserName WithKey:key];
        });
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [self.cameraManager DC_SendVoiceForNetworkModel:DC_NetworkModelRemote WithCameraType:cameraType WithLocalIP:localIP WithConnectionHttp:connectionhttp WithHttpUserName:httpUserName WithKey:key];
        });
    }
}

-(void)takeSnapshot
{
    [self.cameraManager DC_TakeSnapshot];
}

#pragma mark -- DC_PlayVideoDelegate
-(void)DC_LoadVideoFinish:(BOOL)success WithVideoView:(UIView *)videoView WithErrorDescription:(NSString *)description
{
    NSLog(@"Load Video Thread --> %@",[NSThread currentThread]);
    if (success)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.backVideoView addSubview:videoView];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"载入视频失败" message:description preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self closeVideoBack];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
}

-(void)DC_VideoPlayerStartForScrollViewContentInset:(UIEdgeInsets)videoContentInset ScrollRectToVisible:(CGRect)videoRect
{
    NSLog(@"Video Player Start Thread --> %@",[NSThread currentThread]);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //UIEdgeInsets EI = videoContentInset;
        //CGRect VR = videoRect;
    });
}

-(void)DC_VideoPlayerDidDisconnectForErrorDescription:(NSString *)description WithMessageCode:(NSString *)code
{
    NSLog(@"Video Player Did Disconnect Thread --> %@",[NSThread currentThread]);
    
    //[self.cameraManager DC_StopVideo];
    
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
            title = @"视频连接断开";
            message = description;
        }
    }
    else
    {
        title = @"视频连接断开";
        message = description;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self closeVideoBack];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

-(void)DC_TakeSnapshotCanNotAccessPhotoAlbumForMessageCode:(NSString *)code
{
    NSLog(@"Take Snapshot Thread --> %@",[NSThread currentThread]);
    
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
            title = @"截图失败";
            message = @"请检查是否有权限";
        }
    }
    else
    {
        title = @"截图失败";
        message = @"请检查是否有权限";
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

#pragma mark -- DC_VoiceSendDelegate
-(void)DC_SendVoiceFinish:(BOOL)success ForErrorDescription:(NSString *)description
{
    if (success)
    {
        NSLog(@"Send Voice Success");
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Send Voice Failure" message:description preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
}

-(void)closeVideoBack
{
    [self.cameraManager DC_CloseVideo];
    [self.backVideoView removeAllSubviews];
    AppDelegate *mainAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [mainAppDelegate.mainNVC dismissViewControllerAnimated:YES completion:nil];
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
