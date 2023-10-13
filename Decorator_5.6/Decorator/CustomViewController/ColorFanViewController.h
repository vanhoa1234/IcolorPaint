//
//  ColorFanViewController.h
//  Decorator
//
//  Created by Hoang Le on 9/20/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "MBProgressHUD.h"
#import "LayerObject.h"

@class Color;
@protocol ColorFanViewControllerDelegate <NSObject>
@optional
- (void)closeColorFanController:(BOOL)_isChangeColor;
- (void)selectedColorValue:(Color *)_colorValue;
- (void)cancelSelectJPMAColor:(LayerObject *)_layer;
@end

@interface ColorFanViewController : UIViewController<MBProgressHUDDelegate, UIScrollViewDelegate>{
    MBProgressHUD *HUD;
}
@property (nonatomic, assign) id<ColorFanViewControllerDelegate> delegate;
- (IBAction)backToColorMenu:(id)sender;
- (id)initWithFrame:(CGRect)_frame;
- (id)initWithFrame:(CGRect)_frame andLayerSelected:(LayerObject *)_layer;
@property (weak, nonatomic) IBOutlet UIImageView *colorImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)acceptChangeColor:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bt_cancel;
@property (weak, nonatomic) IBOutlet UIButton *bt_accept;
@property (weak, nonatomic) IBOutlet UIView *previewColorView;
@property (weak, nonatomic) IBOutlet UILabel *previewColorName;
- (IBAction)cancelPreviewColor:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *colorPreviewContainer;

@end
