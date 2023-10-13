//
//  BarrierColorViewController.h
//  Decorator
//
//  Created by Le Hoang on 3/23/16.
//  Copyright © 2016 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Color.h"
#import "LayerObject.h"

@protocol BarrierColorViewControllerDelegate <NSObject>
@optional
- (void)dismissBarrierColorController:(BOOL)_isChangeColor;
- (void)selectedBarrierPattern:(NSString *)_barrierPattern;
- (void)cancelBarrierPattern:(LayerObject *)_layer;
@end

@interface BarrierColorViewController : UIViewController<UIScrollViewDelegate>
@property (nonatomic, assign) id<BarrierColorViewControllerDelegate> delegate;
- (IBAction)dismissThisController:(id)sender;
- (id)initWithFrame:(CGRect)_frame andLayer:(LayerObject *)_layer;
- (IBAction)acceptChangePattern:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIScrollView *titleScrollView;

- (IBAction)selectedColor:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bt_cancel;
@property (weak, nonatomic) IBOutlet UIButton *bt_accept;
@property (weak, nonatomic) IBOutlet UIView *subScrollView;

@property (weak, nonatomic) IBOutlet UIScrollView *headerScrollView;
@property (weak, nonatomic) IBOutlet UIView *headerSubScrollView;

@property (weak, nonatomic) IBOutlet UIView *previewColorView;
@property (weak, nonatomic) IBOutlet UILabel *previewColorName;
@property (weak, nonatomic) IBOutlet UILabel *previewTypeName;

- (IBAction)cancelPreviewColor:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *colorPreviewContainer;
@end
