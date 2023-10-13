//
//  MenuViewController.h
//  Decorator
//
//  Created by Hoang Le on 9/16/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "HLTextField.h"
@interface MenuViewController : UIViewController{
    UIPopoverController *popoverController;
}
@property (nonatomic,strong) UIPopoverController *popoverController;
- (IBAction)showAlbumViewController:(id)sender;
- (IBAction)showCameraViewController:(id)sender;
- (IBAction)showReferenceViewController:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bt_photo;
- (IBAction)showSetingViewController:(id)sender;
- (IBAction)showEditPlanViewController:(id)sender;
- (IBAction)showCatalog:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *img_preview;
- (IBAction)retakePicture:(id)sender;
- (IBAction)gotoPlan:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bt_retake;
@property (weak, nonatomic) IBOutlet UIButton *bt_chooseImage;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UIImageView *secondBackground;
@property (weak, nonatomic) IBOutlet UIButton *bt1;
@property (weak, nonatomic) IBOutlet UIButton *bt2;
@property (weak, nonatomic) IBOutlet UIButton *bt3;
@property (weak, nonatomic) IBOutlet UIButton *bt4;
@property (weak, nonatomic) IBOutlet UIButton *bt5;

- (void)handleOpenURL:(NSURL *)url;
- (void)openActivation:(NSURL *)url;
@property (weak, nonatomic) IBOutlet UIView *signinView;
@property (weak, nonatomic) IBOutlet UIButton *bt_signin;
@property (weak, nonatomic) IBOutlet UIButton *bt_laterSignin;
- (IBAction)resetAccount:(id)sender;
- (IBAction)signupAccount:(id)sender;
- (IBAction)actionSignupLater:(id)sender;
- (IBAction)actionSignIn:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lb_dayleft;
@property (weak, nonatomic) IBOutlet UITextField *txt_username;
@property (weak, nonatomic) IBOutlet UITextField *txt_password;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet HLTextField *txt_username_display;
@property (weak, nonatomic) IBOutlet HLTextField *txt_autosaveTime;
@property (weak, nonatomic) IBOutlet UIButton *bt_signup;

@property (weak, nonatomic) IBOutlet UIView *portraitView;
@property (weak, nonatomic) IBOutlet UIButton *pbt1;
@property (weak, nonatomic) IBOutlet UIButton *pbt2;
@property (weak, nonatomic) IBOutlet UIButton *pbt3;
@property (weak, nonatomic) IBOutlet UIButton *pbt4;
@property (weak, nonatomic) IBOutlet UIButton *pbt5;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *versionBottomConstraint;
@end
