//
//  SettingViewController.m
//  Decorator
//
//  Created by Hoang Le on 11/18/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "SettingViewController.h"
#define kALPHA                   @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define kNUMERIC                 @"1234567890"
#define kALPHA_NUMERIC           kALPHA kNUMERIC
#import "NSString+Japanese.h"
#import "JSONKit.h"
#import "ResponseAPI.h"
#import "MBProgressHUD.h"
@interface SettingViewController (){
    BOOL isCorrectUserPass;
    BOOL isSaveData;
    UITextField *lastTextField;
    
    BOOL isChangedContent;
    BOOL isJustUpdateUsername;
    MBProgressHUD *HUD;
}

- (void) _intDisplayUI;

- (void) _saveData;

- (BOOL) _getLockPassword;

- (void) _setLockPassword: (BOOL) value;

- (void) _showLockPass;

- (void) _lockPasswordToEditTextField;


@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        _background.image = [UIImage imageNamed:@"BG_02.jpg"];
    }
    else{
        _background.image = [UIImage imageNamed:@"BG_04.jpg"];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scroller.contentSize = CGSizeMake(677, 978);
    [self settxtAutosave:[self getAutosavetime]];
    isCorrectUserPass = NO;
    isChangedContent = NO;
//    [self.scroller contentSizeToFit];
    [self _intDisplayUI];
    [self _setLockPassword:false];
    
}

- (void)settxtAutosave:(int)time{
//    switch (time) {
//        case 10:
//            _txt_autosave.text = @"10秒";
//            break;
//        case 30:
//            _txt_autosave.text = @"30秒";
//            break;
//        case 60:
//            _txt_autosave.text = @"1分";
//            break;
//        case 120:
//            _txt_autosave.text = @"2分";
//            break;
//        default:
//            break;
//    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;{
    if (UIInterfaceOrientationIsPortrait(fromInterfaceOrientation)) {
        _background.image = [UIImage imageNamed:@"BG_02.jpg"];
    }
    else{
        _background.image = [UIImage imageNamed:@"BG_04.jpg"];
    }
}

- (void) _intDisplayUI{
//    _txtUserName.text   = [SettingViewController getUserName];
    _txtLoginName.text  = [SettingViewController getLoginOfficerName];
    _txtPassword.text   = [SettingViewController getOfficePassword];
    _txtNameOder.text   = [SettingViewController getNameOder];
    _txtAddressOder.text = [SettingViewController getAddressOder];
    _txtAddress.text = [SettingViewController getAddress];
    _txtPhoneNumberOder.text = [SettingViewController getPhoneNumberOder];
    _txtEmailOder.text  = [SettingViewController getEmailOder];
    _txtNameStore.text  = [SettingViewController getNameStore];
    _txtEmailStore.text = [SettingViewController getEmailStore];
    _txtOfficeOfSuzukafine.text = [SettingViewController getOfficeOfSuzukafine];
    _txtCCEmailStore.text = [SettingViewController getCCEmailStore];
    
    _txt_postalCode.text = [SettingViewController getZipcode];
    _txt_secondAddress.text = [SettingViewController getSecondAddress];
    _txt_fax.text = [SettingViewController getFax];
    _txt_mobilePhone.text = [SettingViewController getMobileNumber];
    _txt_storeFax.text = [SettingViewController getStoreFax];
    _txt_storePhoneNumber.text = [SettingViewController getStorePhone];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark IBAction

- (IBAction)backToMenu:(id)sender {
    [self.navigationController fadePopViewController];
}
- (IBAction)saveData:(id)sender{
//    [[NSUserDefaults standardUserDefaults] setValue:_txtUserName.text
//                                            forKey:kUserName];
    [self.navigationController fadePopViewController];
 }
#pragma mark -
#pragma mark Function Private

- (void) showOfficerPass{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"会員専用サービス" message:@"ユーザネーム、パスワードが必要です" delegate:self cancelButtonTitle:@"次へ" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    alert.tag = 102;
    [alert show];
}

- (void) _showLockPass{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"セキュリティ－コード" message:@"" delegate:self cancelButtonTitle:@"次へ" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    alert.tag = 101;
    [alert show];
}
- (void) _lockPasswordToEditTextField{
    [self _setLockPassword:true];
}

- (BOOL) _getLockPassword{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kLockPassword];
}

