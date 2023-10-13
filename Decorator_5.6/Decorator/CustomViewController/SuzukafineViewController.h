//
//  SuzukafineViewController.h
//  Decorator
//
//  Created by Hoang Le on 10/14/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Color.h"
#import "Suzukafine.h"
#import "MBProgressHUD.h"
#import "LayerObject.h"

@protocol SuzukafineViewControllerDelegate <NSObject>
@optional
- (void)closeSuzukaPickerView:(BOOL)_isChangeColor;
- (void)selectedSuzukaColor:(Color *)_color;
- (void)acceptChangeSuzukaColor:(Color *)_color;
@end

@interface SuzukafineViewController : UIViewController<MBProgressHUDDelegate, UIScrollViewDelegate>{
    MBProgressHUD *HUD;
}
@property (nonatomic, assign) id<SuzukafineViewControllerDelegate> delegate;
- (id)initWithFrame:(CGRect)_frame;
- (id)initWithFrame:(CGRect)_frame andLayer:(LayerObject *)_layer;
- (IBAction)closePatternPickerView:(id)sender;
- (IBAction)selectedColor:(id)sender;
- (IBAction)acceptChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bt_cancel;
@property (weak, nonatomic) IBOutlet UIButton *bt_accept;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollLeftConstraint;
@property (weak, nonatomic) IBOutlet UIView *subScrollView;

@property (weak, nonatomic) IBOutlet UIView *previewColorView;
@property (weak, nonatomic) IBOutlet UILabel *previewColorName;
- (IBAction)cancelPreviewColor:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *colorPreviewContainer;
@end
