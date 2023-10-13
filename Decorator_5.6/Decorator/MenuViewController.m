//
//  MenuViewController.m
//  Decorator
//
//  Created by Hoang Le on 9/16/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "MenuViewController.h"
#import "AlbumViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "PlanViewController.h"
#import "SettingViewController.h"
#import "EditPlanViewController.h"
#import "PlanViewController.h"
//test
#import "LayoutViewController.h"
#import "UIImage+UIImage_Extensions.h"
#import <CoreLocation/CoreLocation.h>
#import "ZipArchive.h"
#import "SSZipArchive.h"
#import "ExportUtil.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import <objc/message.h>
#import "ResetAccountViewController.h"
#import "SignUpViewController.h"
#import "Reachability.h"
#import "BSErrorMessageView.h"
#import "UITextField+BSErrorMessageView.h"
#import "LoginResponseAPI.h"
#import "MBProgressHUD.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "ActivationSuccessViewController.h"

#import "PickColorViewController.h"
#import "CameraViewController.h"

@interface MenuViewController (){
    BOOL isNewMedia;
    float longitude;
    float latitude;
    NSArray *guideImages;
    
    BOOL isGoing;
    BOOL isExporting;
    Reachability* internetReachable;
    Reachability* hostReachable;
    BOOL isCorrectUserPass;
    MBProgressHUD *HUD;
    
    BOOL isNewSession;
    BOOL isVN;
}
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *myLocation;
@property (nonatomic) BOOL internetActive;
@property (nonatomic) BOOL hostActive;
@end

@implementation MenuViewController
@synthesize popoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isNewSession = YES;
    }
    return self;
}

- (NSString *)getBackgroundName:(BOOL)_isSecond {
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
            case 1334:
            case 1920:
            case 2208:
                if (_isSecond) {
                    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
                        return @"main_P_R_BG";
                    } else {
                        return @"main_BG_P_R_01";
                    }
                } else {
                    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
                        return isVN ? @"BG_P_R_01_vi.jpg" : @"BG_P_R_01.jpg";
                    } else {
                        return isVN ? @"BG_P_R_03_vi.jpg" : @"BG_P_R_03.jpg";
                    }
                }
                break;
            default:
                if (_isSecond) {
                    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
                        return @"main_P_BG";
                    } else {
                        return @"main_BG_P_01";
                    }
                } else {
                    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
                        return isVN ? @"BG_P_01_vi.jpg" : @"BG_P_01.jpg";
                    } else {
                        return isVN ? @"BG_P_03_vi.jpg" : @"BG_P_03.jpg";
                    }
                }
                break;
        }
    } else {
        if (_isSecond) {
            if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
                return @"main_BG";
            } else {
                return @"main_BG_01";
            }
        } else {
            if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
                return isVN ? @"BG_01_vi.jpg" : @"BG_01.jpg";
            } else {
                return isVN ? @"BG_03_vi.jpg" : @"BG_03.jpg";
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:[UIDevice currentDevice]];
    [self changePositionWithOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        _background.image = [UIImage imageNamed:[self getBackgroundName:NO]];
        _secondBackground.image = [UIImage imageNamed:[self getBackgroundName:YES]];
        _versionBottomConstraint.constant = 30;
    }
    else{
        _background.image = [UIImage imageNamed:[self getBackgroundName:NO]];
        _secondBackground.image = [UIImage imageNamed:[self getBackgroundName:YES]];
        _versionBottomConstraint.constant = 100;
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _background.alpha = 1;
        _secondBackground.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"IS_SIGNIN"] || ![[NSUserDefaults standardUserDefaults] boolForKey:@"IS_TRIAL_ACCOUNT"]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
        
        internetReachable = [Reachability reachabilityForInternetConnection];
        [internetReachable startNotifier];
        
        // check if a pathway to a random host exists
        hostReachable = [Reachability reachabilityWithHostName:@"icp.suzukafine.co.jp"];
        [hostReachable startNotifier];
    }
}

