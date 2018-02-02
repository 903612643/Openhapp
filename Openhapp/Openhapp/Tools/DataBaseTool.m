//
//  DataBaseTool.m
//  Openhapp
//
//  Created by Jesse on 16/2/25.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import "DataBaseTool.h"
#import "FMDB.h"

@implementation DataBaseTool

//Account
+(void)saveAccountToDatabase:(NSDictionary *)accountDic
{
    NSDictionary *existDict = nil;
    //数据库地址
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *sqlitePath = [documentsPath stringByAppendingPathComponent:@"openhapp.sqlite"];
    //创建数据库
    FMDatabase *dataBase = [FMDatabase databaseWithPath:sqlitePath];
    //打开数据库
    if ([dataBase open])
    {
        if ([dataBase tableExists:@"account"])
        {
            existDict = [self getAccountFromDatabase];
        }
        //无表创建表
        [dataBase executeUpdate:@"create table if not exists account (userID text, userType numeric, userPassword text, userFirstName text, userLastName text, userEmail text, userPhone text, userGroup text, language text, planType numeric, offer numeric, acceptTerms numeric, token text)"];
        //清除数据库
        [dataBase executeUpdate:@"delete from account"];
    }
    //写入数据库
    NSString *userID = [accountDic objectForKey:@"userID"]?[accountDic objectForKey:@"userID"]:@"0";
    NSNumber *userType = [accountDic objectForKey:@"userType"]?[accountDic objectForKey:@"userType"]:@0;
    NSString *userPassword = [accountDic objectForKey:@"userPassword"]?[accountDic objectForKey:@"userPassword"]:@"0";
    NSString *userFirstName = [accountDic objectForKey:@"userFirstName"]?[accountDic objectForKey:@"userFirstName"]:@"0";
    NSString *userLastName = [accountDic objectForKey:@"userLastName"]?[accountDic objectForKey:@"userLastName"]:@"0";
    NSString *userEmail = [accountDic objectForKey:@"userEmail"]?[accountDic objectForKey:@"userEmail"]:@"0";
    NSString *userPhone = [accountDic objectForKey:@"userPhone"]?[accountDic objectForKey:@"userPhone"]:@"0";
    NSString *userGroup = [accountDic objectForKey:@"userGroup"]?[accountDic objectForKey:@"userGroup"]:@"0";
    NSString *language = [accountDic objectForKey:@"language"]?[accountDic objectForKey:@"language"]:@"0";
    NSNumber *planType = [accountDic objectForKey:@"planType"]?[accountDic objectForKey:@"planType"]:@0;
    NSNumber *offer = [accountDic objectForKey:@"offer"]?[accountDic objectForKey:@"offer"]:@0;
    NSNumber *acceptTerms = [accountDic objectForKey:@"acceptTerms"]?[accountDic objectForKey:@"acceptTerms"]:@0;
    NSString *token = [accountDic objectForKey:@"token"]?[accountDic objectForKey:@"token"]:@"0";
    if (existDict)
    {
        userID = [accountDic objectForKey:@"userID"]?[accountDic objectForKey:@"userID"]:[existDict objectForKey:@"userID"];
        userType = [accountDic objectForKey:@"userType"]?[accountDic objectForKey:@"userType"]:[existDict objectForKey:@"userType"];
        userPassword = [accountDic objectForKey:@"userPassword"]?[accountDic objectForKey:@"userPassword"]:[existDict objectForKey:@"userPassword"];
        userFirstName = [accountDic objectForKey:@"userFirstName"]?[accountDic objectForKey:@"userFirstName"]:[existDict objectForKey:@"userFirstName"];
        userLastName = [accountDic objectForKey:@"userLastName"]?[accountDic objectForKey:@"userLastName"]:[existDict objectForKey:@"userLastName"];
        userEmail = [accountDic objectForKey:@"userEmail"]?[accountDic objectForKey:@"userEmail"]:[existDict objectForKey:@"userEmail"];
        userPhone = [accountDic objectForKey:@"userPhone"]?[accountDic objectForKey:@"userPhone"]:[existDict objectForKey:@"userPhone"];
        userGroup = [accountDic objectForKey:@"userGroup"]?[accountDic objectForKey:@"userGroup"]:[existDict objectForKey:@"userGroup"];
        language = [accountDic objectForKey:@"language"]?[accountDic objectForKey:@"language"]:[existDict objectForKey:@"language"];
        planType = [accountDic objectForKey:@"planType"]?[accountDic objectForKey:@"planType"]:[existDict objectForKey:@"planType"];
        offer = [accountDic objectForKey:@"offer"]?[accountDic objectForKey:@"offer"]:[existDict objectForKey:@"offer"];
        acceptTerms = [accountDic objectForKey:@"acceptTerms"]?[accountDic objectForKey:@"acceptTerms"]:[existDict objectForKey:@"acceptTerms"];
        token = [accountDic objectForKey:@"token"]?[accountDic objectForKey:@"token"]:[existDict objectForKey:@"token"];
    }
    [dataBase executeUpdate:@"insert into account (userID, userType, userPassword, userFirstName, userLastName, userEmail, userPhone, userGroup, language, planType, offer, acceptTerms, token) values (?,?,?,?,?,?,?,?,?,?,?,?,?)",userID, userType, userPassword, userFirstName, userLastName, userEmail, userPhone, userGroup, language, planType, offer, acceptTerms, token];
    //数据库关闭
    [dataBase close];
}

