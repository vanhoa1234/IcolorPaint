//
//  PickColorViewController.m
//  Decorator
//
//  Created by Le Hoang on 12/7/19.
//  Copyright © 2019 Hoang Le. All rights reserved.
//

#import "PickColorViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CIEDE2000.h"
// UIView+ColorOfPoint.h
#import "JPMAColor.h"
#import "UIColor+CIELAB.h"
#import "Lab.h"
#import "LabList.h"

@interface UIView (ColorOfPoint)
- (UIColor *) colorOfPoint:(CGPoint)point;
@end

@implementation UIView (ColorOfPoint)

- (UIColor *) colorOfPoint:(CGPoint)point
{
    unsigned char pixel[4] = {0};

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);

    CGContextTranslateCTM(context, -point.x, -point.y);

    [self.layer renderInContext:context];

    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    //NSLog(@"pixel: %d %d %d %d", pixel[0], pixel[1], pixel[2], pixel[3]);

    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];

    return color;
}

@end

@interface PickColorViewController () {
    int pickType;
    CGRect frame;
    LayerObject *layer;
    CGPoint currentCameraLocation;
    CAShapeLayer *circleLayer;
    CGSize cameraSize;
    UIColor *selectedColor;
    BOOL detectedSimilarColor;
    BOOL selectedSimilarColor;
    BOOL gotPhotoColor;
    NSMutableArray *colorList;
//    NSMutableArray *labList;
    JPMA *similarColor;
}

@end

@implementation PickColorViewController
- (id)initWithFrame:(CGRect)_frame andLayer:(LayerObject *)_layer{
    self = [super init];
    if (self) {
        //        layer = _layer;
        layer = [[LayerObject alloc] init];
        layer.type = _layer.type;
        layer.image = _layer.image;
        layer.name = _layer.name;
        layer.color = _layer.color;
        layer.colorValue = _layer.colorValue;
        layer.patternImage = _layer.patternImage;
        layer.feature = _layer.feature;
        layer.gloss = _layer.gloss;
        layer.pattern = _layer.pattern;
        frame = _frame;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString* path = [[NSBundle mainBundle] pathForResource:@"AllColor"
                                                     ofType:@"json"];
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSError *error;
    
    JPMAColor *object = [[JPMAColor alloc] initWithString:content error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    else{
        colorList = [[NSMutableArray alloc] initWithArray:object.JPMA];
//        path = [[NSBundle mainBundle] pathForResource:@"lab" ofType:@"json"];
//        content = [NSString stringWithContentsOfFile:path
//        encoding:NSUTF8StringEncoding
//           error:NULL];
//        LabList *labObject = [[LabList alloc] initWithString:content error:&error];
//        labList = [[NSMutableArray alloc] initWithArray:labObject.Lab];
    }
    
    self.view.frame = frame;
    if (_currentImage != nil) {
        _photoImage.image = _currentImage;
        _scrollview.hidden = NO;
        [_btType1 setAlpha:1];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resetZoom];
}

- (void)resetZoom {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect scrollViewFrame = self.scrollview.frame;
        NSLog(@"%f %f", self.scrollview.contentSize.width, self.scrollview.contentSize.height);
        CGFloat scaleWidth = scrollViewFrame.size.width / self.photoImage.image.size.width;//self.scrollview.contentSize.width;
        CGFloat scaleHeight = scrollViewFrame.size.height / self.photoImage.image.size.height;//self.scrollview.contentSize.height;
        CGFloat minScale = MIN(scaleWidth, scaleHeight);
        self.scrollview.minimumZoomScale = minScale;
        self.scrollview.maximumZoomScale = 6.0f;
        self.scrollview.zoomScale = minScale;
        [self centerContent];
    });
}

- (void)centerContent {
    CGFloat top = 0, left = 0;
    if (self.scrollview.contentSize.width < self.scrollview.bounds.size.width) {
        left = (self.scrollview.bounds.size.width-self.scrollview.contentSize.width) * 0.5f;
    }
    self.scrollview.contentInset = UIEdgeInsetsMake(top, left, top, left);
}


- (IBAction)typeChanged:(UIButton *)sender {
    if (pickType == [sender tag] && [sender tag] != 1) {
        return;
    }
    if (circleLayer.superlayer != nil) {
        [circleLayer removeFromSuperlayer];
    }
    pickType = (int)[sender tag];
    [_btType1 setAlpha:0.5];
    [_btType2 setAlpha:0.5];
    [_btType3 setAlpha:0.5];
    switch (pickType) {
        case 0:
            [_btType1 setAlpha:1];
            [self initialCurrentImage];
            break;
        case 1:
            [_btType2 setAlpha:1];
            [self initialPhotoAlbum];
            break;
        case 2:
            [_btType3 setAlpha:1];
            [self initialCamera];
            break;
        default:
            break;
    }
    
}

