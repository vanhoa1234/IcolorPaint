//
//  ActivationSuccessViewController.h
//  Decorator
//
//  Created by Le Hoang on 6/6/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ActivationSuccessViewControllerDelegate <NSObject>

@optional
- (void)activationSuccess:(NSString *)_username password:(NSString *)_password;

@end

@interface ActivationSuccessViewController : UIViewController
@property (nonatomic, assign) id<ActivationSuccessViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *bt_back;
- (IBAction)backToLogin:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UILabel *lb_userID;
- (id)initWithActivationCode:(NSString *)_activationCode andUserEmail:(NSString *)_email password:(NSString *)_password;
@end