- (void)orientationChanged:(NSNotification *)notification{
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _bt1.alpha = 0;
        _bt2.alpha = 0;
        _bt3.alpha = 0;
        _bt4.alpha = 0;
        _bt5.alpha = 0;
        _background.alpha = 0.4;
        _secondBackground.alpha = 0.4;
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            _portraitView.alpha = 0;
        }
    } completion:^(BOOL finished) {
        isGoing = YES;
    }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _bt1.alpha = 0;
        _bt2.alpha = 0;
        _bt3.alpha = 0;
        _bt4.alpha = 0;
        _bt5.alpha = 0;
        _background.alpha = 0.4;
        _secondBackground.alpha = 0.4;
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            _portraitView.alpha = 0;
        }
    } completion:^(BOOL finished) {
    }];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self changePositionWithOrientation:toInterfaceOrientation];
}

- (void)changePositionWithOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        _background.image = [UIImage imageNamed:[self getBackgroundName:NO]];
        _secondBackground.image = [UIImage imageNamed:[self getBackgroundName:YES]];
        _versionBottomConstraint.constant = 30;
    }
    else{
        _background.image = [UIImage imageNamed:[self getBackgroundName:NO]];
        _secondBackground.image = [UIImage imageNamed:[self getBackgroundName:YES]];
        _versionBottomConstraint.constant = 100;
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _background.alpha = 1;
        _secondBackground.alpha = 1;
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad &&  UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            _portraitView.alpha = 1;
        } else {
            _bt1.alpha = 1;
            _bt2.alpha = 1;
            _bt3.alpha = 1;
            _bt4.alpha = 1;
            _bt5.alpha = 1;
        }
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _bt1.alpha = 0;
        _bt2.alpha = 0;
        _bt3.alpha = 0;
        _bt4.alpha = 0;
        _bt5.alpha = 0;
        _background.alpha = 0.4;
        _secondBackground.alpha = 0.4;
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            _portraitView.alpha = 0;
        }
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

- (void)viewDidLoad
{
    [super viewDidLoad];
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = (id)self;
        _locationManager.distanceFilter = 100;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [self settxtAutosave:[self getAutosavetime]];
    _txt_username_display.text   = [SettingViewController getUserName];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
        [_locationManager startUpdatingLocation];
    
//    [self checkTrialDayLeft];
    NSArray *language = [NSLocale preferredLanguages];
    if (language.count > 0) {
        NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:language.firstObject];
        NSString *languageCode = [languageDic objectForKey:@"kCFLocaleLanguageCodeKey"];
        if ([languageCode isEqualToString:@"vi"]) {
            isVN = YES;
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                guideImages = [NSArray arrayWithObjects:@"Manual(iPhone)1_v-pichi",@"Manual(iPhone)2_v-pichi",@"Manual(iPhone)3_v-pichi",@"Manual(iPhone)4_v-pichi",@"Manual(iPhone)5_v-pichi",@"Manual(iPhone)6_v-pichi",@"Manual(iPhone)7_v-pichi", nil];
            } else {
                guideImages = [NSArray arrayWithObjects:@"Manual(iPad)1_v-pichi",@"Manual(iPad)2_v-pichi",@"Manual(iPad)3_v-pichi",@"Manual(iPad)4_v-pichi",@"Manual(iPad)5_v-pichi",@"Manual(iPad)6_v-pichi",@"Manual(iPad)7_v-pichi", nil];
            }
        } else {
            isVN = NO;
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                guideImages = [NSArray arrayWithObjects:@"Manual(iPhone)1-pichi",@"Manual(iPhone)2-pichi",@"Manual(iPhone)3-pichi",@"Manual(iPhone)4-pichi",@"Manual(iPhone)5-pichi",@"Manual(iPhone)6-pichi",@"Manual(iPhone)7-pichi", nil];
            } else {
                guideImages = [NSArray arrayWithObjects:@"Manual(iPad)1-pichi",@"Manual(iPad)2-pichi",@"Manual(iPad)3-pichi",@"Manual(iPad)4-pichi",@"Manual(iPad)5-pichi",@"Manual(iPad)6-pichi",@"Manual(iPad)7-pichi", nil];
            }