- (void) _setLockPassword:(BOOL)value{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:kLockPassword];
}

- (void) _saveData{
    if (isChangedContent) {
        [[NSUserDefaults standardUserDefaults] setValue:_txtLoginName.text
                                                 forKey:kLoginOfficerName];
        [[NSUserDefaults standardUserDefaults] setValue:_txtPassword.text
                                                 forKey:kOfficerPassword];
        [[NSUserDefaults standardUserDefaults] setValue:_txtNameOder.text
                                                 forKey:kNameOder];
        [[NSUserDefaults standardUserDefaults] setValue:_txtAddressOder.text
                                                 forKey:kAddressOder];
        [[NSUserDefaults standardUserDefaults] setValue:_txtPhoneNumberOder.text
                                                 forKey:kPhoneNumberOder];
        [[NSUserDefaults standardUserDefaults] setValue:_txtEmailOder.text
                                                 forKey:kEmailOder];
        [[NSUserDefaults standardUserDefaults] setValue:_txtNameStore.text
                                                 forKey:kNameStore];
        [[NSUserDefaults standardUserDefaults] setValue:_txtEmailStore.text
                                                 forKey:kEmailStore];
        [[NSUserDefaults standardUserDefaults] setValue:_txtOfficeOfSuzukafine.text
                                                 forKey:kOfficeOfSuzukafine];
        [[NSUserDefaults standardUserDefaults] setValue:_txtCCEmailStore.text
                                                 forKey:kCCEmaillStore];
    }
//    [[NSUserDefaults standardUserDefaults] setValue:_txtUserName.text
//                                             forKey:kUserName];
    [self.navigationController fadePopViewController];
}
#pragma mark -
#pragma mark UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 101) {
        if ([[alertView textFieldAtIndex:0].text isEqualToString:[SettingViewController getLoginUserName]] &&
            [[alertView textFieldAtIndex:1].text isEqualToString:[SettingViewController getUserPassword]]) {
            [self _lockPasswordToEditTextField];
            isCorrectUserPass = YES;
            if (isSaveData) {
                [self _saveData];
            }
            else
                [lastTextField becomeFirstResponder];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"入力内容に誤りがあります。" delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
            [alert show];
        }
    }
    else if (alertView.tag == 102){
        if ([SettingViewController getLoginOfficerName].length != 0 || [SettingViewController getOfficePassword].length != 0) {
            if ([[alertView textFieldAtIndex:0].text isEqualToString:[SettingViewController getLoginOfficerName]] &&
                [[alertView textFieldAtIndex:1].text isEqualToString:[SettingViewController getOfficePassword]]) {
                isCorrectUserPass = YES;
                [lastTextField becomeFirstResponder];
            }

        }
        else if ([[alertView textFieldAtIndex:0].text isEqualToString:kFixOfficerName] &&
            [[alertView textFieldAtIndex:1].text isEqualToString:kFixOfficerPassword]) {
                [[NSUserDefaults standardUserDefaults] setValue:kFixOfficerName
                                                         forKey:kLoginOfficerName];
                [[NSUserDefaults standardUserDefaults] setValue:kFixOfficerPassword
                                                         forKey:kOfficerPassword];
            isCorrectUserPass = YES;
            _txtLoginName.text = [SettingViewController getLoginOfficerName];
            _txtPassword.text = [SettingViewController getOfficePassword];
            [lastTextField becomeFirstResponder];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"入力内容に誤りがあります。" delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
            [alert show];
        }
    }
}

#pragma mark -
#pragma mark Function Public

+ (NSString *) getLoginOfficerName{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kLoginOfficerName];
}
+ (NSString *) getOfficePassword{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kOfficerPassword];
}

+ (NSString *) getLoginUserName{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kLoginUserName];
}

+ (NSString *) getUserPassword{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUserPassword];
}

+ (NSString *) getUserName{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kUserName];
}

+ (NSString *) getLoginName{
     return [[NSUserDefaults standardUserDefaults] stringForKey:kOfficerPassword];
}

+ (NSString *) getIsCorrectUserPass{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kIsCorrectUserPass];
}
+ (NSString *) getPassWord{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kOfficerPassword];
}