+(NSDictionary*)getAccountFromDatabase
{
    //数据库地址
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *sqlitePath = [documentsPath stringByAppendingPathComponent:@"openhapp.sqlite"];
    //创建数据库
    FMDatabase *dataBase = [FMDatabase databaseWithPath:sqlitePath];
    NSMutableDictionary *accountDic = [NSMutableDictionary dictionaryWithCapacity:13];
    //打开数据库
    if ([dataBase open])
    {
        //执行循环查询
        FMResultSet *resultSet = [dataBase executeQuery:@"select * from account"];
        while ([resultSet next])
        {
            //获取数据
            [accountDic setObject:[resultSet stringForColumn:@"userID"] forKey:@"userID"];
            [accountDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"userType"]] forKey:@"userType"];
            [accountDic setObject:[resultSet stringForColumn:@"userPassword"] forKey:@"userPassword"];
            [accountDic setObject:[resultSet stringForColumn:@"userFirstName"] forKey:@"userFirstName"];
            [accountDic setObject:[resultSet stringForColumn:@"userLastName"] forKey:@"userLastName"];
            [accountDic setObject:[resultSet stringForColumn:@"userEmail"] forKey:@"userEmail"];
            [accountDic setObject:[resultSet stringForColumn:@"userPhone"] forKey:@"userPhone"];
            [accountDic setObject:[resultSet stringForColumn:@"userGroup"] forKey:@"userGroup"];
            [accountDic setObject:[resultSet stringForColumn:@"language"] forKey:@"language"];
            [accountDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"planType"]] forKey:@"planType"];
            [accountDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"offer"]] forKey:@"offer"];
            [accountDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"acceptTerms"]] forKey:@"acceptTerms"];
            [accountDic setObject:[resultSet stringForColumn:@"token"] forKey:@"token"];
        }
        //获取完成关闭数据库
        [dataBase close];
    }
    return [accountDic copy];
}