//            guideImages = [NSArray arrayWithObjects:@"i color paint取り扱い説明書 ver211",@"i color paint取り扱い説明書 ver212",@"i color paint取り扱い説明書 ver213",@"i color paint取り扱い説明書 ver214",@"i color paint取り扱い説明書 ver215",@"i color paint取り扱い説明書 ver216", nil];
        }
    } else {
        isVN = NO;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            guideImages = [NSArray arrayWithObjects:@"Manual(iPhone)1-pichi",@"Manual(iPhone)2-pichi",@"Manual(iPhone)3-pichi",@"Manual(iPhone)4-pichi",@"Manual(iPhone)5-pichi",@"Manual(iPhone)6-pichi",@"Manual(iPhone)7-pichi", nil];
        } else {
            guideImages = [NSArray arrayWithObjects:@"Manual(iPad)1-pichi",@"Manual(iPad)2-pichi",@"Manual(iPad)3-pichi",@"Manual(iPad)4-pichi",@"Manual(iPad)5-pichi",@"Manual(iPad)6-pichi",@"Manual(iPad)7-pichi", nil];
        }
//        guideImages = [NSArray arrayWithObjects:@"i color paint取り扱い説明書 ver211",@"i color paint取り扱い説明書 ver212",@"i color paint取り扱い説明書 ver213",@"i color paint取り扱い説明書 ver214",@"i color paint取り扱い説明書 ver215",@"i color paint取り扱い説明書 ver216", nil];
    }
}

- (int)getAutosavetime{
    int autosaveTime = [(NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:kAutosaveTime] intValue];
    if (autosaveTime == 0) {
        autosaveTime = 10;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:10] forKey:kAutosaveTime];
    }
    return autosaveTime;
}

- (void)settxtAutosave:(int)time{
    switch (time) {
        case 10:
            _txt_autosaveTime.text = NSLocalizedString(@"10second", nil);
            break;
        case 30:
            _txt_autosaveTime.text = NSLocalizedString(@"30second", nil);
            break;
        case 60:
            _txt_autosaveTime.text = NSLocalizedString(@"1minute", nil);
            break;
        case 120:
            _txt_autosaveTime.text = NSLocalizedString(@"2minute", nil);
            break;
        default:
            break;
    }
}