+ (NSString *) getNameOder{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kNameOder];
}
+ (NSString *) getAddressOder{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kAddressOder];
}
+ (NSString *) getPhoneNumberOder{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kPhoneNumberOder];
}
+ (NSString *) getEmailOder{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kEmailOder];
}

+ (NSString *) getNameStore{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kNameStore];
}
+ (NSString *) getEmailStore{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kEmailStore];
}
+ (NSString *) getOfficeOfSuzukafine{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kOfficeOfSuzukafine];
}
+ (NSString *) getCCEmailStore{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kCCEmaillStore];
}
+ (NSString *) getAddress{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kAddress];
}

+ (NSString *)getZipcode{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kZipcode];
}
+ (NSString *)getFax{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kFax];
}
+ (NSString *)getStoreFax{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kStoreFax];
}
+ (NSString *)getStorePhone{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kStorePhone];
}
+ (NSString *)getMobileNumber{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kMobilePhone];
}
+ (NSString *)getSecondAddress{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kAddress2];
}

- (int)getAutosavetime{
    int autosaveTime = [(NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:kAutosaveTime] intValue];
    if (autosaveTime == 0) {
        autosaveTime = 10;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:10] forKey:kAutosaveTime];
    }
    return autosaveTime;
}

- (void)setAutosavetime:(NSNumber *)value{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:kAutosaveTime];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    int autosaveValue;
    NSString *txtValue = @"";
    switch (buttonIndex) {
        case 0:
            autosaveValue = 10;
            txtValue = @"10秒";
            break;
        case 1:
            autosaveValue = 30;
            txtValue = @"30秒";
            break;
        case 2:
            autosaveValue = 60;
            txtValue = @"1分";
            break;
        case 3:
            autosaveValue = 120;
            txtValue = @"2分";
            break;
        default:
            autosaveValue = 10;
            txtValue = @"10秒";
            break;
    }
    [self setAutosavetime:[NSNumber numberWithInt:autosaveValue]];
//    _txt_autosave.text = txtValue;
}

#pragma mark -
#pragma mark TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    if (textField == _txt_autosave) {
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"プランを自動的に保存する時間設定" delegate:self cancelButtonTitle:@"" destructiveButtonTitle:nil otherButtonTitles:@"10秒",@"30秒",@"1分",@"2分", nil];
//        [actionSheet showInView:self.view];
//        return false;
//    }
    lastTextField = textField;
    if (textField.tag == 1) {
        isSaveData = NO;
        if (!isCorrectUserPass) {
            [self _showLockPass];
        }
        else
            return true;
        return false;
    }
    else if (textField.tag == 2) {
        return true;
    }
    return true;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if (textField != _txtUserName) {
        isChangedContent = YES;
//    }
//    else
//        isChangedContent = NO;
    return YES;
}

