//
//  DC_CameraManager.h
//  DeepCam_SDK
//
//  Created by Jesse on 16/4/29.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
Support Camera Type
*/
typedef NS_ENUM(NSUInteger,DC_CameraType){
    DC_CameraTypeH210 = 0, /* H210 */
    DC_CameraTypeAH8704 = 1 /* AH8704(APEX) */
};

/*
Video Quality Level
*/
typedef NS_ENUM(NSUInteger,DC_VideoLevel){
    DC_VideoLevelHD = 0, /* WiFi HD */
    DC_VideoLevelNormal = 1 /* Cell Low */
};

/*
Network Model
*/
typedef NS_ENUM(NSUInteger,DC_NetworkModel){
    DC_NetworkModelLocal = 0, /* Local Network */
    DC_NetworkModelRemote = 1 /* Remote Network */
};

/*
Video Size
*/
typedef NS_ENUM(NSUInteger,DC_VideoSize){
    DC_VideoSizeFull = 0, /* Full */
    DC_VideoSizeSmall = 1 /* Small */
};

@protocol DC_AddCameraDelegate
/*
It will call back when finish registering camera to server, you can get some camera informations from the result. If register failure, you can get the error from the message code and the error description.
*/
-(void)DC_RegisterCameraToServerFinish:(BOOL)success WithResult:(NSDictionary*)resultDict WithMessageCode:(NSString*)code WithErrorDescription:(NSString*)description;
/*
It will call back when finish registering camera to account, you can get some camera informations from the result. If register failure, you can get the error from the message code and the error description.
*/
-(void)DC_RegisterCameraToAccountFinish:(BOOL)success WithResult:(NSDictionary*)resultDict WithMessageCode:(NSString*)code WithErrorDescription:(NSString*)description;
/*
It will present the result of setting, you can get error from error description.
*/
-(void)DC_SetCameraFinish:(BOOL)success WithErrorDescription:(NSString*)description;

@end

@protocol DC_GetViewerCameraDelegate
/*
It will work when get viewer camera complete and you can reload your camera.
*/
-(void)DC_GetViewerCameraFinish:(BOOL)success ForResult:(NSDictionary*)resultDict WithErrorDescription:(NSString*)description;

@end

@protocol DC_DeleteCameraDelegate
/*
It will call back after finish deleting camera from server.
*/
-(void)DC_DeleteCameraFinish:(BOOL)success WithMessageCode:(NSInteger)code WithErrorDescription:(NSString*)description;

@end

@protocol DC_ModifyCameraNameDelegate
/*
It will call back when finish modifing camera name.
*/
-(void)DC_ModifyCameraNameFinish:(BOOL)success WithMessageCode:(NSInteger)code WithErrorDescription:(NSString*)description;

@end

@protocol DC_PlayVideoDelegate
/*
The method will work when get video connection address complete, if failed you can get message code or error description.
We need the information from resultDict to play video.
*/
-(void)DC_GetVideoConnectionAddressFinish:(BOOL)success WithResult:(NSDictionary*)resultDict WithMessageCode:(NSInteger)code WithErrorDescription:(NSString*)description;
/*
The method will call back after finish loading video, you can get video player view, if load failure you can get error description.
*/
-(void)DC_LoadVideoFinish:(BOOL)success WithVideoView:(UIView*)videoView WithErrorDescription:(NSString*)description;
/*
It will call back when video player start and video vertical > 0 && video horizontal > 0.
You can scale the video view to fit your screen by setting scrollView contentInset and scrollRectToVisible.
*/
-(void)DC_VideoPlayerStartForScrollViewContentInset:(UIEdgeInsets)videoContentInset ScrollRectToVisible:(CGRect)videoRect;
/*
It will call back when the video disconnect, you can get error description and message code.
*/
-(void)DC_VideoPlayerDidDisconnectForErrorDescription:(NSString*)description WithMessageCode:(NSString*)code;
/*
It will only call back when can not access to photo album and present a message code.
*/
-(void)DC_TakeSnapshotCanNotAccessPhotoAlbumForMessageCode:(NSString*)code;

@end

@protocol DC_SendVoiceDelegate
/*
It will call back after send voice complete.
*/
-(void)DC_SendVoiceFinish:(BOOL)success ForErrorDescription:(NSString*)description;

@end

@interface DC_CameraManager : NSObject

@property (weak,nonatomic) id <DC_AddCameraDelegate> DC_AddDelegate;

@property (weak,nonatomic) id <DC_GetViewerCameraDelegate> DC_GetViewerDelegate;

@property (weak,nonatomic) id <DC_DeleteCameraDelegate> DC_DeleteDelegate;

@property (weak,nonatomic) id <DC_ModifyCameraNameDelegate> DC_ModifyNameDelegate;

@property (weak,nonatomic) id <DC_PlayVideoDelegate> DC_PlayVideoDelegate;