- (void)checkTrialDayLeft{
    NSDate *startDate;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"TRIAL_START_DATE"]) {
        startDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"TRIAL_START_DATE"];
    }
    else{
        startDate = [NSDate date];
    }
    int dayLeft = 30 - (int)[self daysBetweenDate:startDate andDate:[NSDate date]];
    _lb_dayleft.text = [NSString stringWithFormat:@"%d%@",dayLeft, NSLocalizedString(@"totalday", nil)];
    
    if (([[NSUserDefaults standardUserDefaults] boolForKey:@"OpenToLogin"] || isNewSession) && ![[NSUserDefaults standardUserDefaults] boolForKey:@"IS_SIGNIN"]) {
        if (isNewSession) {
            isNewSession = NO;
        }
        else
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"OpenToLogin"];
        _signinView.hidden = NO;
        _signinView.layer.cornerRadius = 25.0f;
        _bt_signin.layer.cornerRadius = 5.0f;
        _bt_laterSignin.layer.cornerRadius = 5.0f;
        _bt_signup.layer.cornerRadius = 5.0f;
        _bt1.hidden = YES;
        _bt2.hidden = YES;
        _bt3.hidden = YES;
        _bt4.hidden = YES;
        _bt5.hidden = YES;
        _portraitView.hidden = YES;
        
        _view1.hidden = YES;
        _view2.hidden = YES;
        [self.txt_username bs_setupErrorMessageViewWithMessage:NSLocalizedString(@"required", nil)];
        self.txt_username.errorMessageView.messageDefaultHidden = NO;
        [self.txt_password bs_setupErrorMessageViewWithMessage:NSLocalizedString(@"required", nil)];
        self.txt_password.errorMessageView.messageDefaultHidden = NO;
        return;
    }
    
    if ((dayLeft <= 0 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"IS_SIGNIN"])) {
        [self showMessageError:NSLocalizedString(@"expired_error_msg", nil)];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"IS_SIGNIN"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"IS_TRIAL_ACCOUNT"];
        
        _signinView.hidden = NO;
        _signinView.layer.cornerRadius = 25.0f;
        _bt_signin.layer.cornerRadius = 5.0f;
        _bt_laterSignin.layer.cornerRadius = 5.0f;
        _bt_signup.layer.cornerRadius = 5.0f;
        _bt1.hidden = YES;
        _bt2.hidden = YES;
        _bt3.hidden = YES;
        _bt4.hidden = YES;
        _bt5.hidden = YES;
        _portraitView.hidden = YES;
        
        _view1.hidden = YES;
        _view2.hidden = YES;
        [self.txt_username bs_setupErrorMessageViewWithMessage:NSLocalizedString(@"required", nil)];
        self.txt_username.errorMessageView.messageDefaultHidden = NO;
        [self.txt_password bs_setupErrorMessageViewWithMessage:NSLocalizedString(@"required", nil)];
        self.txt_password.errorMessageView.messageDefaultHidden = NO;
        return;
    }
    else{
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"IS_SIGNIN"] || ([[NSUserDefaults standardUserDefaults] boolForKey:@"IS_TRIAL_ACCOUNT"])) {
        _signinView.hidden = YES;
        _portraitView.hidden = NO;
        _bt1.hidden = NO;
        _bt2.hidden = NO;
        _bt3.hidden = NO;
        _bt4.hidden = NO;
        _bt5.hidden = NO;
        _view1.hidden = NO;
        _view2.hidden = NO;
        
        _view1.layer.cornerRadius = 10.0f;
        _view2.layer.cornerRadius = 10.0f;
//        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"IS_SIGNIN"]) {
//            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"IS_TRIAL_ACCOUNT"];
//        }
    }
    else{
        _signinView.hidden = NO;
        _signinView.layer.cornerRadius = 25.0f;
        _bt_signin.layer.cornerRadius = 5.0f;
        _bt_laterSignin.layer.cornerRadius = 5.0f;
        _bt_signup.layer.cornerRadius = 5.0f;
        _bt1.hidden = YES;
        _bt2.hidden = YES;
        _bt3.hidden = YES;
        _bt4.hidden = YES;
        _bt5.hidden = YES;
        _portraitView.hidden = YES;
        
        _view1.hidden = YES;
        _view2.hidden = YES;
        [self.txt_username bs_setupErrorMessageViewWithMessage:NSLocalizedString(@"required", nil)];
        self.txt_username.errorMessageView.messageDefaultHidden = NO;
        [self.txt_password bs_setupErrorMessageViewWithMessage:NSLocalizedString(@"required", nil)];
        self.txt_password.errorMessageView.messageDefaultHidden = NO;
    }
}

- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    return [difference day];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            NSLog(@"%d", [[UIDevice currentDevice] orientation]);
            int (*action)(id, SEL, int) = (int (*)(id, SEL, int)) objc_msgSend;
            action([UIDevice currentDevice], @selector(setOrientation:),[[UIDevice currentDevice] orientation]);
        }
    isGoing = NO;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad && UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            _portraitView.alpha = 1;
            _bt1.alpha = 0;
            _bt2.alpha = 0;
            _bt3.alpha = 0;
            _bt4.alpha = 0;
            _bt5.alpha = 0;
        } else {
            _portraitView.alpha = 0;
            _bt1.alpha = 1;
            _bt2.alpha = 1;
            _bt3.alpha = 1;
            _bt4.alpha = 1;
            _bt5.alpha = 1;
        }
    } completion:^(BOOL finished) {
        
    }];
    [self checkTrialDayLeft];
}


- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation{
    _myLocation = newLocation;
    longitude = newLocation.coordinate.longitude;
    latitude = newLocation.coordinate.latitude;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)showAlbumViewController:(id)sender {
    if (isGoing) {
        return;
    }
    isGoing = YES;
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    AlbumViewController *albumViewController = [[AlbumViewController alloc] init];
    [self.navigationController pushFadeViewController:albumViewController];
}