- (void)viewDidUnload {
//    [self setTxtUserName:nil];
    [self setTxtLoginName:nil];
    [self setTxtPassword:nil];
    [self setTxtNameOder:nil];
    [self setTxtAddressOder:nil];
    [self setTxtPhoneNumberOder:nil];
    [self setTxtEmailOder:nil];
    [self setTxtNameStore:nil];
    [self setTxtEmailStore:nil];
    [self setTxtOfficeOfSuzukafine:nil];
    [self setTxtCCEmailStore:nil];
    [super viewDidUnload];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [HUD hide:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー" message:@"同期する時はエラーが発生しました。あとで試してください。" delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
    [alert show];
}
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{

}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{

}
-   (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData{
    [HUD hide:YES];
    NSString *receivedString = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    NSString *convertedString = [receivedString mutableCopy];
    CFStringRef transform = CFSTR("Any-Hex/Java");
    CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
//    NSLog(@"%@",convertedString);
    JSONModelError *error;
    ResponseAPI *reponseObj = [[ResponseAPI alloc] initWithString:convertedString error:&error];
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー" message:@"同期する時はエラーが発生しました。あとで試してください。" delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
        [alert show];
    }
    else{
        if ([reponseObj.result isEqualToString:@"true"] && [reponseObj.status isEqualToString:@"normal"]) {
            [self saveUserInfor:reponseObj.infor];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"エラー" message:@"ユーザー名は間違いです。もう一度入力してください。" delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
            [alert show];
        }
    }
}
- (void)saveUserInfor:(UserInfo *)_userInfo{
    _txtLoginName.text = _userInfo.login_name;
    _txtPassword.text = _userInfo.login_password;
    _txtNameOder.text = _userInfo.company_name;
    _txtAddressOder.text = _userInfo.username;//[NSString stringWithFormat:@"%@ - %@",_userInfo.address1,_userInfo.address2];
    _txtAddress.text = _userInfo.address1;
    _txtPhoneNumberOder.text = _userInfo.phone_number;
    _txtEmailOder.text = _userInfo.mail;
    _txtNameStore.text = _userInfo.store;
    _txtEmailStore.text = _userInfo.store_mail;
    _txtOfficeOfSuzukafine.text = _userInfo.suzuka;
    _txtCCEmailStore.text = _userInfo.suzuka_mail;
    
    _txt_postalCode.text = _userInfo.zipcode;
    _txt_secondAddress.text = _userInfo.address2;
    _txt_fax.text = _userInfo.fax;
    _txt_mobilePhone.text = _userInfo.mobile_number;
    _txt_storeFax.text = _userInfo.store_fax;
    _txt_storePhoneNumber.text = _userInfo.store_phone_number;
//    _txtUserName.text = _userInfo.username;
    
    [[NSUserDefaults standardUserDefaults] setValue:_userInfo.login_name forKey:kLoginOfficerName];
    [[NSUserDefaults standardUserDefaults] setValue:_userInfo.login_password forKey:kOfficerPassword];
    [[NSUserDefaults standardUserDefaults] setValue:_userInfo.company_name forKey:kNameOder];
    [[NSUserDefaults standardUserDefaults] setValue:_userInfo.username forKey:kAddressOder];
    [[NSUserDefaults standardUserDefaults] setValue:_userInfo.phone_number forKey:kPhoneNumberOder];
    [[NSUserDefaults standardUserDefaults] setValue:_userInfo.mail forKey:kEmailOder];
    [[NSUserDefaults standardUserDefaults] setValue:_userInfo.store forKey:kNameStore];
    [[NSUserDefaults standardUserDefaults] setValue:_userInfo.store_mail forKey:kEmailStore];
    [[NSUserDefaults standardUserDefaults] setValue:_userInfo.suzuka forKey:kOfficeOfSuzukafine];
    [[NSUserDefaults standardUserDefaults] setValue:_userInfo.suzuka_mail forKey:kCCEmaillStore];
//    [[NSUserDefaults standardUserDefaults] setValue:_txtUserName.text forKey:kUserName];
    [[NSUserDefaults standardUserDefaults] setValue:_userInfo.address1 forKey:kAddress];
    
    [[NSUserDefaults standardUserDefaults] setValue:_userInfo.address2 forKey:kAddress2];
    [[NSUserDefaults standardUserDefaults] setValue:_userInfo.zipcode forKey:kZipcode];
    [[NSUserDefaults standardUserDefaults] setValue:_userInfo.fax forKey:kFax];
    [[NSUserDefaults standardUserDefaults] setValue:_userInfo.mobile_number forKey:kMobilePhone];
    [[NSUserDefaults standardUserDefaults] setValue:_userInfo.store_fax forKey:kStoreFax];
    [[NSUserDefaults standardUserDefaults] setValue:_userInfo.store_phone_number forKey:kStorePhone];
}

- (IBAction)syncAccount:(id)sender {
    if (_txtLoginName.text.length == 0 || _txtPassword.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"セキュリティ－コード" message:@"ユーザネーム、パスワードが必要です" delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSString *post = [NSString stringWithFormat:@"params={\"username\":\"%@\",\"password\":\"%@\"}",_txtLoginName.text,_txtPassword.text];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://icp.suzukafine.co.jp/index.php/api/login"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", @"icp2014@suzukafine.co.jp", @"7azhnux1"];
    NSData *authData = [basicAuthCredentials dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authenticateValue = [authData base64Encoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", authenticateValue];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.dimBackground = YES;
    HUD.labelText = @"同期する...";
    [conn start];
}

@end
