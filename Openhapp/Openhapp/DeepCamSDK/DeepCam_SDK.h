//
//  DeepCam_SDK.h
//  DeepCam_SDK
//
//  Created by Jesse on 16/4/29.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/************************************************************************************/
/*
I Have Put All The Delegate Method Into Main Queue.
我已将所有回调协议方法置于主队列中.
*/
/************************************************************************************/

/*
Alert Type
*/
typedef NS_ENUM(NSUInteger,DC_AlertsType){
    DC_AlertsTypeNoise = 0, /* Noise Alerts */
    DC_AlertsTypeViewer = 1, /* Viewer Alerts */
    DC_AlertsTypeMotion = 2 /* Motion Alerts */
};

@protocol DC_BasicMessagesDelegate

/*
This Is The Server Call Back Result Delegate, You Can Know The Request Is Success or Failure. If Request Success And Have Messages, You Can Get The Messages Array. If You Request Failure Or Get A Empty Array, You Will Get Error Description.
*/
-(void)DC_DidReceiveBasicMessagesComplete:(BOOL)success WithMessages:(NSArray*)messages WithErrorDescription:(NSString*)description;

@end

@protocol DC_CameraDiscoveryDelegate
/*
Discovery camera call back one result.
key:CameraDiscoveredAttributesKey & key:CameraDiscoveredAddressKey
*/
-(void)DC_BroadcastCameraDiscoveryResult:(NSDictionary*)cameraDict;
/*
The camera is offline for mac.
*/
-(void)DC_BroadcastCameraStatusOfflineForCameraMac:(NSString*)mac;

@end

@protocol DC_GetAlertLogDelegate
/*
It will call back alert log url.
*/
-(void)DC_GetAlertLogWithWebView:(NSString*)alertUrl;

@end

@interface DeepCam_SDK : NSObject

@property (weak,nonatomic) id <DC_BasicMessagesDelegate> DC_MessageDelegate;

@property (weak,nonatomic) id <DC_CameraDiscoveryDelegate> DC_CameraDiscoveryDelegate;

@property (weak,nonatomic) id <DC_GetAlertLogDelegate> DC_AlertLogDelegate;

/*
Get Terms Site
*/
+(NSString*)DC_TermsSite;

/*
 The Method Get Messages Array From Server, The Messages Array Contains Titles And Messages, They Are Used For The Server Call Back Description, The Server's Call Back Is Code (Number), We Can Search The Result's Title And Message By The Code.
 LastSyncDate Is The Last Date You Get Messages Array From Server, You Can Get It Once Again After A Week.
 LastSyncDate Format: mm/dd/YYYY
 If You Want To Use Our Defined Messages And You Need To Get From Server.
 */
-(void)DC_GetBasicMessagesWithLastSyncDate:(NSString*)date;

/*
Initialize broadcasting camera and call back self, if you want to start server, you need to set start YES. It works on local network mode.
 */
-(id)DC_InitBroadcastCameraDiscoveryWithLocalCamerasMac:(NSArray*)macs ForStartServer:(BOOL)start AndTimeInterval:(double)timeInterval;
/*
The method can broadcast camera from local network and judge whether online once, camera must have connected the local network and your phone too, it works on local network mode.
*/
-(void)DC_BroadcastCameraDiscoveryRequest;
/*
Start keeping broadcasting local camera and judge whether online, it works on local network mode.
*/
-(void)DC_BroadcastCameraStartPolling;
/*
Stop keeping broadcasting camera, it works on local network mode.
*/
-(void)DC_BroadcastCameraStopPolling;

/*
Get Alert Log
*/
-(void)DC_GetAlertLogForType:(DC_AlertsType)type WithUserID:(NSString*)userID WithUserGroup:(NSString*)userGroup WithPassword:(NSString*)password;

@end