- (IBAction)showCameraViewController:(id)sender {
    if (isGoing) {
        return;
    }
    isGoing = YES;
    CameraViewController *cameraVC = [[CameraViewController alloc] initWithNibName:@"CameraViewController" bundle:nil];
    cameraVC.modalPresentationStyle = UIModalPresentationFullScreen;
    cameraVC.delegate = (id)self;
//    [self presentViewController:cameraVC animated:YES completion:nil];
    [self.navigationController pushFadeViewController:cameraVC];
    
    
//    PickColorViewController *pickColorVC = [[PickColorViewController alloc] initWithNibName:@"PickColorViewController" bundle:nil];
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:pickColorVC];
//    navController.navigationBarHidden = YES;
//    navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
//    pickColorVC.currentImage = [UIImage imageNamed:@"BG_01.jpg"];
//    [self presentViewController:navController animated:YES completion:nil];
}

- (void)cameraDidCaptureImage:(UIImage *)_image andMetadata:(NSDictionary *)_metadata {
//    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.navigationController popViewControllerAnimated:YES];
    isGoing = NO;
    _previewView.hidden = NO;
    
    _img_preview.image = _image;
    NSMutableDictionary * imageMetadata = [_metadata mutableCopy];
    if (_myLocation) {
        [imageMetadata setObject:[self gpsDictionaryForLocation:_myLocation] forKey:(NSString*)kCGImagePropertyGPSDictionary];
    }
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // create a completion block for when we process the image
    ALAssetsLibraryWriteImageCompletionBlock imageWriteCompletionBlock =
    ^(NSURL *newURL, NSError *error) {
        if (error) {
            NSLog( @"Error writing image with metadata to Photo Library: %@", error );
        } else {
            NSLog( @"Wrote image %@ with metadata %@ to Photo Library",newURL,imageMetadata);
        }
    };
    [library writeImageToSavedPhotosAlbum:[_image CGImage]
                                 metadata:imageMetadata
                          completionBlock:imageWriteCompletionBlock];
}

- (NSDictionary *) gpsDictionaryForLocation:(CLLocation *)location
{
    CLLocationDegrees exifLatitude  = location.coordinate.latitude;
    CLLocationDegrees exifLongitude = location.coordinate.longitude;
    
    NSString * latRef;
    NSString * longRef;
    if (exifLatitude < 0.0) {
        exifLatitude = exifLatitude * -1.0f;
        latRef = @"S";
    } else {
        latRef = @"N";
    }
    
    if (exifLongitude < 0.0) {
        exifLongitude = exifLongitude * -1.0f;
        longRef = @"W";
    } else {
        longRef = @"E";
    }
    
    NSMutableDictionary *locDict = [[NSMutableDictionary alloc] init];
    
    // requires ImageIO
    [locDict setObject:location.timestamp forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
    [locDict setObject:latRef forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    [locDict setObject:[NSNumber numberWithFloat:exifLatitude] forKey:(NSString *)kCGImagePropertyGPSLatitude];
    [locDict setObject:longRef forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    [locDict setObject:[NSNumber numberWithFloat:exifLongitude] forKey:(NSString *)kCGImagePropertyGPSLongitude];
    [locDict setObject:[NSNumber numberWithFloat:location.horizontalAccuracy] forKey:(NSString*)kCGImagePropertyGPSDOP];
    [locDict setObject:[NSNumber numberWithFloat:location.altitude] forKey:(NSString*)kCGImagePropertyGPSAltitude];
    
    return locDict;
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    isGoing = NO;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)showReferenceViewController:(id)sender {
}


- (IBAction)showSetingViewController:(id)sender {
    if (isGoing) {
        return;
    }
    isGoing = YES;
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
//    SettingViewController *settingController = [[SettingViewController alloc] init];
//    [self.navigationController pushFadeViewController:settingController];
    SignUpViewController *signupViewController = [[SignUpViewController alloc] init];
    signupViewController.isUpdateAccount = YES;
    [self.navigationController pushFadeViewController:signupViewController];
}

- (IBAction)showEditPlanViewController:(id)sender {
    if (isGoing) {
        return;
    }
    isGoing = YES;
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    EditPlanViewController *editPlanController = [[EditPlanViewController alloc] init];
    [self.navigationController pushFadeViewController:editPlanController];
}

- (IBAction)showCatalog:(id)sender {
    if (isGoing) {
        return;
    }
    isGoing = YES;
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:(id)self isShowBackground:YES];
    browser.displayActionButton = NO;
    browser.wantsFullScreenLayout = YES;
    [browser setInitialPageIndex:0];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController pushFadeViewController:browser];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return [guideImages count];
}
- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    NSString *guide = [guideImages objectAtIndex:index];
    MWPhoto *photo = [[MWPhoto alloc] initWithImage:[UIImage imageNamed:guide]];
    return photo;
}

