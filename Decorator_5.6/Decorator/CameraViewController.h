//
//  CameraViewController.h
//  Decorator
//
//  Created by Le Hoang on 12/4/19.
//  Copyright © 2019 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CameraViewControllerDelegate <NSObject>
@optional
- (void)cameraDidCaptureImage:(UIImage *)_image andMetadata:(NSDictionary *)_metadata;
@end

@interface CameraViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, assign) id<CameraViewControllerDelegate> delegate;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
//@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property dispatch_queue_t captureSessionQueue;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (weak, nonatomic) IBOutlet UIView *cameraContainerView;
@property (weak, nonatomic) IBOutlet UILabel *lb_guide;
@property (weak, nonatomic) IBOutlet UIImageView *img_guide;
@property (weak, nonatomic) IBOutlet UISwitch *switch_hide;
@property (weak, nonatomic) IBOutlet UILabel *lb_titleHide;
- (IBAction)dismissCamera:(id)sender;
- (IBAction)hideGuide:(id)sender;
- (IBAction)captureImage:(id)sender;
@end

NS_ASSUME_NONNULL_END
