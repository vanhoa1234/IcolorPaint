        //
//  SignUpViewController.m
//  Decorator
//
//  Created by Le Hoang on 2/24/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import "SignUpViewController.h"
#import <objc/message.h>
#import "Reachability.h"
#import "BSErrorMessageView.h"
#import "UITextField+BSErrorMessageView.h"
#import "NSString+Japanese.h"
#import "MBProgressHUD.h"
#import "LoginResponseAPI.h"
#import "KMJPZipLookUp.h"
#import "ConfirmSignupViewController.h"

@interface SignUpViewController (){
    Reachability* internetReachable;
    Reachability* hostReachable;
    MBProgressHUD *HUD;
    BOOL isVN;
}
@property (nonatomic) BOOL internetActive;
@property (nonatomic) BOOL hostActive;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bt_signup.layer.cornerRadius = 10.0f;
    self.checkbox_sendmail.multipleSelectionEnabled = YES;
    NSArray *language = [NSLocale preferredLanguages];
    if (language.count > 0) {
        NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:language.firstObject];
        NSString *languageCode = [languageDic objectForKey:@"kCFLocaleLanguageCodeKey"];
        if ([languageCode isEqualToString:@"vi"]) {
            isVN = YES;
        } else {
            isVN = NO;
        }
    } else {
        isVN = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        int (*action)(id, SEL, int) = (int (*)(id, SEL, int)) objc_msgSend;
        action([UIDevice currentDevice], @selector(setOrientation:),[[UIDevice currentDevice] orientation]);
    }
    if (_isUpdateAccount) {
        int userid = (int)[[NSUserDefaults standardUserDefaults] integerForKey:kUserID];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendGetInfoRequest:userid];
        });
    } else {
        _internetLabelHeightConstraint.active = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        _background.image = [UIImage imageNamed:@"BG_02.jpg"];
//        self.scrollview.contentSize = CGSizeMake(1024, 1202);
    }
    else{
        _background.image = [UIImage imageNamed:@"BG_04.jpg"];
//        self.scrollview.contentSize = CGSizeMake(768, 1202);
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _background.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"IS_SIGINED"] || ![[NSUserDefaults standardUserDefaults] objectForKey:@""]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
        
        internetReachable = [Reachability reachabilityForInternetConnection];
        [internetReachable startNotifier];
        
        // check if a pathway to a random host exists
        hostReachable = [Reachability reachabilityWithHostName:@"icp.suzukafine.co.jp"];
        [hostReachable startNotifier];
    }

}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _background.alpha = 0.4;
    } completion:^(BOOL finished) {
    }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _background.alpha = 0.4;
    } completion:^(BOOL finished) {
    }];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self changePositionWithOrientation:toInterfaceOrientation];
}

- (void)changePositionWithOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        _background.image = [UIImage imageNamed:@"BG_02.jpg"];
//        self.scrollview.contentSize = CGSizeMake(1024, 1202);
    }
    else{
        _background.image = [UIImage imageNamed:@"BG_04.jpg"];
//        self.scrollview.contentSize = CGSizeMake(768, 1202);
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _background.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _background.alpha = 0.4;
    } completion:^(BOOL finished) {
        
    }];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        [self changePositionWithOrientation:orientation];
    }];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    
}


- (IBAction)backtoMenu:(id)sender {
    [self.navigationController fadePopViewController];
}

- (void) checkNetworkStatus:(NSNotification *)notice
{
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            self.internetActive = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            self.internetActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            self.internetActive = YES;
            break;
        }
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus)
    {
        case NotReachable:
        {
            self.hostActive = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            self.hostActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            self.hostActive = YES;
            break;
        }
    }
}