- (void)cancelPhotoBrowser{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController fadePopViewController];
}


- (IBAction)retakePicture:(id)sender {
    _previewView.hidden = YES;
    
    [self showCameraViewController:sender];
}

- (IBAction)gotoPlan:(id)sender {
    _previewView.hidden = YES;
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    UIInterfaceOrientation layoutOrientation;
    if (_img_preview.image.size.height > _img_preview.image.size.width) {
        layoutOrientation = UIInterfaceOrientationPortrait;
    }
    else
        layoutOrientation = UIInterfaceOrientationLandscapeLeft;
    if (UIInterfaceOrientationIsLandscape(layoutOrientation) == UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        layoutOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    }
    PlanViewController *planController = [[PlanViewController alloc] initWithImage:[self fixImageOrientation:_img_preview.image withOrientation:_img_preview.image.imageOrientation] withResizeImage:NO andImageOrientation:_img_preview.image.imageOrientation andLongitude:longitude andLatitude:latitude andLayoutOrientation:layoutOrientation];
    [self.navigationController pushFadeViewController:planController];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


- (UIImage *)fixImageOrientation:(UIImage *)originalImg withOrientation:(UIImageOrientation)orientation{
    float radian;
    switch (orientation) {
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            return originalImg;
            break;
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            radian = M_PI;
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:{
            radian = 3.0 * M_PI / 2.0;
            originalImg = [originalImg imageRotatedByRadians:radian];
            originalImg = [originalImg imageByScalingToSize:CGSizeMake(originalImg.size.height, originalImg.size.width)];
            return originalImg;
        }
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:{
            radian = M_PI / 2.0;
            originalImg = [originalImg imageRotatedByRadians:radian];
            originalImg = [originalImg imageByScalingToSize:CGSizeMake(originalImg.size.height, originalImg.size.width)];
            return originalImg;
        }
            break;
        default:
            break;
    }
    return [originalImg imageRotatedByRadians:radian];
}

- (UIImage *)imageByRotatingImage:(UIImage*)initImage fromImageOrientation:(UIImageOrientation)orientation
{
    CGImageRef imgRef = initImage.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = orientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            return initImage;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    // Create the bitmap context
    CGContextRef    context = NULL;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (bounds.size.width * 4);
    bitmapByteCount     = (bitmapBytesPerRow * bounds.size.height);
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        return nil;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    CGColorSpaceRef colorspace = CGImageGetColorSpace(imgRef);
    context = CGBitmapContextCreate (bitmapData,bounds.size.width,bounds.size.height,8,bitmapBytesPerRow,
                                     colorspace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorspace);
    
    if (context == NULL)
        // error creating context
        return nil;
    
    CGContextScaleCTM(context, -1.0, -1.0);
    CGContextTranslateCTM(context, -bounds.size.width, -bounds.size.height);
    
    CGContextConcatCTM(context, transform);
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(context, CGRectMake(0,0,width, height), imgRef);
    
    CGImageRef imgRef2 = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    free(bitmapData);
    UIImage * image = [UIImage imageWithCGImage:imgRef2 scale:initImage.scale orientation:UIImageOrientationUp];
    CGImageRelease(imgRef2);
    return image;
}

- (void)handleOpenURL:(NSURL *)url {
    [self.navigationController fadePopRootViewController];
    isExporting = YES;
    ExportUtil *exportManager = [[ExportUtil alloc] init];
    if ([exportManager importFromURL:url]) {
       
    }
}

- (void)openActivation:(NSURL *)url{
    if ([[url query] isEqualToString:@"login=true"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"OpenToLogin"]) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"OpenToLogin"];
            _signinView.hidden = NO;
            _signinView.layer.cornerRadius = 25.0f;
            _bt_signin.layer.cornerRadius = 5.0f;
            _bt_laterSignin.layer.cornerRadius = 5.0f;
            _bt_signup.layer.cornerRadius = 5.0f;
            _bt1.hidden = YES;
            _bt2.hidden = YES;
            _bt3.hidden = YES;
            _bt4.hidden = YES;
            _bt5.hidden = YES;
            _view1.hidden = YES;
            _view2.hidden = YES;
            [self.txt_username bs_setupErrorMessageViewWithMessage:NSLocalizedString(@"required", nil)];
            self.txt_username.errorMessageView.messageDefaultHidden = NO;
            [self.txt_password bs_setupErrorMessageViewWithMessage:NSLocalizedString(@"required", nil)];
            self.txt_password.errorMessageView.messageDefaultHidden = NO;
            return;
        }
        return;
    }
    NSArray *queries = [[url query] componentsSeparatedByString:@"&"];
    if (queries.count != 3) {
        return;
    }
    [self.navigationController fadePopRootViewController];
    NSString *activationCode = [queries[0] componentsSeparatedByString:@"="][1];
    NSString *email = [queries[1] componentsSeparatedByString:@"="][1];
    NSString *password = [queries[2] componentsSeparatedByString:@"="][1];
    ActivationSuccessViewController *activationController = [[ActivationSuccessViewController alloc] initWithActivationCode:activationCode andUserEmail:email password:password];
    activationController.delegate = (id)self;
    [self.navigationController pushFadeViewController:activationController];
}

