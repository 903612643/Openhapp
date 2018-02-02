//
//  DataBaseTool.h
//  Openhapp
//
//  Created by Jesse on 16/2/25.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBaseTool : NSObject

/************************************************************************************/
/*
It's A Bad Database Mode, I Have No Time Fix.(Only Messages Can Work)
*/
/************************************************************************************/

//Account
+(void)saveAccountToDatabase:(NSDictionary*)accountDic;
+(NSDictionary*)getAccountFromDatabase;

//Camera
+(void)saveCamerasToDatabase:(NSArray*)cameras;
+(void)saveCameraToDatabase:(NSDictionary *)cameraDic WithMACAddress:(NSString*)mac;
+(NSArray*)getCamerasFromDatabase;
+(NSDictionary*)getCameraFromDatabaseWithMACAddress:(NSString*)mac;

//Application
+(void)saveApplicationToDatabase:(NSDictionary*)applicationDic;
+(NSDictionary*)getApplicationFromDatabase;

//ReferenceURL
+(void)saveReferenceURLsToDatabase:(NSArray*)referenceURLs;
+(NSArray*)getReferenceURLsFromDatabase;

//Messages
+(void)saveMessagesToDatabase:(NSArray*)messages;
+(NSDictionary*)getMessagesFromDatabaseForCode:(NSString*)code;

//Versioninfo
+(void)createVersioninfoToDatabase;
+(NSDictionary*)getVersioninfoFromDatabase;

@end