@property (weak,nonatomic) id <DC_SendVoiceDelegate> DC_VoiceSendDelegate;

/*
Camera Initialization
You need to get camera mac and key, enter your home network SSID and password.
*/
-(void)DC_InitWithCameraType:(DC_CameraType)type WithCameraMac:(NSString*)mac WithCameraKey:(NSString*)key WithCameraName:(NSString*)name WithHomeNetworkSSID:(NSString*)ssid WithHomeNetworkPassword:(NSString*)pw;
/*
Register Camera
You must enter userGroup, userEmail and userPassword.
*/
-(void)DC_RegisterCameraWithUserGroup:(NSString*)userGroup WithUserEmail:(NSString*)userEmail WithUserPassword:(NSString*)userPassword;
/*
Set Camera
The method you can set your camera and make it connect to server.
*/
-(void)DC_SetCamera;

/*
Delete Camera
You need to enter userGroup, userEmail and userPassword, they are from account.
The camera mac and key must match the camera you want to delete.
*/
-(void)DC_DeleteCameraWithUserGroup:(NSString*)userGroup WithCameraMac:(NSString*)mac WithCameraKey:(NSString*)key WithUserEmail:(NSString*)userEmail WithUserPassword:(NSString*)userPassword;

/*
You can get camera information and reload camera before enter main view.
*/
-(void)DC_GetViewerCameraWithDeviceID:(NSString*)deviceID WithUserEmail:(NSString*)userEmail WithUserPassword:(NSString*)userPassword;

/*
Modify Camera Name
You need to enter account userGroup, the camera mac and key should be the one you want to modify.
*/
-(void)DC_ModifyCameraNameWithUserGroup:(NSString*)userGroup WithCameraMac:(NSString*)mac WithCameraKey:(NSString*)key WithNewCameraName:(NSString*)name;

/*
If your network is remote (remote wifi or cellular) but for local (home wifi), you should use this method to get connection address.
The method you can get video connection address from server, choose the video level you need (level is based on your network condition for example wifi or cellular), enter the mac and key from the camera you want to watch, must enter account's userID, token, userGroup and planType.
Talkback connectionHttp is gotten from here.
*/
-(void)DC_GetVideoConnectionAddressWithVideoLevel:(DC_VideoLevel)level WithCameraMac:(NSString*)mac WithCameraKey:(NSString*)key WithAccountUserID:(NSString*)userID WithAccountToken:(NSString*)token WithAccountUserGroup:(NSString*)userGroup WithAccountPlanType:(NSString*)planType;
/*
Local WiFi Network
localIP, rtspUserName, key, rtspPort and localPath are from the camera.
This videoTimeOut is videoWiFiTimeout from server.
ViewFrame is your screen view frame.
Local network video level HD.
*/
-(void)DC_LoadVideoFromCameraLocalIP:(NSString*)localIP CameraRtspUserName:(NSString*)rtspUserName CameraKey:(NSString*)key CameraRtspPort:(NSString*)rtspPort CameraLocalPath:(NSString*)localPath AspectRatio:(NSString*)aspectRatio VideoTimeOut:(NSNumber*)videoTimeOut ForViewFrame:(CGRect)frame AndVideoSize:(DC_VideoSize)size;
/*
Remote WiFi Network
remoteURL is gotten from server, rtspUserName, key, remotePath and cellPath are from camera.
This videoTimeOut: DC_VideoLevelHD --> videoWiFiTimeout / DC_VideoLevelNormal --> videoCellTimeout, they are from server.
ViewFrame is your screen view frame.
video level is based on your network condition.
*/
-(void)DC_LoadVideoFromCameraRemoteURL:(NSString*)remoteURL CameraRtspUserName:(NSString*)rtspUserName CameraKey:(NSString*)key CameraRemotePath:(NSString*)remotePath CameraCellPath:(NSString*)cellPath AspectRatio:(NSString*)aspectRatio ForVideoLevel:(DC_VideoLevel)level VideoTimeOut:(NSNumber*)videoTimeOut ForViewFrame:(CGRect)frame AndVideoSize:(DC_VideoSize)size;
/*
Stop Playing Video
App Background
*/
-(void)DC_StopVideo;
/*
Close Video
Back Main View Close Video
*/
-(void)DC_CloseVideo;
/*
Take Snapshot
*/
-(void)DC_TakeSnapshot;

/*
Talkback
Record Voice Start
*/
-(void)DC_RecordVoice;
/*
Talkback
Record Voice Stop And Send Voice
*/
-(void)DC_SendVoiceForNetworkModel:(DC_NetworkModel)networkModel WithCameraType:(DC_CameraType)cameraType WithLocalIP:(NSString*)localIP WithConnectionHttp:(NSString*)connectionHttp WithHttpUserName:(NSString*)httpUserName WithKey:(NSString*)key;

@end
