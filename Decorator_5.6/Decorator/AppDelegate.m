//
//  AppDelegate.m
//  Decorator
//
//  Created by Hoang Le on 9/13/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "AppDelegate.h"

#import "MenuViewController.h"
#import "SettingViewController.h"
#import "Color.h"
#import "RotatingNavigationController.h"
#import "ExportUtil.h"
#import "PlanViewController.h"
#import "LayoutViewController.h"
#import "EditImageViewController.h"
#import "PreviewModalViewController.h"
#import "ColorPickerModalViewViewController.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self initialDatabase];
    hasTopNotch = [self hasTopNotch];
    sleep(3);
//    [BugSenseController sharedControllerWithBugSenseAPIKey:@"e5a3d72e"];
//    if ([SettingViewController getLoginName].length == 0) {
//        [[NSUserDefaults standardUserDefaults] setValue:@"icolorpaint"
//                                                 forKey:kLoginOfficerName];
//        [[NSUserDefaults standardUserDefaults] setValue:@"NO"
//                                                 forKey:kIsCorrectUserPass];
//    }
//    if ([SettingViewController getPassWord].length == 0) {
//        [[NSUserDefaults standardUserDefaults] setValue:@"abc123"
//                                                 forKey:kOfficerPassword];
//        [[NSUserDefaults standardUserDefaults] setValue:@"NO"
//                                                 forKey:kIsCorrectUserPass];
//    }
    if ([SettingViewController getLoginUserName].length == 0) {
        [[NSUserDefaults standardUserDefaults] setValue:@"suzukafine"
                                                 forKey:kLoginUserName];
    }
    if ([SettingViewController getUserPassword].length == 0) {
        [[NSUserDefaults standardUserDefaults] setValue:@"123456"
                                                 forKey:kUserPassword];
    }
    self.menuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.menuViewController];
    self.navController.delegate = (id)self;
    //    RotatingNavigationController *navController = [[RotatingNavigationController alloc] initWithRootViewController:self.menuViewController];
    self.navController.navigationBarHidden = YES;
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
//    NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
//    if (url != nil && [url isFileURL]) {
//        [self.menuViewController handleOpenURL:url];
//    }
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    if (url != nil && [url isFileURL]) {
        [self.menuViewController handleOpenURL:url];
    }
    return YES;
}

- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController{
    if ([[navigationController topViewController] isKindOfClass:[PlanViewController class]]) {
        UIInterfaceOrientation orientation = [(PlanViewController *)[navigationController topViewController] layoutOrientation];
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && hasTopNotch)? UIInterfaceOrientationMaskLandscapeRight : UIInterfaceOrientationMaskLandscape;
        }
        else
            return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && hasTopNotch)? UIInterfaceOrientationMaskPortrait : UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    else if ([[navigationController topViewController] isKindOfClass:[LayoutViewController class]]){
        UIInterfaceOrientation orientation = [(LayoutViewController *)[navigationController topViewController] layoutOrientation];
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && hasTopNotch)? UIInterfaceOrientationMaskLandscapeRight : UIInterfaceOrientationMaskLandscape;
        }
        else
            return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && hasTopNotch)? UIInterfaceOrientationMaskPortrait : UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    else if ([[navigationController topViewController] isKindOfClass:[EditImageViewController class]]){
        UIInterfaceOrientation orientation = [(EditImageViewController *)[navigationController topViewController] layoutOrientation];
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && hasTopNotch)? UIInterfaceOrientationMaskLandscapeRight : UIInterfaceOrientationMaskLandscape;
        }
        else
            return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && hasTopNotch)? UIInterfaceOrientationMaskPortrait : UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    else if ([[navigationController topViewController] isKindOfClass:[PreviewModalViewController class]]){
        UIInterfaceOrientation orientation = [(PreviewModalViewController *)[navigationController topViewController] orientation];
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && hasTopNotch)? UIInterfaceOrientationMaskLandscapeRight : UIInterfaceOrientationMaskLandscape;
        }
        else
            return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && hasTopNotch)? UIInterfaceOrientationMaskPortrait : UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    else if ([[navigationController topViewController] isKindOfClass:[ColorPickerModalViewViewController class]]){
        UIInterfaceOrientation orientation = [(ColorPickerModalViewViewController *)[navigationController topViewController] orientation];
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && hasTopNotch)? UIInterfaceOrientationMaskLandscapeRight : UIInterfaceOrientationMaskLandscape;
        }
        else
            return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && hasTopNotch)? UIInterfaceOrientationMaskPortrait : UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    return UIInterfaceOrientationMaskAll;
}

-(BOOL)hasTopNotch{
    if (@available(iOS 11.0, *)) {
        float max_safe_area_inset = MAX(MAX([[[UIApplication sharedApplication] delegate] window].safeAreaInsets.top, [[[UIApplication sharedApplication] delegate] window].safeAreaInsets.right),MAX([[[UIApplication sharedApplication] delegate] window].safeAreaInsets.bottom, [[[UIApplication sharedApplication] delegate] window].safeAreaInsets.left));
        return max_safe_area_inset >= 44.0;
    }

    return  NO;
}

//- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController{
//    return UIInterfaceOrientationLandscapeLeft;
//}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [self.navController fadePopRootViewController];
    MenuViewController *menuController = (MenuViewController *) [self.navController.viewControllers objectAtIndex:0];
    if (url != nil && [url isFileURL]) {
        [menuController handleOpenURL:url];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    if ([[url scheme] localizedCaseInsensitiveCompare:@"icolorpaint"] == NSOrderedSame) {
//        if ([self.navController.topViewController isKindOfClass:[PlanViewController class]]) {
//            
//        }
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"OpenToLogin"];
        [self.navController fadePopRootViewController];
        MenuViewController *menuController = (MenuViewController *) [self.navController.viewControllers objectAtIndex:0];
        if (url != nil) {
            [menuController openActivation:url];
        }
    }
    else{
        NSString *fileName = [url lastPathComponent];
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSURL *destinationUrl = [NSURL fileURLWithPath:[documentPath stringByAppendingPathComponent:fileName] isDirectory:NO];
        NSError *error = nil;
        if ([[NSFileManager defaultManager] moveItemAtURL:url toURL:destinationUrl error:&error]) {
            ExportUtil *exportManager = [[ExportUtil alloc] init];
            exportManager.delegate = (id)self;
            //    [HUD show:YES];
            if ([exportManager importFromURL:destinationUrl]) {
                
            }
        }
        else{
            NSLog(@"error %@",error);
        }
    }
    return YES;
}

- (void)importedMailData{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Import plan successfully" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ImportSucess" object:nil];
}