- (IBAction)selectedRadio:(id)sender{
    if ([[(UIButton *)sender titleLabel].text isEqualToString:NSLocalizedString(@"other", nil)]) {
        _txt_businessname.enabled = YES;
    }
    else{
        _txt_businessname.text = @"";
        _txt_businessname.enabled = NO;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [textField bs_hideError];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == _txt_email) {
        if (![self validEmail:_txt_email.text]) {
            [_txt_email bs_setupErrorMessageViewWithMessage:NSLocalizedString(@"email_incorrect", nil)];
            [_txt_email bs_showError];
        }
        else
            [_txt_email bs_hideError];
    }
    else if (textField == _txt_confirm_email){
        if (![_txt_confirm_email.text isEqualToString:_txt_email.text]) {
            [_txt_confirm_email bs_setupErrorMessageViewWithMessage:NSLocalizedString(@"email_not_match", nil)];
            [_txt_confirm_email bs_showError];
        }
        else
            [_txt_confirm_email bs_hideError];
    }
    else if (textField == _txt_password){
        if (_txt_password.text.length < 8) {
            [_txt_password bs_setupErrorMessageViewWithMessage:NSLocalizedString(@"character_require", nil)];
            [_txt_password bs_showError];
        }
        else
            [_txt_password bs_hideError];
    }
    else if (textField == _txt_confirm_password){
        if (![_txt_confirm_password.text isEqualToString:_txt_password.text]) {
            [_txt_confirm_password bs_setupErrorMessageViewWithMessage:NSLocalizedString(@"password_not_match", nil)];
            [_txt_confirm_password bs_showError];
        }
        else
            [_txt_confirm_password bs_hideError];
    }
    else if (textField == _txt_postalcode_field1 || textField == _txt_postalcode_field2){
        if (_txt_postalcode_field1.text.length > 0 && _txt_postalcode_field2.text.length > 0) {
            [self requestAPIWithZipcode:[_txt_postalcode_field1.text stringByAppendingString:_txt_postalcode_field2.text]];
        }
    }
}

- (void)requestAPIWithZipcode:(NSString *)zipcode
{
    NSError *error = nil;
    if (![[KMJPZipLookUpClient sharedClient] validateZipcode:zipcode withError:&error]) {
        NSDictionary *userInfo = error.userInfo;
        NSString *message = userInfo[NSLocalizedDescriptionKey];
        [self showAlertNotFoundAddressListWithMessage:message];
        return;
    }
    [[KMJPZipLookUpClient sharedClient] lookUpWithZipcode:zipcode success:^(AFHTTPRequestOperation *operation, KMJPZipLookUpResponse *response){
        if (response.addresses == 0) {
            return;
        }
        KMJPZipLookUpAddress *firstAddress = response.addresses[0];
        _txt_streetaddress.text = [NSString stringWithFormat:@"%@%@%@",firstAddress.prefecture,firstAddress.city,[firstAddress.address componentsSeparatedByString:@"（"][0]];
        NSLog(@"%@",_txt_streetaddress.text);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
//        [self showAlertNotFoundAddressListWithMessage:error.description];
    }];
}


- (void)showAlertNotFoundAddressListWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"search_postal_code", nil) message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (range.length > 0 && string.length == 0) {
        return YES;
    }
    if (textField == _txt_postalcode_field1 || textField == _txt_postalcode_field2 || textField == _txt_phone_field1 || textField == _txt_phone_field2 || textField == _txt_phone_field3 || textField == _txt_fax_field1 || textField == _txt_fax_field2 || textField == _txt_fax_field3) {
        if (![self validNumber:string]) {
            return NO;
        }
        if (textField == _txt_postalcode_field1 && _txt_postalcode_field1.text.length == 3) {
            [_txt_postalcode_field2 becomeFirstResponder];
            return NO;
        }
        if (textField == _txt_postalcode_field2 && _txt_postalcode_field2.text.length == 4) {
            [_txt_streetaddress becomeFirstResponder];
            return NO;
        }
    }
    if (textField == _txt_password && _txt_password.text.length == 16) {
        [_txt_confirm_password becomeFirstResponder];
        return NO;
    }

    return YES;
}