- (void)activationSuccess:(NSString *)_username password:(NSString *)_password{
    [self.navigationController fadePopRootViewController];
    _txt_username.text = _username;
    _txt_password.text = _password;
}

- (IBAction)resetAccount:(id)sender {
    if (isGoing) {
        return;
    }
    isGoing = YES;
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    ResetAccountViewController *resetViewController = [[ResetAccountViewController alloc] init];
    [self.navigationController pushFadeViewController:resetViewController];
}

- (IBAction)signupAccount:(id)sender {
    if (isGoing) {
        return;
    }
    isGoing = YES;
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    SignUpViewController *signupViewController = [[SignUpViewController alloc] init];
    [self.navigationController pushFadeViewController:signupViewController];
}

- (IBAction)actionSignupLater:(id)sender {
    NSDate *startDate;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"TRIAL_START_DATE"]) {
        startDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"TRIAL_START_DATE"];
    }
    else{
        startDate = [NSDate date];
        [[NSUserDefaults standardUserDefaults] setObject:startDate forKey:@"TRIAL_START_DATE"];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IS_TRIAL_ACCOUNT"];
    [self checkTrialDayLeft];
}

- (IBAction)actionSignIn:(id)sender {
    if (!self.internetActive) {
        [self showMessageError:NSLocalizedString(@"internet_error", nil)];
        return;
    }
    if (!self.hostActive) {
        [self showMessageError:NSLocalizedString(@"gateway_error", nil)];
        return;
    }
    if (self.txt_username.text.length == 0) {
        [self.txt_username bs_showError];
        if (self.txt_password.text.length == 0) {
            [self.txt_password bs_showError];
        }
        return;
    }
    else{
        if (self.txt_password.text.length == 0) {
            [self.txt_password bs_showError];
            return;
        }
        [_txt_username resignFirstResponder];
        [_txt_password resignFirstResponder];
        [self sendRequest:self];
    }
    
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

#pragma mark -
#pragma mark TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == _txt_autosaveTime) {
        UIActionSheet *actionSheet;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"title_autosave", nil) delegate:(id)self cancelButtonTitle:NSLocalizedString(@"back", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"10secondf", nil),NSLocalizedString(@"30secondf", nil),NSLocalizedString(@"1minutef", nil),NSLocalizedString(@"2minutef", nil), nil];
        } else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"title_autosave", nil) delegate:(id)self cancelButtonTitle:@"" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"10secondf", nil),NSLocalizedString(@"30secondf", nil),NSLocalizedString(@"1minutef", nil),NSLocalizedString(@"2minutef", nil), nil];
        }
        [actionSheet showInView:self.view];
        return false;
    }
    if (textField == _txt_username_display) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad &&  UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
                _portraitView.alpha = 0;
            } else {
                _bt1.alpha = 0;
                _bt2.alpha = 0;
                _bt3.alpha = 0;
                _bt4.alpha = 0;
                _bt5.alpha = 0;
            }
        } completion:^(BOOL finished) {
            
        }];
    }
    return true;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [[NSUserDefaults standardUserDefaults] setValue:_txt_username_display.text
                                             forKey:kUserName];
    if (textField == _txt_username_display) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad &&  UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
                _portraitView.alpha = 1;
            } else {
                _bt1.alpha = 1;
                _bt2.alpha = 1;
                _bt3.alpha = 1;
                _bt4.alpha = 1;
                _bt5.alpha = 1;
            }
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _txt_username_display) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (void) _showLockPass{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"passcode", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"continue", nil) otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    alert.tag = 101;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 101) {
        if ([[alertView textFieldAtIndex:0].text isEqualToString:[SettingViewController getLoginUserName]] &&
            [[alertView textFieldAtIndex:1].text isEqualToString:[SettingViewController getUserPassword]]) {
            [self _lockPasswordToEditTextField];
            isCorrectUserPass = YES;
            [_txt_username_display becomeFirstResponder];
        }
        else{
            [self showMessageError:NSLocalizedString(@"input_error", nil)];
        }
    }
}

