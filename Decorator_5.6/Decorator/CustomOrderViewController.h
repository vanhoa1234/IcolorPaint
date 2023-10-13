//
//  CustomOrderViewController.h
//  Decorator
//
//  Created by Hoang Le on 11/26/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Material.h"

@protocol CustomOrderViewControllerDelegate <NSObject>
@optional
- (void)savedCustomOrder:(Material *)_savedMaterial;

@end

@interface CustomOrderViewController : UIViewController
@property (nonatomic, assign) id<CustomOrderViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *img_type;
@property (weak, nonatomic) IBOutlet UILabel *lb_type;
@property (weak, nonatomic) IBOutlet UIImageView *img_feature;
@property (weak, nonatomic) IBOutlet UILabel *fname;
@property (weak, nonatomic) IBOutlet UILabel *fdescription;
@property (weak, nonatomic) IBOutlet UIButton *btt_gloss1;
@property (weak, nonatomic) IBOutlet UIButton *btb_gloss1;
@property (weak, nonatomic) IBOutlet UIButton *btt_gloss2;
@property (weak, nonatomic) IBOutlet UIButton *btb_gloss2;
@property (weak, nonatomic) IBOutlet UIButton *btt_gloss3;
@property (weak, nonatomic) IBOutlet UIButton *btb_gloss3;
@property (weak, nonatomic) IBOutlet UIButton *btt_gloss4;
@property (weak, nonatomic) IBOutlet UIButton *btb_gloss4;

@property (weak, nonatomic) IBOutlet UIButton *btt_pattern1;
@property (weak, nonatomic) IBOutlet UIButton *btb_pattern1;
@property (weak, nonatomic) IBOutlet UIButton *btt_pattern2;
@property (weak, nonatomic) IBOutlet UIButton *btb_pattern2;
@property (weak, nonatomic) IBOutlet UIButton *btt_pattern3;
@property (weak, nonatomic) IBOutlet UIButton *btb_pattern3;
@property (weak, nonatomic) IBOutlet UIButton *btt_pattern4;
@property (weak, nonatomic) IBOutlet UIButton *btb_pattern4;
@property (weak, nonatomic) IBOutlet UIButton *btt_pattern5;
@property (weak, nonatomic) IBOutlet UIButton *btb_pattern5;

@property (weak, nonatomic) IBOutlet UIView *customView;
- (id)initWithMaterial:(Material *)_material;
- (IBAction)backToOrderDetail:(id)sender;
- (IBAction)changeGloss:(id)sender;
- (IBAction)changePattern:(id)sender;
- (IBAction)saveEditAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UILabel *lb_glossDescription;
@end