- (IBAction)dismiss:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [_delegate dismissPickColorController:NO];
}

- (IBAction)confirm:(id)sender {
    if (gotPhotoColor) {
        //chon mau similar
        if (selectedSimilarColor) {
            Color *convertColor = [[Color alloc] init];
            convertColor.No = similarColor.No;
            convertColor.ColorCode = similarColor.ColorCode;
            convertColor.R = similarColor.R;
            convertColor.R1 = similarColor.R;
            convertColor.G = similarColor.G;
            convertColor.G1 = similarColor.G;
            convertColor.B = similarColor.B;
            convertColor.B1 = similarColor.B;
            [_delegate selectedPickColor:convertColor];
        } else {
            const CGFloat *_components = CGColorGetComponents(selectedColor.CGColor);
            Color *convertColor = [[Color alloc] init];
            convertColor.No = 0;
            convertColor.ColorCode = NSLocalizedString(@"select_color", nil);//@"-";
            convertColor.R = _components[0]*255;
            convertColor.R1 = _components[0]*255;
            convertColor.G = _components[1]*255;
            convertColor.G1 = _components[1]*255;
            convertColor.B = _components[2]*255;
            convertColor.B1 = _components[2]*255;
            [_delegate selectedPickColor:convertColor];
        }
    }
}

- (IBAction)tapCameraAction:(UITapGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:_containerView];
    currentCameraLocation = location;
    if (circleLayer.superlayer != nil) {
        [circleLayer removeFromSuperlayer];
    }
    circleLayer = [CAShapeLayer layer];
    [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(location.x - 15, location.y - 15, 30, 30)] CGPath]];
    [circleLayer setStrokeColor:[[UIColor redColor] CGColor]];
    [circleLayer setLineWidth:5];
    [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
    [_containerView.layer addSublayer:circleLayer];
}

- (IBAction)tapPhotoAction:(UITapGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:_photoImage];
    if (location.x < 0 || location.y < 0 || location.x > _photoImage.image.size.width || location.y > _photoImage.image.size.height) {
        return;
    }
    if (circleLayer.superlayer != nil) {
        [circleLayer removeFromSuperlayer];
    }
    UIColor *color = [_photoImage colorOfPoint:location];
    if (CGColorGetAlpha(color.CGColor) == 0) {
        return;
    }
    currentCameraLocation = location;
    circleLayer = [CAShapeLayer layer];
    [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(location.x - 15/ _scrollview.zoomScale, location.y - 15/ _scrollview.zoomScale, 30 / _scrollview.zoomScale, 30 / _scrollview.zoomScale)] CGPath]];
    [circleLayer setStrokeColor:[[UIColor redColor] CGColor]];
    [circleLayer setLineWidth:5/_scrollview.zoomScale];
    [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
    [_photoImage.layer addSublayer:circleLayer];
    
    selectedColor = color;
    _selectedColorPreview.backgroundColor = selectedColor;
    gotPhotoColor = YES;
    if (!detectedSimilarColor) {
        [self tapPhotoColorAction:nil];
    }
    _similarColorPreview.backgroundColor = [self getSimilarColor:selectedColor];
    
}

