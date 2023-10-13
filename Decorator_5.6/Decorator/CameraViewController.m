//
//  CameraViewController.m
//  Decorator
//
//  Created by Le Hoang on 12/4/19.
//  Copyright © 2019 Hoang Le. All rights reserved.
//

#import "CameraViewController.h"
#import "UIImage-Extension.h"

@interface CameraViewController ()

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        _lb_guide.font = [UIFont boldSystemFontOfSize:14];
        _lb_titleHide.font = [UIFont boldSystemFontOfSize:14];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initialCamera];
}

- (void)initialCamera {
    if (_captureSession == nil) {
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
        
        AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error;
        AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:backCamera error:&error];
        if (error == nil && [_captureSession canAddInput:input]) {
            [_captureSession addInput:input];
            _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;//AVCaptureSessionPreset1920x1080;
            _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
            _stillImageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
            
            [_captureSession beginConfiguration];
            if ([_captureSession canAddOutput:_stillImageOutput]) {
                [_captureSession addOutput:_stillImageOutput];
                [_captureSession commitConfiguration];
                _captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
                
                _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
                _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                switch ([[UIDevice currentDevice] orientation]) {
                    case UIDeviceOrientationPortrait:
                        _previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
                        break;
                    case UIDeviceOrientationPortraitUpsideDown:
                        _previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                        break;
                    case UIDeviceOrientationLandscapeLeft:
                        _previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                        break;
                    case UIDeviceOrientationLandscapeRight:
                        _previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                        break;
                    default:
                        _previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
                        break;
                }
                _previewLayer.frame = self.cameraContainerView.layer.bounds;
                [self.cameraContainerView.layer addSublayer:_previewLayer];
                dispatch_queue_t globalQueue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_async(globalQueue, ^{
                    [self.captureSession startRunning];
                });
            } else {
                _captureSession = nil;
                return;
            }
        }
    } else {
        [_captureSession startRunning];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _previewLayer.frame = _cameraContainerView.layer.bounds;
//    cameraSize = _containerView.frame.size;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (orientation) {
        case UIInterfaceOrientationUnknown:
            break;
        case UIInterfaceOrientationPortrait:
            [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
            _img_guide.image = [UIImage imageNamed:@"cameraFramePortrait"];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
            _img_guide.image = [UIImage imageNamed:@"cameraFramePortrait"];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
            _img_guide.image = [UIImage imageNamed:@"cameraFrame"];
            break;
        case UIInterfaceOrientationLandscapeRight:
            [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
            _img_guide.image = [UIImage imageNamed:@"cameraFrame"];
            break;
    }
    AVCaptureConnection *videoConnection = [_stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([videoConnection isVideoOrientationSupported]) {
        [videoConnection setVideoOrientation:_previewLayer.connection.videoOrientation];
    }
}

- (IBAction)hideGuide:(id)sender {
    _lb_guide.hidden = !_lb_guide.isHidden;
    _img_guide.hidden = !_img_guide.isHidden;
    if ([(UISwitch *)sender isOn]) {
        _lb_titleHide.text =  NSLocalizedString(@"show_guide", nil);
    }
    else
        _lb_titleHide.text = NSLocalizedString(@"hide_guide", nil);
}

- (IBAction)dismissCamera:(id)sender {
    if ([self presentingViewController] != nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (IBAction)captureImage:(id)sender {
    AVCaptureConnection *videoConnection = [_stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
//    if ([videoConnection isVideoOrientationSupported]) {
//        [videoConnection setVideoOrientation:_previewLayer.connection.videoOrientation];
//    }
    if (videoConnection != nil) {
        [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
            if (error == nil) {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                NSDictionary *metadata = CFBridgingRelease(CMCopyDictionaryOfAttachments(nil, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate));
                UIImage *output = [UIImage imageWithData:imageData];
                if (output.size.width / output.size.height == 0.75 || output.size.height / output.size.width == 0.75) {
                    [_delegate cameraDidCaptureImage:[UIImage imageWithData:imageData] andMetadata:metadata];
                } else {
                    if (output.size.width > output.size.height) {
                        UIImage *cropImage = [output cropImage:CGRectMake((output.size.height / 0.75 - output.size.height) / 2, 0, output.size.height / 0.75, output.size.height)];
                        [_delegate cameraDidCaptureImage:cropImage andMetadata:metadata];
                    } else {
                        UIImage *cropImage = [output cropImage:CGRectMake(0, (output.size.width / 0.75 - output.size.width) / 2, output.size.width, output.size.width / 0.75)];
                        [_delegate cameraDidCaptureImage:cropImage andMetadata:metadata];
                    }
                }
            }
        }];
    }
}
@end
