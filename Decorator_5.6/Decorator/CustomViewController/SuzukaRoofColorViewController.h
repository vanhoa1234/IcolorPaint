//
//  SuzukaRoofColorViewController.h
//  Decorator
//
//  Created by Le Hoang on 12/5/19.
//  Copyright © 2019 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Color.h"
#import "LayerObject.h"

@protocol SuzukaRoofColorViewControllerDelegate <NSObject>
@optional
- (void)dismissSuzukaRoofColorController:(BOOL)_isChangeColor;
- (void)selectedSuzukaRoofColor:(Color *)_color;
- (void)cancelSelectSuzukaRoofColorWithLayer:(LayerObject *)_layer;
@end

NS_ASSUME_NONNULL_BEGIN

@interface SuzukaRoofColorViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
- (IBAction)dismissThisController:(id)sender;
- (IBAction)acceptColorChange:(id)sender;
- (IBAction)selectedColor:(id)sender;
@property (nonatomic, assign) id<SuzukaRoofColorViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *subScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollLeftConstraint;
- (id)initWithFrame:(CGRect)_frame andLayer:(LayerObject *)_layer;
@property (weak, nonatomic) IBOutlet UIButton *bt_cancel;
@property (weak, nonatomic) IBOutlet UIButton *bt_accept;

@property (weak, nonatomic) IBOutlet UIView *previewColorView;
@property (weak, nonatomic) IBOutlet UILabel *previewColorName;
- (IBAction)cancelPreviewColor:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *colorPreviewContainer;
@end

NS_ASSUME_NONNULL_END