- (void)importDataError:(NSString *)errorMessage{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)initialDatabase{
    NSString *legacyDocumentDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSLog(@"%@", legacyDocumentDir);
        NSString *legacyDbPath = [[NSString alloc] initWithString:[legacyDocumentDir stringByAppendingPathComponent:@"dbDecorator.sqlite"]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:legacyDbPath]) {
            NSError *error;
            NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *dbPath = [[NSString alloc] initWithString:[documentDir stringByAppendingPathComponent:@"dbDecorator.sqlite"]];
    //        [fileManager copyItemAtPath:legacyDbPath toPath:dbPath error:&error];
            
            NSURL *destinationURL = [NSURL fileURLWithPath:dbPath];
            [fileManager replaceItemAtURL:destinationURL withItemAtURL:[NSURL fileURLWithPath:legacyDbPath] backupItemName:nil options:NSFileManagerItemReplacementUsingNewMetadataOnly resultingItemURL:&destinationURL error:&error];
            if (error == nil) {
                [fileManager removeItemAtPath:legacyDbPath error:&error];
            }
            [FCModel openDatabaseAtPath:dbPath withSchemaBuilder:^(FMDatabase *db, int *schemaVersion) {
                NSLog(@"schema version %d",*schemaVersion);
                [db beginTransaction];
                void (^failedAt)(int statement) = ^(int statement){
                    int lastErrorCode = db.lastErrorCode;
                    NSString *lastErrorMessage = db.lastErrorMessage;
                    [db rollback];
                    NSLog(@"Migration statement %d failed, code %d: %@", statement, lastErrorCode, lastErrorMessage);
                };
                
                if (*schemaVersion < 4) {
                    if (! [db executeUpdate:
                           @"CREATE TABLE MaterialDefault ("
                           @"type integer PRIMARY KEY,"
                           @"feature text,"
                           @"gloss text,"
                           @"pattern text,"
                           @"isPattern integer DEFAULT 0"
                           @");"
                           ]) failedAt(1);
                    if (! [db executeUpdate:@"INSERT INTO MaterialDefault VALUES (0, '未設定', '未設定', '未設定', 0);"]) failedAt(2);
                    if (! [db executeUpdate:@"INSERT INTO MaterialDefault VALUES (1, 'ニューモルコン', 'つや消し', 'フラット', 0);"]) failedAt (2);
                    if (! [db executeUpdate:@"INSERT INTO MaterialDefault VALUES (2, '１液ワイドシリコン', 'つやあり', 'フラット', 0);"]) failedAt (2);
                    if (! [db executeUpdate:@"INSERT INTO MaterialDefault VALUES (3, '水性ベスコロ', 'つやあり', 'フラット', 0);"]) failedAt (2);
                    if (! [db executeUpdate:@"INSERT INTO MaterialDefault VALUES (4, '１液ワイドシリコン', 'つやあり', 'フラット', 0);"]) failedAt (2);
                    if (! [db executeUpdate:@"INSERT INTO MaterialDefault VALUES (5, '水性ジェルアートSi', '３分つやあり', 'パターンローラー', 1);"]) failedAt (2);
                    if (! [db executeUpdate:@"INSERT INTO MaterialDefault VALUES (6, '水性シリコンユニ', 'つやあり', 'フラット', 0);"]) failedAt (2);
                    
                    if (![db executeUpdate:@"CREATE TABLE LayoutPosition (layoutIndex integer PRIMARY KEY,houseID integer,type integer,xValue float,yValue float,width float,height float);"]) {
                        failedAt(1);
                    }
                    if (![db executeUpdate:@"ALTER TABLE House ADD COLUMN backgroundImg text;"]) {
                        failedAt(2);
                    }
                    *schemaVersion = 4;
                }
                if (*schemaVersion < 5) {
                    *schemaVersion = 5;
                }
                if (*schemaVersion < 6) {
                    if (! [db executeUpdate:
                           @"CREATE TABLE Comment ("
                           @"commentID integer PRIMARY KEY,"
                           @"content text,"
                           @"width integer,"
                           @"height integer,"
                           @"xValue integer,"
                           @"yValue integer,"
                           @"houseID integer"
                           @");"
                           ]) failedAt(1);
                    *schemaVersion = 6;
                }
                if (*schemaVersion < 7) {
                    if (! [db executeUpdate:
                           @"ALTER TABLE Material ADD transparent integer DEFAULT 0;"
                           ]) failedAt(1);
                    *schemaVersion = 7;
                }
                [db commit];
            }];
        } else {
            NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *dbPath = [[NSString alloc] initWithString:[documentDir stringByAppendingPathComponent:@"dbDecorator.sqlite"]];
            NSLog(@"%@",dbPath);
            NSError *error;
            NSString *databPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"dbDecorator.sqlite"];
            if (![fileManager fileExistsAtPath:dbPath]) {
                [fileManager copyItemAtPath:databPath toPath:dbPath error:&error];
            }
            [FCModel openDatabaseAtPath:dbPath withSchemaBuilder:^(FMDatabase *db, int *schemaVersion) {
                NSLog(@"schema version %d",*schemaVersion);
                [db beginTransaction];
                void (^failedAt)(int statement) = ^(int statement){
                    int lastErrorCode = db.lastErrorCode;
                    NSString *lastErrorMessage = db.lastErrorMessage;
                    [db rollback];
                    NSLog(@"Migration statement %d failed, code %d: %@", statement, lastErrorCode, lastErrorMessage);
                };
                
                if (*schemaVersion < 4) {
                    if (! [db executeUpdate:
                           @"CREATE TABLE MaterialDefault ("
                           @"type integer PRIMARY KEY,"
                           @"feature text,"
                           @"gloss text,"
                           @"pattern text,"
                           @"isPattern integer DEFAULT 0"
                           @");"
                           ]) failedAt(1);
                    if (! [db executeUpdate:@"INSERT INTO MaterialDefault VALUES (0, '未設定', '未設定', '未設定', 0);"]) failedAt(2);
                    if (! [db executeUpdate:@"INSERT INTO MaterialDefault VALUES (1, 'ニューモルコン', 'つや消し', 'フラット', 0);"]) failedAt (2);
                    if (! [db executeUpdate:@"INSERT INTO MaterialDefault VALUES (2, '１液ワイドシリコン', 'つやあり', 'フラット', 0);"]) failedAt (2);
                    if (! [db executeUpdate:@"INSERT INTO MaterialDefault VALUES (3, '水性ベスコロ', 'つやあり', 'フラット', 0);"]) failedAt (2);
                    if (! [db executeUpdate:@"INSERT INTO MaterialDefault VALUES (4, '１液ワイドシリコン', 'つやあり', 'フラット', 0);"]) failedAt (2);
                    if (! [db executeUpdate:@"INSERT INTO MaterialDefault VALUES (5, '水性ジェルアートSi', '３分つやあり', 'パターンローラー', 1);"]) failedAt (2);
                    if (! [db executeUpdate:@"INSERT INTO MaterialDefault VALUES (6, '水性シリコンユニ', 'つやあり', 'フラット', 0);"]) failedAt (2);
                    
                    if (![db executeUpdate:@"CREATE TABLE LayoutPosition (layoutIndex integer PRIMARY KEY,houseID integer,type integer,xValue float,yValue float,width float,height float);"]) {
                        failedAt(1);
                    }
                    if (![db executeUpdate:@"ALTER TABLE House ADD COLUMN backgroundImg text;"]) {
                        failedAt(2);
                    }
                    *schemaVersion = 4;
                }
                if (*schemaVersion < 5) {
                    *schemaVersion = 5;
                }
                if (*schemaVersion < 6) {
                    if (! [db executeUpdate:
                           @"CREATE TABLE Comment ("
                           @"commentID integer PRIMARY KEY,"
                           @"content text,"
                           @"width integer,"
                           @"height integer,"
                           @"xValue integer,"
                           @"yValue integer,"
                           @"houseID integer"
                           @");"
                           ]) failedAt(1);
                    *schemaVersion = 6;
                }
                if (*schemaVersion < 7) {
                    if (! [db executeUpdate:
                           @"ALTER TABLE Material ADD transparent integer DEFAULT 0;"
                           ]) failedAt(1);
                    *schemaVersion = 7;
                }
                [db commit];
            }];
        }
}

@end
