//
//  ScanViewController.m
//  Openhapp
//
//  Created by Jesse on 16/3/2.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import "ScanViewController.h"
#import "LBXScanView.h"
#import "LBXScanViewStyle.h"
#import "LBXScanWrapper.h"
#import "LBXScanResult.h"
#import "AppDelegate.h"
#import "AddDeviceViewController.h"

#define MAXWIDTH self.view.bounds.size.width;

@interface ScanViewController ()
@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) UILabel *promptLabel;
@property (nonatomic,strong) LBXScanViewStyle *scanStyle;
@property (nonatomic,strong) LBXScanView *scanView;
@property (nonatomic,strong) LBXScanWrapper *scanWrapper;
@property (nonatomic,strong) UITextField *nameTF;
@end

@implementation ScanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"扫描二维码";
    self.navigationItem.hidesBackButton = YES;
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showScanView];
}

-(void)showScanView
{
    CGFloat maxWidth = MAXWIDTH;
    
    [self.backView removeFromSuperview];
    self.backView = nil;
    self.backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.backView.backgroundColor = [UIColor colorWithRed:240/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
    [self.view addSubview:self.backView];
    
    self.promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, maxWidth, 30)];
    self.promptLabel.text = @"扫描摄像机底部的二维码";
    self.promptLabel.textColor = [UIColor grayColor];
    self.promptLabel.font = [UIFont systemFontOfSize:14];
    self.promptLabel.textAlignment = NSTextAlignmentCenter;
    [self.backView addSubview:self.promptLabel];
    
    self.scanStyle = [[LBXScanViewStyle alloc]init];
    self.scanStyle.centerUpOffset = 0;
    self.scanStyle.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Inner;
    self.scanStyle.photoframeLineW = 3;
    self.scanStyle.photoframeAngleW = maxWidth - 100;
    self.scanStyle.photoframeAngleH = maxWidth - 100;
    self.scanStyle.isNeedShowRetangle = NO;
    self.scanStyle.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
    UIImage *imgLine = [UIImage imageNamed:@"qrcode_scan_light_green"];
    self.scanStyle.animationImage = imgLine;
    self.scanView = [[LBXScanView alloc] initWithFrame:CGRectMake(0, 0, maxWidth - 100, maxWidth - 100) style:self.scanStyle];
    self.scanView.center = self.backView.center;
    [self.backView addSubview:self.scanView];
    [self performSelector:@selector(startScan) withObject:nil afterDelay:0];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame = CGRectMake((self.backView.bounds.size.width - 80) / 2, self.backView.size.height - 60, 80, 30);
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor colorWithRed:216/255.0 green:191/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [backBtn setBackgroundColor:[UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0]];
    [backBtn.layer setMasksToBounds:YES];
    [backBtn.layer setCornerRadius:3.0];
    [self.backView addSubview:backBtn];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.scanWrapper stopScan];
    [self.scanView stopScanAnimation];
    [self.scanView removeFromSuperview];
    [self.backView removeFromSuperview];
}

- (void)startScan
{
    if (![LBXScanWrapper isGetCameraPermission])
    {
        [self.scanView stopDeviceReadying];
        return;
    }
    if (!self.scanWrapper)
    {
        __weak __typeof(self) weakSelf = self;
        CGRect cropRect = CGRectZero;
        cropRect = [LBXScanView getScanRectWithPreView:self.scanView style:self.scanStyle];
        self.scanWrapper = [[LBXScanWrapper alloc]initWithPreView:self.scanView//相机预览区域
                                              ArrayObjectType:nil
                                                     cropRect:cropRect
                                                      success:^(NSArray<LBXScanResult *> *array){
                                                          [weakSelf scanResultWithArray:array];
                                                      }];
    }
    [self.scanWrapper startScan];
    [self.scanView stopDeviceReadying];
    [self.scanView startScanAnimation];
}

- (void)scanResultWithArray:(NSArray<LBXScanResult*>*)array
{
    LBXScanResult *scanResult = [[LBXScanResult alloc] init];
    for (LBXScanResult *result in array)
    {
        scanResult = result;
        NSLog(@"Scan Result: %@",result.strScanned);
    }
    [self.scanWrapper stopScan];
    [self.scanView stopScanAnimation];
    [self.scanView removeFromSuperview];
    
    self.promptLabel.text = @"读取的二维码信息";
    UILabel *resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.backView.bounds.size.width - 40, 60)];
    resultLabel.center = self.backView.center;
    resultLabel.text = scanResult.strScanned;
    resultLabel.numberOfLines = 0;
    resultLabel.textAlignment = NSTextAlignmentCenter;
    [self.backView addSubview:resultLabel];
    
    [self parseScanResult:scanResult.strScanned];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame = CGRectMake((self.backView.bounds.size.width - 80) / 2, self.backView.size.height - 60, 80, 30);
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor colorWithRed:216/255.0 green:191/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [backBtn setBackgroundColor:[UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0]];
    [backBtn.layer setMasksToBounds:YES];
    [backBtn.layer setCornerRadius:3.0];
    [self.backView addSubview:backBtn];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    nextBtn.frame = CGRectMake((self.backView.bounds.size.width - 80) / 2, self.backView.size.height - 110, 80, 30);
    [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor colorWithRed:216/255.0 green:191/255.0 blue:216/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [nextBtn setBackgroundColor:[UIColor colorWithRed:240/255.0 green:230/255.0 blue:140/255.0 alpha:1.0]];
    [nextBtn.layer setMasksToBounds:YES];
    [nextBtn.layer setCornerRadius:3.0];
    [self.backView addSubview:nextBtn];
    [nextBtn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
}

-(void)parseScanResult:(NSString*)resultText
{
    if (resultText.length != 31)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Scan Error" message:@"QR Code Is Wrong Format" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self back];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    NSRange range1 = NSMakeRange(3, 12);
    NSString *mac = [resultText substringWithRange:range1];
    NSRange range2 = NSMakeRange(19, 12);
    NSString *key = [resultText substringWithRange:range2];
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    [df setObject:mac forKey:@"TEMPMAC"];
    [df setObject:key forKey:@"TEMPKEY"];
    [df synchronize];
    NSLog(@"Save Temp Mac & key");
}

-(void)next
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入设备名称" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        self.nameTF = textField;
    }];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (!self.nameTF.text.length)
        {
            [self back];
            return;
        }
        NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
        [df setObject:self.nameTF.text forKey:@"name"];
        [df synchronize];
        NSLog(@"Save Temp Device Name -- %@",self.nameTF.text);
        AddDeviceViewController *addVC = [AddDeviceViewController new];
        [self.navigationController pushViewController:addVC animated:YES];
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)back
{
    AppDelegate *mainAppDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [mainAppDelegate.mainNVC popToRootViewControllerAnimated:YES];
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
