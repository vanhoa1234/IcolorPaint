//
//  SignupSuccessViewController.m
//  Decorator
//
//  Created by Le Hoang on 6/6/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import "SignupSuccessViewController.h"
#import <objc/message.h>
@interface SignupSuccessViewController ()

@end

@implementation SignupSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bt_back.layer.cornerRadius = 10.0f;
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

- (IBAction)backtoMenu:(id)sender {
    [self.navigationController fadePopRootViewController];
}
@end
