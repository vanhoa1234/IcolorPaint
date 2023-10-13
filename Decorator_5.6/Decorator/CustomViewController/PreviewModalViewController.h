//
//  PreviewModalViewController.h
//  Decorator
//
//  Created by Hoang Le on 7/3/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PreviewModalViewControllerDelegate <NSObject>
@optional
- (void)closePreviewModal;

@end

@interface PreviewModalViewController : UIViewController
@property (nonatomic, assign) id<PreviewModalViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *btBack;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (nonatomic) UIInterfaceOrientation orientation;
- (id)initWithPreviewImage:(UIImage *)_previewImage;
- (id)initWithPreviewImage:(UIImage *)_previewImage andOrientation:(UIInterfaceOrientation)_orientation;
- (IBAction)closePreview:(id)sender;
@end
