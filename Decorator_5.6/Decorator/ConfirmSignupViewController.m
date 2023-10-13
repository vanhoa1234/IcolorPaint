//
//  ConfirmSignupViewController.m
//  Decorator
//
//  Created by Le Hoang on 4/26/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import "ConfirmSignupViewController.h"
#import "MBProgressHUD.h"
#import "LoginResponseAPI.h"
#import "Reachability.h"
#import <objc/message.h>
#import "SignupSuccessViewController.h"

@interface ConfirmSignupViewController (){
    Reachability* internetReachable;
    Reachability* hostReachable;
    MBProgressHUD *HUD;
    NSDictionary *signupParameter;
}
@property (nonatomic) BOOL internetActive;
@property (nonatomic) BOOL hostActive;
@end

@implementation ConfirmSignupViewController

- (id)initWithSignUpParameter:(NSDictionary *)_parameter{
    self = [super init];
    if (self) {
        signupParameter = [[NSDictionary alloc] initWithDictionary:_parameter];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bt_confirmSignup.layer.cornerRadius = 10.0f;
    self.bt_cancelSignup.layer.cornerRadius = 10.0f;
    // Do any additional setup after loading the view from its nib.
    if (signupParameter) {
        _txt_email.text = [signupParameter objectForKey:@"mail"];
        _txt_password.text = [signupParameter objectForKey:@"password"];
        _txt_surname.text = [signupParameter objectForKey:@"name_sei"];
        _txt_name.text = [signupParameter objectForKey:@"name_mei"];
        _txt_phonetic_surname.text = [signupParameter objectForKey:@"furigana_sei"];
        _txt_phonetic_name.text = [signupParameter objectForKey:@"furigana_mei"];
        _txt_companyname.text = [signupParameter objectForKey:@"kaisyamei"];
        _txt_divisionname.text = [signupParameter objectForKey:@"busho"];
        _txt_title.text = [signupParameter objectForKey:@"yakushoku"];
        _txt_postalcode_field1.text = [[signupParameter objectForKey:@"yubin"] componentsSeparatedByString:@"-"][0];
        _txt_postalcode_field2.text = [[signupParameter objectForKey:@"yubin"] componentsSeparatedByString:@"-"][1];
        _txt_streetaddress.text = [signupParameter objectForKey:@"address"];
        _txt_buildingname.text = [signupParameter objectForKey:@"tatemono"];
        _txt_phone_field1.text = [[signupParameter objectForKey:@"tel"] componentsSeparatedByString:@"-"][0];
        _txt_phone_field2.text = [[signupParameter objectForKey:@"tel"] componentsSeparatedByString:@"-"][1];
        _txt_phone_field3.text = [[signupParameter objectForKey:@"tel"] componentsSeparatedByString:@"-"][2];
        _txt_fax_field1.text = [[signupParameter objectForKey:@"fax"] componentsSeparatedByString:@"-"][0];
        _txt_fax_field2.text = [[signupParameter objectForKey:@"fax"] componentsSeparatedByString:@"-"][1];
        _txt_fax_field3.text = [[signupParameter objectForKey:@"fax"] componentsSeparatedByString:@"-"][2];
        
        NSArray *gyoushuList = @[NSLocalizedString(@"owner", nil), NSLocalizedString(@"goverment", nil), NSLocalizedString(@"designer", nil), NSLocalizedString(@"construction", nil), NSLocalizedString(@"plastering", nil), NSLocalizedString(@"paint", nil), NSLocalizedString(@"waterproofing", nil), NSLocalizedString(@"sale_outlet", nil), NSLocalizedString(@"manufacturer", nil), NSLocalizedString(@"other", nil)];
        _txt_businessname.text = [gyoushuList objectAtIndex:[[signupParameter objectForKey:@"gyoushu"] intValue]];
        if ([_txt_businessname.text isEqualToString:NSLocalizedString(@"other", nil)]) {
            _txt_businessname.text = [signupParameter objectForKey:@"gyoushu_sonota"];
        }
        _lb_isreceivemail.text = [[signupParameter objectForKey:@"send_mail"] intValue] == 1 ? NSLocalizedString(@"receive_mail", nil) : NSLocalizedString(@"not_receive_mail", nil);
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        int (*action)(id, SEL, int) = (int (*)(id, SEL, int)) objc_msgSend;
        action([UIDevice currentDevice], @selector(setOrientation:),[[UIDevice currentDevice] orientation]);
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        _background.image = [UIImage imageNamed:@"BG_02.jpg"];
//        _scrollView.contentSize = CGSizeMake(1024, 876);
    }
    else{
        _background.image = [UIImage imageNamed:@"BG_04.jpg"];
//        _scrollView.contentSize = CGSizeMake(768, 876);
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _background.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostName:@"icp.suzukafine.co.jp"];
    [hostReachable startNotifier];
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
//        _scrollView.contentSize = CGSizeMake(1024, 876);
    }
    else{
        _background.image = [UIImage imageNamed:@"BG_04.jpg"];
//        _scrollView.contentSize = CGSizeMake(768, 876);
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

/*
 {
     address = "\U6771\U4eac\U90fd\U5343\U4ee3\U7530\U533a";
     busho = vsii;
     fax = "813-457-21731";
     "furigana_mei" = le;
     "furigana_sei" = hoang;
     gyoushu = 1;
     "gyoushu_sonota" = "VP ch\U00ednh ph\U1ee7";
     kaisyamei = vsii;
     mail = "lehoang991@gmail.com";
     "name_mei" = le;
     "name_sei" = hoang;
     password = abcd1234;
     "send_mail" = 1;
     tatemono = 111;
     tel = "813-457-20731";
     yakushoku = ceo;
     yubin = "100-0000";
 }
 
 {"status":1,"message":"Success","data":{"id":"7439","mail":"lehoang991@gmail.com","password":"abcd1234","name_sei":"giant","name_mei":"le","furigana_sei":"hoang","furigana_mei":"le","kaisyamei":"test","busho":"test","yakushoku":"test","yubin":"100-0000","address":"東京都千代田区","tatemono":"test","tel":"876-555-0987","fax":"876-555-0987","gyoushu":"0","gyoushu_sonota":"施　主","send_mail":"1","active_token":"745e180c9c0456c5dffeecc83b26d2b38faae6e0","registered_date":"2020-03-02 16:41:48","status":"0"}}
 */

- (void)sendRequest:(NSDictionary *)bodyParameters
{
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
    /* Configure session, choose between:
     * defaultSessionConfiguration
     * ephemeralSessionConfiguration
     * backgroundSessionConfigurationWithIdentifier:
     And set session-wide properties, such as: HTTPAdditionalHeaders,
     HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
     */
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    /* Create session, and optionally set a NSURLSessionDelegate. */
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    
    /* Create the Request:
     My API (2) (POST http://icp.suzukafine.co.jp/index.php/member/register)
     */
    
    NSURL* URL = [NSURL URLWithString:@"http://icp.suzukafine.co.jp/index.php/member/register"];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:bodyParameters];
    NSArray *language = [NSLocale preferredLanguages];
    if (language.count > 0) {
        NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:language.firstObject];
        NSString *languageCode = [languageDic objectForKey:@"kCFLocaleLanguageCodeKey"];
        if ([languageCode isEqualToString:@"vi"]) {
            [body setValue:@"vn" forKey:@"language"];
        } else {
            [body setValue:@"jp" forKey:@"language"];
        }
    } else {
        [body setValue:@"jp" forKey:@"language"];
    }
    request.HTTPBody = [NSStringFromQueryParameters(body) dataUsingEncoding:NSUTF8StringEncoding];
    
    [self showHUD];
    /* Start a new Task */
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD hide:YES];
        });
        if (error == nil) {
            // Success
            NSLog(@"URL Session Task Succeeded: HTTP %ld", (long)((NSHTTPURLResponse*)response).statusCode);
            // Success
            NSString *receivedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *convertedString = [receivedString mutableCopy];
            CFStringRef transform = CFSTR("Any-Hex/Java");
            CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
            //    NSLog(@"%@",convertedString);
            JSONModelError *jsonerror;
            LoginResponseAPI *responseObj = [[LoginResponseAPI alloc] initWithString:convertedString error:&jsonerror];
            if (!jsonerror) {
                NSLog(@"%@",responseObj);
                if (responseObj.status == 1) {
//                    [self showMessageError:@"申請いただきましたメールアドレス宛に仮登録完了のメールをお送りました。メールをご確認頂き、メール内のURLをクリックし、登録を完了させてください。" withTitle:@"仮登録が完了いたしました。"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SignupSuccessViewController *signupSuccessController = [[SignupSuccessViewController alloc] init];
                        [self.navigationController pushFadeViewController:signupSuccessController];
                    });
                }
                else if (responseObj.status == 3){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showMessageError:NSLocalizedString(@"email_existed", nil)];
                    });
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showMessageError:NSLocalizedString(@"cannot_register", nil)];
                    });
                }
            }
        }
        else {
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMessageError:NSLocalizedString(@"email_existed", nil)];
            });
        }
    }];
    [task resume];
}

/*
 * Utils: Add this section before your class implementation
 */

/**
 This creates a new query parameters string from the given NSDictionary. For
 example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
 string will be @"day=Tuesday&month=January".
 @param queryParameters The input dictionary.
 @return The created parameters string.
 */
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
            
            [self.navigationController presentViewController:alertController animated:YES completion:nil];
        });
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:_message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
            [alert show];
        });
    }
}

- (void)showMessageError:(NSString *)_message withTitle:(NSString *)_title{
    if (IS_OS_8_OR_LATER) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:_title message:_message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self.navigationController presentViewController:alertController animated:YES completion:nil];
        });
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_title message:_message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
            [alert show];
        });
    }
}

- (IBAction)confirmSignup:(id)sender {
    [self sendRequest:signupParameter];
//    [self sendSignupRequest:signupParameter];
}
- (IBAction)cancelSignUp:(id)sender {
    [self.navigationController fadePopViewController];
}
@end