- (IBAction)tapPhotoColorAction:(UITapGestureRecognizer *)sender {
    if (gotPhotoColor) {
        selectedSimilarColor = NO;
        _selectedColorPreview.layer.borderColor = [UIColor redColor].CGColor;
        _selectedColorPreview.layer.borderWidth = 5;
        
        _similarColorPreview.layer.borderWidth = 0;
        _similarColorPreview.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

- (IBAction)tapSimilarColorAction:(UITapGestureRecognizer *)sender {
    if (detectedSimilarColor) {
        selectedSimilarColor = YES;
        
        _similarColorPreview.layer.borderColor = [UIColor redColor].CGColor;
        _similarColorPreview.layer.borderWidth = 5;
        
        _selectedColorPreview.layer.borderWidth = 0;
        _selectedColorPreview.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

- (void)initialCurrentImage {
    _previewLayer.hidden = YES;
    if (_captureSession != nil) {
        [_captureSession stopRunning];
    }
    _scrollview.hidden = NO;
    if (_currentImage != nil) {
        _photoImage.image = _currentImage;
        [self resetZoom];
    }
}

- (void)initialPhotoAlbum {
    _previewLayer.hidden = YES;
    if (_captureSession != nil) {
        [_captureSession stopRunning];
    }
//    _capturedImage.hidden = NO;
    AlbumViewController *albumViewController = [[AlbumViewController alloc] init];
    albumViewController.delegate = self;
//    [self.navigationController pushFadeViewController:albumViewController];
    [self presentViewController:albumViewController animated:YES completion:nil];
}

- (void)cancelAlbum {
    [self dismissViewControllerAnimated:YES completion:^{
        if (circleLayer.superlayer != nil) {
            [circleLayer removeFromSuperlayer];
        }
        pickType = 0;
        [_btType2 setAlpha:0.5];
        [_btType3 setAlpha:0.5];
        [_btType1 setAlpha:1];
        [self initialCurrentImage];
    }];
}

- (void)selectedPhoto:(UIImage *)image {
    [self dismissViewControllerAnimated:YES completion:nil];
    _scrollview.hidden = NO;
    _photoImage.image = image;
    [self resetZoom];
}

- (void)initialCamera {
    _previewLayer.hidden = NO;
    [_scrollview setHidden:YES];
    if (_captureSession == nil) {
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
        
        AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error;
        AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:backCamera error:&error];
        if (error == nil && [_captureSession canAddInput:input]) {
            [_captureSession addInput:input];
            NSDictionary *outputSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInteger:kCVPixelFormatType_32BGRA]};
            _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
            _videoDataOutput.videoSettings = outputSettings;
            
            [_captureSession beginConfiguration];
            if ([_captureSession canAddOutput:_videoDataOutput]) {
                [_captureSession addOutput:_videoDataOutput];
                [_captureSession commitConfiguration];
                _captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
                [_videoDataOutput setSampleBufferDelegate:self queue:_captureSessionQueue];
                _videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
                
                _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
                _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
                switch (orientation) {
                    case UIInterfaceOrientationUnknown:
                        break;
                    case UIInterfaceOrientationPortrait:
                        [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
                        break;
                    case UIInterfaceOrientationPortraitUpsideDown:
                        [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
                        break;
                    case UIInterfaceOrientationLandscapeLeft:
                        [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
                        break;
                    case UIInterfaceOrientationLandscapeRight:
                        [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
                        break;
                }
                _previewLayer.frame = _containerView.layer.bounds;
                [_containerView.layer addSublayer:_previewLayer];
                dispatch_queue_t globalQueue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
                dispatch_async(globalQueue, ^{
                    [self.captureSession startRunning];
                });
            } else {
                NSLog(@"Cannot add video data output");
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
    if (circleLayer.superlayer == nil) {
        return;
    }
    UIColor* currentColor = nil;

    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:(CVPixelBufferRef)imageBuffer options:nil];

    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:ciImage fromRect:ciImage.extent];
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);

    CGPoint pointInCamera = [_previewLayer captureDevicePointOfInterestForPoint:currentCameraLocation];
    NSUInteger x = pointInCamera.x * width; //(NSUInteger)floor(pointInCamera.x) * width/cameraSize.width;
    NSUInteger y = pointInCamera.y * height; //(NSUInteger)floor(pointInCamera.y) * height/cameraSize.height;
    if ((x < width) && (y < height)) {
        NSUInteger width = CGImageGetWidth(cgImage);
        NSUInteger height = CGImageGetHeight(cgImage);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
        NSUInteger bytesPerPixel = 4;
        NSUInteger bytesPerRow = bytesPerPixel * width;
        NSUInteger bitsPerComponent = 8;
        CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                     bitsPerComponent, bytesPerRow, colorSpace,
                                                     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGColorSpaceRelease(colorSpace);
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
        CGContextRelease(context);
        // Now your rawData contains the image data in the RGBA8888 pixel format.

        int byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
        CGFloat red   = (rawData[byteIndex]     * 1.0) /255.0;
        CGFloat green = (rawData[byteIndex + 1] * 1.0)/255.0 ;
        CGFloat blue  = (rawData[byteIndex + 2] * 1.0)/255.0 ;
        CGFloat alpha = (rawData[byteIndex + 3] * 1.0) /255.0;
        byteIndex += 4;
        currentColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
//        NSLog(@"width:%lu hight:%i Color:%@",(unsigned long)width,height,[currentColor description]);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (circleLayer.superlayer != nil) {
                [circleLayer removeFromSuperlayer];
            }
            gotPhotoColor = YES;
            selectedColor = currentColor;
            _selectedColorPreview.backgroundColor = selectedColor;
            if (!detectedSimilarColor) {
                [self tapPhotoColorAction:nil];
            }
            _similarColorPreview.backgroundColor = [self getSimilarColor:selectedColor];
        });
        free(rawData);
    }
    CFRelease(cgImage);
    
    
    
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _previewLayer.frame = _containerView.layer.bounds;
    cameraSize = _containerView.frame.size;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (orientation) {
        case UIInterfaceOrientationUnknown:
            break;
        case UIInterfaceOrientationPortrait:
            [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
            break;
        case UIInterfaceOrientationLandscapeRight:
            [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
            break;
    }
}

-(UIColor *)getRGBAFromImage:(UIImage*)image atx:(int)xp atY:(int)yp

{
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    // Now your rawData contains the image data in the RGBA8888 pixel format.

    int byteIndex = (bytesPerRow * yp) + xp * bytesPerPixel;
    CGFloat red   = (rawData[byteIndex]     * 1.0) /255.0;
    CGFloat green = (rawData[byteIndex + 1] * 1.0)/255.0 ;
    CGFloat blue  = (rawData[byteIndex + 2] * 1.0)/255.0 ;
    CGFloat alpha = (rawData[byteIndex + 3] * 1.0) /255.0;
    byteIndex += 4;
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    free(rawData);
    return color;

}

- (CIEDE2000::LAB) cvtRGB2Lab:(cv::Mat) colorMat {
    cv::cvtColor(colorMat, colorMat, CV_BGR2Lab);
    cv::Scalar colorLab = (cv::Scalar) colorMat.at<cv::Vec3b>(0,0);
    return { colorLab.val[0], colorLab.val[1] - 128, colorLab.val[2] - 128};
}

- (CIEDE2000::LAB) cvtUIColor2Lab:(UIColor *) _rgbColor {
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    [_rgbColor getRed:&red green:&green blue:&blue alpha:&alpha];
    cv::Mat selectedMat(1, 1, CV_8UC3, CV_RGB(255*blue, 255*green, 255*red));
    return [self cvtRGB2Lab:selectedMat];
}

- (CIEDE2000::LAB) cvtJPMA2Lab:(JPMA *) color {
    cv::Mat colorMat(1, 1, CV_8UC3, CV_RGB(color.B, color.G, color.R));
    return [self cvtRGB2Lab:colorMat];
}


-(UIColor *)getSimilarColor:(UIColor *)_selectedColor {
    CIEDE2000::LAB selectedLab, refLab;
    selectedLab = [self cvtUIColor2Lab:selectedColor];
//    JPMA *similarColor;
    double deltaMin = 255.0;
    for (JPMA *color in colorList) {
        refLab = [self cvtJPMA2Lab:color];
        double delta = CIEDE2000::CIEDE2000(selectedLab, refLab);
        if (deltaMin > delta) {
            deltaMin = delta;
            similarColor = color;
        }
    }
//    int index = 0;
//    int similarIndex = 0;
//    for (Lab *color in labList) {
//        refLab = {color.l, color.a, color.b};
//        double delta = CIEDE2000::CIEDE2000(selectedLab, refLab);
//        if (deltaMin > delta) {
//            deltaMin = delta;
//            similarIndex = index;
//        }
//        index++;
//    }
//    similarColor = colorList[similarIndex];
    
//    NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:similarColor.ColorCode attributes:@{NSStrokeWidthAttributeName: [NSNumber numberWithInt:-6],NSStrokeColorAttributeName: [UIColor blackColor],NSForegroundColorAttributeName: [UIColor whiteColor]}];
//    _similarColorLabel.attributedText = attributed;
    _similarColorLabel.text = NSLocalizedString(similarColor.ColorCode, nil);
    if ([similarColor.ColorCode containsString:@"CS"]) {
        _sheetLabel.text = NSLocalizedString(@"スズカ遮熱用CS版", nil);
    } else if ([similarColor.ColorCode containsString:@"-"]) {
        _sheetLabel.text = NSLocalizedString(@"日塗工K版", nil);
    } else if ([similarColor.ColorCode containsString:@"A"]) {
        _sheetLabel.text = NSLocalizedString(@"スズカ壁用標準色", nil);
    } else {
        _sheetLabel.text = NSLocalizedString(@"スズカ屋根用標準色", nil);
    }
    detectedSimilarColor = true;
    return [UIColor colorWithRed:similarColor.R/255.0 green:similarColor.G/255.0 blue:similarColor.B/255.0 alpha:1.0];
}
#pragma mark - scroll view delegate
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoImage;
}
@end