//Camera
+(void)saveCamerasToDatabase:(NSArray *)cameras
{
    //数据库地址
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *sqlitePath = [documentsPath stringByAppendingPathComponent:@"openhapp.sqlite"];
    //创建数据库
    FMDatabase *dataBase = [FMDatabase databaseWithPath:sqlitePath];
    //打开数据库
    if ([dataBase open])
    {
        //无表创建表
        [dataBase executeUpdate:@"create table if not exists camera (id integer primary key autoincrement, deviceID text, name text, macAddress text, key text, localIP text, remoteURL text, httpUserName text, rtspUserName text, rtspPort text, online numeric, panTilt numeric, aspectRatio text, remoteAspectRatio text, cellAspectRatio text, vgLogLevel numeric, vgRegistrar text, temperature numeric, deviceType text, unitType text, localPath text, remotePath text, cellPath text)"];
        //清除数据库
        [dataBase executeUpdate:@"delete from camera"];
    }
    for (NSDictionary *cameraDic in cameras)
    {
        //写入数据库
        NSString *deviceID = [cameraDic objectForKey:@"deviceID"]?[cameraDic objectForKey:@"deviceID"]:@"0";
        NSString *name = [cameraDic objectForKey:@"name"]?[cameraDic objectForKey:@"name"]:@"0";
        NSString *macAddress = [cameraDic objectForKey:@"mac"]?[cameraDic objectForKey:@"mac"]:@"0";
        NSString *key = [cameraDic objectForKey:@"key"]?[cameraDic objectForKey:@"key"]:@"0";
        NSString *localIP = [cameraDic objectForKey:@"localIP"]?[cameraDic objectForKey:@"localIP"]:@"0";
        NSString *remoteURL = [cameraDic objectForKey:@"remoteURL"]?[cameraDic objectForKey:@"remoteURL"]:@"0";
        NSString *httpUserName = [cameraDic objectForKey:@"httpUserName"]?[cameraDic objectForKey:@"httpUserName"]:@"0";
        NSString *rtspUserName = [cameraDic objectForKey:@"rtspUserName"]?[cameraDic objectForKey:@"rtspUserName"]:@"0";
        NSString *rtspPort = [cameraDic objectForKey:@"rtspPort"]?[cameraDic objectForKey:@"rtspPort"]:@"0";
        NSNumber *online = [cameraDic objectForKey:@"online"]?[cameraDic objectForKey:@"online"]:@0;
        NSNumber *panTilt = [cameraDic objectForKey:@"panTilt"]?[cameraDic objectForKey:@"panTilt"]:@0;
        NSString *aspectRatio = [cameraDic objectForKey:@"aspectRatio"]?[cameraDic objectForKey:@"aspectRatio"]:@"0";
        NSString *remoteAspectRatio = [cameraDic objectForKey:@"remoteAspectRatio"]?[cameraDic objectForKey:@"remoteAspectRatio"]:@"0";
        NSString *cellAspectRatio = [cameraDic objectForKey:@"cellAspectRatio"]?[cameraDic objectForKey:@"cellAspectRatio"]:@"0";
        NSNumber *vgLogLevel = [cameraDic objectForKey:@"vgLogLevel"]?[cameraDic objectForKey:@"vgLogLevel"]:@0;
        NSString *vgRegistrar = [cameraDic objectForKey:@"vgRegistrar"]?[cameraDic objectForKey:@"vgRegistrar"]:@"0";
        NSNumber *temperature = [cameraDic objectForKey:@"temperature"]?[cameraDic objectForKey:@"temperature"]:@0;
        NSString *deviceType = [cameraDic objectForKey:@"deviceType"]?[cameraDic objectForKey:@"deviceType"]:@"0";
        NSString *unitType = [cameraDic objectForKey:@"unitType"]?[cameraDic objectForKey:@"unitType"]:@"0";
        NSString *localPath = [cameraDic objectForKey:@"localPath"]?[cameraDic objectForKey:@"localPath"]:@"0";
        NSString *remotePath = [cameraDic objectForKey:@"remotePath"]?[cameraDic objectForKey:@"remotePath"]:@"0";
        NSString *cellPath = [cameraDic objectForKey:@"cellPath"]?[cameraDic objectForKey:@"cellPath"]:@"0";
        [dataBase executeUpdate:@"insert into camera (deviceID, name, macAddress, key, localIP, remoteURL, httpUserName, rtspUserName, rtspPort, online, panTilt, aspectRatio, remoteAspectRatio, cellAspectRatio, vgLogLevel, vgRegistrar, temperature, deviceType, unitType, localPath, remotePath, cellPath) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", deviceID, name, macAddress, key, localIP, remoteURL, httpUserName, rtspUserName, rtspPort, online, panTilt, aspectRatio, remoteAspectRatio, cellAspectRatio, vgLogLevel, vgRegistrar, temperature, deviceType, unitType, localPath, remotePath, cellPath];
    }
    //数据库关闭
    [dataBase close];
}
+(NSArray*)getCamerasFromDatabase
{
    //数据库地址
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *sqlitePath = [documentsPath stringByAppendingPathComponent:@"openhapp.sqlite"];
    //创建数据库
    FMDatabase *dataBase = [FMDatabase databaseWithPath:sqlitePath];
    NSMutableArray *cameras = [NSMutableArray array];
    //打开数据库
    if ([dataBase open])
    {
        //执行循环查询
        FMResultSet *resultSet = [dataBase executeQuery:@"select * from camera"];
        while ([resultSet next])
        {
            NSMutableDictionary *cameraDic = [NSMutableDictionary dictionaryWithCapacity:22];
            //获取数据
            [cameraDic setObject:[resultSet stringForColumn:@"deviceID"] forKey:@"deviceID"];
            [cameraDic setObject:[resultSet stringForColumn:@"name"] forKey:@"name"];
            [cameraDic setObject:[resultSet stringForColumn:@"macAddress"] forKey:@"macAddress"];
            [cameraDic setObject:[resultSet stringForColumn:@"key"] forKey:@"key"];
            [cameraDic setObject:[resultSet stringForColumn:@"localIP"] forKey:@"localIP"];
            [cameraDic setObject:[resultSet stringForColumn:@"remoteURL"] forKey:@"remoteURL"];
            [cameraDic setObject:[resultSet stringForColumn:@"httpUserName"] forKey:@"httpUserName"];
            [cameraDic setObject:[resultSet stringForColumn:@"rtspUserName"] forKey:@"rtspUserName"];
            [cameraDic setObject:[resultSet stringForColumn:@"rtspPort"] forKey:@"rtspPort"];
            [cameraDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"online"]] forKey:@"online"];
            [cameraDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"panTilt"]] forKey:@"panTilt"];
            [cameraDic setObject:[resultSet stringForColumn:@"aspectRatio"] forKey:@"aspectRatio"];
            [cameraDic setObject:[resultSet stringForColumn:@"remoteAspectRatio"] forKey:@"remoteAspectRatio"];
            [cameraDic setObject:[resultSet stringForColumn:@"cellAspectRatio"] forKey:@"cellAspectRatio"];
            [cameraDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"vgLogLevel"]] forKey:@"vgLogLevel"];
            [cameraDic setObject:[resultSet stringForColumn:@"vgRegistrar"] forKey:@"vgRegistrar"];
            [cameraDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"temperature"]] forKey:@"temperature"];
            [cameraDic setObject:[resultSet stringForColumn:@"deviceType"] forKey:@"deviceType"];
            [cameraDic setObject:[resultSet stringForColumn:@"unitType"] forKey:@"unitType"];
            [cameraDic setObject:[resultSet stringForColumn:@"localPath"] forKey:@"localPath"];
            [cameraDic setObject:[resultSet stringForColumn:@"remotePath"] forKey:@"remotePath"];
            [cameraDic setObject:[resultSet stringForColumn:@"cellPath"] forKey:@"cellPath"];
            [cameras addObject:cameraDic];
        }
        //获取完成关闭数据库
        [dataBase close];
    }
    return [cameras copy];
}
+(void)saveCameraToDatabase:(NSDictionary *)cameraDic WithMACAddress:(NSString *)mac
{
    //数据库地址
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *sqlitePath = [documentsPath stringByAppendingPathComponent:@"openhapp.sqlite"];
    //创建数据库
    FMDatabase *dataBase = [FMDatabase databaseWithPath:sqlitePath];
    //打开数据库
    if ([dataBase open])
    {
        //无表创建表
        [dataBase executeUpdate:@"create table if not exists camera (id integer primary key autoincrement, deviceID text, name text, macAddress text, key text, localIP text, remoteURL text, httpUserName text, rtspUserName text, rtspPort text, online numeric, panTilt numeric, aspectRatio text, remoteAspectRatio text, cellAspectRatio text, vgLogLevel numeric, vgRegistrar text, temperature numeric, deviceType text, unitType text, localPath text, remotePath text, cellPath text)"];
    }
    //写入数据库
    NSArray *cameraArr = [self getCamerasFromDatabase];
    NSMutableDictionary *cameraDict = nil;
    for (NSDictionary *cameradict in cameraArr)
    {
        if ([cameradict[@"macAddress"] isEqualToString:mac])
        {
            cameraDict = [NSMutableDictionary dictionaryWithDictionary:cameradict];
        }
    }
    if ([[cameraDict allKeys] count])
    {
        NSString *deviceID = [cameraDic objectForKey:@"deviceID"];
        if (deviceID && deviceID.length)
        {
            [cameraDict setObject:deviceID forKey:@"deviceID"];
        }
        NSString *name = [cameraDic objectForKey:@"name"];
        if (name && name.length)
        {
            [cameraDict setObject:name forKey:@"name"];
        }
        NSString *macAddress = [cameraDic objectForKey:@"mac"];
        if (macAddress && macAddress.length)
        {
            [cameraDict setObject:macAddress forKey:@"macAddress"];
        }
        NSString *key = [cameraDic objectForKey:@"key"];
        if (key && key.length)
        {
            [cameraDict setObject:key forKey:@"key"];
        }
        NSString *localIP = [cameraDic objectForKey:@"localIP"];
        if (localIP && localIP.length)
        {
            [cameraDict setObject:localIP forKey:@"localIP"];
        }
        NSString *remoteURL = [cameraDic objectForKey:@"remoteURL"];
        if (remoteURL && remoteURL.length)
        {
            [cameraDict setObject:remoteURL forKey:@"remoteURL"];
        }
        NSString *httpUserName = [cameraDic objectForKey:@"httpUserName"];
        if (httpUserName && httpUserName.length)
        {
            [cameraDict setObject:httpUserName forKey:@"httpUserName"];
        }
        NSString *rtspUserName = [cameraDic objectForKey:@"rtspUserName"];
        if (rtspUserName && rtspUserName.length)
        {
            [cameraDict setObject:rtspUserName forKey:@"rtspUserName"];
        }
        NSString *rtspPort = [cameraDic objectForKey:@"rtspPort"];
        if (rtspPort && rtspPort.length)
        {
            [cameraDict setObject:rtspPort forKey:@"rtspPort"];
        }
        NSNumber *online = [cameraDic objectForKey:@"online"];
        if (online)
        {
            [cameraDict setObject:online forKey:@"online"];
        }
        NSNumber *panTilt = [cameraDic objectForKey:@"panTilt"];
        if (panTilt)
        {
            [cameraDict setObject:panTilt forKey:@"panTilt"];
        }
        NSString *aspectRatio = [cameraDic objectForKey:@"aspectRatio"];
        if (aspectRatio && aspectRatio.length)
        {
            [cameraDict setObject:aspectRatio forKey:@"aspectRatio"];
        }
        NSString *remoteAspectRatio = [cameraDic objectForKey:@"remoteAspectRatio"];
        if (remoteAspectRatio && remoteAspectRatio.length)
        {
            [cameraDict setObject:remoteAspectRatio forKey:@"remoteAspectRatio"];
        }
        NSString *cellAspectRatio = [cameraDic objectForKey:@"cellAspectRatio"];
        if (cellAspectRatio && cellAspectRatio.length)
        {
            [cameraDict setObject:cellAspectRatio forKey:@"cellAspectRatio"];
        }
        NSNumber *vgLogLevel = [cameraDic objectForKey:@"vgLogLevel"];
        if (vgLogLevel)
        {
            [cameraDict setObject:vgLogLevel forKey:@"vgLogLevel"];
        }
        NSString *vgRegistrar = [cameraDic objectForKey:@"vgRegistrar"];
        if (vgRegistrar && vgRegistrar.length)
        {
            [cameraDict setObject:vgRegistrar forKey:@"vgRegistrar"];
        }
        NSNumber *temperature = [cameraDic objectForKey:@"temperature"];
        if (temperature && temperature)
        {
            [cameraDict setObject:temperature forKey:@"temperature"];
        }
        NSString *deviceType = [cameraDic objectForKey:@"deviceType"];
        if (deviceType && deviceType.length)
        {
            [cameraDict setObject:deviceType forKey:@"deviceType"];
        }
        NSString *unitType = [cameraDic objectForKey:@"unitType"];
        if (unitType && unitType.length)
        {
            [cameraDict setObject:unitType forKey:@"unitType"];
        }
        NSString *localPath = [cameraDic objectForKey:@"localPath"];
        if (localPath && localPath.length)
        {
            [cameraDict setObject:localPath forKey:@"localPath"];
        }
        NSString *remotePath = [cameraDic objectForKey:@"remotePath"];
        if (remotePath && remotePath.length)
        {
            [cameraDict setObject:remotePath forKey:@"remotePath"];
        }
        NSString *cellPath = [cameraDic objectForKey:@"cellPath"];
        if (cellPath && cellPath.length)
        {
            [cameraDict setObject:cellPath forKey:@"cellPath"];
        }
        NSString *deleteText = [NSString stringWithFormat:@"delete from camera where macAddress = '%@'",[cameraDict objectForKey:@"macAddress"]];
        [dataBase executeUpdate:deleteText];
        [dataBase executeUpdate:@"insert into camera (deviceID, name, macAddress, key, localIP, remoteURL, httpUserName, rtspUserName, rtspPort, online, panTilt, aspectRatio, remoteAspectRatio, cellAspectRatio, vgLogLevel, vgRegistrar, temperature, deviceType, unitType, localPath, remotePath, cellPath) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", [cameraDict objectForKey:@"deviceID"], [cameraDict objectForKey:@"name"], [cameraDict objectForKey:@"macAddress"], [cameraDict objectForKey:@"key"], [cameraDict objectForKey:@"localIP"], [cameraDict objectForKey:@"remoteURL"], [cameraDict objectForKey:@"httpUserName"], [cameraDict objectForKey:@"rtspUserName"], [cameraDict objectForKey:@"rtspPort"], [cameraDict objectForKey:@"online"], [cameraDict objectForKey:@"panTilt"], [cameraDict objectForKey:@"aspectRatio"], [cameraDict objectForKey:@"remoteAspectRatio"], [cameraDict objectForKey:@"cellAspectRatio"], [cameraDict objectForKey:@"vgLogLevel"], [cameraDict objectForKey:@"vgRegistrar"], [cameraDict objectForKey:@"temperature"], [cameraDict objectForKey:@"deviceType"], [cameraDict objectForKey:@"unitType"], [cameraDict objectForKey:@"localPath"], [cameraDict objectForKey:@"remotePath"], [cameraDict objectForKey:@"cellPath"]];
        //数据库关闭
        [dataBase close];
    }
    else
    {
        //写入数据库
        NSString *deviceID = [cameraDic objectForKey:@"deviceID"]?[cameraDic objectForKey:@"deviceID"]:@"0";
        NSString *name = [cameraDic objectForKey:@"name"]?[cameraDic objectForKey:@"name"]:@"0";
        NSString *macAddress = [cameraDic objectForKey:@"mac"]?[cameraDic objectForKey:@"mac"]:@"0";
        NSString *key = [cameraDic objectForKey:@"key"]?[cameraDic objectForKey:@"key"]:@"0";
        NSString *localIP = [cameraDic objectForKey:@"localIP"]?[cameraDic objectForKey:@"localIP"]:@"0";
        NSString *remoteURL = [cameraDic objectForKey:@"remoteURL"]?[cameraDic objectForKey:@"remoteURL"]:@"0";
        NSString *httpUserName = [cameraDic objectForKey:@"httpUserName"]?[cameraDic objectForKey:@"httpUserName"]:@"0";
        NSString *rtspUserName = [cameraDic objectForKey:@"rtspUserName"]?[cameraDic objectForKey:@"rtspUserName"]:@"0";
        NSString *rtspPort = [cameraDic objectForKey:@"rtspPort"]?[cameraDic objectForKey:@"rtspPort"]:@"0";
        NSNumber *online = [cameraDic objectForKey:@"online"]?[cameraDic objectForKey:@"online"]:@0;
        NSNumber *panTilt = [cameraDic objectForKey:@"panTilt"]?[cameraDic objectForKey:@"panTilt"]:@0;
        NSString *aspectRatio = [cameraDic objectForKey:@"aspectRatio"]?[cameraDic objectForKey:@"aspectRatio"]:@"0";
        NSString *remoteAspectRatio = [cameraDic objectForKey:@"remoteAspectRatio"]?[cameraDic objectForKey:@"remoteAspectRatio"]:@"0";
        NSString *cellAspectRatio = [cameraDic objectForKey:@"cellAspectRatio"]?[cameraDic objectForKey:@"cellAspectRatio"]:@"0";
        NSNumber *vgLogLevel = [cameraDic objectForKey:@"vgLogLevel"]?[cameraDic objectForKey:@"vgLogLevel"]:@0;
        NSString *vgRegistrar = [cameraDic objectForKey:@"vgRegistrar"]?[cameraDic objectForKey:@"vgRegistrar"]:@"0";
        NSNumber *temperature = [cameraDic objectForKey:@"temperature"]?[cameraDic objectForKey:@"temperature"]:@0;
        NSString *deviceType = [cameraDic objectForKey:@"deviceType"]?[cameraDic objectForKey:@"deviceType"]:@"0";
        NSString *unitType = [cameraDic objectForKey:@"unitType"]?[cameraDic objectForKey:@"unitType"]:@"0";
        NSString *localPath = [cameraDic objectForKey:@"localPath"]?[cameraDic objectForKey:@"localPath"]:@"0";
        NSString *remotePath = [cameraDic objectForKey:@"remotePath"]?[cameraDic objectForKey:@"remotePath"]:@"0";
        NSString *cellPath = [cameraDic objectForKey:@"cellPath"]?[cameraDic objectForKey:@"cellPath"]:@"0";
        [dataBase executeUpdate:@"insert into camera (deviceID, name, macAddress, key, localIP, remoteURL, httpUserName, rtspUserName, rtspPort, online, panTilt, aspectRatio, remoteAspectRatio, cellAspectRatio, vgLogLevel, vgRegistrar, temperature, deviceType, unitType, localPath, remotePath, cellPath) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", deviceID, name, macAddress, key, localIP, remoteURL, httpUserName, rtspUserName, rtspPort, online, panTilt, aspectRatio, remoteAspectRatio, cellAspectRatio, vgLogLevel, vgRegistrar, temperature, deviceType, unitType, localPath, remotePath, cellPath];
        //数据库关闭
        [dataBase close];
    }
}
+(NSDictionary*)getCameraFromDatabaseWithMACAddress:(NSString *)mac
{
    //数据库地址
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *sqlitePath = [documentsPath stringByAppendingPathComponent:@"openhapp.sqlite"];
    //创建数据库
    FMDatabase *dataBase = [FMDatabase databaseWithPath:sqlitePath];
    NSMutableDictionary *cameraDic = [NSMutableDictionary dictionaryWithCapacity:22];
    //打开数据库
    if ([dataBase open])
    {
        //执行循环查询
        NSString *sql = [NSString stringWithFormat:@"select * from camera where macAddress = '%@'",mac];
        FMResultSet *resultSet = [dataBase executeQuery:sql];
        while ([resultSet next])
        {
            //获取数据
            [cameraDic setObject:[resultSet stringForColumn:@"deviceID"] forKey:@"deviceID"];
            [cameraDic setObject:[resultSet stringForColumn:@"name"] forKey:@"name"];
            [cameraDic setObject:[resultSet stringForColumn:@"macAddress"] forKey:@"macAddress"];
            [cameraDic setObject:[resultSet stringForColumn:@"key"] forKey:@"key"];
            [cameraDic setObject:[resultSet stringForColumn:@"localIP"] forKey:@"localIP"];
            [cameraDic setObject:[resultSet stringForColumn:@"remoteURL"] forKey:@"remoteURL"];
            [cameraDic setObject:[resultSet stringForColumn:@"httpUserName"] forKey:@"httpUserName"];
            [cameraDic setObject:[resultSet stringForColumn:@"rtspUserName"] forKey:@"rtspUserName"];
            [cameraDic setObject:[resultSet stringForColumn:@"rtspPort"] forKey:@"rtspPort"];
            [cameraDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"online"]] forKey:@"online"];
            [cameraDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"panTilt"]] forKey:@"panTilt"];
            [cameraDic setObject:[resultSet stringForColumn:@"aspectRatio"] forKey:@"aspectRatio"];
            [cameraDic setObject:[resultSet stringForColumn:@"remoteAspectRatio"] forKey:@"remoteAspectRatio"];
            [cameraDic setObject:[resultSet stringForColumn:@"cellAspectRatio"] forKey:@"cellAspectRatio"];
            [cameraDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"vgLogLevel"]] forKey:@"vgLogLevel"];
            [cameraDic setObject:[resultSet stringForColumn:@"vgRegistrar"] forKey:@"vgRegistrar"];
            [cameraDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"temperature"]] forKey:@"temperature"];
            [cameraDic setObject:[resultSet stringForColumn:@"deviceType"] forKey:@"deviceType"];
            [cameraDic setObject:[resultSet stringForColumn:@"unitType"] forKey:@"unitType"];
            [cameraDic setObject:[resultSet stringForColumn:@"localPath"] forKey:@"localPath"];
            [cameraDic setObject:[resultSet stringForColumn:@"remotePath"] forKey:@"remotePath"];
            [cameraDic setObject:[resultSet stringForColumn:@"cellPath"] forKey:@"cellPath"];
        }
        //获取完成关闭数据库
        [dataBase close];
    }
    return [(NSDictionary*)cameraDic copy];
}

