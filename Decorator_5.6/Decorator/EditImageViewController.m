//
//  EditImageViewController.m
//  Decorator
//
//  Created by Hoang Le on 5/13/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import "EditImageViewController.h"
//#include <opencv2/highgui/ios.h>
#include <opencv2/imgcodecs/ios.h>
#include "Mask.h"
#import "ImageProcessor.h"
#include "CloneStamp.h"
#import "MBProgressHUD.h"
#import "PreviewModalViewController.h"
#import "MZFormSheetController.h"
#import "LayerObject.h"
#import "OBShapedButton.h"
#import "STAlertView.h"

const int UNDO_DEEP = 10;
@interface EditImageViewController (){
    UIImage *originalImage;
    CAShapeLayer *horizontalLine;
    CAShapeLayer *verticalLine;
    CGPoint sliderPoint;
    cv::Mat opencvImgSrc;
    cv::Mat tempImg;
    cv::Mat images[UNDO_DEEP];
    cv::Mat maskImage;
    
    cv::Mat previewImgDist;
    UIBezierPath *myPath;
    CAShapeLayer *shapeLayer;
    NSMutableArray *pathPoint;
//    MBProgressHUD *HUD;
    int index;
    int undoNumber;
    MZFormSheetController *formsheetController;
    int bannerIndex;
    bool tapToProcess;
    NSMutableArray *layerDatasource;
//    AwesomeMenu *menu;
    int selectedType;
    STAlertView *confirmAlert;
}

@end

@implementation EditImageViewController

float radius = 15;
@synthesize delegate;
@synthesize layoutOrientation;

//- (id)initWithOriginalImage:(UIImage *)_originalImage{
//    index = 0;
//    undoNumber = 0;
//    self = [super init];
//    if (self) {
//        originalImage = _originalImage;
//        UIImageToMat(originalImage, opencvImgSrc);
//        cv::cvtColor(opencvImgSrc, opencvImgSrc, CV_BGRA2BGR);
//        tempImg = opencvImgSrc.clone();
//        maskImage = cv::Mat::zeros(opencvImgSrc.size(), CV_8UC1);
//    }
//    return self;	
//}
- (void)reloadBannerView{
    bannerIndex += 1;
    if (bannerIndex > 4) {
        bannerIndex = 1;
    }
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        _bannerImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"banner_L_0%d.jpg",bannerIndex]];
    }
    else{
        _bannerImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"banner_P_0%d.jpg",bannerIndex]];
    }
}

- (bool)increaseIndex:(bool) _add{
    _btundo.enabled = YES;
    if(_add){
        for (int i=index+1; i<UNDO_DEEP; i++)
            images[i].release();
        
        if (index==UNDO_DEEP-1){        
            for(int i=1; i<UNDO_DEEP; i++){
                images[i].copyTo(images[i-1]);
            }
        } else index++;
        undoNumber = index;
        images[index] = opencvImgSrc.clone();
        _btredo.enabled = NO;
//        std::cout<<"add index = " << index<<std::endl;
        return false;
    }
    if(index==undoNumber){
        _btredo.enabled = NO;
        return false;
    }
    index++;
//    std::cout<<"undo index = " << index<<std::endl;
    return true;
}

- (id)initWithcvOriginalImage:(cv::Mat)_cvoriginalImage{
    self = [super init];
    index = 0;
    undoNumber = 0;
    tapToProcess = false;
    if (self) {
        originalImage = MatToUIImage(_cvoriginalImage);
//        UIImageToMat(originalImage, opencvImgSrc);
        opencvImgSrc = _cvoriginalImage.clone();
        cv::cvtColor(opencvImgSrc, opencvImgSrc, CV_BGRA2BGR);
        tempImg = opencvImgSrc.clone();
        images[index] = opencvImgSrc.clone();
        maskImage = cv::Mat::zeros(opencvImgSrc.size(), CV_8UC1);
    }
    return self;
}

- (id)initWithcvOriginalImage:(cv::Mat)_cvoriginalImage withLayoutOrientation:(UIInterfaceOrientation)_orientation{
    self = [self initWithcvOriginalImage:_cvoriginalImage];
    if (self) {
        layoutOrientation = _orientation;
    }
    return self;
}