- (BOOL) validNumber:(NSString *)numberString{
    if([numberString length]==0){
        return NO;
    }
    NSString *regExPattern = @"[0-9]";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:numberString options:0 range:NSMakeRange(0, [numberString length])];
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL) validEmail:(NSString *)emailString {
    if([emailString length]==0){
        return NO;
    }
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL) validKatakana:(NSString *)katakanaString{
    if([katakanaString length]==0){
        return NO;
    }
    NSString *regExPattern = @"[ァ-ン]";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:katakanaString options:0 range:NSMakeRange(0, [katakanaString length])];
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (IBAction)action_signup:(id)sender {
    BOOL canSignup = YES;
    if (![self checkRequireField:_txt_email]) {
        canSignup = NO;
    }
    if (![self checkRequireField:_txt_confirm_email]) {
        canSignup = NO;
    }
    if (![self checkRequireField:_txt_password]) {
        canSignup = NO;
    }
    if (![self checkRequireField:_txt_confirm_password]) {
        canSignup = NO;
    }
    if (![self checkRequireField:_txt_surname]) {
        canSignup = NO;
    }
    if (![self checkRequireField:_txt_name]) {
        canSignup = NO;
    }
    if (![self checkRequireField:_txt_phonetic_surname]) {
        canSignup = NO;
    }
    if (![self checkRequireField:_txt_phonetic_name]) {
        canSignup = NO;
    }

    if (!_checkbox_businessname.selectedButton) {
        canSignup = NO;
        _icon_businessError.hidden = NO;
    } else {
        _icon_businessError.hidden = YES;
        if ([_checkbox_businessname.selectedButton.titleLabel.text isEqualToString:NSLocalizedString(@"other", nil)]) {
            if (![self checkRequireField:_txt_businessname]) {
                canSignup = NO;
            }
        } else {
            [_txt_buildingname bs_hideError];
        }
    }
    
    if (![self validEmail:_txt_email.text]) {
        [_txt_email bs_setupErrorMessageViewWithMessage:NSLocalizedString(@"email_incorrect", nil)];
        [_txt_email bs_showError];
        canSignup = NO;
    } else {
        [_txt_email bs_hideError];
    }
    
    if (![_txt_confirm_email.text isEqualToString:_txt_email.text]) {
        [_txt_confirm_email bs_setupErrorMessageViewWithMessage:NSLocalizedString(@"email_not_match", nil)];
        [_txt_confirm_email bs_showError];
        canSignup = NO;
    } else {
        [_txt_confirm_email bs_hideError];
    }
    
    if (_txt_password.text.length < 8) {
        [_txt_password bs_setupErrorMessageViewWithMessage:NSLocalizedString(@"character_require", nil)];
        [_txt_password bs_showError];
        canSignup = NO;
    } else {
        [_txt_password bs_hideError];
    }
    
    if (![_txt_confirm_password.text isEqualToString:_txt_password.text]) {
        [_txt_confirm_password bs_setupErrorMessageViewWithMessage:NSLocalizedString(@"password_not_match", nil)];
        [_txt_confirm_password bs_showError];
        canSignup = NO;
    } else {
        [_txt_confirm_password bs_hideError];
    }
    
    if (!self.internetActive) {
        NSLog(@"The internet is down. Please check your internet connection");
        [self showMessageError:NSLocalizedString(@"internet_error", nil)];
        return;
    }
    
    if (!self.hostActive) {
        NSLog(@"A gateway to the host server is down.");
        [self showMessageError:NSLocalizedString(@"gateway_error", nil)];
        return;
    }
    
    if (canSignup) {
        [self sendRequest:self];
    }
}

- (BOOL)checkRequireField:(UITextField *)_textField{
    if (_textField.text.length == 0) {
        [_textField bs_setupErrorMessageViewWithMessage:NSLocalizedString(@"required", nil)];
        [_textField bs_showError];
        return NO;
    }
    else{
        [_textField bs_hideError];
        return YES;
    }
}

- (void)sendRequest:(id)sender
{
    // Form URL-Encoded Body
    NSArray *gyoushuList = @[NSLocalizedString(@"owner", nil), NSLocalizedString(@"goverment", nil), NSLocalizedString(@"designer", nil), NSLocalizedString(@"construction", nil), NSLocalizedString(@"plastering", nil), NSLocalizedString(@"paint", nil), NSLocalizedString(@"waterproofing", nil), NSLocalizedString(@"sale_outlet", nil), NSLocalizedString(@"manufacturer", nil), NSLocalizedString(@"other", nil)];
    int index = 0;
    NSString *gyoushuName = _checkbox_businessname.selectedButton ? _checkbox_businessname.selectedButton.selectedButton.titleLabel.text : _txt_businessname.text;
    
    for (NSString *gyoushu in gyoushuList) {
        if ([gyoushu isEqualToString:gyoushuName]) {
            break;
        }
        index += 1;
    }
    if (index == 9 && _txt_businessname.text.length > 0) {
        gyoushuName = _txt_businessname.text;
    }
    NSDictionary* bodyParameters = @{
                                     @"mail": _txt_email.text,
                                     @"password": _txt_password.text,
                                     @"name_sei": _txt_surname.text,
                                     @"name_mei": _txt_name.text,
                                     @"furigana_sei": _txt_phonetic_surname.text,
                                     @"furigana_mei": _txt_phonetic_name.text,
                                     @"kaisyamei": _txt_companyname.text,
                                     @"busho": _txt_divisionname.text,
                                     @"yakushoku": _txt_title.text,
                                     @"yubin": [NSString stringWithFormat:@"%@-%@",_txt_postalcode_field1.text,_txt_postalcode_field2.text],
                                     @"address": _txt_streetaddress.text,
                                     @"tatemono": _txt_buildingname.text,
                                     @"tel": [NSString stringWithFormat:@"%@-%@-%@",_txt_phone_field1.text,_txt_phone_field2.text,_txt_phone_field3.text],
                                     @"fax": [NSString stringWithFormat:@"%@-%@-%@",_txt_fax_field1.text,_txt_fax_field2.text,_txt_fax_field3.text],
                                     @"gyoushu": [NSString stringWithFormat:@"%d",index],
                                     @"gyoushu_sonota": gyoushuName,
                                     @"send_mail": _checkbox_sendmail.selected ? @"1" : @"0",
                                     };
    if (_isUpdateAccount) {
        int userid = (int)[[NSUserDefaults standardUserDefaults] integerForKey:kUserID];
        [self sendPutInfoRequest:userid withParameter:bodyParameters];
    } else {
        ConfirmSignupViewController *confirmSignupController = [[ConfirmSignupViewController alloc] initWithSignUpParameter:bodyParameters];
        [self.navigationController pushFadeViewController:confirmSignupController];
    }
}

