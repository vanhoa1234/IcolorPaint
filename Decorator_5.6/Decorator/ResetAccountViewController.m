//
//  ResetAccountViewController.m
//  Decorator
//
//  Created by Le Hoang on 2/24/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import "ResetAccountViewController.h"
#import <objc/message.h>
#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"
#import "LoginResponseAPI.h"
#import "MBProgressHUD.h"

@interface ResetAccountViewController (){
    Reachability* internetReachable;
    Reachability* hostReachable;
    MBProgressHUD *HUD;
}
@property (nonatomic) BOOL internetActive;
@property (nonatomic) BOOL hostActive;
@end

@implementation ResetAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.bt_sent.layer.cornerRadius =15.0f;
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
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        _background.image = [UIImage imageNamed:@"BG_02.jpg"];
    }
    else{
        _background.image = [UIImage imageNamed:@"BG_04.jpg"];
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


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _background.alpha = 0.4;
    } completion:^(BOOL finished) {
    }];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    }
    else{
        _background.image = [UIImage imageNamed:@"BG_04.jpg"];
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

- (IBAction)action_sentEmail:(id)sender {
    [_txt_email resignFirstResponder];
    if (![self validEmail:_txt_email.text]) {
        [self showMessageError:NSLocalizedString(@"input_wrong", nil)];
        return;
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
    [self sendRequest:self];
}

- (BOOL) validEmail:(NSString *)emailString {
    if([emailString length]==0){
        return NO;
    }
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    NSLog(@"%i", regExMatches);
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
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

- (void)sendRequest:(id)sender
{
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
     My API (3) (POST http://icp.suzukafine.co.jp/index.php/member/forgot-password)
     */
    
    NSURL* URL = [NSURL URLWithString:@"http://icp.suzukafine.co.jp/index.php/member/forgot-password"];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    
    // Headers
    
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    // Form URL-Encoded Body
    
    NSDictionary* bodyParameters = @{
                                     @"mail": _txt_email.text,
                                     };
    request.HTTPBody = [NSStringFromQueryParameters(bodyParameters) dataUsingEncoding:NSUTF8StringEncoding];
    
    /* Start a new Task */
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
                if (responseObj.status == 1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showMessageError:NSLocalizedString(@"email_sent", nil)];
                    });
                }
                else if (responseObj.status == 3){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showMessageError:NSLocalizedString(@"email_not_exist", nil)];
                    });
                }
                else if (responseObj.status == 4){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showMessageError:NSLocalizedString(@"email_send_error", nil)];
                    });
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showMessageError:NSLocalizedString(@"email_connection_error", nil)];
                    });
                }
            }
        }
        else {
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMessageError:NSLocalizedString(@"email_connection_error", nil)];
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
@end
