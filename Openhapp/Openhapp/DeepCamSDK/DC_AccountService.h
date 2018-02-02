//
//  DC_AccountService.h
//  DeepCam_SDK
//
//  Created by Jesse on 16/4/29.
//  Copyright © 2016年 Linksprite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol DC_RegisterAccountDelegate
/*
This delegate is from register a new account or authenticate the account's exist, if success new account "newAccount" is yes and old account it's no, "resultDict" is the register or authenticate result, it's the account's informations, if you request failure you can get the error description.
 */
-(void)DC_RegisterAccountDelegateFinish:(BOOL)success WithResult:(NSDictionary*)resultDict WithAccountType:(BOOL)newAccount WithErrorDescription:(NSString*)description;

@end

@protocol DC_AuthenticateAccountDelegate
/*
It will be called when authenticate account finish.
If success, you can get account, camera and applicaion informations, they are important.
If you request failure you can get the error description.
 */
-(void)DC_AuthenticateAccountDelegateFinish:(BOOL)success WithResult:(NSDictionary*)resultDict WithErrorDescription:(NSString*)description;

@end

@protocol DC_ForgetAccountDelegate
/*
It will make you know whether your forget password requestion is success, if failure you can get the error description.
 */
-(void)DC_ForgetAccountDelegateFinish:(BOOL)success WithErrorDescription:(NSString*)description;

@end

@protocol DC_ModifyAccountEmailDelegate
/*
It is called after finish modify email, you can use the message code to search the title and message from messages array, the message will present the result.
If failure, you can get the error description.
 */
-(void)DC_ModifyAccountEmailDelegateFinish:(BOOL)success WithMessageCode:(NSString*)code WithErrorDescription:(NSString*)description;

@end

@protocol DC_ModifyAccountPasswordDelegate
/*
It is called after finish modify password, you can use the message code to search the title and message from messages array, the message will present the result.
If failure, you can get the error description.
*/
-(void)DC_ModifyAccountPasswordDelegateFinish:(BOOL)success WithMessageCode:(NSString*)code WithErrorDescription:(NSString*)description;

@end

@protocol DC_ModifyAccountUserNameDelegate
/*
It is called after finish modify user name, you can use the message code to search the title and message from messages array, the message will present the result.
If failure, you can get the error description.
*/
-(void)DC_ModifyAccountUserNameDelegateFinish:(BOOL)success WithMessageCode:(NSString*)code WithErrorDescription:(NSString*)description;

@end

@interface DC_AccountService : NSObject

@property (weak,nonatomic) id <DC_RegisterAccountDelegate> DC_RegisterDelegate;

@property (weak,nonatomic) id <DC_AuthenticateAccountDelegate> DC_AuthenticateDelegate;

@property (weak,nonatomic) id <DC_ForgetAccountDelegate> DC_ForgetDelegate;

@property (weak,nonatomic) id <DC_ModifyAccountEmailDelegate> DC_ModifyEmailDelegate;

@property (weak,nonatomic) id <DC_ModifyAccountPasswordDelegate> DC_ModifyPasswordDelegate;

@property (weak,nonatomic) id <DC_ModifyAccountUserNameDelegate> DC_ModifyUserNameDelegate;

/*
The method is used for registering a new account or authenticating the account is existing, the password need to be encrypted by base64.
The email format must be correct, password should be more than 6 characters.
 */
-(void)DC_RegisterAccountWithFirstName:(NSString*)fn WithLastName:(NSString*)ln WithEmail:(NSString*)email WithPassword:(NSString*)pw;
/*
It's used for authenticating your account and password, the password need to be encrypted by base64.
The email format must be correct, password should be more than 6 characters.
 */
-(void)DC_AuthenticateAccountWithEmail:(NSString*)email WithPassword:(NSString*)pw WithUserID:(NSString*)userID;
/*
The method you can request forget your account's password, you should enter your email address and the server will send a email to your email.
The email format must be correct.
 */
-(void)DC_ForgetAccountWithEmail:(NSString*)email;
/*
You can use the account's userID and email from database you have saved, the mac address is from your camera, if you have more than one, you just enter one of them.
The email format must be correct.
 */
-(void)DC_ModifyAccountEmailWithUserID:(NSString*)userID WithNewEmail:(NSString*)email WithMACAddress:(NSString*)macAddress;
/*
You can use the account's userID from database you have saved, must enter your old password and new password.
The password should be more than 6 characters.
 */
-(void)DC_ModifyAccountPasswordWithUserID:(NSString*)userID WithOldPassword:(NSString*)oldPassword WithNewPassword:(NSString*)newPassword;
/*
You can use the account's userID from database you have saved, must enter your new first name and new last name.
*/
-(void)DC_ModifyAccountUserNameWithUserID:(NSString*)userID WithFirstName:(NSString*)fn WithLastName:(NSString*)ln;

@end
