//
//  DataTool.h
//  Openhapp
//
//  Created by Jesse on 16/2/24.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataTool : NSObject

//记住密码模式
+(void)saveRemindState:(BOOL)state;
+(BOOL)getRemindState;

//记住账号
+(void)saveAccount:(NSString*)account;
+(NSString*)getAccount;

//记住密码
+(void)savePassword:(NSString*)pw;
+(NSString*)getPassword;

//登录记录
+(void)saveLoginState:(BOOL)state;
+(BOOL)getLoginState;

//获取设置项目
+(NSArray*)getSetItems;
+(NSArray*)getSetImages;

//临时账号
+(void)saveTempAccount:(NSDictionary*)tempDic;
+(NSDictionary*)getTempAccount;

@end