//Application
+(void)saveApplicationToDatabase:(NSDictionary *)applicationDic
{
    //数据库地址
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *sqlitePath = [documentsPath stringByAppendingPathComponent:@"openhapp.sqlite"];
    //创建数据库
    FMDatabase *dataBase = [FMDatabase databaseWithPath:sqlitePath];
    //打开数据库
    if ([dataBase open])
    {
        //无表创建表
        [dataBase executeUpdate:@"create table if not exists application (autoLoginRemote numeric, wakeSensitivity numeric, homeNetworkName text, homeNetworkPassword text, useCellularNetwork numeric, temperatureFormat text, videoWiFiTimeout numeric, videoCellTimeout numeric, videoFrozenTimeout numeric, soundVibrate numeric, connectionLostVolume numeric, soundTone text, SoundThresholdLevel numeric, privacyMode numeric, brightnessLevel numeric, audioLevel numeric, wanIPAddress text, lastSyncDate text, showHome numeric, serviceURL text, siteURL text, useBackgroundAudio numeric)"];
        //清除数据库
        [dataBase executeUpdate:@"delete from application"];
    }
    //写入数据库
    NSNumber *autoLoginRemote = [applicationDic objectForKey:@"autoLoginRemote"]?[applicationDic objectForKey:@"autoLoginRemote"]:@0;
    NSNumber *wakeSensitivity = [applicationDic objectForKey:@"wakeSensitivity"]?[applicationDic objectForKey:@"wakeSensitivity"]:@0;
    NSString *homeNetworkName = [applicationDic objectForKey:@"homeNetworkName"]?[applicationDic objectForKey:@"homeNetworkName"]:@"0";
    NSString *homeNetworkPassword = [applicationDic objectForKey:@"homeNetworkPassword"]?[applicationDic objectForKey:@"homeNetworkPassword"]:@"0";
    NSNumber *useCellularNetwork = [applicationDic objectForKey:@"useCellularNetwork"]?[applicationDic objectForKey:@"useCellularNetwork"]:@0;
    NSString *temperatureFormat = [applicationDic objectForKey:@"temperatureFormat"]?[applicationDic objectForKey:@"temperatureFormat"]:@"0";
    NSNumber *videoWiFiTimeout = [applicationDic objectForKey:@"videoWiFiTimeout"]?[applicationDic objectForKey:@"videoWiFiTimeout"]:@0;
    NSNumber *videoCellTimeout = [applicationDic objectForKey:@"videoCellTimeout"]?[applicationDic objectForKey:@"videoCellTimeout"]:@0;
    NSNumber *videoFrozenTimeout = [applicationDic objectForKey:@"videoFrozenTimeout"]?[applicationDic objectForKey:@"videoFrozenTimeout"]:@0;
    NSNumber *soundVibrate = [applicationDic objectForKey:@"soundVibrate"]?[applicationDic objectForKey:@"soundVibrate"]:@0;
    NSNumber *connectionLostVolume = [applicationDic objectForKey:@"connectionLostVolume"]?[applicationDic objectForKey:@"connectionLostVolume"]:@0;
    NSString *soundTone = [applicationDic objectForKey:@"soundTone"]?[applicationDic objectForKey:@"soundTone"]:@"0";
    NSNumber *SoundThresholdLevel = [applicationDic objectForKey:@"SoundThresholdLevel"]?[applicationDic objectForKey:@"SoundThresholdLevel"]:@0;
    NSNumber *privacyMode = [applicationDic objectForKey:@"privacyMode"]?[applicationDic objectForKey:@"privacyMode"]:@0;
    NSNumber *brightnessLevel = [applicationDic objectForKey:@"brightnessLevel"]?[applicationDic objectForKey:@"brightnessLevel"]:@0;
    NSNumber *audioLevel = [applicationDic objectForKey:@"audioLevel"]?[applicationDic objectForKey:@"audioLevel"]:@0;
    NSString *wanIPAddress = [applicationDic objectForKey:@"wanIPAddress"]?[applicationDic objectForKey:@"wanIPAddress"]:@"0";
    NSString *lastSyncDate = [applicationDic objectForKey:@"lastSyncDate"]?[applicationDic objectForKey:@"lastSyncDate"]:@"0";
    NSNumber *showHome = [applicationDic objectForKey:@"showHome"]?[applicationDic objectForKey:@"showHome"]:@0;
    NSString *serviceURL = [applicationDic objectForKey:@"serviceURL"]?[applicationDic objectForKey:@"serviceURL"]:@"0";
    NSString *siteURL = [applicationDic objectForKey:@"siteURL"]?[applicationDic objectForKey:@"siteURL"]:@"0";
    NSNumber *useBackgroundAudio = [applicationDic objectForKey:@"useBackgroundAudio"]?[applicationDic objectForKey:@"useBackgroundAudio"]:@0;
    [dataBase executeUpdate:@"insert into application (autoLoginRemote, wakeSensitivity, homeNetworkName, homeNetworkPassword, useCellularNetwork, temperatureFormat, videoWiFiTimeout, videoCellTimeout, videoFrozenTimeout, soundVibrate, connectionLostVolume, soundTone, SoundThresholdLevel, privacyMode, brightnessLevel, audioLevel, wanIPAddress, lastSyncDate, showHome, serviceURL, siteURL, useBackgroundAudio) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",autoLoginRemote, wakeSensitivity, homeNetworkName, homeNetworkPassword, useCellularNetwork, temperatureFormat, videoWiFiTimeout, videoCellTimeout, videoFrozenTimeout, soundVibrate, connectionLostVolume, soundTone, SoundThresholdLevel, privacyMode, brightnessLevel, audioLevel, wanIPAddress, lastSyncDate, showHome, serviceURL, siteURL, useBackgroundAudio];
    //数据库关闭
    [dataBase close];
}

