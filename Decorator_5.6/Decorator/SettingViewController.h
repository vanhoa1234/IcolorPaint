//
//  SettingViewController.h
//  Decorator
//
//  Created by Hoang Le on 11/18/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "TPKeyboardAvoidingScrollView.h"

#define kFixOfficerName          @"icolorpaint"
#define kFixOfficerPassword      @"abc123"

@interface SettingViewController : UIViewController<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
//@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtLoginName;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtNameOder;
@property (weak, nonatomic) IBOutlet UITextField *txtAddressOder;
@property (weak, nonatomic) IBOutlet UITextField *txtPhoneNumberOder;
@property (weak, nonatomic) IBOutlet UITextField *txtEmailOder;
@property (weak, nonatomic) IBOutlet UITextField *txtNameStore;
@property (weak, nonatomic) IBOutlet UITextField *txtEmailStore;
@property (weak, nonatomic) IBOutlet UITextField *txtOfficeOfSuzukafine;
@property (weak, nonatomic) IBOutlet UITextField *txtCCEmailStore;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;

@property (weak, nonatomic) IBOutlet UITextField *txt_postalCode;
@property (weak, nonatomic) IBOutlet UITextField *txt_secondAddress;
@property (weak, nonatomic) IBOutlet UITextField *txt_fax;
@property (weak, nonatomic) IBOutlet UITextField *txt_mobilePhone;
@property (weak, nonatomic) IBOutlet UITextField *txt_storeFax;
@property (weak, nonatomic) IBOutlet UITextField *txt_storePhoneNumber;

- (IBAction)backToMenu:(id)sender;
- (IBAction)saveData:(id)sender;

+ (NSString *) getUserName;

+ (NSString *) getLoginName;
+ (NSString *) getPassWord;

+ (NSString *) getNameOder;
+ (NSString *) getAddressOder;
+ (NSString *) getPhoneNumberOder;
+ (NSString *) getEmailOder;

+ (NSString *) getNameStore;
+ (NSString *) getEmailStore;
+ (NSString *) getOfficeOfSuzukafine;
+ (NSString *) getCCEmailStore;
+ (NSString *) getIsCorrectUserPass;

+ (NSString *) getLoginUserName;
+ (NSString *) getUserPassword;

+ (NSString *) getLoginOfficerName;
+ (NSString *) getOfficePassword;
+ (NSString *) getAddress;

+ (NSString *)getZipcode;
+ (NSString *)getFax;
+ (NSString *)getStoreFax;
+ (NSString *)getStorePhone;
+ (NSString *)getMobileNumber;
+ (NSString *)getSecondAddress;
- (int)getAutosavetime;
- (void)setAutosavetime:(NSNumber *)value;
@property (weak, nonatomic) IBOutlet UIImageView *background;

//@property (weak, nonatomic) IBOutlet UITextField *txt_autosave;
- (IBAction)syncAccount:(id)sender;

@end