- (id)initWithcvOriginalImage:(cv::Mat)_cvoriginalImage withLayoutOrientation:(UIInterfaceOrientation)_orientation andLayerDatasource:(NSMutableArray *)_layerDatasource{
    self = [self initWithcvOriginalImage:_cvoriginalImage];
    if (self) {
        layoutOrientation = _orientation;
        layerDatasource = [NSMutableArray arrayWithArray:_layerDatasource];
    }
    return self;
}

- (bool)decreaseIndex{
    if(index==0){
        _btundo.enabled = NO;
        return false;
    }
    index--;
    _btredo.enabled = YES;
    return true;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)showHUD{
    _processingView.hidden = NO;
    [_processingActivity startAnimating];
//    if (HUD == nil)
//    {
//        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
//        [self.navigationController.view addSubview:HUD];
//        HUD.mode = MBProgressHUDModeIndeterminate;
//        HUD.labelText = @"Processing...";
//        HUD.dimBackground = YES;
//        HUD.delegate = (id)self;
//    }
//    [HUD show:YES];
}

- (void)hideHUD{
    [_processingActivity stopAnimating];
    _processingView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self hasTopNotch]) {
            _menuBottomConstraint.constant = -22;
            _scrollViewLeftConstraint.constant = 14;
        } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            _scrollViewBottomContraint.constant = 41;
        }
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                CGFloat scrollHeight = 551 * [UIScreen mainScreen].bounds.size.height / 768;
                CGFloat left = ([UIScreen mainScreen].bounds.size.width - scrollHeight/0.75 - 210 + 1) / 2;
                _scrollViewLeftConstraintPad.constant = left + 1;
                _scrollViewRightConstraintPad.constant = left - 1;
                _scrollViewWidthContraint.constant = scrollHeight/0.75;
                _leftMenuWidthConstraint.active = NO;
                _scrollViewWidthContraint.active = YES;
 
            }
        }
        else{
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                _bannerTopConstraint.active = NO;
                _scrollViewHeightConstraint.constant = ([UIScreen mainScreen].bounds.size.width - 219)/0.75;
                _scrollViewHeightConstraint.active = YES;
                _scrollViewBottomConstraintPad.constant = 42;
                _scrollViewTopConstraintPad.constant = 40;
            }
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect scrollViewFrame = self.scrollView.frame;
        NSLog(@"%f %f", self.scrollView.contentSize.width, self.scrollView.contentSize.height);
        CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
        CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
        CGFloat minScale = MIN(scaleWidth, scaleHeight);
        self.scrollView.minimumZoomScale = minScale;
        self.scrollView.maximumZoomScale = 6.0f;
        self.scrollView.zoomScale = minScale;
        _imageView.layer.cornerRadius = 20/_scrollView.zoomScale;
        [self centerContent];
//        [UIView animateWithDuration:0.2 animations:^{
//            self.scrollView.alpha = 1;
//        }];
        [self initialImageGestures];
    });
    
    
//    [self initialLine];
    [self drawCenterPoint];
    [self.view addSubview:self.menuView];
    self.menuView.hidden = YES;
    
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        _backgroundImageView.image = [UIImage imageNamed:@"BG_02.jpg"];
        _bannerImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"banner_L_0%d.jpg",bannerIndex]];
    }
    else{
        _backgroundImageView.image = [UIImage imageNamed:@"BG_04.jpg"];
        _bannerImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"banner_P_0%d.jpg",bannerIndex]];
    }
}

- (void)centerContent {
    CGFloat top = 0, left = 0;
    if (self.scrollView.contentSize.width < self.scrollView.bounds.size.width) {
        left = (self.scrollView.bounds.size.width-self.scrollView.contentSize.width) * 0.5f;
    }
//    if (self.scrollView.contentSize.height < self.scrollView.bounds.size.height) {
//        top = (self.scrollView.bounds.size.height-self.scrollView.contentSize.height) * 0.5f;
//    }
    self.scrollView.contentInset = UIEdgeInsetsMake(top, left, top, left);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    bannerIndex = 1;
//    if (UIInterfaceOrientationIsPortrait(layoutOrientation) && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
//        _scrollViewHeightConstraint.constant = ([UIScreen mainScreen].bounds.size.width - 219)/0.75;
//        _scrollViewHeightConstraint.active = YES;
//        _bannerTopConstraint.active = NO;
//    }
    _btredo.enabled = NO;
    _btundo.enabled = NO;
    _imageView.image = originalImage;
    _imageView.layer.masksToBounds = YES;
    
    _scrollView.layer.cornerRadius = 20.0f;
    _scrollView.layer.masksToBounds = YES;
    _scrollView.contentSize = _imageView.image.size;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        _lbUndo.font = [UIFont systemFontOfSize:8];
        _lbRedo.font = [UIFont systemFontOfSize:8];
        _lbPreview.font = [UIFont systemFontOfSize:8];
        _lbMasking.font = [UIFont systemFontOfSize:8];
        _lbTop.font = [UIFont systemFontOfSize:8];
    }
}