- (void) _lockPasswordToEditTextField{
    [self _setLockPassword:true];
}

- (void) _setLockPassword:(BOOL)value{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:kLockPassword];
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
            txtValue = NSLocalizedString(@"10second", nil);
            break;
        case 1:
            autosaveValue = 30;
            txtValue = NSLocalizedString(@"30second", nil);
            break;
        case 2:
            autosaveValue = 60;
            txtValue = NSLocalizedString(@"1minute", nil);
            break;
        case 3:
            autosaveValue = 120;
            txtValue = NSLocalizedString(@"2minute", nil);
            break;
        default:
            autosaveValue = 10;
            txtValue = NSLocalizedString(@"10second", nil);
            break;
    }
    [self setAutosavetime:[NSNumber numberWithInt:autosaveValue]];
    _txt_autosaveTime.text = txtValue;
}

#pragma mark - Login request

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
     My API (POST http://icp.suzukafine.co.jp/index.php/member/login)
     */
    
    NSURL* URL = [NSURL URLWithString:@"http://icp.suzukafine.co.jp/index.php/member/login"];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    
    // Headers
    
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    // Form URL-Encoded Body
    
    NSDictionary* bodyParameters = @{
                                     @"mail": _txt_username.text,
                                     @"password": _txt_password.text,
                                     };
    request.HTTPBody = [NSStringFromQueryParameters(bodyParameters) dataUsingEncoding:NSUTF8StringEncoding];
    
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
                if (responseObj.status == 1) {
                    [[NSUserDefaults standardUserDefaults] setInteger:responseObj.data.userID forKey:kUserID];
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IS_SIGNIN"];
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IS_TRIAL_ACCOUNT"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self checkTrialDayLeft];
                    });
                }
                else if (responseObj.status == 3){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showMessageError:NSLocalizedString(@"id_error", nil)];
                    });
                }
                else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showMessageError:NSLocalizedString(@"login_fail", nil)];
                    });
                }
            }
        }
        else {
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMessageError:NSLocalizedString(@"login_fail", nil)];
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

- (void)showHUD{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Loading...";
    HUD.dimBackground = YES;
    [HUD show:YES];
}
@end
