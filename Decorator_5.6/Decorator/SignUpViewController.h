//
//  SignUpViewController.h
//  Decorator
//
//  Created by Le Hoang on 2/24/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "DLRadioButton.h"

@interface SignUpViewController : UIViewController<UITextFieldDelegate>
@property (nonatomic) BOOL isUpdateAccount;

@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollview;
- (IBAction)backtoMenu:(id)sender;
- (IBAction)selectedRadio:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txt_email;
@property (weak, nonatomic) IBOutlet UITextField *txt_confirm_email;
@property (weak, nonatomic) IBOutlet UITextField *txt_password;
@property (weak, nonatomic) IBOutlet UITextField *txt_confirm_password;
@property (weak, nonatomic) IBOutlet UITextField *txt_surname;
@property (weak, nonatomic) IBOutlet UITextField *txt_name;
@property (weak, nonatomic) IBOutlet UITextField *txt_phonetic_surname;
@property (weak, nonatomic) IBOutlet UITextField *txt_phonetic_name;
@property (weak, nonatomic) IBOutlet UITextField *txt_companyname;
@property (weak, nonatomic) IBOutlet UITextField *txt_divisionname;
@property (weak, nonatomic) IBOutlet UITextField *txt_title;
@property (weak, nonatomic) IBOutlet UITextField *txt_postalcode_field1;
@property (weak, nonatomic) IBOutlet UITextField *txt_postalcode_field2;
@property (weak, nonatomic) IBOutlet UITextField *txt_streetaddress;
@property (weak, nonatomic) IBOutlet UITextField *txt_buildingname;
@property (weak, nonatomic) IBOutlet UITextField *txt_phone_field1;
@property (weak, nonatomic) IBOutlet UITextField *txt_phone_field2;
@property (weak, nonatomic) IBOutlet UITextField *txt_phone_field3;
@property (weak, nonatomic) IBOutlet UITextField *txt_fax_field1;
@property (weak, nonatomic) IBOutlet UITextField *txt_fax_field2;
@property (weak, nonatomic) IBOutlet UITextField *txt_fax_field3;
@property (weak, nonatomic) IBOutlet UITextField *txt_businessname;
- (IBAction)action_signup:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bt_signup;
@property (weak, nonatomic) IBOutlet DLRadioButton *checkbox_sendmail;
@property (weak, nonatomic) IBOutlet DLRadioButton *checkbox_businessname;
@property (weak, nonatomic) IBOutlet UIImageView *icon_businessError;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@property (weak, nonatomic) IBOutlet DLRadioButton *opt1;
@property (weak, nonatomic) IBOutlet DLRadioButton *opt2;
@property (weak, nonatomic) IBOutlet DLRadioButton *opt3;
@property (weak, nonatomic) IBOutlet DLRadioButton *opt4;
@property (weak, nonatomic) IBOutlet DLRadioButton *opt5;
@property (weak, nonatomic) IBOutlet DLRadioButton *opt6;
@property (weak, nonatomic) IBOutlet DLRadioButton *opt7;
@property (weak, nonatomic) IBOutlet DLRadioButton *opt8;
@property (weak, nonatomic) IBOutlet DLRadioButton *opt9;
@property (weak, nonatomic) IBOutlet DLRadioButton *opt10;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *internetLabelHeightConstraint;

@end