+(NSDictionary*)getApplicationFromDatabase
{
    //数据库地址
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *sqlitePath = [documentsPath stringByAppendingPathComponent:@"openhapp.sqlite"];
    //创建数据库
    FMDatabase *dataBase = [FMDatabase databaseWithPath:sqlitePath];
    NSMutableDictionary *applicationDic = [NSMutableDictionary dictionaryWithCapacity:22];
    //打开数据库
    if ([dataBase open])
    {
        //执行循环查询
        FMResultSet *resultSet = [dataBase executeQuery:@"select * from application"];
        while ([resultSet next])
        {
            //获取记录数据
            [applicationDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"autoLoginRemote"]] forKey:@"autoLoginRemote"];
            [applicationDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"wakeSensitivity"]] forKey:@"wakeSensitivity"];
            [applicationDic setObject:[resultSet stringForColumn:@"homeNetworkName"] forKey:@"homeNetworkName"];
            [applicationDic setObject:[resultSet stringForColumn:@"homeNetworkPassword"] forKey:@"homeNetworkPassword"];
            [applicationDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"useCellularNetwork"]] forKey:@"useCellularNetwork"];
            [applicationDic setObject:[resultSet stringForColumn:@"temperatureFormat"] forKey:@"temperatureFormat"];
            [applicationDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"videoWiFiTimeout"]] forKey:@"videoWiFiTimeout"];
            [applicationDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"videoCellTimeout"]] forKey:@"videoCellTimeout"];
            [applicationDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"videoFrozenTimeout"]] forKey:@"videoFrozenTimeout"];
            [applicationDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"soundVibrate"]] forKey:@"soundVibrate"];
            [applicationDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"connectionLostVolume"]] forKey:@"connectionLostVolume"];
            [applicationDic setObject:[resultSet stringForColumn:@"soundTone"] forKey:@"soundTone"];
            [applicationDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"SoundThresholdLevel"]] forKey:@"SoundThresholdLevel"];
            [applicationDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"privacyMode"]] forKey:@"privacyMode"];
            [applicationDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"brightnessLevel"]] forKey:@"brightnessLevel"];
            [applicationDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"audioLevel"]] forKey:@"audioLevel"];
            [applicationDic setObject:[resultSet stringForColumn:@"wanIPAddress"] forKey:@"wanIPAddress"];
            [applicationDic setObject:[resultSet stringForColumn:@"lastSyncDate"] forKey:@"lastSyncDate"];
            [applicationDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"showHome"]] forKey:@"showHome"];
            [applicationDic setObject:[resultSet stringForColumn:@"serviceURL"] forKey:@"serviceURL"];
            [applicationDic setObject:[resultSet stringForColumn:@"siteURL"] forKey:@"siteURL"];
            [applicationDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"useBackgroundAudio"]] forKey:@"useBackgroundAudio"];
        }
        //获取设备完成关闭数据库
        [dataBase close];
    }
    return [applicationDic copy];
}

