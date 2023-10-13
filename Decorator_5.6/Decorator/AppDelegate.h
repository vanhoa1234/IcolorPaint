//
//  AppDelegate.h
//  Decorator
//
//  Created by Hoang Le on 9/13/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MenuViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    BOOL hasTopNotch;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MenuViewController *menuViewController;
@property (strong, nonatomic) UINavigationController *navController;
@end
