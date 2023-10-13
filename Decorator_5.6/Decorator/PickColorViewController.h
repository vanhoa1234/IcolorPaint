//
//  PickColorViewController.h
//  Decorator
//
//  Created by Le Hoang on 12/7/19.
//  Copyright © 2019 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Color.h"
#import "LayerObject.h"
#import "AlbumViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PickColorViewControllerDelegate <NSObject>
- (void)dismissPickColorController:(BOOL)_isChangeColor;
- (void)selectedPickColor:(Color *)_color;
@optional

@end

@interface PickColorViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, AlbumViewControllerDelegate>
@property (nonatomic, assign) id<PickColorViewControllerDelegate> delegate;
- (id)initWithFrame:(CGRect)_frame andLayer:(LayerObject *)_layer;

@property (nonatomic, strong) UIImage *currentImage;
@property (weak, nonatomic) IBOutlet UIView *containerView;
//@property (weak, nonatomic) IBOutlet UIImageView *capturedImage;

@property (nonatomic, strong) AVCaptureSession *captureSession;
//@property (nonatomic, strong) AVCapturePhotoOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property dispatch_queue_t captureSessionQueue;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (weak, nonatomic) IBOutlet UIView *similarColorPreview;
@property (weak, nonatomic) IBOutlet UIView *selectedColorPreview;

@property (weak, nonatomic) IBOutlet UIButton *btType1;
@property (weak, nonatomic) IBOutlet UIButton *btType2;
@property (weak, nonatomic) IBOutlet UIButton *btType3;
@property (weak, nonatomic) IBOutlet UILabel *sheetLabel;
@property (weak, nonatomic) IBOutlet UILabel *similarColorLabel;
- (IBAction)typeChanged:(UIButton *)sender;
- (IBAction)dismiss:(id)sender;
- (IBAction)confirm:(id)sender;
- (IBAction)tapCameraAction:(UITapGestureRecognizer *)sender;
- (IBAction)tapPhotoAction:(UITapGestureRecognizer *)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIImageView *photoImage;

@end

NS_ASSUME_NONNULL_END