//ReferenceURL
+(void)saveReferenceURLsToDatabase:(NSArray *)referenceURLs
{
    //数据库地址
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *sqlitePath = [documentsPath stringByAppendingPathComponent:@"openhapp.sqlite"];
    //创建数据库
    FMDatabase *dataBase = [FMDatabase databaseWithPath:sqlitePath];
    //打开数据库
    if ([dataBase open])
    {
        //无表创建表
        [dataBase executeUpdate:@"create table if not exists referenceURL (id integer, name text, url text)"];
        //清除数据库
        [dataBase executeUpdate:@"delete from referenceURL"];
        
    }
    for (NSDictionary *referenceURLDic in referenceURLs)
    {
        //写入数据库
        NSNumber *id = [referenceURLDic objectForKey:@"id"]?[referenceURLDic objectForKey:@"id"]:@0;
        NSString *name = [referenceURLDic objectForKey:@"name"]?[referenceURLDic objectForKey:@"name"]:@"0";
        NSString *url = [referenceURLDic objectForKey:@"url"]?[referenceURLDic objectForKey:@"url"]:@"0";
        [dataBase executeUpdate:@"insert into referenceURL (id, name, url) values (?,?,?)",id, name, url];
    }
    //数据库关闭
    [dataBase close];
    
    //创建VersionInfo数据
    [DataBaseTool createVersioninfoToDatabase];
}