-(BOOL)hasTopNotch{
    if (@available(iOS 11.0, *)) {
        float max_safe_area_inset = MAX(MAX([[[UIApplication sharedApplication] delegate] window].safeAreaInsets.top, [[[UIApplication sharedApplication] delegate] window].safeAreaInsets.right),MAX([[[UIApplication sharedApplication] delegate] window].safeAreaInsets.bottom, [[[UIApplication sharedApplication] delegate] window].safeAreaInsets.left));
        return max_safe_area_inset >= 44.0;
    }

    return  NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialLine{
    if (!horizontalLine) {
        horizontalLine = [[CAShapeLayer alloc] initWithLayer:self.sliderArea.layer];
        [self.sliderArea.layer addSublayer:horizontalLine];
        horizontalLine.lineWidth = 0.5f;
        horizontalLine.strokeColor = [UIColor redColor].CGColor;
    }
    if (!verticalLine) {
        verticalLine = [[CAShapeLayer alloc] initWithLayer:self.sliderArea.layer];
        [self.sliderArea.layer addSublayer:verticalLine];
        verticalLine.lineWidth = 0.5f;
        verticalLine.strokeColor = [UIColor redColor].CGColor;
    }
    UIBezierPath *path = [UIBezierPath bezierPath];
    //draw horizontal line
    [path moveToPoint:CGPointMake(0, sliderPoint.y)];
    [path addLineToPoint:CGPointMake(_sliderArea.frame.size.width, sliderPoint.y)];
    horizontalLine.path = path.CGPath;
    //draw vertical line
    [path moveToPoint:CGPointMake(sliderPoint.x, 0)];
    [path addLineToPoint:CGPointMake(sliderPoint.x, _sliderArea.frame.size.height)];
    verticalLine.path = path.CGPath;
}

- (void)drawCenterPoint{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sliderPoint = CGPointMake(_sliderArea.frame.size.width/2, _sliderArea.frame.size.height/2);
        if (!horizontalLine) {
               horizontalLine = [[CAShapeLayer alloc] initWithLayer:self.sliderArea.layer];
               [self.sliderArea.layer addSublayer:horizontalLine];
               horizontalLine.lineWidth = 0.5f;
               horizontalLine.strokeColor = [UIColor redColor].CGColor;
           }
           if (!verticalLine) {
               verticalLine = [[CAShapeLayer alloc] initWithLayer:self.sliderArea.layer];
               [self.sliderArea.layer addSublayer:verticalLine];
               verticalLine.lineWidth = 0.5f;
               verticalLine.strokeColor = [UIColor redColor].CGColor;
           }
           UIBezierPath *path = [UIBezierPath bezierPath];
           //draw horizontal line
           [path moveToPoint:CGPointMake(0, sliderPoint.y)];
           [path addLineToPoint:CGPointMake(_sliderArea.frame.size.width, sliderPoint.y)];
           horizontalLine.path = path.CGPath;
           //draw vertical line
           [path moveToPoint:CGPointMake(sliderPoint.x, 0)];
           [path addLineToPoint:CGPointMake(sliderPoint.x, _sliderArea.frame.size.height)];
           verticalLine.path = path.CGPath;
        
        UIView *centerPoint = [[UIView alloc] initWithFrame:CGRectMake(sliderPoint.x - radius, sliderPoint.y - radius, radius*2, radius*2)];
        [centerPoint.layer addSublayer:[self drawCirclePointWithColor:[UIColor redColor]]];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToolPoint:)];
        panGesture.maximumNumberOfTouches = 1;
        panGesture.delegate = (id)self;
        [centerPoint addGestureRecognizer:panGesture];
        [self.sliderArea addSubview:centerPoint];
        [self.sliderArea layoutSubviews];
    });
}

