//
//  ActivationSuccessViewController.m
//  Decorator
//
//  Created by Le Hoang on 6/6/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import "ActivationSuccessViewController.h"
#import <objc/message.h>
#import "MBProgressHUD.h"
@interface ActivationSuccessViewController (){
    NSString *activationCode;
    NSString *userEmail;
    NSString *password;
    MBProgressHUD *HUD;
    BOOL isActivationSuccess;
}

@end

@implementation ActivationSuccessViewController

- (id)initWithActivationCode:(NSString *)_activationCode andUserEmail:(NSString *)_email password:(NSString *)_password{
    self = [super initWithNibName:@"ActivationSuccessViewController" bundle:nil];
    if (self) {
        activationCode = _activationCode;
        userEmail = _email;
        password = _password;
    }
    return self;
}

- (void)showHUD{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.dimBackground = YES;
    HUD.delegate = (id)self;
    [HUD show:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _bt_back.layer.cornerRadius = 10.0f;
    _lb_userID.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"id_login", nil),userEmail];
    [self sendRequest:self];
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
}

- (IBAction)backToLogin:(id)sender {
//    [self.navigationController fadePopRootViewController];
    [_delegate activationSuccess:userEmail password:password];
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
     ACTIVATE ACCOUNT (GET http://icp.suzukafine.co.jp/index.php/member/activate-account/)
     */
    
    NSURL* URL = [NSURL URLWithString:[@"http://icp.suzukafine.co.jp/index.php/member/activate-account/" stringByAppendingPathComponent:activationCode]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    
    // Headers
    
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    // Form URL-Encoded Body
    
    NSDictionary* bodyParameters = @{
                                     };
    request.HTTPBody = [NSStringFromQueryParameters(bodyParameters) dataUsingEncoding:NSUTF8StringEncoding];
    
    [self showHUD];
    /* Start a new Task */
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
            });
            // Success
            NSLog(@"URL Session Task Succeeded: HTTP %d", (int)((NSHTTPURLResponse*)response).statusCode);
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if ([[responseDict objectForKey:@"status"] intValue] == 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IS_SIGNIN"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IS_TRIAL_ACCOUNT"];
//                    [self.navigationController fadePopRootViewController];
//                    [_delegate activationSuccess:userEmail password:password];
                    isActivationSuccess = YES;
                    
                });
            }
            else if ([[responseDict objectForKey:@"status"] intValue] == 3){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController fadePopRootViewController];
                    isActivationSuccess = NO;
                    [self showMessageError:NSLocalizedString(@"activation_expired", nil)];
                });
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController fadePopRootViewController];
                    isActivationSuccess = NO;
                    [self showMessageError:NSLocalizedString(@"cannot_register", nil)];
                });
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hide:YES];
                // Failure
                NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
                isActivationSuccess = NO;
                [self.navigationController fadePopRootViewController];
                [self showMessageError:NSLocalizedString(@"cannot_register", nil)];
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
@end
