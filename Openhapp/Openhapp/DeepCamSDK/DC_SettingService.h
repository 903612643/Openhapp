//
//  DC_SettingService.h
//  DeepCam_SDK
//
//  Created by Jesse on 16/4/29.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
Notity Type
*/
typedef NS_ENUM(NSUInteger,DC_NotityType){
    DC_NotityTypeEmail = 0, /* email */
    DC_NotityTypeText = 1, /* text */
    DC_NotityTypePush = 2, /* applePush */
    DC_NotityTypeLog = 3 /* none */
};

/*
Time Zone
*/
typedef NS_ENUM(NSUInteger,DC_TimeZone){
    DC_TimeZoneEastern = 0, /* Eastern */
    DC_TimeZoneCentral = 1, /* Central */
    DC_TimeZoneMountain = 2, /* Mountain */
    DC_TimeZonePacific = 3, /* Pacific */
    DC_TimeZoneAlaska = 4, /* Alaska */
    DC_TimeZoneArizona = 5, /* Arizona */
    DC_TimeZoneHawaii = 6 /* Hawaii */
};


@protocol DC_SetPrivacyModeDelegate
/*
It present that set privacy mode is success or failure, you can set privacy status base on the result.
*/
-(void)DC_SetPrivacyModeFinish:(BOOL)success WithMessageCode:(NSString*)code WithErrorDescription:(NSString*)description;

@end

@protocol DC_ViewerAlertDelegate
/*
It will call back when get viewer alerts finish, you can get viewer alerts status from open.
*/
-(void)DC_GetViewerAlertsFinish:(BOOL)success ForStatus:(BOOL)open WithMessageCode:(NSString*)code WithErrorDescription:(NSString*)description;
/*
It will call back after finish setting viewer alerts status.
*/
-(void)DC_SetViewerAlertsFinish:(BOOL)success WithMessageCode:(NSString*)code WithErrorDescription:(NSString*)description;

@end

@protocol DC_NotifyDelegate
/*
It will call back when get notify type finish.
*/
-(void)DC_GetNotifyTypeFinish:(BOOL)success ForType:(DC_NotityType)type WithMessageCode:(NSString*)code WithErrorDescription:(NSString*)description;
/*
It will call back after set notify type complete.
*/
-(void)DC_SetNotifyTypeFinish:(BOOL)success WithMessageCode:(NSString*)code WithErrorDescription:(NSString*)description;

@end

@protocol DC_TimeZoneDelegate
/*
It will call back when get time zone finish.
*/
-(void)DC_GetTimeZoneFinish:(BOOL)success ForTimeZone:(DC_TimeZone)timeZone WithMessageCode:(NSString*)code WithErrorDescription:(NSString*)description;
/*
It will call back after set time zone complete.
*/
-(void)DC_SetTimeZoneFinish:(BOOL)success WithMessageCode:(NSString*)code WithErrorDescription:(NSString*)description;

@end

@protocol DC_AlertDelegate
/*
It will call back after get alert complete.
Result: Alert Open --> 1 / Close --> 0 | Alert Level: 0 ~ 100
*/
-(void)DC_GetAlertFinish:(BOOL)success WithResult:(NSDictionary*)resultDict WithMessageCode:(NSString*)code WithErrorDescription:(NSString*)description;
/*
It will call back after set alert complete.
Result: Alert Open --> 1 / Close --> 0 | Alert Level: 0 ~ 100
*/
-(void)DC_SetAlertFinish:(BOOL)success WithResult:(NSDictionary*)resultDict WithMessageCode:(NSString*)code WithErrorDescription:(NSString*)description;

@end

@interface DC_SettingService : NSObject

@property (weak,nonatomic) id <DC_SetPrivacyModeDelegate> DC_PrivacyModeDelegate;

@property (weak,nonatomic) id <DC_ViewerAlertDelegate> DC_ViewerAlertDelegate;

@property (weak,nonatomic) id <DC_NotifyDelegate> DC_NotifyDelegate;

@property (weak,nonatomic) id <DC_TimeZoneDelegate> DC_TimeZoneDelegate;

@property (weak,nonatomic) id <DC_AlertDelegate> DC_AlertDelegat;

/*
Request for server to get privacy mode.
*/
-(void)DC_SetPrivacyModeForUserGroup:(NSString*)userGroup;

/*
Get Viewer Alerts Status From Server.
*/
-(void)DC_GetViewerAlertsForUserGroup:(NSString*)userGroup;
/*
Set Viewer Alerts Status.
*/
-(void)DC_SetViewerAlertsForUserGroup:(NSString*)userGroup Status:(BOOL)open;

/*
Get Notify Type.
userID and userGroup are from account.
*/
-(void)DC_GetNotifyTypeWithUserID:(NSString*)userID WithUserGroup:(NSString*)userGroup;
/*
Set Notify Type.
userID and userGroup are from account.
If notity type is DC_NotityTypeEmail or DC_NotityTypeText, you should enter user email or user phone number for delivery, others just enter nil.
*/
-(void)DC_SetNotifyTypeWithUserID:(NSString*)userID WithUserGroup:(NSString*)userGroup WithDelivery:(NSString*)delivery ForNotityType:(DC_NotityType)type;

/*
Get Time Zone.
*/
-(void)DC_GetTimeZoneWithUserGroup:(NSString*)userGroup;
/*
Set Time Zone.
*/
-(void)DC_SetTimeZoneWithUserGroup:(NSString*)userGroup ForTimeZone:(DC_TimeZone)timeZone;

/*
Get a device noise and motion alert from server.
*/
-(void)DC_GetAlertForUserGroup:(NSString*)userGroup AndDeviceID:(NSString*)deviceID;
/*
Set a device noise and motion alert's open and level.
Enable Switch: Open --> 1 / Close --> 0
Level Set: 0 ~ 100
*/
-(void)DC_SetAlertForUserGroup:(NSString*)userGroup AndDeviceID:(NSString*)deviceID WithNoiseEnable:(NSInteger)noiseEnable WithNoiseLevel:(NSInteger)noiseLevel WithMotionEnable:(NSInteger)motionEnable WithMotionLevel:(NSInteger)motionLevel;

@end