+(NSArray*)getReferenceURLsFromDatabase
{
    //数据库地址
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *sqlitePath = [documentsPath stringByAppendingPathComponent:@"openhapp.sqlite"];
    //创建数据库
    FMDatabase *dataBase = [FMDatabase databaseWithPath:sqlitePath];
    NSMutableArray *referenceURLs = [NSMutableArray array];
    //打开数据库
    if ([dataBase open])
    {
        //执行循环查询
        FMResultSet *resultSet = [dataBase executeQuery:@"select * from referenceURL"];
        NSMutableDictionary *referenceURLDic = [NSMutableDictionary dictionaryWithCapacity:3];
        while ([resultSet next])
        {
            //获取记录数据
            [referenceURLDic setObject:[NSNumber numberWithInteger:[resultSet intForColumn:@"id"]] forKey:@"id"];
            [referenceURLDic setObject:[resultSet stringForColumn:@"name"] forKey:@"name"];
            [referenceURLDic setObject:[resultSet stringForColumn:@"url"] forKey:@"url"];
            [referenceURLs addObject:referenceURLDic];
        }
        //获取设备完成关闭数据库
        [dataBase close];
    }
    return [referenceURLs copy];
}

//Messages
+(void)saveMessagesToDatabase:(NSArray *)messages
{
    //数据库地址
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *sqlitePath = [documentsPath stringByAppendingPathComponent:@"openhapp.sqlite"];
    //创建数据库
    FMDatabase *dataBase = [FMDatabase databaseWithPath:sqlitePath];
    //打开数据库
    if ([dataBase open])
    {
        //无表创建表
        [dataBase executeUpdate:@"create table if not exists messages (id integer, code numeric, title text, body text, language text, logic numeric)"];
        //清除数据库
        [dataBase executeUpdate:@"delete from messages"];
    }
    for (NSDictionary *messagesDic in messages)
    {
        //写入数据库
        NSNumber *id = [messagesDic objectForKey:@"id"]?[messagesDic objectForKey:@"id"]:@0;
        NSNumber *code = [messagesDic objectForKey:@"code"]?[messagesDic objectForKey:@"code"]:@0;
        NSString *title = [messagesDic objectForKey:@"title"]?[messagesDic objectForKey:@"title"]:@"0";
        NSString *body = [messagesDic objectForKey:@"body"]?[messagesDic objectForKey:@"body"]:@"0";
        NSString *language = [messagesDic objectForKey:@"language"]?[messagesDic objectForKey:@"language"]:@"0";
        NSNumber *logic = [messagesDic objectForKey:@"logic"]?[messagesDic objectForKey:@"logic"]:@0;
        [dataBase executeUpdate:@"insert into messages (id, code, title, body, language, logic) values (?,?,?,?,?,?)", id, code, title, body, language, logic];
    }
    //数据库关闭
    [dataBase close];
}

