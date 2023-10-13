//
//  ConfirmSignupViewController.h
//  Decorator
//
//  Created by Le Hoang on 4/26/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ConfirmSignupViewControllerDelegate <NSObject>

@end

@interface ConfirmSignupViewController : UIViewController
- (id)initWithSignUpParameter:(NSDictionary *)_parameter;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UITextField *txt_email;
@property (weak, nonatomic) IBOutlet UITextField *txt_password;
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
@property (weak, nonatomic) IBOutlet UIButton *bt_confirmSignup;
@property (weak, nonatomic) IBOutlet UIButton *bt_cancelSignup;
- (IBAction)confirmSignup:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lb_isreceivemail;
- (IBAction)cancelSignUp:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end
