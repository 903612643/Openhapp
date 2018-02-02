//
//  DataTool.m
//  Openhapp
//
//  Created by Jesse on 16/2/24.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import "DataTool.h"

@implementation DataTool


//记住密码模式
+(void)saveRemindState:(BOOL)state
{
    NSUserDefaults *setDefaults = [NSUserDefaults standardUserDefaults];
    [setDefaults setBool:state forKey:@"PASSWORDREMINDSTATE"];
    [setDefaults synchronize];
}
+(BOOL)getRemindState
{
    NSUserDefaults *setDefaults = [NSUserDefaults standardUserDefaults];
    return [setDefaults boolForKey:@"PASSWORDREMINDSTATE"];
}

//记住账号
+(void)saveAccount:(NSString *)account
{
    NSUserDefaults *setDefaults = [NSUserDefaults standardUserDefaults];
    [setDefaults setObject:account forKey:@"ACCOUNT"];
    [setDefaults synchronize];
}
+(NSString*)getAccount
{
    NSUserDefaults *setDefaults = [NSUserDefaults standardUserDefaults];
    return (NSString*)[setDefaults objectForKey:@"ACCOUNT"];
}

//记住密码
+(void)savePassword:(NSString *)pw
{
    NSUserDefaults *setDefaults = [NSUserDefaults standardUserDefaults];
    [setDefaults setObject:pw forKey:@"PASSWORD"];
    [setDefaults synchronize];
}
+(NSString*)getPassword
{
    NSUserDefaults *setDefaults = [NSUserDefaults standardUserDefaults];
    return (NSString*)[setDefaults objectForKey:@"PASSWORD"];
}

//登录记录
+(void)saveLoginState:(BOOL)state
{
    NSUserDefaults *setDefaults = [NSUserDefaults standardUserDefaults];
    [setDefaults setBool:state forKey:@"LOGINSTATE"];
    [setDefaults synchronize];
}
+(BOOL)getLoginState
{
    NSUserDefaults *setDefaults = [NSUserDefaults standardUserDefaults];
    return [setDefaults boolForKey:@"LOGINSTATE"];
}

//获取设置项目
+(NSArray*)getSetItems
{
    NSString *firstSetItem = @"注销";
    NSString *secondSetItem = @"主界面";
    NSString *thirdSetItem = @"设备管理";
    NSString *fourthSetItem = @"用户";
    NSString *fifthSetItem = @"帮助";
    NSString *sixthSetItem = @"系统配置";
    NSString *seventhSetItem = @"关于";
    NSArray *setItems = @[firstSetItem,secondSetItem,thirdSetItem,fourthSetItem,fifthSetItem,sixthSetItem,seventhSetItem];
    return [setItems copy];
}
+(NSArray*)getSetImages
{
    NSString *firstSetImage = @"logout_drawer_icon";
    NSString *secondSetImage = @"home_drawer_icon";
    NSString *thirdSetImage = @"things_drawer_icon";
    NSString *fourthSetImage = @"users_drawer_icon";
    NSString *fifthSetImage = @"help_drawer_icon";
    NSString *sixthSetImage = @"global_settings_drawer_icon";
    NSString *seventhSetImage = @"about_drawer_icon";
    NSArray *setImages = @[firstSetImage,secondSetImage,thirdSetImage,fourthSetImage,fifthSetImage,sixthSetImage,seventhSetImage];
    return [setImages copy];
}

//临时账号
+(void)saveTempAccount:(NSDictionary *)tempDic
{
    NSUserDefaults *setDefaults = [NSUserDefaults standardUserDefaults];
    [setDefaults setObject:tempDic forKey:@"TEMPACCOUNT"];
    [setDefaults synchronize];
}
+(NSDictionary*)getTempAccount
{
    NSUserDefaults *setDefaults = [NSUserDefaults standardUserDefaults];
    return (NSDictionary*)[setDefaults objectForKey:@"TEMPACCOUNT"];
}


@end