- (void)panToolPoint:(UIPanGestureRecognizer *)recognizer{
    CGPoint location = [recognizer locationInView:_sliderArea];
    sliderPoint = [self fixToolPoint:location];
    recognizer.view.center = sliderPoint;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    //draw horizontal line
    [path moveToPoint:CGPointMake(0, sliderPoint.y)];
    [path addLineToPoint:CGPointMake(_sliderArea.frame.size.width, sliderPoint.y)];
    horizontalLine.path = path.CGPath;
    //draw vertical line
    [path moveToPoint:CGPointMake(sliderPoint.x, 0)];
    [path addLineToPoint:CGPointMake(sliderPoint.x, _sliderArea.frame.size.height)];
    verticalLine.path = path.CGPath;
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
//        float contrastValue = (_sliderArea.frame.size.width - radius)/(2*(sliderPoint.x - radius));
//        float brighnessValue = (_sliderArea.frame.size.height - radius)/2 - (sliderPoint.y - radius);
//        tempImg.convertTo(opencvImgSrc, -1, 1/contrastValue, brighnessValue);
//        images[index] = opencvImgSrc.clone();
//        self.imageView.image = MatToUIImage(opencvImgSrc);
        int alpha = sliderPoint.x - _sliderArea.frame.size.width/2.;
        float c=1.0;
        if(alpha >= 0) c = (2.0 * alpha/255.0 + 1.0);
        else c = -1.0/(-1.0 + 2.0 * alpha/255.0);
        
        float b = sliderPoint.y - _sliderArea.frame.size.height/2.;
        
        b = -b * 50.0/(_sliderArea.frame.size.height/2.);
        tempImg.convertTo(opencvImgSrc, -1, c, b);
        images[index] = opencvImgSrc.clone();
        self.imageView.image = MatToUIImage(opencvImgSrc);
    }
}

- (CGPoint)fixToolPoint:(CGPoint)_point{
    float x,y;
    x = _point.x;
    y = _point.y;
    if (_point.x < radius) {
        //        x = 0 + POINT_RADIUS;
        x = radius;
    }
    else if (_point.x > _sliderArea.frame.size.width - radius){
        x = _sliderArea.frame.size.width - radius;
    }
    if (_point.y < radius) {
        y = radius;
    }
    else if (_point.y > _sliderArea.frame.size.height - radius){
        y = _sliderArea.frame.size.height - radius;
    }
    return CGPointMake(x, y);
}

- (CGPoint)fixPanPoint:(CGPoint)_point{
    float x,y;
    x = _point.x;
    y = _point.y;
    if (_point.x < 0) {
        //        x = 0 + POINT_RADIUS;
        x = 0;
    }
    else if (_point.x > _imageView.image.size.width){
        x = _imageView.image.size.width;
    }
    if (_point.y < 0) {
        y = 0;
    }
    else if (_point.y > _imageView.image.size.height){
        y = _imageView.image.size.height;
    }
    return CGPointMake(x, y);
}

- (CGPoint)fixPanPointScrollView:(CGPoint)_point{
    float x,y;
    x = _point.x;
    y = _point.y;
    if (_point.x < 0) {
        //        x = 0 + POINT_RADIUS;
        x = 0;
    }
    else if (_point.x > _scrollView.frame.size.width){
        x = _scrollView.frame.size.width;
    }
    if (_point.y < 0) {
        y = 0;
    }
    else if (_point.y > _scrollView.frame.size.height){
        y = _scrollView.frame.size.height;
    }
    return CGPointMake(x, y);
}


- (CAShapeLayer *)drawCirclePointWithColor:(UIColor *)_fillColor{
    CAShapeLayer *circlePoint = [CAShapeLayer layer];
    CGFloat lineWidth = 4.0f;
    circlePoint.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius)
                                                      radius:radius
                                                  startAngle:0
                                                    endAngle:DEGREES_TO_RADIANS(360)
                                                   clockwise:YES].CGPath;
    circlePoint.fillColor   = _fillColor.CGColor;
    circlePoint.strokeColor = [UIColor blackColor].CGColor;
    circlePoint.lineWidth   = lineWidth;
    circlePoint.opacity = 0.9;
    return circlePoint;
}

#pragma mark - initial image gesture (zoom in, zoom out)

- (void)initialImageGestures{
    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped1:)];
    twoFingerTapRecognizer.numberOfTapsRequired = 1;
    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
    twoFingerTapRecognizer.delegate = (id)self;
    [self.scrollView addGestureRecognizer:twoFingerTapRecognizer];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPoint1:)];
    panGestureRecognizer.maximumNumberOfTouches = 1;
    panGestureRecognizer.delegate = (id)self;
    [self.scrollView addGestureRecognizer:panGestureRecognizer];
    
