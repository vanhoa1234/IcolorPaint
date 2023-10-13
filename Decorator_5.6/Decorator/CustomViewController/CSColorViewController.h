//
//  CSColorViewController.h
//  Decorator
//
//  Created by Le Hoang on 2/19/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Color.h"
#import "LayerObject.h"

@protocol CSColorViewControllerDelegate <NSObject>
@optional
- (void)dismissCSColorController:(BOOL)_isChangeColor;
- (void)selectedCSColor:(Color *)_color;
- (void)cancelSelectCSColorWithLayer:(LayerObject *)_layer;
@end

@interface CSColorViewController : UIViewController<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
- (IBAction)dismissThisController:(id)sender;
- (IBAction)acceptColorChange:(id)sender;
- (IBAction)selectedColor:(id)sender;
@property (nonatomic, assign) id<CSColorViewControllerDelegate> delegate;

- (id)initWithFrame:(CGRect)_frame andLayer:(LayerObject *)_layer;
@property (weak, nonatomic) IBOutlet UIButton *bt_cancel;
@property (weak, nonatomic) IBOutlet UIButton *bt_accept;
@property (weak, nonatomic) IBOutlet UIView *subScrollView;


@property (weak, nonatomic) IBOutlet UIView *previewColorView;
@property (weak, nonatomic) IBOutlet UILabel *previewColorName;
- (IBAction)cancelPreviewColor:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *colorPreviewContainer;
@end