+(NSDictionary*)getMessagesFromDatabaseForCode:(NSString*)code
{
    //数据库地址
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *sqlitePath = [documentsPath stringByAppendingPathComponent:@"openhapp.sqlite"];
    //创建数据库
    FMDatabase *dataBase = [FMDatabase databaseWithPath:sqlitePath];
    NSMutableDictionary *messagesDic = [NSMutableDictionary dictionaryWithCapacity:2];
    //打开数据库
    if ([dataBase open])
    {
        //执行循环查询
        NSString *sql = [NSString stringWithFormat:@"select title,body from messages where code=%@",code];
        FMResultSet *resultSet = [dataBase executeQuery:sql];
        while ([resultSet next])
        {
            //获取数据
            //[messagesDic setObject:[NSNumber numberWithInteger:[resultSet intForColumn:@"id"]] forKey:@"id"];
            //[messagesDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"code"]] forKey:@"code"];
            [messagesDic setObject:[resultSet stringForColumn:@"title"] forKey:@"title"];
            [messagesDic setObject:[resultSet stringForColumn:@"body"] forKey:@"body"];
            //[messagesDic setObject:[resultSet stringForColumn:@"language"] forKey:@"language"];
            //[messagesDic setObject:[NSNumber numberWithDouble:[resultSet doubleForColumn:@"logic"]] forKey:@"logic"];
        }
        //获取完成关闭数据库
        [dataBase close];
    }
    return (NSDictionary*)[messagesDic copy];
}

//创建VersionInfo数据
+(void)createVersioninfoToDatabase
{
    //数据库地址
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *sqlitePath = [documentsPath stringByAppendingPathComponent:@"openhapp.sqlite"];
    //创建数据库
    FMDatabase *dataBase = [FMDatabase databaseWithPath:sqlitePath];
    //打开数据库
    if ([dataBase open])
    {
        //无表创建表
        [dataBase executeUpdate:@"create table if not exists versioninfo (appName text, copyrightYear text, copyrightBoiler text, copyrightClaim text)"];
        //清除数据库
        [dataBase executeUpdate:@"delete from versioninfo"];
    }
    //写入数据库
    NSString *appName = @"Openhapp";
    NSString *copyrightYear = @"2016";
    NSString *copyrightBoiler = @"All rights reserved.";
    NSString *copyrightClaim = @"The Openhapp name is a trademark of Openhapp";
    [dataBase executeUpdate:@"insert into versioninfo (appName, copyrightYear, copyrightBoiler, copyrightClaim) values (?,?,?,?)",appName, copyrightYear, copyrightBoiler, copyrightClaim];
    //数据库关闭
    [dataBase close];
}

+(NSDictionary*)getVersioninfoFromDatabase
{
    //数据库地址
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *sqlitePath = [documentsPath stringByAppendingPathComponent:@"openhapp.sqlite"];
    //创建数据库
    FMDatabase *dataBase = [FMDatabase databaseWithPath:sqlitePath];
    NSMutableDictionary *versioninfoDic = [NSMutableDictionary dictionaryWithCapacity:4];
    //打开数据库
    if ([dataBase open])
    {
        //执行循环查询
        FMResultSet *resultSet = [dataBase executeQuery:@"select * from versioninfo"];
        while ([resultSet next])
        {
            //获取数据
            [versioninfoDic setObject:[resultSet stringForColumn:@"appName"] forKey:@"appName"];
            [versioninfoDic setObject:[resultSet stringForColumn:@"copyrightYear"] forKey:@"copyrightYear"];
            [versioninfoDic setObject:[resultSet stringForColumn:@"copyrightBoiler"] forKey:@"copyrightBoiler"];
            [versioninfoDic setObject:[resultSet stringForColumn:@"copyrightClaim"] forKey:@"copyrightClaim"];
            
        }
        //获取完成关闭数据库
        [dataBase close];
    }
    return [versioninfoDic copy];
}


@end