//    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped1:)];
//    tapRecognizer.numberOfTapsRequired = 1;
//    tapRecognizer.numberOfTouchesRequired = 1;
//    tapRecognizer.delegate = (id)self;
//    [self.imageView addGestureRecognizer:tapRecognizer];
}

- (void)scrollViewTwoFingerTapped1:(UITapGestureRecognizer *)recognizer {
    CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

- (void)panPoint1:(UIPanGestureRecognizer *)recognizer{
    CGPoint location = [recognizer locationInView:_imageView];
    location = [self fixPanPoint:location];
    if (!pathPoint) {
        pathPoint = [NSMutableArray array];
    }
    if (!myPath){
        myPath = [UIBezierPath bezierPath];
    }
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.menuView.hidden = YES;
        [myPath removeAllPoints];
        [pathPoint removeAllObjects];
        [myPath moveToPoint:location];
        [pathPoint addObject:[NSValue valueWithCGPoint:location]];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [myPath addLineToPoint:location];
        [pathPoint addObject:[NSValue valueWithCGPoint:location]];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [myPath addLineToPoint:location];
        [pathPoint addObject:[NSValue valueWithCGPoint:location]];
        if(selectedType == 0){
            [self showHUD];
            [myPath removeAllPoints];
            dispatch_queue_t processQueue = dispatch_queue_create("PROCESS_IMAGE", NULL);
            dispatch_async(processQueue, ^{
                //HuanVB
                int lineSize = _sliderWidth.value - 2;
                maskImage.setTo(0);
                cv::Point pt0(-1,-1);
                for (NSValue *obj in pathPoint) {
                    cv::Point pt = cv::Point([obj CGPointValue].x,[obj CGPointValue].y);
                    if (pt0.x!=-1)
                        cv::line(maskImage, pt0, pt, CV_RGB(255,255,255), lineSize);
                    pt0=pt;
                }
                [pathPoint removeAllObjects];
                CCloneStamp clone(0.7);
                cv::Mat src = images[index];
                cv::Mat dst;// = opencvImgSrc;
                //if([(UISegmentedControl *)_segmentedControl selectedSegmentIndex] == 0)
                clone.fillExemplar(src, maskImage, dst);
                //clone.inpaintCV(src, maskImage, dst);
                
                opencvImgSrc = dst.clone();
                tempImg = opencvImgSrc.clone();
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [HUD hide:YES];
                    [self hideHUD];
                    self.imageView.image = MatToUIImage(dst);
                    [self increaseIndex:true];
                });
            });
        } else {
            tapToProcess = true;
            if (pathPoint.count > 0) {
                CGPoint center = [recognizer locationInView:self.view];
                center = [self fixPanPointScrollView:center];
                self.menuView.center = center;
                self.menuView.hidden = NO;
                
            }
        }
    } else if (recognizer.state == UIGestureRecognizerStateCancelled) {
    }
    if (!shapeLayer) {
        shapeLayer = [[CAShapeLayer alloc] initWithLayer:self.view.layer];
        [self.imageView.layer addSublayer:shapeLayer];
        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        shapeLayer.lineDashPhase = 0;
        shapeLayer.lineJoin = @"round";
        shapeLayer.lineCap = @"round";
        shapeLayer.opacity = 0.6f;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        [shapeLayer setLineDashPattern:nil];
    }
    shapeLayer.lineWidth = _sliderWidth.value;
    shapeLayer.path = myPath.CGPath;
}

- (void)imageViewTapped1:(UITapGestureRecognizer *)recognizer{
//    CGPoint location = [recognizer locationInView:self.imageView];
//    location = [self fixPanPoint:location];
    
}

#pragma mark - scroll view delegate
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
}


#pragma mark - control action
- (IBAction)segmentedChanged:(id)sender {
//    [(UISegmentedControl *)sender selectedSegmentIndex];
}

- (IBAction)sliderValueChanged:(id)sender {
    shapeLayer.lineWidth = _sliderWidth.value;
}

- (IBAction)backToPlan:(id)sender {
    confirmAlert = [[STAlertView alloc] initWithTitle:NSLocalizedString(@"overwrite_original_image", nil) message:@"" cancelButtonTitle:NSLocalizedString(@"no", nil) otherButtonTitles:NSLocalizedString(@"yes", nil) cancelButtonBlock:^{
        [self.navigationController fadePopViewController];
    } otherButtonBlock:^{
        [delegate editImageComplete:opencvImgSrc];
        [self.navigationController fadePopViewController];
    }];
}

