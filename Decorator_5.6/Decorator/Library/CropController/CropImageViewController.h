//
//  CropImageViewController.h
//  Decorator
//
//  Created by Hoang Le on 11/29/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UzysImageCropper.h"
#import "MBProgressHUD.h"

@protocol CropImageViewControllerDelegate;
@class  UzysImageCropper;

@interface CropImageViewController : UIViewController<MBProgressHUDDelegate>
@property (nonatomic,strong) UzysImageCropper *cropperView;
@property (nonatomic, assign) id <CropImageViewControllerDelegate> delegate;
- (id)initWithImage:(UIImage*)newImage andframeSize:(CGSize)frameSize andcropSize:(CGSize)cropSize;
- (id)initWithImage:(UIImage*)newImage andframeSize:(CGSize)frameSize andcropSize:(CGSize)cropSize andImage:(NSString *)imageName;
- (IBAction)backAction:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)rotateAction:(id)sender;
- (IBAction)resetAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end
@protocol CropImageViewControllerDelegate<NSObject>
- (void)imageCropper:(CropImageViewController *)cropper didFinishCroppingWithImage:(UIImage *)image;
- (void)imageCropperDidCancel:(CropImageViewController *)cropper;
@end