- (void)showHUD{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Loading...";
    HUD.dimBackground = YES;
    [HUD show:YES];
}

- (void)showMessageError:(NSString *)_message{
    if (IS_OS_8_OR_LATER) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:_message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
        });
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:_message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
            [alert show];
        });
    }
}

- (void)fillUserData: (UserResponse *)_data {
    _txt_email.text = _data.mail;
    _txt_confirm_email.text = _data.mail;
    _txt_password.text = _data.password;
    _txt_confirm_password.text = _data.password;
    _txt_surname.text = _data.name_sei;
    _txt_name.text = _data.name_mei;
    _txt_phonetic_surname.text = _data.furigana_sei;
    _txt_phonetic_name.text = _data.furigana_mei;
    _txt_companyname.text = _data.kaisyamei;
    _txt_divisionname.text = _data.busho;
    _txt_title.text = _data.yakushoku;
    if (_data.send_mail == 1) {
        [_checkbox_sendmail setSelected:YES];
    } else {
//        [_checkbox_sendmail setSelected:NO];
    }
    NSArray *postalcodes = [_data.yubin componentsSeparatedByString:@"-"];
    if (postalcodes.count > 1) {
        _txt_postalcode_field1.text = postalcodes[0];
        _txt_postalcode_field2.text = postalcodes[1];
    }
    _txt_streetaddress.text = _data.address;
    _txt_buildingname.text = _data.tatemono;
    NSArray *tels = [_data.tel componentsSeparatedByString:@"-"];
    if (tels.count > 2) {
        _txt_phone_field1.text = tels[0];
        _txt_phone_field2.text = tels[1];
        _txt_phone_field3.text = tels[2];
    }
    NSArray *faxs = [_data.fax componentsSeparatedByString:@"-"];
    if (tels.count > 2) {
        _txt_fax_field1.text = faxs[0];
        _txt_fax_field2.text = faxs[1];
        _txt_fax_field3.text = faxs[2];
    }
    NSArray *gyoushuList = @[NSLocalizedString(@"owner", nil), NSLocalizedString(@"goverment", nil), NSLocalizedString(@"designer", nil), NSLocalizedString(@"construction", nil), NSLocalizedString(@"plastering", nil), NSLocalizedString(@"paint", nil), NSLocalizedString(@"waterproofing", nil), NSLocalizedString(@"sale_outlet", nil), NSLocalizedString(@"manufacturer", nil), NSLocalizedString(@"other", nil)];
    
    int index = _data.gyoushu;
    if (index >= 9) {
        [_opt10 setSelected:YES];
        _txt_businessname.text = _data.gyoushu_sonota;//gyoushuList[index];
    } else {
        switch (index) {
            case 0:
                [_opt1 setSelected:YES];
                break;
            case 1:
                [_opt2 setSelected:YES];
                break;
            case 2:
                [_opt3 setSelected:YES];
                break;
            case 3:
                [_opt4 setSelected:YES];
                break;
            case 4:
                [_opt5 setSelected:YES];
                break;
            case 5:
                [_opt6 setSelected:YES];
                break;
            case 6:
                [_opt7 setSelected:YES];
                break;
            case 7:
                [_opt8 setSelected:YES];
                break;
            case 8:
                [_opt9 setSelected:YES];
                break;
            case 9:
                [_opt10 setSelected:YES];
                break;
            default:
                break;
        }
//        if (_checkbox_businessname.otherButtons.count > index) {
//            [(DLRadioButton *)_checkbox_businessname.otherButtons[index] setSelected:YES];
//        }
        
    }
    
    [_checkbox_sendmail setSelected:_data.send_mail == 1 ? YES : NO];
    
}