- (IBAction)backToRoot:(id)sender {
    [self.navigationController fadePopRootViewController];
}
- (IBAction)action_Undo:(id)sender {
    [self decreaseIndex];
    opencvImgSrc = images[index].clone();
    tempImg= opencvImgSrc.clone();
    self.imageView.image = MatToUIImage(opencvImgSrc);
}

- (IBAction)action_Redo:(id)sender {
    [self increaseIndex:false];
    opencvImgSrc = images[index].clone();
    tempImg= opencvImgSrc.clone();
    self.imageView.image = MatToUIImage(opencvImgSrc);
}

- (IBAction)previewAction:(id)sender {
    _previewImage.image = [self drawPreviewImage];
    _previewView.hidden = NO;
}

- (void)closePreviewModal{
    [formsheetController dismissAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        
    }];
}

- (UIImage *)drawPreviewImage
{
    previewImgDist.release();
    for(int i = (int)[layerDatasource count]-1; i>=0; i--)
    {
        [(LayerObject *)[layerDatasource objectAtIndex:i] mask]->clearCache();
        [(LayerObject *)[layerDatasource objectAtIndex:i] mask]->Paint(opencvImgSrc, previewImgDist);
    }
    if (previewImgDist.data)
    {
        return MatToUIImage(previewImgDist);
    }
    else {
        return MatToUIImage(opencvImgSrc);
    }
}
- (IBAction)selectedType:(id)sender {
    if (sender == _btSmallErase) {
        selectedType = 0;
        [_btSmallErase setBackgroundImage:[UIImage imageNamed:@"ws_BG_tools_brush"] forState:UIControlStateNormal];
        [_btBigErase setBackgroundImage:[UIImage imageNamed:@"ws_BG_tools_brush_disable"] forState:UIControlStateNormal];
    }
    else{
        selectedType = 1;
        [_btBigErase setBackgroundImage:[UIImage imageNamed:@"ws_BG_tools_brush"] forState:UIControlStateNormal];
        [_btSmallErase setBackgroundImage:[UIImage imageNamed:@"ws_BG_tools_brush_disable"] forState:UIControlStateNormal];
    }
}
- (IBAction)selectedMenuItem:(id)sender {
    [self.menuView setHidden:YES];
    if ([(OBShapedButton *)sender tag] == 4) {
        [myPath removeAllPoints];
        [pathPoint removeAllObjects];
        shapeLayer.path = myPath.CGPath;
        return;
    }
    if (tapToProcess){
        tapToProcess = false;
        [self showHUD];
        [myPath removeAllPoints];
        dispatch_queue_t processQueue = dispatch_queue_create("PROCESS_IMAGE", NULL);
        dispatch_async(processQueue, ^{
            //HuanVB
            int lineSize = _sliderWidth.value - 2;
            maskImage.setTo(0);
            cv::Point pt0(-1,-1);
            for (NSValue *obj in pathPoint) {
                cv::Point pt = cv::Point([obj CGPointValue].x,[obj CGPointValue].y);
                if (pt0.x!=-1)
                    cv::line(maskImage, pt0, pt, CV_RGB(255,255,255), lineSize);
                pt0=pt;
            }
            [pathPoint removeAllObjects];
            
            CCloneStamp clone(0.7);
            cv::Mat src = images[index];
            cv::Mat dst;// = opencvImgSrc;
            clone.fillExemplarWithDirectionControl(src, maskImage, dst, [(OBShapedButton *)sender tag]);
            
            opencvImgSrc = dst.clone();
            tempImg = opencvImgSrc.clone();
            dispatch_async(dispatch_get_main_queue(), ^{
//                [HUD hide:YES];
                [self hideHUD];
                self.imageView.image = MatToUIImage(dst);
                [self increaseIndex:true];
            });
        });
        shapeLayer.lineWidth = _sliderWidth.value;
        shapeLayer.path = myPath.CGPath;
    }
}

- (IBAction)cancelProcessing:(id)sender {
    [self hideHUD];
    CCloneStamp clone(0.7);
    clone.stopProccess(true);
}
- (IBAction)closePreview:(id)sender {
    _previewView.hidden = YES;
}
@end