- (void)sendGetInfoRequest:(int)_userid
{
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    NSString *languagePrefix = @"";
    if (isVN) {
        languagePrefix = @"vn";
    } else {
        languagePrefix = @"jp";
    }
    NSString *urlString = [NSString stringWithFormat:@"http://icp.suzukafine.co.jp/index.php/member/%d/%@",_userid,languagePrefix];
    NSURL* URL = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";

    [request addValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    // Form URL-Encoded Body
    [self showHUD];
    /* Start a new Task */
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hide:YES];
        });
        if (error == nil) {
            NSLog(@"URL Session Task Succeeded: HTTP %ld", (long)((NSHTTPURLResponse*)response).statusCode);
            NSString *receivedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *convertedString = [receivedString mutableCopy];
            CFStringRef transform = CFSTR("Any-Hex/Java");
            CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
            //    NSLog(@"%@",convertedString);
            JSONModelError *jsonerror;
            LoginResponseAPI *responseObj = [[LoginResponseAPI alloc] initWithString:convertedString error:&jsonerror];
            if (!jsonerror) {
                NSLog(@"%@",responseObj);
                if (responseObj.status == 1 && responseObj.data != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.titleLabel.text = NSLocalizedString(@"update_account_title", nil);
                        [self.bt_signup setTitle:NSLocalizedString(@"update_account", nil) forState:UIControlStateNormal];
                        [self fillUserData:responseObj.data];
                    });
                }
                else if (responseObj.status == 3){
                    _isUpdateAccount = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showMessageError:NSLocalizedString(@"id_error", nil)];
                    });
                }
                else{
                    _isUpdateAccount = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showMessageError:NSLocalizedString(@"login_fail", nil)];
                    });
                }
            }
        }
        else {
            _isUpdateAccount = NO;
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMessageError:NSLocalizedString(@"login_fail", nil)];
            });
        }
    }];
    [task resume];
    [session finishTasksAndInvalidate];
}

- (void)sendPutInfoRequest:(int)_userid withParameter: (NSDictionary *)_params
{
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    NSString *languagePrefix = @"";
    if (isVN) {
        languagePrefix = @"vn";
    } else {
        languagePrefix = @"jp";
    }
    NSString *urlString = [NSString stringWithFormat:@"http://icp.suzukafine.co.jp/index.php/member/%d/%@",_userid,languagePrefix];
//    NSString *urlString = [NSString stringWithFormat:@"http://icp.suzukafine.co.jp/index.php/member/%d",_userid];
    NSURL* URL = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"PUT";
    request.HTTPBody = [NSStringFromQueryParameters(_params) dataUsingEncoding:NSUTF8StringEncoding];
    [request addValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    // Form URL-Encoded Body
    [self showHUD];
    /* Start a new Task */
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hide:YES];
        });
        if (error == nil) {
            // Success
            NSLog(@"URL Session Task Succeeded: HTTP %ld", (long)((NSHTTPURLResponse*)response).statusCode);
            NSString *receivedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *convertedString = [receivedString mutableCopy];
            CFStringRef transform = CFSTR("Any-Hex/Java");
            CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
            //    NSLog(@"%@",convertedString);
            JSONModelError *jsonerror;
            LoginResponseAPI *responseObj = [[LoginResponseAPI alloc] initWithString:convertedString error:&jsonerror];
            if (!jsonerror) {
                NSLog(@"%@",responseObj);
                if (responseObj.status == 1 && responseObj.data != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationController fadePopViewController];
                    });
                } else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showMessageError:NSLocalizedString(@"update_account_error", nil)];
                    });
                }
            }
        }
        else {
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMessageError:NSLocalizedString(@"update_account_error", nil)];
            });
        }
    }];
    [task resume];
    [session finishTasksAndInvalidate];
}

static NSString* NSStringFromQueryParameters(NSDictionary* queryParameters)
{
    NSMutableArray* parts = [NSMutableArray array];
    [queryParameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *part = [NSString stringWithFormat: @"%@=%@",
            [key stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding],
            [value stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]
        ];
        [parts addObject:part];
    }];
    return [parts componentsJoinedByString: @"&"];
}

/**
 Creates a new URL by adding the given query parameters.
 @param URL The input URL.
 @param queryParameters The query parameter dictionary to add.
 @return A new NSURL.
*/
static NSURL* NSURLByAppendingQueryParameters(NSURL* URL, NSDictionary* queryParameters)
{
    NSString* URLString = [NSString stringWithFormat:@"%@?%@",
        [URL absoluteString],
        NSStringFromQueryParameters(queryParameters)
    ];
    return [NSURL URLWithString:URLString];
}
@end
