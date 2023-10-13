//
//  PlanViewController.m
//  Decorator
//
//  Created by Hoang Le on 9/16/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//
#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#endif

#import "PlanViewController.h"
#import "LayerCell.h"
#import "LayerObject.h"
#import <QuartzCore/QuartzCore.h>
//#include <opencv2/opencv.hpp>
//#include <opencv2/highgui/ios.h>
//#include <opencv2/imgcodecs/ios.h>
#import "ImageProcessor.h"
#import "BNRLoupe.h"
#import "BNRLoupeTouchGestureRecognizer.h"
#include "Mask.h"
#import "LayerPickerViewController.h"
#import "ColorFanViewController.h"
#import "PatternPickerViewController.h"
#import "SuzukafineViewController.h"
#import "UIAlertView+Blocks.h"
#import "UIImage+ResizeMagick.h"
#import "House.h"
#import "Plan.h"
#import "Material.h"
#import "LayoutViewController.h"
#import "sqlite_sequence.h"
#import "MZFormSheetController.h"
#import "ColorPickerModalViewViewController.h"
#import "MaterialDefault.h"
#import <objc/message.h>
#import "EditImageViewController.h"
#import "SettingViewController.h"
#import "STAlertView.h"
#import "CSColorViewController.h"
#import "HouseTemplateViewController.h"
#import "BarrierColorViewController.h"
#import "SuzukaRoofColorViewController.h"
#import "PickColorViewController.h"
#import "THLabel.h"

#define CLOSE_DISTANCE 40.0f
#define kStrokeColor        [UIColor blackColor]
#define kStrokeSize         (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 2.0 : 2.0)

float pointRadius = POINT_RADIUS;
const int undoMaxLevel = 15;

static int TAG_ALERT_NEWHOUSE = 100;
static int TAG_ALERT_CONFIRM_QUIT = 101;
@interface PlanViewController (){
    BNRLoupe *_loupe;
    BOOL isLoupeVisible;
    cv::Mat imgSrc;
    cv::Mat imgResizedSrc;
    cv::Mat imgDst;
    int selectedLayerIndex;
    BOOL isDismissModalView;    
    ColorFanViewController *colorFanController;
    PatternPickerViewController *patternPickerController;
    SuzukafineViewController *suzukaPickerController;
    CSColorViewController *csColorViewController;
    HouseTemplateViewController *houseTemplateViewController;
    BarrierColorViewController *barrierColorController;
    SuzukaRoofColorViewController *suzukaRoofController;
    PickColorViewController *pickColorController;
    NSMutableArray *actionJourner;
    int undoIndex;
    cv::Point startPathPoint;
    cv::Point startEraser;
    cv::Point seedPoint;
    bool isProcessing;
    int preTolerance;
    int maskProcessingCounter;
    bool isEraseLayers;
    BOOL flipToLayout;
    
    NSMutableArray *lastSavedLayer;
    float longitude;
    float latitude;
    
    NSMutableArray *planArray;
    int planIndexPage;
    Plan *planObj;
    
    NSTimer *bannerReloadTimer;
    int bannerIndex;
    
    int drawplanCount;
    int lastdrawCount;
    
    NSTimer *autosaveTimer;
    NSMutableArray *highlightLines;
    NSDictionary *patternNames;
    
    BOOL initialTime;
}
@property (nonatomic, strong) STAlertView *stAlertView;
@property (nonatomic, strong) STAlertView *confirmAlertView;
@end

@implementation PlanViewController
@synthesize layoutOrientation;

- (void)drawStartPathPoint
{
    const int startPointSize = 10;
    cv::circle(imgDst, startPathPoint, startPointSize, CV_RGB(0, 0, 255), CV_FILLED, CV_AA);
    cv::ellipse(imgDst, startPathPoint, cv::Size(startPointSize, startPointSize), 0, 45, 135, CV_RGB(0, 255, 255), CV_FILLED, CV_AA);
    cv::ellipse(imgDst, startPathPoint, cv::Size(startPointSize, startPointSize), 0, 225, 315, CV_RGB(0, 255, 255), CV_FILLED, CV_AA);
    cv::circle(imgDst, startPathPoint, startPointSize+1, CV_RGB(0, 0, 0), 1, CV_AA);
    cv::circle(imgDst, startPathPoint, startPointSize+2, CV_RGB(255, 255, 255), 1, CV_AA);
}

- (void) drawErasePathOnImage:(cv::Point)_location
{
    if (!imgDst.data) imgDst = imgResizedSrc.clone();
    cv::line(imgDst, startEraser, _location, CV_RGB(255,255,255), _slider_penWidth.value - 2);
    startEraser = _location;
    _imageView.image  = MatToUIImage(imgDst);
    _loupe.image = _imageView.image;
}

- (std::string) writeMasking:(cv::Mat)_imMask withDirectory:(NSString *)directory
{
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    documentDir = [documentDir stringByAppendingPathComponent:directory];
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:documentDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
//    std::string dir = std::string([documentDir UTF8String])+std::string("/masking_huan_")+std::string([[self generateRandomString] UTF8String])+std::string(".png");
    std::string dir = std::string([documentDir UTF8String])+std::string("/masking_huan_")+std::string([[self generateRandomString] UTF8String])+std::string(".bmp");
    documentDir = nil;
    
    try{
        cv::imwrite(dir.c_str(), _imMask);
    }
    catch(std::runtime_error &ex) {

        return std::string("");
    }
    
    return dir;
}

- (cv::Mat) getMaskedRegion {
    cv::Mat m = cv::Mat::zeros(imgResizedSrc.rows, imgResizedSrc.cols, CV_8UC1);
    for(int i = (int)[layerDatasource count]-1; i>=0; i--)
    {
        cv::Mat layerMask = [(LayerObject *)[layerDatasource objectAtIndex:i] mask]->getCurrentMask();
        if (layerMask.data){
            cv::bitwise_or(m, layerMask, m);
        }
    }
    return m;
}

- (void)drawPlan
{
//    return;
    drawplanCount += 1;
    imgDst.release();
    for(int i = (int)[layerDatasource count]-1; i>=0; i--)
    {
        [(LayerObject *)[layerDatasource objectAtIndex:i] mask]->Paint(imgResizedSrc, imgDst);
    }
    if (imgDst.data)
    {
        if (startPathPoint.x>-1)  
        {
            [self drawStartPathPoint];
        }
        if (selectedLayerIndex != -1) {
            [self drawHightlightAtIndexLayer:selectedLayerIndex];
//            [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->drawHighLight(imgDst);
        }
        _imageView.image  = MatToUIImage(imgDst);
    }
    else {
        if (selectedLayerIndex != -1) {
            [self drawHightlightAtIndexLayer:selectedLayerIndex];
//            [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->drawHighLight(imgResizedSrc);
        }
        _imageView.image  = MatToUIImage(imgResizedSrc);
    }
    
    _loupe.image = _imageView.image;
}

- (void)addAreaAction:(ACTION_TYPE)_actionType
{
    if (undoIndex>0)
    {
        [actionJourner removeObjectsInRange:NSMakeRange(undoIndex, [actionJourner count]-undoIndex-1)];
    } 
    if ([actionJourner count] >= undoMaxLevel){
        ActionObject *a = (ActionObject *)[actionJourner objectAtIndex:0];
        if(a.action_type == ACTION_TYPE::ACTION_ADDAREA){
            [(LayerObject *)[layerDatasource objectAtIndex:a.index_post] mask]->removeLastUndo();
        } else if (a.action_type == ACTION_TYPE::ACTION_ERASE_LAYERS){
            for(int i = (int)[layerDatasource count]-1; i>=0; i--)
            {
                [(LayerObject *)[layerDatasource objectAtIndex:i] mask]->removeLastUndo();
            }
        }
        [actionJourner removeObjectAtIndex:0];
        undoIndex --;
    }    
    seedPoint = cv::Point(-1, -1);
    ActionObject *ac = [[ActionObject alloc] init];
    ac.action_type = _actionType;//ACTION_TYPE::ACTION_ADDAREA;
    ac.index = selectedLayerIndex;
    ac.index_post = selectedLayerIndex;
    [actionJourner insertObject:ac atIndex:[actionJourner count]];
    undoIndex++;
    _bt_undo.enabled = YES;
    _bt_redo.enabled = NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (id)initWithImage:(UIImage *)_image withResizeImage:(BOOL)_isResizeImage andImageOrientation:(UIImageOrientation)orientation  andLayoutOrientation:(UIInterfaceOrientation)_layoutOrientation{
    if ((self = [super init])) {
        [[ImageProcessor sharedManager] setOrientSrc:orientation];
        UIImageToMat(_image,imgSrc);
        if (_isResizeImage) {
//            cv::pyrDown(imgSrc, imgSrc);
            imgSrc.copyTo(imgResizedSrc);
        }
        else
            cv::pyrDown(imgSrc, imgResizedSrc);
    }
    layoutOrientation = _layoutOrientation;
    undoIndex = -1;
    isEraserMode = NO;
    startPathPoint = cv::Point(-1, -1);
    startEraser = cv::Point(-1, -1);
    seedPoint = cv::Point(-1, -1);
    isProcessing = false;
    isEraseLayers = false;
    maskProcessingCounter = 0;
    layerDatasource = [[NSMutableArray alloc] init];
    actionJourner = [[NSMutableArray alloc] init];
    return self;
}

- (id)initWithImage:(UIImage *)_image withResizeImage:(BOOL)_isResizeImage andImageOrientation:(UIImageOrientation)orientation withHouseID:(int)_houseID andLayoutOrientation:(UIInterfaceOrientation)_layoutOrientation{
    if ((self = [self initWithImage:_image withResizeImage:_isResizeImage andImageOrientation:orientation andLayoutOrientation:_layoutOrientation])) {
        houseID = _houseID;
    }
    return self;
}

- (id)initWithImage:(UIImage *)_image withResizeImage:(BOOL)_isResizeImage andImageOrientation:(UIImageOrientation)orientation withHouseID:(int)_houseID planID:(int)_planID andLayers:(NSMutableArray *)_layers andLayoutOrientation:(UIInterfaceOrientation)_layoutOrientation{
    if ((self = [self initWithImage:_image withResizeImage:_isResizeImage andImageOrientation:orientation andLayoutOrientation:_layoutOrientation])) {
        planObj = [Plan instanceWithPrimaryKey:@(_planID)];
        houseID = _houseID;
        savedPlanID = _planID;
        isSavedPlan = YES;
        lastSavedLayer = [[NSMutableArray alloc] init];
        layerDatasource = [[NSMutableArray alloc] init];
        actionJourner = [[NSMutableArray alloc] init];
        
//        [_layers setArray:[[_layers reverseObjectEnumerator] allObjects]];
        for (Material *obj in _layers) {
            LayerObject *layer = [[LayerObject alloc] init];
            layer.type = (LAYER_TYPE)obj.type;
            layer.name = [DecoratorUtil getTypeNameByID:layer.type];
            layer.image = [DecoratorUtil getTypeImageByID:layer.type];
            layer.color = obj.colorCode;
            Color *color = [[Color alloc] init];
            color.R1 = obj.R1;
            color.G1 = obj.G1;
            color.B1 = obj.B1;
            color.No = obj.No;
            color.ColorCode = obj.colorCode;
            layer.colorValue = color;
            layer.patternImage = obj.patternImage;
            
            layer.feature = obj.feature;
            layer.gloss = obj.gloss;
            layer.pattern = obj.pattern;
            if (layer.patternImage == nil)
                layer.mask = new CMask((int)color.R1, (int)color.G1, (int)color.B1);//(0, 125, 0);
            else{
                layer.mask = new CMask(0, 125, 0);                
                cv::Mat imgPattern;
                UIImage *_i = [UIImage imageNamed:layer.patternImage];
                UIImageToMat(_i,imgPattern);
                _i = nil;
                layer.mask->setColor(imgPattern);
                imgPattern.release();
            }
//            int tol = (int)((self.thresholdSlider.value));
//            NSLog(@"threshold [%f]",self.thresholdSlider.value);
            layer.mask->setTolerance(16);
            layer.mask->iniMaskByImagePath(std::string([obj.imageLink UTF8String]));
            layer.mask->setReferenceColor((int)obj.No);
            layer.mask->setTransparent((int)obj.transparent);
            layer.transparent = obj.transparent; //QuyPV add
            
            if ([obj.colorCode isEqualToString:@"未設定"]) {
                layer.mask->setDefaultColor(true);
            }
            [layerDatasource addObject:layer];
            [lastSavedLayer addObject:obj.imageLink];
        }
    }
    return self;
}

- (id)initWithImage:(UIImage *)_image withResizeImage:(BOOL)_isResizeImage andImageOrientation:(UIImageOrientation)orientation andLongitude:(float)_longitude andLatitude:(float)_latitude andLayoutOrientation:(UIInterfaceOrientation)_layoutOrientation{
    if (self = [self initWithImage:_image withResizeImage:_isResizeImage andImageOrientation:orientation andLayoutOrientation:_layoutOrientation]) {
        longitude = _longitude;
        latitude = _latitude;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self hasTopNotch]) {
                _menuPortraitBottomConstraint.constant = 16;
                _scrollViewLeftConstraint.constant = 58;
                _scrollViewBottomConstraint.constant = -37;
            } else if (UIInterfaceOrientationIsLandscape(layoutOrientation)) {
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                    
                    _menuRightConstraint.constant = 231;
                    _menuBottomConstraint.constant = 20;
                    _tableHeightConstraint.constant = 200;
                    NSLog(@"%f %f", [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
                    CGFloat scrollHeight = 551 * ([UIScreen mainScreen].bounds.size.height - 11) / 768;
                    _scrollViewLeftConstraintPad.constant = ([UIScreen mainScreen].bounds.size.width - scrollHeight/0.75 - 199) / 2;
                    _scrollViewRightConstraintPad.constant = _scrollViewLeftConstraintPad.constant;
                    _scrollViewWidthConstraint.constant = scrollHeight/0.75;
                    _scrollViewWidthConstraint.active = YES;
                }
            }
            else{
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                    _bannerTopConstraint.active = NO;
                    _scrollViewHeightConstraint.constant = ([UIScreen mainScreen].bounds.size.width - 219)/0.75;
                    _scrollViewHeightConstraint.active = YES;
                    _scrollViewBottomConstraintPad.constant = 42;
                    _scrollViewTopConstraintPad.constant = 40;
                    
                    _menuRightConstraint.constant = 25;
                    _menuBottomConstraint.constant = 142;
                    _tableHeightConstraint.constant = 260;
                }
            }
        });
    if (!flipToLayout) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            CGRect scrollViewFrame = self.scrollView.frame;
            CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
            CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
            CGFloat minScale = MIN(scaleWidth, scaleHeight);
            self.scrollView.minimumZoomScale = minScale;
            self.scrollView.maximumZoomScale = 6.0f;
            [self.scrollView setZoomScale:minScale animated:NO];
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                [self centerContent];
            }
            //        initialTime = YES;
            _imageView.layer.cornerRadius = 20/_scrollView.zoomScale;
            _imageView.layer.masksToBounds = YES;
            [UIView animateWithDuration:0.3 animations:^{
                self.scrollView.alpha = 1;
            }];
        });
    }
    [self sliderTransarentEnable:false];
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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([autosaveTimer isValid]) {
        autosaveTimer = [NSTimer scheduledTimerWithTimeInterval:[self getAutosavetime] target:self selector:@selector(autosaveFire) userInfo:nil repeats:YES];
    }
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        _background.image = [UIImage imageNamed:@"BG_02.jpg"];
        _bannerView.image = [UIImage imageNamed:[NSString stringWithFormat:@"banner_L_0%d.jpg",bannerIndex]];
    }
    else{
        _background.image = [UIImage imageNamed:@"BG_04.jpg"];
        _bannerView.image = [UIImage imageNamed:[NSString stringWithFormat:@"banner_P_0%d.jpg",bannerIndex]];
    }
    if (flipToLayout) {
        flipToLayout = NO;
    }
    else{
        [self.thresholdSlider setValue:16];
        preTolerance = 16;
        _bt_undo.enabled = NO;
        _bt_redo.enabled = NO;
        if (houseID == 0) {
            [self showAlertCreateNewHouse];
        }
        else{
            [self configPlanArray];
            _lb_planValue.text = [NSString stringWithFormat:@"Plan %d",planIndexPage+1];
        }
        [self drawPlan];
    }
    if (selectedLayerIndex != -1) {
        [self drawHightlightAtIndexLayer:selectedLayerIndex];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [autosaveTimer invalidate];
    if (! flipToLayout){
        for (LayerObject *obj in layerDatasource) {
            delete obj.mask;
        }
    }
}

- (IBAction)deleteThisPlan:(id)sender {
    [Plan executeUpdateQuery:[NSString stringWithFormat:@"DELETE from Plan WHERE planID = %d",planIndex]];
    [self configPlanArray];
    [self updatePlanIndex];
    if (planArray.count == 0) {
        [House executeUpdateQuery:[NSString stringWithFormat:@"DELETE from House WHERE houseID = %d",houseID]];
        [self.navigationController fadePopRootViewController];
    }
    else{
        [self loadPlanAtIndex:planIndexPage isNext:YES];
    }
}

- (void)updatePlanIndex{
    int count = 1;
    for (Plan *plan in planArray) {
        [Plan executeUpdateQuery:[NSString stringWithFormat:@"UPDATE Plan SET planName = 'Plan %d' where planID = %d",count,plan.planID]];
        count = count + 1;
    }
}

- (void)loadPlanAtIndex:(int)_planIndex isNext:(BOOL)_isNext{
    @try {
        self.menuView.userInteractionEnabled = NO;
        for (CAShapeLayer *highlight in highlightLines){
            [highlight removeFromSuperlayer];
        }
        [highlightLines removeAllObjects];
        for (LayerObject *obj in layerDatasource) {
            delete obj.mask;
        }
        [lastSavedLayer removeAllObjects];
        [layerDatasource removeAllObjects];
        [actionJourner removeAllObjects];
        [pointArray removeAllObjects];
        [buttonPointArray removeAllObjects];
        planObj = [planArray objectAtIndex:MIN(_planIndex, [planArray count] - 1)];
        if (planObj.applyPlan == 1) {
            [_applyIcon setImage:[UIImage imageNamed:@"iconLike20"] forState:UIControlStateNormal];
        }
        else
            [_applyIcon setImage:[UIImage imageNamed:@"iconUnlike20"] forState:UIControlStateNormal];
        undoIndex = -1;
        isEraserMode = NO;
        startPathPoint = cv::Point(-1, -1);
        startEraser = cv::Point(-1, -1);
        seedPoint = cv::Point(-1, -1);
        isProcessing = false;
        isEraseLayers = false;
        maskProcessingCounter = 0;
        savedPlanID = (int)planObj.planID;
        NSArray *layers = [Material instancesWhere:[NSString stringWithFormat:@"planID = %d",planObj.planID]];
        isSavedPlan = YES;
        lastSavedLayer = [[NSMutableArray alloc] init];
        layerDatasource = [[NSMutableArray alloc] init];
        actionJourner = [[NSMutableArray alloc] init];
        for (Material *obj in layers) {
            LayerObject *layer = [[LayerObject alloc] init];
            layer.type = (LAYER_TYPE)obj.type;
            layer.name = [DecoratorUtil getTypeNameByID:layer.type];
            layer.image = [DecoratorUtil getTypeImageByID:layer.type];
            layer.color = obj.colorCode;
            Color *color = [[Color alloc] init];
            color.R1 = obj.R1;
            color.G1 = obj.G1;
            color.B1 = obj.B1;
            color.No = obj.No;
            color.ColorCode = obj.colorCode;
            layer.colorValue = color;
            layer.patternImage = obj.patternImage;
            
            layer.feature = obj.feature;
            layer.gloss = obj.gloss;
            layer.pattern = obj.pattern;
            if (layer.patternImage == nil)
                layer.mask = new CMask((int)color.R1, (int)color.G1, (int)color.B1);//(0, 125, 0);
            else{
                layer.mask = new CMask(0, 125, 0);
                cv::Mat imgPattern;
                UIImage *_i = [UIImage imageNamed:layer.patternImage];
                UIImageToMat(_i,imgPattern);
                _i = nil;
                layer.mask->setColor(imgPattern);
                imgPattern.release();
            }
            int tol = (int)((self.thresholdSlider.value));
            layer.mask->setTolerance(tol);
            layer.mask->iniMaskByImagePath(std::string([obj.imageLink UTF8String]));
            layer.mask->setReferenceColor((int)obj.No);
            layer.mask->setTransparent((int) obj.transparent);
            layer.transparent = obj.transparent; //QuyPV add
            
            if ([obj.colorCode isEqualToString:@"未設定"]) {
                layer.mask->setDefaultColor(true);
            }
            [layerDatasource addObject:layer];
            [lastSavedLayer addObject:obj.imageLink];
        }
        planIndex = savedPlanID;
        _lb_planValue.text = planObj.planName;//[NSString stringWithFormat:@"プラン　%d",planIndex];
        selectedLayerIndex = -1;
        pointArray = [[NSMutableArray alloc] init];
        buttonPointArray = [[NSMutableArray alloc] init];
        CATransition *animation = [CATransition animation];
        animation.delegate = (id)self;
        animation.duration = 0.7;
        animation.type = @"pageCurl";
        if (_isNext) {
            animation.subtype = kCATransitionFromRight;
        }
        else
            animation.subtype = kCATransitionFromLeft;
        [[self.view layer] addAnimation:animation forKey:@"animation"];
        [_planTableView reloadData];
        [self drawPlan];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (void)reloadBannerView{
    bannerIndex += 1;
    if (bannerIndex > 4) {
        bannerIndex = 1;
    }
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        _bannerView.image = [UIImage imageNamed:[NSString stringWithFormat:@"banner_L_0%d.jpg",bannerIndex]];
    }
    else{
        _bannerView.image = [UIImage imageNamed:[NSString stringWithFormat:@"banner_P_0%d.jpg",bannerIndex]];
    }
}

- (int)getAutosavetime{
    int autosaveTime = [(NSNumber *)[[NSUserDefaults standardUserDefaults] valueForKey:kAutosaveTime] intValue];
    if (autosaveTime == 0) {
        autosaveTime = 30;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:30] forKey:kAutosaveTime];
    }
    return autosaveTime;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (UIInterfaceOrientationIsLandscape(layoutOrientation) != UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        if (UIInterfaceOrientationIsLandscape(layoutOrientation)) {
            layoutOrientation = UIInterfaceOrientationLandscapeRight;
        } else {
            layoutOrientation = UIInterfaceOrientationPortrait;
        }
        if ([[UIDevice
              currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            //            objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),layoutOrientation);
            int (*action)(id, SEL, int) = (int (*)(id, SEL, int)) objc_msgSend;
            action([UIDevice currentDevice], @selector(setOrientation:),layoutOrientation);
        }
    }
    
    _scrollView.alpha = 0;
    patternNames = @{@"外壁材_1_A":@"WB2256",@"外壁材_1_B":@"WB2256",@"外壁材_1_C":@"WB2256",@"外壁材_1_D":@"WB2256",@"外壁材_2_A":@"WB2289",@"外壁材_2_B":@"WB2289",@"外壁材_2_C":@"WB2289",@"外壁材_2_D":@"WB2289",@"外壁材_3_A":@"WB2285",@"外壁材_3_B":@"WB2285",@"外壁材_3_C":@"WB2285",@"外壁材_3_D":@"WB2285",@"外壁材_4_A":@"WB2225",@"外壁材_4_B":@"WB2225",@"外壁材_4_C":@"WB2225",@"外壁材_4_D":@"WB2225",@"外壁材_5_A":@"WB2178",@"外壁材_5_B":@"WB2178",@"外壁材_5_C":@"WB2178",@"外壁材_5_D":@"WB2178",@"外壁材_6_A":@"WB2142",@"外壁材_6_B":@"WB2142",@"外壁材_6_C":@"WB2142",@"外壁材_6_D":@"WB2142",@"外壁材_7_A":@"WB2391",@"外壁材_7_B":@"WB2391",@"外壁材_7_C":@"WB2391",@"外壁材_7_D":@"WB2391",@"外壁材_8_A":@"WB2393",@"外壁材_8_B":@"WB2393",@"外壁材_8_C":@"WB2393",@"外壁材_8_D":@"WB2393",@"外壁材_9_A":@"WB2117",@"外壁材_9_B":@"WB2117",@"外壁材_9_C":@"WB2117",@"外壁材_9_D":@"WB2117",@"外壁材_10_A":@"WB2140",@"外壁材_10_B":@"WB2140",@"外壁材_10_C":@"WB2140",@"外壁材_10_D":@"WB2140",@"外壁材_11_A":@"WB2170",@"外壁材_11_B":@"WB2170",@"外壁材_11_C":@"WB2170",@"外壁材_11_D":@"WB2170",@"外壁材_12_A":@"WB2179",@"外壁材_12_B":@"WB2179",@"外壁材_12_C":@"WB2179",@"外壁材_12_D":@"WB2179",@"外壁材_13_A":@"WB2144",@"外壁材_13_B":@"WB2144",@"外壁材_13_C":@"WB2144",@"外壁材_13_D":@"WB2144",@"外壁材_14_A":@"WB2394",@"外壁材_14_B":@"WB2394",@"外壁材_14_C":@"WB2394",@"外壁材_14_D":@"WB2394",@"外壁材_15_A":@"WB2149",@"外壁材_15_B":@"WB2149",@"外壁材_15_C":@"WB2149",@"外壁材_15_D":@"WB2149",@"外壁材_16_A":@"WB2333",@"外壁材_16_B":@"WB2333",@"外壁材_16_C":@"WB2333",@"外壁材_16_D":@"WB2333",@"外壁材_17_A":@"WB3220",@"外壁材_17_B":@"WB3220",@"外壁材_17_C":@"WB3220",@"外壁材_17_D":@"WB3220",@"外壁材_18_A":@"WB3252",@"外壁材_18_B":@"WB3252",@"外壁材_18_C":@"WB3252",@"外壁材_18_D":@"WB3252",@"外壁材_19_A":@"WB3175",@"外壁材_19_B":@"WB3175",@"外壁材_19_C":@"WB3175",@"外壁材_19_D":@"WB3175",@"外壁材_20_A":@"WB3147",@"外壁材_20_B":@"WB3147",@"外壁材_20_C":@"WB3147",@"外壁材_20_D":@"WB3147",@"外壁材_21_A":@"WB3335",@"外壁材_21_B":@"WB3335",@"外壁材_21_C":@"WB3335",@"外壁材_21_D":@"WB3335",@"外壁材_22_A":@"WB3281",@"外壁材_22_B":@"WB3281",@"外壁材_22_C":@"WB3281",@"外壁材_22_D":@"WB3281",@"外壁材_23_A":@"WB2118",@"外壁材_23_B":@"WB2118",@"外壁材_23_C":@"WB2118",@"外壁材_23_D":@"WB2118",@"外壁材_24_A":@"WB2141",@"外壁材_24_B":@"WB2141",@"外壁材_24_C":@"WB2141",@"外壁材_24_D":@"WB2141",@"外壁材_25_A":@"WB2168",@"外壁材_25_B":@"WB2168",@"外壁材_25_C":@"WB2168",@"外壁材_25_D":@"WB2168",@"外壁材_26_A":@"WB2172",@"外壁材_26_B":@"WB2172",@"外壁材_26_C":@"WB2172",@"外壁材_26_D":@"WB2172",@"外壁材_27_A":@"WB2174",@"外壁材_27_B":@"WB2174",@"外壁材_27_C":@"WB2174",@"外壁材_27_D":@"WB2174",@"外壁材_28_A":@"WB2223",@"外壁材_28_B":@"WB2223",@"外壁材_28_C":@"WB2223",@"外壁材_28_D":@"WB2223",@"外壁材_29_A":@"WB2287",@"外壁材_29_B":@"WB2287",@"外壁材_29_C":@"WB2287",@"外壁材_29_D":@"WB2287",@"外壁材_30_A":@"WB2295",@"外壁材_30_B":@"WB2295",@"外壁材_30_C":@"WB2295",@"外壁材_30_D":@"WB2295",@"外壁材_31_A":@"WB2386",@"外壁材_31_B":@"WB2386",@"外壁材_31_C":@"WB2386",@"外壁材_31_D":@"WB2386",@"外壁材_32_A":@"WB3183",@"外壁材_32_B":@"WB3183",@"外壁材_32_C":@"WB3183",@"外壁材_32_D":@"WB3183",@"外壁材_33_A":@"WB3284",@"外壁材_33_B":@"WB3284",@"外壁材_33_C":@"WB3284",@"外壁材_33_D":@"WB3284",@"外壁材_34_A":@"WB3288",@"外壁材_34_B":@"WB3288",@"外壁材_34_C":@"WB3288",@"外壁材_34_D":@"WB3288",@"外壁材_35_A":@"WB3396",@"外壁材_35_B":@"WB3396",@"外壁材_35_C":@"WB3396",@"外壁材_35_D":@"WB3396"};
    lastdrawCount = 1;
    drawplanCount = 0;
    
    bannerReloadTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(reloadBannerView) userInfo:nil repeats:YES];
    bannerIndex = 1;
    
    _formatter = [[NSDateFormatter alloc] init];
    _formatter.dateFormat = @"yyyy.MM.dd";
    
    if (planObj.applyPlan == 1) {
        [_applyIcon setImage:[UIImage imageNamed:@"iconLike20"] forState:UIControlStateNormal];
    }
    else
        [_applyIcon setImage:[UIImage imageNamed:@"iconUnlike20"] forState:UIControlStateNormal];
    _planTableView.layer.cornerRadius = 10.0f;
    _planTableView.layer.borderWidth = 0.5f;
    _planTableView.clipsToBounds = YES;
    
    _scrollView.layer.cornerRadius = 20.0f;
    _scrollView.layer.masksToBounds = YES;
    
    if (!isSavedPlan) {
        planIndex = 1;
//        _lb_planValue.text = @"新規なプラン";
    }
    else{
        planIndex = savedPlanID;
//        _lb_planValue.text = [NSString stringWithFormat:@"プラン　%d",planIndex];
    }
    
    if ([layerDatasource count] >= 10) {
        _bt_addLayer.enabled = NO;
    }
    else
        _bt_addLayer.enabled = YES;
    
    selectedLayerIndex = -1;
    pointArray = [[NSMutableArray alloc] init];
    buttonPointArray = [[NSMutableArray alloc] init];
    [self setImageViewFrame];
    [self initialImageGestures];
    [self initialLoupeGlass];
    highlightLines = [NSMutableArray array];

    [_slider_penWidth setThumbImage:[UIImage imageNamed:@"sliderThumb"] forState:UIControlStateNormal];
    [_slider_transparent setThumbImage:[UIImage imageNamed:@"sliderThumb"] forState:UIControlStateNormal];
    [_thresholdSlider setThumbImage:[UIImage imageNamed:@"sliderThumb"] forState:UIControlStateNormal];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        _lbSave.font = [UIFont systemFontOfSize:8];
        _lbUndo.font = [UIFont systemFontOfSize:8];
        _lbRedo.font = [UIFont systemFontOfSize:8];
        _lbDelete.font = [UIFont systemFontOfSize:8];
        _lbAdd.font = [UIFont systemFontOfSize:8];
        _lbEdit.font = [UIFont systemFontOfSize:8];
        _lbLayout.font = [UIFont systemFontOfSize:8];
        _lbBack.font = [UIFont systemFontOfSize:8];
    }
}

-(BOOL)hasTopNotch{
    if (@available(iOS 11.0, *)) {
        float max_safe_area_inset = MAX(MAX([[[UIApplication sharedApplication] delegate] window].safeAreaInsets.top, [[[UIApplication sharedApplication] delegate] window].safeAreaInsets.right),MAX([[[UIApplication sharedApplication] delegate] window].safeAreaInsets.bottom, [[[UIApplication sharedApplication] delegate] window].safeAreaInsets.left));
        return max_safe_area_inset >= 44.0;
    }

    return  NO;
}

- (void)autosaveFire{
    NSLog(@"TIMER FIRE");
    if (drawplanCount > lastdrawCount) {
        lastdrawCount = drawplanCount;
        [self savePlan:self];
        NSLog(@"AUTOSAVE PLAN");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _rightView.alpha = 0;
        _toolFrameView.alpha = 0;
        _planTableView.alpha = 0;
        _backgroundTool.alpha = 0;
        _view_drawMode.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _rightView.alpha = 1;
        _toolFrameView.alpha = 1;
        _planTableView.alpha = 1;
        _backgroundTool.alpha = 1;
        _view_drawMode.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)setLayoutWithOrientation:(UIInterfaceOrientation)interfaceOrientation{
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        _background.image = [UIImage imageNamed:@"BG_04.jpg"];
        _backgroundTool.image = [UIImage imageNamed:@"ws_BG_tools_P"];
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            _menuRightConstraint.constant = 25;
        }
    }
    else{
        _background.image = [UIImage imageNamed:@"BG_02.jpg"];
        _backgroundTool.image = [UIImage imageNamed:@"ws_BG_tools"];
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            _menuRightConstraint.constant = 231;
        }
    }
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _rightView.alpha = 1;
        _toolFrameView.alpha = 1;
        _planTableView.alpha = 1;
        _backgroundTool.alpha = 1;
        _view_drawMode.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)setImageViewFrame{
//    if (UIInterfaceOrientationIsLandscape(layoutOrientation)) {
////        _scrollView.frame = CGRectMake(68, 106, 713, 540);
//    }
//    else{
////        _scrollView.frame = CGRectMake(10, 160, 550, 733);
//    }
    _imageView.image  = MatToUIImage(imgResizedSrc);
//    _imageView.frame  = CGRectMake(0, 0, imgResizedSrc.cols, imgResizedSrc.rows);
    _scrollView.contentSize = CGSizeMake(imgResizedSrc.cols, imgResizedSrc.rows);//_imageView.image.size;
}

#pragma mark - initial swipe right,left in plan view

- (void)initialLoupeGlass{
    isLoupeVisible = NO;
    CGFloat edgeClearance = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? -40 : 10;
    _loupe = [[BNRLoupe alloc] initWithDiameter:150 offset:150 offsetAngle:3*M_PI_4 constraintsRect:self.view.bounds edgeClearance:edgeClearance];
    _loupe.image = _imageView.image;
}

#pragma mark - initial image gesture (zoom in, zoom out)

- (void)initialImageGestures{
//    UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
//    twoFingerTapRecognizer.numberOfTapsRequired = 1;
//    twoFingerTapRecognizer.numberOfTouchesRequired = 2;
//    twoFingerTapRecognizer.delegate = (id)self;
//    [self.scrollView addGestureRecognizer:twoFingerTapRecognizer];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panImageView:)];
    panGestureRecognizer.maximumNumberOfTouches = 1;
    panGestureRecognizer.delegate = (id)self;
    [self.scrollView addGestureRecognizer:panGestureRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    tapRecognizer.delegate = (id)self;
    [self.scrollView addGestureRecognizer:tapRecognizer];
}

#pragma mark - zoom,scale scrollview
- (void)centerScrollViewContents {
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint o = _scrollView.contentOffset;
    CGSize s = _scrollView.bounds.size;
    [_loupe setConstraintsRect:CGRectMake(o.x, o.y, s.width, s.height)];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
    
    [self refresPointer:YES];
    CGFloat imagePixelsPerScreenPixel = 1 / _scrollView.zoomScale;
    _loupe.screenToImageTransform = CGAffineTransformMakeScale(imagePixelsPerScreenPixel, imagePixelsPerScreenPixel);
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer *)recognizer {
    CGFloat newZoomScale = self.scrollView.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

- (void)refresPointer:(BOOL)_isZoomed{
    
    pointRadius = POINT_RADIUS/_scrollView.zoomScale;
    // fix bug SUZUKADECO-368
    if ([buttonPointArray count] == 0) return;
    // end fix bug
    if ([pointArray count] == 0) return;
    [self removePointPath];
    
    [myPath removeAllPoints];
    
    UIColor *fillColor;
    if (_isZoomed) {
        if (pointArray.count <= 2) {
            fillColor = [UIColor greenColor];
        }
        else
            fillColor = [UIColor yellowColor];
    }
    else if (pointArray.count < 2) {
        fillColor = [UIColor greenColor];
    }
    else
        fillColor = [UIColor yellowColor];
    for (int i = 0; i < [pointArray count]; i ++){
        NSValue * pt = [pointArray objectAtIndex:i];
        CGPoint loc = [pt CGPointValue];
        UIView *pointer = [[UIView alloc] initWithFrame:CGRectMake(loc.x - pointRadius, loc.y - pointRadius, pointRadius*2, pointRadius*2)];
        [pointer.layer addSublayer:[self drawCirclePointWithColor:fillColor]];
        pointer.tag = i;
        [self.imageView addSubview:pointer];
        [buttonPointArray addObject:pointer];

        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPoint:)];
        panGesture.maximumNumberOfTouches = 1;
        panGesture.delegate = (id)self;
        [pointer addGestureRecognizer:panGesture];
        
        if (i==0)
            [myPath moveToPoint:loc];
        else
            [myPath addLineToPoint:loc];
    }
    shapeLayer.path = myPath.CGPath;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
	{
        CGPoint location = [touch locationInView:self.imageView];
        for (UIView *point in buttonPointArray) {
            if (CGRectContainsPoint(point.frame, location)){
                return FALSE;
            }
        }
        
	}
	return TRUE;
}
- (void)imageViewTapped:(UITapGestureRecognizer *)recognizer{
    if (selectedLayerIndex == -1 || (isEraserMode && !isCreatePointMode)) {
        return;
    }
    
    CGPoint location = [recognizer locationInView:self.imageView];
    if (isCreatePointMode || isEraserMode) {
        // fix bug SUZUKADECO-255 reopen
//        for (UIView *point in buttonPointArray) {          
//            if (CGRectContainsPoint(point.frame, location)){
//                return;
//            }
//        }
        [self refresPointer:NO];
        
        UIView *point = [[UIView alloc] initWithFrame:CGRectMake(location.x - pointRadius, location.y - pointRadius, pointRadius*2, pointRadius*2)];
        if (pointArray.count <= 1) {
            [point.layer addSublayer:[self drawCirclePointWithColor:[UIColor greenColor]]];
        }
        else
            [point.layer addSublayer:[self drawCirclePointWithColor:[UIColor yellowColor]]];
        point.tag = [pointArray count];
        [self.imageView addSubview:point];
        [buttonPointArray addObject:point];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPoint:)];
        panGesture.maximumNumberOfTouches = 1;
        panGesture.delegate = (id)self;
        [point addGestureRecognizer:panGesture];
        
        if (!shapeLayer) {
            shapeLayer = [[CAShapeLayer alloc] initWithLayer:self.view.layer];
            [self.imageView.layer addSublayer:shapeLayer];
        }
        if (pointArray.count == 0) {
            myPath = [UIBezierPath bezierPath];
            [myPath moveToPoint:[recognizer locationInView:self.imageView]];
        }
        else{
            [myPath addLineToPoint:[recognizer locationInView:self.imageView]];
        }
        [pointArray addObject:[NSValue valueWithCGPoint:[recognizer locationInView:self.imageView]]];
        if (pointArray.count == 2) {
            _slider_penWidth.enabled = YES;
            _bg_scrollPen.image = [UIImage imageNamed:@"ws_scollbarOn"];
            shapeLayer.lineWidth = _slider_penWidth.value;
            shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
            shapeLayer.lineDashPhase = 0;
            shapeLayer.lineCap = @"round";
            shapeLayer.lineJoin = @"round";
            [shapeLayer setLineDashPattern:nil];
        }
        else{
            _slider_penWidth.enabled = NO;
            _bg_scrollPen.image = [UIImage imageNamed:@"ws_scollbarOff"];
            shapeLayer.lineDashPhase = 2.0f;
            shapeLayer.fillColor = [UIColor whiteColor].CGColor;
            shapeLayer.fillRule = kCAFillRuleEvenOdd;
            shapeLayer.lineWidth = 2;
            shapeLayer.strokeColor = [UIColor blackColor].CGColor;
            [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:15],[NSNumber numberWithInt:15], nil]];
        }
        shapeLayer.opacity = 0.6f;
        shapeLayer.path = myPath.CGPath;
        _bt_removeLastPoint.hidden = NO;
//        if (isEraserMode){
            _menuView.alpha = 0.6;
            _menuView.userInteractionEnabled = NO;
//        }
        if ([pointArray count] >= 2) {
            _bt_complete.hidden = NO;
        }
    }
    else{
        [self removePath];
        if (selectedLayerIndex>=0){
            [self maskProcessing:cv::Point(location.x, location.y) withAddMask:true];
            seedPoint = cv::Point(location.x, location.y);
            
        }
    }
}

- (CAShapeLayer *)drawCirclePointWithColor:(UIColor *)_fillColor{
    CAShapeLayer *circlePoint = [CAShapeLayer layer];
    CGFloat lineWidth = 1.2*pointRadius/POINT_RADIUS;
    circlePoint.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(pointRadius, pointRadius)
                                                      radius:pointRadius
                                                  startAngle:0
                                                    endAngle:DEGREES_TO_RADIANS(360)
                                                   clockwise:YES].CGPath;
    
    circlePoint.fillColor   = _fillColor.CGColor;
    circlePoint.strokeColor = [UIColor redColor].CGColor;
    circlePoint.lineWidth   = lineWidth;
    circlePoint.opacity = 0.7;
    return circlePoint;
}

- (void)panPoint:(UIPanGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        [_loupe displayInView:_scrollView];
        [_loupe setScreenPoint:[recognizer locationInView:_scrollView]];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [_loupe setScreenPoint:[recognizer locationInView:_scrollView]];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [_loupe removeFromView];
    } else if (recognizer.state == UIGestureRecognizerStateCancelled) {
        [_loupe removeFromView];
    }
    CGPoint location = [recognizer locationInView:_imageView];
    location = [self fixPanPoint:location];
    recognizer.view.center = location;
//    if (recognizer.state == UIGestureRecognizerStateChanged){
    @try {
        [pointArray replaceObjectAtIndex:recognizer.view.tag withObject:[NSValue valueWithCGPoint:location]];
        [myPath removeAllPoints];
        [myPath moveToPoint:[(NSValue *)[pointArray objectAtIndex:0] CGPointValue]];
        if ([pointArray count] == 0) {
            shapeLayer.path = myPath.CGPath;
            return;
        }
        for (int i = 1; i < [pointArray count]; i ++) {
            [myPath addLineToPoint:[(NSValue *)[pointArray objectAtIndex:i] CGPointValue]];
        }
        shapeLayer.path = myPath.CGPath;
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
//    }
}

- (CGPoint)fixPointFromScrollView:(CGPoint)_point{
    float x,y;
    x = _point.x;
    y = _point.y;
    if (_point.x < 0) {
        //        x = 0 + POINT_RADIUS;
        x = 0;
    }
    else if (_point.x > _scrollView.frame.size.width){
        //        x = _imageView.image.size.width - POINT_RADIUS;
        x = _scrollView.frame.size.width;
    }
    if (_point.y < 0) {
        //        y = 0 + POINT_RADIUS;
        y = 0;
    }
    else if (_point.y > _scrollView.frame.size.height){
        //        y = _imageView.image.size.height - POINT_RADIUS;
        y = _scrollView.frame.size.height;
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
//        x = _imageView.image.size.width - POINT_RADIUS;
        x = _imageView.image.size.width;
    }
    if (_point.y < 0) {
//        y = 0 + POINT_RADIUS;
        y = 0;
    }
    else if (_point.y > _imageView.image.size.height){
//        y = _imageView.image.size.height - POINT_RADIUS;
        y = _imageView.image.size.height;
    }
    return CGPointMake(x, y);
}

- (void) maskProcessing:(cv::Point)_location withAddMask:(bool)_add{
    [self showHUD];
    dispatch_queue_t processQueue = dispatch_queue_create("PROCESS_IMAGE", NULL);
    dispatch_async(processQueue, ^{
        bool addAction = false;
        cv::Point seedBackup = _location;
        cv::Mat layerMask = [self getMaskedRegion];
        if (_add) {
            addAction = [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->addMaskBySeed(imgSrc, imgResizedSrc, _location, false, layerMask);
            
        } else {
            [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->modifyMaskBySeed(imgSrc, imgResizedSrc, _location, false, layerMask);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self drawPlan];
            [HUD hide:YES];
            isProcessing = false;
            if (_thresholdSlider.value != preTolerance)
                _thresholdSlider.value = preTolerance;
            if (addAction)
                [self addAreaAction:ACTION_TYPE::ACTION_ADDAREA];
            seedPoint=seedBackup;
        });
    });
}

- (void)panImageView:(UIPanGestureRecognizer *)recognizer{
    if (selectedLayerIndex == -1) {
        return;
    }
    if (isCreatePointMode) {
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            [_loupe displayInView:_scrollView];
            [_loupe setScreenPoint:[recognizer locationInView:_scrollView]];
        } else if (recognizer.state == UIGestureRecognizerStateChanged) {
            [_loupe setScreenPoint:[recognizer locationInView:_scrollView]];
        } else if (recognizer.state == UIGestureRecognizerStateEnded) {
            [_loupe removeFromView];
        } else if (recognizer.state == UIGestureRecognizerStateCancelled) {
            [_loupe removeFromView];
        }
    }
    if (isCreatePointMode) {
        return;
    }
    @try {
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            for (CAShapeLayer *highlight in highlightLines){
                [highlight removeFromSuperlayer];
            }
            [highlightLines removeAllObjects];
            
            _menuView.alpha = 0.6;
            _menuView.userInteractionEnabled = NO;
            [pointArray removeAllObjects];
            [myPath removeAllPoints];
            [pointArray addObject:[NSValue valueWithCGPoint:[recognizer locationInView:self.imageView]]];
            shapeLayer.path = myPath.CGPath;
            startDraw = YES;
            
            myPath = [UIBezierPath bezierPath];
            [myPath moveToPoint:[recognizer locationInView:self.imageView]];
            if (!shapeLayer) {
                shapeLayer = [[CAShapeLayer alloc] initWithLayer:self.view.layer];
                [self.imageView.layer addSublayer:shapeLayer];
            }
            shapeLayer.lineWidth = _slider_penWidth.value;
            shapeLayer.lineCap = @"round";
            shapeLayer.lineJoin = @"round";
            shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
            shapeLayer.fillColor = [UIColor clearColor].CGColor;
            [shapeLayer setLineDashPattern:nil];
            shapeLayer.lineDashPhase = 0.0f;
            shapeLayer.opacity = 0.6f;
        }
        else if (recognizer.state == UIGestureRecognizerStateChanged){
            [pointArray addObject:[NSValue valueWithCGPoint:[recognizer locationInView:self.imageView]]];
                [myPath addLineToPoint:[recognizer locationInView:self.imageView]];
                shapeLayer.path = myPath.CGPath;
        }
        else{
            _menuView.alpha = 1.0;
            _menuView.userInteractionEnabled = YES;
            std::vector<cv::Point> polygon;
            for (NSValue *obj in pointArray) {
                polygon.push_back(cv::Point([obj CGPointValue].x,[obj CGPointValue].y));
            }
            [self removePath];
            [self removePointPath];
            if (selectedLayerIndex>=0){
                cv::Mat layerMask = [self getMaskedRegion];
                ACTION_TYPE actionType = ACTION_TYPE::ACTION_ADDAREA;
                if (_tool_eraser.selected == YES) // Fix Bug SUZUKADECO-306 //if (isEraserMode)
                {
                    if (isEraseLayers)
                    {
                        [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->eraseMaskByPolygon(imgResizedSrc, polygon, _slider_penWidth.value - 2, false, layerMask);
                        actionType = ACTION_TYPE::ACTION_ERASE_LAYERS;

                    }
                    else {
                        [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->eraseMaskByPolygon(imgResizedSrc, polygon, _slider_penWidth.value - 2, false, layerMask);
                    }
                }
                else
                {
                    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->eraseMaskByPolygon(imgResizedSrc, polygon, _slider_penWidth.value - 2, true, layerMask);
                }
                [self drawPlan];
                [self addAreaAction:actionType];
                isSavedPlan = YES;
                [self savePlanToDatabase];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"error %@",exception.description);
    }
    @finally {
    }
}

- (void)removePath{
//    [self removeFirstPoint];
    [pointArray removeAllObjects];
    [myPath removeAllPoints];
    shapeLayer.path = myPath.CGPath;
    startDraw = NO;
}

- (void)removePointPath{
    for (UIView *point in buttonPointArray) {
        [point removeFromSuperview];
    }
    // fix bug SUZUKADECO-368
    [buttonPointArray removeAllObjects];
    // end fix bug
}

- (UIImage *)imageFromLayer:(CAShapeLayer *)layer
{
    UIGraphicsBeginImageContext(layer.bounds.size);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (IBAction)eraseWidthChanged:(id)sender {
    shapeLayer.lineWidth = [(UISlider *)sender value];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

-(float)distanceFrom:(CGPoint)point1 to:(CGPoint)point2
{
    CGFloat xDist = (point2.x - point1.x);
    CGFloat yDist = (point2.y - point1.y);
    NSLog(@"%f",sqrt((xDist * xDist) + (yDist * yDist)));
    return sqrt((xDist * xDist) + (yDist * yDist));
}

- (void)drawFirstPoint:(CGPoint)_point{    
    startPathPoint = cv::Point(_point.x, _point.y);
    [self drawPlan];
}

- (void)removeFirstPoint{
    startPathPoint = cv::Point(-1, -1);
    [self drawPlan];
}

#pragma mark - Layer table datasource, delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 40;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return 30;
    } else {
        return 40;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return _headerTableView;
}

- (NSInteger)tableView:(FMMoveTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfRows = [layerDatasource count];
    if ([tableView movingIndexPath] && [[tableView movingIndexPath] section] != [[tableView initialIndexPathForMovingRow] section]) {
        if (section == [[tableView movingIndexPath] section]) {
			numberOfRows++;
		}
		else if (section == [[tableView initialIndexPathForMovingRow] section]) {
			numberOfRows--;
		}
    }
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return 40;
    } else {
        return 60;
    }
}

- (UITableViewCell *)tableView:(FMMoveTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellIdentifier";
    LayerCell *tbCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIView *selectionColor;
    if (tbCell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LayerCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[LayerCell class]])
            {
                tbCell = (LayerCell *)currentObject;
                break;
            }
        }
        
        selectionColor = [[UIView alloc] init];
        selectionColor.tag = 401;
        tbCell.selectedBackgroundView = selectionColor;
    } else
        selectionColor = [tbCell viewWithTag:401];
    if ([_planTableView indexPathIsMovingIndexPath:indexPath]) {
        [tbCell prepareForMove];
    } else {
        if ([_planTableView movingIndexPath]) {
            indexPath = [_planTableView adaptedIndexPathForRowAtIndexPath:indexPath];
        }
        LayerObject *object = [layerDatasource objectAtIndex:indexPath.row];
        if (object.type == LAYER_NOPAINT) {
            object.colorValue = nil;
            object.patternImage = nil;
            object.color = @"-";
            selectionColor.backgroundColor = [UIColor colorWithRed:(210/255.0) green:(204/255.0) blue:(102/255.0) alpha:1];
            [tbCell.colorButton setBackgroundColor:[UIColor colorWithRed:(210/255.0) green:(204/255.0) blue:(102/255.0) alpha:1]];
        } else {
            if (object.colorValue == nil) {
                object.color = @"-";
            }
            [tbCell.colorButton addTarget:self action:@selector(selectColor:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        if (object.patternImage != nil) {
            tbCell.lblColor.text = [self getPatternImage:object.patternImage].length > 0 ? [self getPatternImage:object.patternImage] : object.patternImage;
        } else {
            tbCell.lblColor.text = NSLocalizedString(object.color, nil);
        }
        
        tbCell.layerImage.image = [UIImage imageNamed:object.image];
        tbCell.lbName.text = NSLocalizedString(object.name, nil);
            
        [tbCell.layerButton setTag:indexPath.row];
        [tbCell.layerButton addTarget:self action:@selector(selectLayerType:) forControlEvents:UIControlEventTouchUpInside];
        
        [tbCell.colorButton setTag:indexPath.row];
        if (object.patternImage.length > 0) {
            [tbCell.colorButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:object.patternImage]]];
            [tbCell.layerButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:object.patternImage]]];
            selectionColor.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:object.patternImage]];
        } else if (object.colorValue != nil) {
            if (object.colorValue.R1 == 0 && object.colorValue.G1 == 0 && object.colorValue.B1 == 0) {
                selectionColor.backgroundColor = [UIColor colorWithRed:(210/255.0) green:(204/255.0) blue:(102/255.0) alpha:1];
                [tbCell.colorButton setBackgroundColor:[UIColor colorWithRed:(210/255.0) green:(204/255.0) blue:(102/255.0) alpha:1]];
            } else {
                [tbCell.colorButton setBackgroundColor:[UIColor colorWithRed:object.colorValue.R1/255.0f green:object.colorValue.G1/255.0f blue:object.colorValue.B1/255.0f alpha:1]];
                selectionColor.backgroundColor = [UIColor colorWithRed:object.colorValue.R1/255.0f green:object.colorValue.G1/255.0f blue:object.colorValue.B1/255.0f alpha:1];
            }
            
            [tbCell.layerButton setBackgroundColor:tbCell.colorButton.backgroundColor];
        } else {
            selectionColor.backgroundColor = [UIColor colorWithRed:(210/255.0) green:(204/255.0) blue:(102/255.0) alpha:1];
            [tbCell.colorButton setBackgroundColor:[UIColor colorWithRed:(210/255.0) green:(204/255.0) blue:(102/255.0) alpha:1]];
            [tbCell.layerButton setBackgroundColor:tbCell.colorButton.backgroundColor];
        }
        
        [self setLabelStyle:tbCell.lbName];
        [self setLabelStyle:tbCell.lblColor];
        tbCell.lbName.letterSpacing = 2;
        tbCell.lblColor.letterSpacing = 2;
    }
    
    return tbCell;
}

// doing
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_planTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0] animated:YES];
    LayerCell *tbCell = [tableView cellForRowAtIndexPath:indexPath];
    tbCell.layerButton.backgroundColor = tbCell.colorButton.backgroundColor;
    selectedLayerIndex = (int)indexPath.row;
    [self setSliderTransparentValue];
    [self drawHightlightAtIndexLayer:selectedLayerIndex];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    LayerCell *tbCell = [tableView cellForRowAtIndexPath:indexPath];
    tbCell.layerButton.backgroundColor = tbCell.colorButton.backgroundColor;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return NSLocalizedString(@"delete", nil);
}

- (void)drawHightlightAtIndexLayer:(int)_indexLayer{
    for (CAShapeLayer *highlight in highlightLines){
        [highlight removeFromSuperlayer];
    }
    [highlightLines removeAllObjects];
    
    std::vector<std::vector<cv::Point>> region;
    ((LayerObject *)[layerDatasource objectAtIndex:_indexLayer]).mask->getHighLightRegion(region);
    if (region.size() == 0) {
        return;
    }
    UIBezierPath *path = [UIBezierPath bezierPath];
//    for (int i=0;i<region.size();i++){
        CAShapeLayer *highlight = [[CAShapeLayer alloc] initWithLayer:self.imageView.layer];
        highlight.lineDashPhase = 2.0f;
        highlight.lineWidth = 1.0f;
        highlight.strokeColor = [UIColor colorWithWhite:0.2 alpha:1].CGColor;
        highlight.fillColor = [UIColor clearColor].CGColor;
        [highlight setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:15],[NSNumber numberWithInt:15], nil]];
    for (int i=0;i<region.size();i++){
        for (int j=0; j<region[i].size(); j++) {
            if (j==0) {
                [path moveToPoint:CGPointMake(region[i][j].x, region[i][j].y)];
            }
            else
                [path addLineToPoint:CGPointMake(region[i][j].x, region[i][j].y)];
        }
    }
        [path closePath];
        highlight.path = path.CGPath;
        [self.imageView.layer addSublayer:highlight];
        [highlightLines addObject:highlight];
        
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
        pathAnimation.fromValue = (id)[UIColor colorWithWhite:0.8 alpha:1].CGColor;
        pathAnimation.toValue = (id)[UIColor colorWithWhite:0.2 alpha:1].CGColor;
        
        //        CABasicAnimation *dashRun = [CABasicAnimation animationWithKeyPath:@"lineDashPhase"];
        //        [dashRun setFromValue:[NSNumber numberWithFloat:0.0f]];
        //        [dashRun setToValue:[NSNumber numberWithFloat:10.0f]];
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.duration = 0.4f;
        group.repeatCount = HUGE_VALF;
        group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        group.animations = [NSArray arrayWithObjects:pathAnimation, nil];
        [highlight addAnimation:group forKey:@"allAnimation"];
 //   }
}

- (void) deleteMask:(int)_maskIndex {
    [self sliderTransarentEnable:false]; //QuyPV add
    // HuanVB
    int lastUndo = (int)[actionJourner count] - 1 - undoIndex;
    NSMutableIndexSet *indexesToDelete = [NSMutableIndexSet indexSet];
    NSUInteger currentIndex = 0;
    for (ActionObject *obj in actionJourner) {
        if (obj.index_post==_maskIndex){
            [indexesToDelete addIndex:currentIndex];
            currentIndex++;
            undoIndex --;
        }
        else if (obj.index_post>_maskIndex){
            obj.index_post--;
        }
    }
    [actionJourner removeObjectsAtIndexes:indexesToDelete];
    undoIndex += lastUndo;
    if (undoIndex <0){
        undoIndex =-1;
        _bt_undo.enabled = NO;
    }
    if (undoIndex >= [actionJourner count]-1){
        undoIndex = (int)[actionJourner count]-1;
        _bt_redo.enabled = NO;
    }
    //  endl HuanVB
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removePath];
        [self removePointPath];
        _bt_complete.hidden = YES;
        _bt_removeLastPoint.hidden = YES;
        if (indexPath.row == selectedLayerIndex || layerDatasource.count == 1) {
            for (CAShapeLayer *highlight in highlightLines){
                [highlight removeFromSuperlayer];
            }
            [highlightLines removeAllObjects];
            selectedLayerIndex=-1;
        }
        for (Plan *plan in planArray) {
            NSArray *materials = [Material instancesWhere:[NSString stringWithFormat:@"planID = %d",plan.planID]];
            @try {
                [Material executeUpdateQuery:[NSString stringWithFormat:@"DELETE from Material where materialID = %lld",[(Material *)[materials objectAtIndex:indexPath.row] materialID]]];
            }
            @catch (NSException *exception) {
            }
            @finally {
            }
        }
        
        LayerObject *obj = [layerDatasource objectAtIndex:indexPath.row];
        delete obj.mask;
        [layerDatasource removeObjectAtIndex:indexPath.row];
        [self deleteMask:(int)indexPath.row];
        
        // fix bug SUZUKADECO-368 -- when delete mask then path is showed
        [self removePath];
        [self removePointPath];
        // end 
        
        selectedLayerIndex=-1;
        [_planTableView setEditing:NO];
//        [_planTableView reloadData];
        [_planTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        seedPoint = cv::Point(-1,-1);
        [self drawPlan];
        
        if ([layerDatasource count] < 10) {
            [_bt_addLayer setEnabled:YES];
        }
    }
}


- (BOOL)moveTableView:(FMMoveTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    LayerObject *tempObj = [layerDatasource objectAtIndex:fromIndexPath.row];
    [layerDatasource removeObjectAtIndex:fromIndexPath.row];
    [layerDatasource insertObject:tempObj atIndex:toIndexPath.row];
    selectedLayerIndex = (int)toIndexPath.row;
    
    for (Plan *plan in planArray) {
        NSMutableArray *materials = [NSMutableArray arrayWithArray:[Material instancesWhere:[NSString stringWithFormat:@"planID = %d",plan.planID] ]];
        @try {
            [Material executeUpdateQuery:[NSString stringWithFormat:@"DELETE FROM $T WHERE planID = %d",plan.planID]];
            Material *materialToMove = [materials objectAtIndex:fromIndexPath.row];
            [materials removeObjectAtIndex:fromIndexPath.row];
            [materials insertObject:materialToMove atIndex:toIndexPath.row];
            NSArray *materialsToSave = [NSArray arrayWithArray:materials];
            for (Material *material in materialsToSave) {
                Material *newMaterial = [Material new];
                newMaterial.planID = material.planID;
                newMaterial.type = material.type;
                newMaterial.colorCode = material.colorCode;
                newMaterial.feature = material.feature;
                newMaterial.gloss = material.gloss;
                newMaterial.pattern = material.pattern;
                newMaterial.isSelected = material.isSelected;
                newMaterial.imageLink = material.imageLink;
                newMaterial.patternImage = material.patternImage;
                newMaterial.R1 = material.R1;
                newMaterial.G1 = material.G1;
                newMaterial.B1 = material.B1;
                newMaterial.No = material.No;
                [newMaterial save];
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    
    [_planTableView reloadData];
    // HuanVB
    for (ActionObject *obj in actionJourner) {
        if (obj.index_post == fromIndexPath.row)
            obj.index_post = (int)toIndexPath.row;
        else{
            if (fromIndexPath.row < toIndexPath.row){
                if ((fromIndexPath.row<obj.index_post)&&(obj.index_post<=toIndexPath.row))
                    obj.index_post--;
            }
            else if ((fromIndexPath.row>obj.index_post)&&(obj.index_post>=toIndexPath.row))
                obj.index_post++;
        }
    }
    [self drawPlan];
    // end HuanVB
}

- (NSIndexPath *)moveTableView:(FMMoveTableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - select color type, color

- (void)selectLayerType:(id)sender{
    LayerCell *currentCell = (LayerCell *)[[[[(UIButton *)sender superview] superview] superview] superview];
    NSIndexPath *currentIndexPath = [_planTableView indexPathForCell:currentCell];
    if (![_planTableView indexPathForSelectedRow] || currentIndexPath.row != [_planTableView indexPathForSelectedRow].row) {
        currentCell.layerButton.backgroundColor = currentCell.colorButton.backgroundColor;
        [_planTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0] animated:YES];
        selectedLayerIndex = (int)currentIndexPath.row;
        [_planTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        [self setSliderTransparentValue];
        [self drawHightlightAtIndexLayer:selectedLayerIndex];
        return;
    }
    LayerPickerViewController *layerPicker = [[LayerPickerViewController alloc] init];
    layerPicker.currentLayes = [[NSArray alloc] initWithArray:layerDatasource];
    layerPicker.modalPresentationStyle = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? UIModalPresentationFormSheet : UIModalPresentationOverFullScreen;
    layerPicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    layerPicker.delegate = (id)self;
    [self presentViewController:layerPicker animated:YES completion:^{
    }];
}

- (void)selectedLayerType:(LayerObject *)_layerObj{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    LayerObject *selectedObject = [layerDatasource objectAtIndex:selectedLayerIndex];
    if ((_layerObj.type < LAYER_WALL || _layerObj.type > LAYER_WALL3) && (selectedObject.type >= LAYER_WALL && selectedObject.type <= LAYER_WALL3)) {
        if (selectedObject.patternImage.length > 0) {
            RIButtonItem *cancelButton = [RIButtonItem itemWithLabel:NSLocalizedString(@"no", nil) action:^{
                
            }];
            RIButtonItem *acceptButton = [RIButtonItem itemWithLabel:NSLocalizedString(@"yes", nil) action:^{
                _layerObj.color = @"未設定";
                _layerObj.colorValue.R1 = 210;
                _layerObj.colorValue.G1 = 204;
                _layerObj.colorValue.B1 = 102;
                _layerObj.colorValue.ColorCode = @"未設定";
                _layerObj.patternImage = nil;
                [selectedObject setType:_layerObj.type];
                [selectedObject setName:_layerObj.name];
                [selectedObject setImage:_layerObj.image];
                [selectedObject setColorValue:_layerObj.colorValue];
                [selectedObject setColor:_layerObj.color];
                [selectedObject setPatternImage:_layerObj.patternImage];
                [self setDefaultMaterialValue:selectedObject isPattern:NO];
                [selectedObject mask]->setColor(210,204,102);
                
                [_planTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
                [_planTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                if (_layerObj.type == 0)
                {
                    [selectedObject mask]->setNonePainting(true);
                }
                else
                {
                    [selectedObject mask]->setNonePainting(false);
                }
                [self drawPlan];
                for (Plan *plan in planArray) {
                    NSArray *materials = [Material instancesWhere:[NSString stringWithFormat:@"planID = %d",plan.planID]];
                    @try {
                        int64_t materialID = [(Material *)[materials objectAtIndex:selectedLayerIndex] materialID];
                        Material *material = [Material instanceWithPrimaryKey:@(materialID)];
                        if (material.type >= LAYER_WALL && material.type <= LAYER_WALL3) {
                            if (material.patternImage.length > 0) {
                                material.type = _layerObj.type;
                                material.R1 = _layerObj.colorValue.R1;
                                material.G1 = _layerObj.colorValue.G1;
                                material.B1 = _layerObj.colorValue.B1;
                                material.patternImage = nil;
                                material.feature = selectedObject.feature;
                                material.gloss = selectedObject.gloss;
                                material.pattern = selectedObject.pattern;
                                material.colorCode = _layerObj.color;
                            }
                            else{
                                material.type = _layerObj.type;
                                material.feature = selectedObject.feature;
                                material.gloss = selectedObject.gloss;
                                material.pattern = selectedObject.pattern;
                            }
                        }
                        else{
                            material.type = _layerObj.type;
                            material.feature = selectedObject.feature;
                            material.gloss = selectedObject.gloss;
                            material.pattern = selectedObject.pattern;
                        }
                        [material save];
                    }
                    @catch (NSException *exception) {
                        
                    }
                    @finally {
                    }
                }
            }];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"replace_color_confirmation", nil) cancelButtonItem:cancelButton otherButtonItems:acceptButton, nil];
            [alert show];
            return;
        }
    }
    else{
        
    }
    [selectedObject setType:_layerObj.type];
    [selectedObject setName:_layerObj.name];
    [selectedObject setImage:_layerObj.image];
    if (selectedObject.patternImage.length > 0) {
        [self setDefaultMaterialValue:selectedObject isPattern:YES];
    }
    else
        [self setDefaultMaterialValue:selectedObject isPattern:NO];
    for (Plan *plan in planArray) {
        NSArray *materials = [Material instancesWhere:[NSString stringWithFormat:@"planID = %d",plan.planID] ];
        @try {
            int64_t materialID = [(Material *)[materials objectAtIndex:selectedLayerIndex] materialID];
            Material *material = [Material instanceWithPrimaryKey:@(materialID)];
            if (material.type >= LAYER_WALL && material.type <= LAYER_WALL3) {
                if (material.patternImage.length > 0) {
                    _layerObj.color = @"未設定";
                    _layerObj.colorValue.R1 = 210;
                    _layerObj.colorValue.G1 = 204;
                    _layerObj.colorValue.B1 = 102;
                    _layerObj.colorValue.ColorCode = @"未設定";
                    _layerObj.patternImage = nil;
                    material.type = _layerObj.type;
                    material.R1 = _layerObj.colorValue.R1;
                    material.G1 = _layerObj.colorValue.G1;
                    material.B1 = _layerObj.colorValue.B1;
                    material.patternImage = nil;
                    material.feature = selectedObject.feature;
                    material.gloss = selectedObject.gloss;
                    material.pattern = selectedObject.pattern;
                    material.colorCode = _layerObj.color;
                }
                else{
                    material.type = _layerObj.type;
                    material.feature = selectedObject.feature;
                    material.gloss = selectedObject.gloss;
                    material.pattern = selectedObject.pattern;
                }
            }
            else{
                material.type = _layerObj.type;
                material.feature = selectedObject.feature;
                material.gloss = selectedObject.gloss;
                material.pattern = selectedObject.pattern;
            }
            [material save];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
        }
    }
    
    [_planTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    [_planTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    if (_layerObj.type == 0)
    {
        [selectedObject mask]->setNonePainting(true);
    }
    else
    {
        [selectedObject mask]->setNonePainting(false);
    }
    [self drawPlan];
}

- (void)closeLayerPicker{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)selectColor:(id)sender{
    LayerCell *currentCell = (LayerCell *)[[[[(UIButton *)sender superview] superview] superview] superview];
    currentCell.layerButton.backgroundColor = currentCell.colorButton.backgroundColor;
    NSIndexPath *currentIndexPath = [_planTableView indexPathForCell:currentCell];
    [self openColorPickerWithRow:(int)currentIndexPath.row];
}

- (void)openColorPickerWithRow:(int)_row{
    @try {
        if (![_planTableView indexPathForSelectedRow] || _row != [_planTableView indexPathForSelectedRow].row) {
            [_planTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0] animated:YES];
            selectedLayerIndex = _row;
            [_planTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            [self setSliderTransparentValue];
            [self drawHightlightAtIndexLayer:selectedLayerIndex];
            return;
        }
    }
    @catch (NSException *exception) {
        [_planTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0] animated:YES];
        selectedLayerIndex = 0;
        [_planTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        [self setSliderTransparentValue];
        [self drawHightlightAtIndexLayer:selectedLayerIndex];
        return;
    }
    @finally {
    }
    
    LayerObject *object = [layerDatasource objectAtIndex:selectedLayerIndex];
    ColorPickerModalViewViewController *colorModal;
    if (object.type < LAYER_WALL || object.type > LAYER_WALL3) {
        colorModal = [[ColorPickerModalViewViewController alloc] initWithHidePatternColorWithLayerObject:object andOrientation:layoutOrientation withLayerCount:(int)[layerDatasource count]];
    }
    else
        colorModal = [[ColorPickerModalViewViewController alloc] initWithLayer:object andOrientation:layoutOrientation withLayerCount:(int)[layerDatasource count]];
    flipToLayout = YES;
    colorModal.delegate = (id)self;

    colorModal.modalPresentationStyle = UIModalPresentationOverFullScreen;
    colorModal.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:colorModal animated:YES completion:nil];
}

- (void)closeColorPicker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectColorType:(int)_type tranferLayer:(LayerObject *)_layer{
    [self dismissViewControllerAnimated:YES completion:^{
        [self processSelectColorType:_type tranferLayer:_layer];
    }];
}

- (void)processSelectColorType:(int)_type tranferLayer:(LayerObject *)_layer{
    switch (_type) {
        case LCT_SUZUKAFINE:{
            if ([(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->getNonePainting()) {
                [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->setNonePainting(false);
            }
            if (!colorFanController) {
                colorFanController = [[ColorFanViewController alloc] initWithFrame:self.view.frame andLayerSelected:_layer];
                colorFanController.delegate = (id)self;
            }
            colorFanController.modalPresentationStyle = UIModalPresentationOverFullScreen;
            colorFanController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:colorFanController animated:YES completion:nil];
//            [UIView transitionWithView:colorFanController.view duration:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
//                [self.view addSubview:colorFanController.view];
//            } completion:^(BOOL finished) {
//
//            }];
        }
            break;
        case LCT_TYPE2:{
            if ([(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->getNonePainting()) {
                [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->setNonePainting(false);
            }
            if (!suzukaPickerController) {
                suzukaPickerController = [[SuzukafineViewController alloc] initWithFrame:self.view.frame andLayer:_layer];
                suzukaPickerController.delegate = (id)self;
            }
            [UIView transitionWithView:suzukaPickerController.view duration:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.view addSubview:suzukaPickerController.view];
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
        case LCT_TYPE3:{
            if ([(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->getNonePainting()) {
                [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->setNonePainting(false);
            }
            if (!patternPickerController) {
                patternPickerController = [[PatternPickerViewController alloc] initWithFrame:self.view.frame andLayer:_layer];
                patternPickerController.delegate = (id)self;
            }
            [UIView transitionWithView:patternPickerController.view duration:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.view addSubview:patternPickerController.view];
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
        case LCT_CSTYPE:{
            if ([(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->getNonePainting()) {
                [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->setNonePainting(false);
            }
            if (!csColorViewController) {
                csColorViewController = [[CSColorViewController alloc] initWithFrame:self.view.frame andLayer:_layer];
                csColorViewController.delegate = (id)self;
            }
            [UIView transitionWithView:csColorViewController.view duration:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.view addSubview:csColorViewController.view];
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
        case LCT_HOUSE_TEMPLATE:{
            if ([(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->getNonePainting()) {
                [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->setNonePainting(false);
            }
            if (!houseTemplateViewController) {
                if (self.view.frame.size.width > self.view.frame.size.height) {
                    houseTemplateViewController = [[HouseTemplateViewController alloc] initWithNibName:@"HouseTemplateViewController" bundle:nil withFrame:self.view.frame andLayer:_layer];
//                    houseTemplateViewController = [[HouseTemplateViewControllerLandscape alloc] initWithFrame:self.view.frame andLayer:_layer];
                }
                else{
                    houseTemplateViewController = [[HouseTemplateViewController alloc] initWithNibName:@"HouseTemplateViewController_Potrait" bundle:nil withFrame:self.view.frame andLayer:_layer];
//                    houseTemplateViewController = [[HouseTemplateViewControllerPortrait alloc] initWithFrame:self.view.frame andLayer:_layer];
                }
                houseTemplateViewController.delegate = (id)self;
            }
            [UIView transitionWithView:houseTemplateViewController.view duration:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.view addSubview:houseTemplateViewController.view];
            } completion:^(BOOL finished) {
            }];
        }
            break;
        case LCT_NOPAINT:{
            [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->setNonePainting(true);
            [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setColor:@"-"];
            [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setColorValue:nil];
            [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setPatternImage:nil];
            [_planTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
            [self drawPlan];
            [_planTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
            break;
        case LCT_BARRIER:{
            if ([(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->getNonePainting()) {
                [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->setNonePainting(false);
            }
            if (!barrierColorController) {
                barrierColorController = [[BarrierColorViewController alloc] initWithFrame:self.view.frame andLayer:_layer];
                barrierColorController.delegate = (id)self;
            }
            [UIView transitionWithView:barrierColorController.view duration:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.view addSubview:barrierColorController.view];
            } completion:^(BOOL finished) {
                
            }];
            
        }
            break;
        case LCT_SUZUKAROOF: {
            if ([(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->getNonePainting()) {
                [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->setNonePainting(false);
            }
            if (!suzukaRoofController) {
                suzukaRoofController = [[SuzukaRoofColorViewController alloc] initWithFrame:self.view.frame andLayer:_layer];
                suzukaRoofController.delegate = (id)self;
            }
            [UIView transitionWithView:suzukaRoofController.view duration:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.view addSubview:suzukaRoofController.view];
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
        case LCT_PICKCOLOR: {
            if ([(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->getNonePainting()) {
                [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->setNonePainting(false);
            }
            if (!pickColorController) {
                pickColorController = [[PickColorViewController alloc] initWithFrame:self.view.frame andLayer:_layer];
                pickColorController.currentImage = _imageView.image;
                pickColorController.delegate = (id)self;
            }
            [UIView transitionWithView:pickColorController.view duration:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.view addSubview:pickColorController.view];
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - House Template delegate
- (void)selectedHouseTemplate:(HouseTemplate *)_template{
    [UIView transitionWithView:houseTemplateViewController.view duration:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [houseTemplateViewController.view removeFromSuperview];
    } completion:^(BOOL finished) {
        houseTemplateViewController = nil;
        [self removePath];
        [self removePointPath];
        _bt_complete.hidden = YES;
        _bt_removeLastPoint.hidden = YES;
        for (CAShapeLayer *highlight in highlightLines){
            [highlight removeFromSuperlayer];
        }
        [highlightLines removeAllObjects];
        @try {
//            LayerObject *layer = layerDatasource[selectedLayerIndex];
//            if (layer.type != LAYER_WALL && layer.type != LAYER_WALL2 && layer.type != LAYER_ROOF && layer.type != LAYER_GUTTER) {
//                [layerDatasource removeObjectAtIndex:selectedLayerIndex];
//            }
//            selectedLayerIndex=-1;
//            if ([layerDatasource count] < 10) {
//                [_bt_addLayer setEnabled:YES];
//            }
            
            int layerindex = 0;
            BOOL isExist = NO;
            for (LayerObject *layer in layerDatasource) {
                if (layer.type == LAYER_WALL) {
                    isExist = YES;
                    break;
                }
                layerindex += 1;
            }
            if (!isExist && [(LayerObject *)layerDatasource[selectedLayerIndex] type] == LAYER_UNSET) {
                layerindex = selectedLayerIndex;
                isExist = YES;
            }
            if (isExist) {
                LayerObject *wall1Layer = layerDatasource[layerindex];
                wall1Layer.type = LAYER_WALL;
                wall1Layer.name = NSLocalizedString(@"外壁①", nil);
                wall1Layer.image = @"layer_wall";
                wall1Layer.color = _template.wall2Code;
                wall1Layer.patternImage = nil;
                Color *wall1ColorValue = [[Color alloc] init];
                wall1ColorValue.R1 = _template.wall2R;
                wall1ColorValue.G1 = _template.wall2G;
                wall1ColorValue.B1 = _template.wall2B;
                wall1ColorValue.ColorCode = _template.wall2Code;
                wall1Layer.colorValue = wall1ColorValue;
                [self setDefaultMaterialValue:wall1Layer isPattern:NO];
                wall1Layer.mask->setColor((int)wall1ColorValue.R1, (int)wall1ColorValue.G1, (int)wall1ColorValue.B1);
            }
            else{
                LayerObject *wall1Layer = [[LayerObject alloc] init];
                wall1Layer.type = LAYER_WALL;
                wall1Layer.name = NSLocalizedString(@"外壁①", nil);
                wall1Layer.image = @"layer_wall";
                wall1Layer.color = _template.wall2Code;
                wall1Layer.patternImage = nil;
                Color *wall1ColorValue = [[Color alloc] init];
                wall1ColorValue.R1 = _template.wall2R;
                wall1ColorValue.G1 = _template.wall2G;
                wall1ColorValue.B1 = _template.wall2B;
                wall1ColorValue.ColorCode = _template.wall2Code;
                wall1Layer.colorValue = wall1ColorValue;
                [self setDefaultMaterialValue:wall1Layer isPattern:NO];
                wall1Layer.mask = new CMask();
                int wall2Tol = (int)((self.thresholdSlider.value));
                wall1Layer.mask->setTolerance(wall2Tol);
                wall1Layer.mask->setColor((int)wall1ColorValue.R1, (int)wall1ColorValue.G1, (int)wall1ColorValue.B1);
                [layerDatasource addObject:wall1Layer];
                
                for (Plan *plan in planArray) {
                    Material *wall1Material = [Material new];
                    wall1Material.planID = plan.planID;
                    wall1Material.type = wall1Layer.type;
                    wall1Material.R1 = wall1Layer.colorValue.R1;
                    wall1Material.G1 = wall1Layer.colorValue.G1;
                    wall1Material.B1 = wall1Layer.colorValue.B1;
                    wall1Material.No = wall1Layer.colorValue.No;
                    wall1Material.patternImage = wall1Layer.patternImage;
                    wall1Material.feature = wall1Layer.feature;
                    wall1Material.gloss = wall1Layer.gloss;
                    wall1Material.pattern = wall1Layer.pattern;
                    if (wall1Material.patternImage.length > 0) {
                        wall1Material.colorCode = wall1Layer.patternImage;
                    }
                    else
                        wall1Material.colorCode = wall1Layer.color;
                    wall1Material.imageLink = @"";
                    [wall1Material save];
                }
            }
            
            layerindex = 0;
            isExist = NO;
            for (LayerObject *layer in layerDatasource) {
                if (layer.type == LAYER_WALL2) {
                    isExist = YES;
                    break;
                }
                layerindex += 1;
            }
            if (!isExist && [(LayerObject *)layerDatasource[selectedLayerIndex] type] == LAYER_UNSET) {
                layerindex = selectedLayerIndex;
                isExist = YES;
            }
            if (isExist) {
                LayerObject *wall2Layer = layerDatasource[layerindex];
                wall2Layer.type = LAYER_WALL2;
                wall2Layer.name = NSLocalizedString(@"外壁②", nil);
                wall2Layer.image = @"layer_wall";
                wall2Layer.color = _template.wall1Code;
                wall2Layer.patternImage = nil;
                Color *wall2ColorValue = [[Color alloc] init];
                wall2ColorValue.R1 = _template.wall1R;
                wall2ColorValue.G1 = _template.wall1G;
                wall2ColorValue.B1 = _template.wall1B;
                wall2ColorValue.ColorCode = _template.wall1Code;
                wall2Layer.colorValue = wall2ColorValue;
                [self setDefaultMaterialValue:wall2Layer isPattern:NO];
                wall2Layer.mask->setColor((int)wall2ColorValue.R1, (int)wall2ColorValue.G1, (int)wall2ColorValue.B1);
            }
            else{
                LayerObject *wall2Layer = [[LayerObject alloc] init];
                wall2Layer.type = LAYER_WALL2;
                wall2Layer.name = NSLocalizedString(@"外壁②", nil);
                wall2Layer.image = @"layer_wall";
                wall2Layer.color = _template.wall1Code;
                wall2Layer.patternImage = nil;
                Color *wall2ColorValue = [[Color alloc] init];
                wall2ColorValue.R1 = _template.wall1R;
                wall2ColorValue.G1 = _template.wall1G;
                wall2ColorValue.B1 = _template.wall1B;
                wall2ColorValue.ColorCode = _template.wall1Code;
                wall2Layer.colorValue = wall2ColorValue;
                [self setDefaultMaterialValue:wall2Layer isPattern:NO];
                wall2Layer.mask = new CMask();
                int wall1Tol = (int)((self.thresholdSlider.value));
                wall2Layer.mask->setTolerance(wall1Tol);
                wall2Layer.mask->setColor((int)wall2ColorValue.R1, (int)wall2ColorValue.G1, (int)wall2ColorValue.B1);
                [layerDatasource addObject:wall2Layer];
                
                for (Plan *plan in planArray) {
                    Material *wall2Material = [Material new];
                    wall2Material.planID = plan.planID;
                    wall2Material.type = wall2Layer.type;
                    wall2Material.R1 = wall2Layer.colorValue.R1;
                    wall2Material.G1 = wall2Layer.colorValue.G1;
                    wall2Material.B1 = wall2Layer.colorValue.B1;
                    wall2Material.No = wall2Layer.colorValue.No;
                    wall2Material.patternImage = wall2Layer.patternImage;
                    wall2Material.feature = wall2Layer.feature;
                    wall2Material.gloss = wall2Layer.gloss;
                    wall2Material.pattern = wall2Layer.pattern;
                    if (wall2Material.patternImage.length > 0) {
                        wall2Material.colorCode = wall2Layer.patternImage;
                    }
                    else
                        wall2Material.colorCode = wall2Layer.color;
                    wall2Material.imageLink = @"";
                    [wall2Material save];
                }
            }
            
            layerindex = 0;
            isExist = NO;
            for (LayerObject *layer in layerDatasource) {
                if (layer.type == LAYER_ROOF) {
                    isExist = YES;
                    break;
                }
                layerindex += 1;
            }
            if (!isExist && [(LayerObject *)layerDatasource[selectedLayerIndex] type] == LAYER_UNSET) {
                layerindex = selectedLayerIndex;
                isExist = YES;
            }
            if (isExist) {
                LayerObject *roofLayer = layerDatasource[layerindex];
                roofLayer.type = LAYER_ROOF;
                roofLayer.name = NSLocalizedString(@"屋根", nil);
                roofLayer.image = @"layer_roof";
                roofLayer.color = _template.roofCode;
                roofLayer.patternImage = nil;
                Color *roofColorValue = [[Color alloc] init];
                roofColorValue.R1 = _template.roofR;
                roofColorValue.G1 = _template.roofG;
                roofColorValue.B1 = _template.roofB;
                roofColorValue.ColorCode = _template.roofCode;
                roofLayer.colorValue = roofColorValue;
                [self setDefaultMaterialValue:roofLayer isPattern:NO];
                roofLayer.mask->setColor((int)roofColorValue.R1, (int)roofColorValue.G1, (int)roofColorValue.B1);
            }
            else{
                LayerObject *roofLayer = [[LayerObject alloc] init];
                roofLayer.type = LAYER_ROOF;
                roofLayer.name = NSLocalizedString(@"屋根", nil);
                roofLayer.image = @"layer_roof";
                roofLayer.color = _template.roofCode;
                roofLayer.patternImage = nil;
                Color *roofColorValue = [[Color alloc] init];
                roofColorValue.R1 = _template.roofR;
                roofColorValue.G1 = _template.roofG;
                roofColorValue.B1 = _template.roofB;
                roofColorValue.ColorCode = _template.roofCode;
                roofLayer.colorValue = roofColorValue;
                [self setDefaultMaterialValue:roofLayer isPattern:NO];
                roofLayer.mask = new CMask();
                int roofTol = (int)((self.thresholdSlider.value));
                roofLayer.mask->setTolerance(roofTol);
                roofLayer.mask->setColor((int)roofColorValue.R1, (int)roofColorValue.G1, (int)roofColorValue.B1);
                [layerDatasource addObject:roofLayer];
                
                for (Plan *plan in planArray) {
                    Material *roofMaterial = [Material new];
                    roofMaterial.planID = plan.planID;
                    roofMaterial.type = roofLayer.type;
                    roofMaterial.R1 = roofLayer.colorValue.R1;
                    roofMaterial.G1 = roofLayer.colorValue.G1;
                    roofMaterial.B1 = roofLayer.colorValue.B1;
                    roofMaterial.No = roofLayer.colorValue.No;
                    roofMaterial.patternImage = roofLayer.patternImage;
                    roofMaterial.feature = roofLayer.feature;
                    roofMaterial.gloss = roofLayer.gloss;
                    roofMaterial.pattern = roofLayer.pattern;
                    if (roofMaterial.patternImage.length > 0) {
                        roofMaterial.colorCode = roofLayer.patternImage;
                    }
                    else
                        roofMaterial.colorCode = roofLayer.color;
                    roofMaterial.imageLink = @"";
                    [roofMaterial save];
                }
            }
            
            layerindex = 0;
            isExist = NO;
            for (LayerObject *layer in layerDatasource) {
                if (layer.type == LAYER_GUTTER) {
                    isExist = YES;
                    break;
                }
                layerindex += 1;
            }
            if (!isExist && [(LayerObject *)layerDatasource[selectedLayerIndex] type] == LAYER_UNSET) {
                layerindex = selectedLayerIndex;
                isExist = YES;
            }
            if (isExist) {
                LayerObject *pipeLayer = layerDatasource[layerindex];
                pipeLayer.type = LAYER_GUTTER;
                pipeLayer.name = NSLocalizedString(@"雨樋", nil);
                pipeLayer.image = @"layer_gutter";
                pipeLayer.color = _template.pipeCode;
                pipeLayer.patternImage = nil;
                Color *pipeColorValue = [[Color alloc] init];
                pipeColorValue.R1 = _template.pipeR;
                pipeColorValue.G1 = _template.pipeG;
                pipeColorValue.B1 = _template.pipeB;
                pipeColorValue.ColorCode = _template.pipeCode;
                pipeLayer.colorValue = pipeColorValue;
                [self setDefaultMaterialValue:pipeLayer isPattern:NO];
                pipeLayer.mask->setColor((int)pipeColorValue.R1, (int)pipeColorValue.G1, (int)pipeColorValue.B1);
            }
            else{
                LayerObject *pipeLayer = [[LayerObject alloc] init];
                pipeLayer.type = LAYER_GUTTER;
                pipeLayer.name = NSLocalizedString(@"雨樋", nil);
                pipeLayer.image = @"layer_gutter";
                pipeLayer.color = _template.pipeCode;
                pipeLayer.patternImage = nil;
                Color *pipeColorValue = [[Color alloc] init];
                pipeColorValue.R1 = _template.pipeR;
                pipeColorValue.G1 = _template.pipeG;
                pipeColorValue.B1 = _template.pipeB;
                pipeColorValue.ColorCode = _template.pipeCode;
                pipeLayer.colorValue = pipeColorValue;
                [self setDefaultMaterialValue:pipeLayer isPattern:NO];
                pipeLayer.mask = new CMask();
                int pipeTol = (int)((self.thresholdSlider.value));
                pipeLayer.mask->setTolerance(pipeTol);
                pipeLayer.mask->setColor((int)pipeColorValue.R1, (int)pipeColorValue.G1, (int)pipeColorValue.B1);
                [layerDatasource addObject:pipeLayer];

                for (Plan *plan in planArray) {
                    Material *pipeMaterial = [Material new];
                    pipeMaterial.planID = plan.planID;
                    pipeMaterial.type = pipeLayer.type;
                    pipeMaterial.R1 = pipeLayer.colorValue.R1;
                    pipeMaterial.G1 = pipeLayer.colorValue.G1;
                    pipeMaterial.B1 = pipeLayer.colorValue.B1;
                    pipeMaterial.No = pipeLayer.colorValue.No;
                    pipeMaterial.patternImage = pipeLayer.patternImage;
                    pipeMaterial.feature = pipeLayer.feature;
                    pipeMaterial.gloss = pipeLayer.gloss;
                    pipeMaterial.pattern = pipeLayer.pattern;
                    if (pipeMaterial.patternImage.length > 0) {
                        pipeMaterial.colorCode = pipeLayer.patternImage;
                    }
                    else
                        pipeMaterial.colorCode = pipeLayer.color;
                    pipeMaterial.imageLink = @"";
                    [pipeMaterial save];
                }
            }
            
            selectedLayerIndex = (int)layerDatasource.count - 1;
            [_planTableView reloadData];
            [_planTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            seedPoint = cv::Point(-1,-1);
            [self drawPlan];
            isSavedPlan = YES;
            [self savePlanToDatabase];
            
            if ([layerDatasource count] >= 10) {
                [_bt_addLayer setEnabled:NO];
            }
        }
        @catch (NSException *exception) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[exception description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        @finally {
        }
    }];
}

- (void)dismissHouseTemplateViewController{
    [UIView transitionWithView:houseTemplateViewController.view duration:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [houseTemplateViewController.view removeFromSuperview];
    } completion:^(BOOL finished) {
        houseTemplateViewController = nil;
        [self openColorPickerWithRow:selectedLayerIndex];
    }];
}

#pragma mark - Pattern delegate
- (void)closePatternPickerView:(BOOL)_isChangePattern{
    [UIView transitionWithView:patternPickerController.view duration:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [patternPickerController.view removeFromSuperview];
    } completion:^(BOOL finished) {
        patternPickerController = nil;
        if (!_isChangePattern) {
            [self openColorPickerWithRow:selectedLayerIndex];
        }
    }];
}

- (void)selectedPattern:(NSString *)_patternStr{
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setColor:_patternStr];
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setColorValue:nil];
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setPatternImage:_patternStr];
    [self setDefaultMaterialValue:(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] isPattern:YES];
    [_planTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    //HuanVB
    cv::Mat imgPattern;
    UIImage *_i = [UIImage imageNamed:_patternStr];
    UIImageToMat(_i,imgPattern);
    _i = nil;
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->setColor(imgPattern);
    imgPattern.release();
    [self drawPlan];
    //end HuanVB
    [_planTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)cancelSelectPatternWithLayer:(LayerObject *)_layer{
    [self cancelChangeColorWithLayer:_layer];
}

#pragma mark - SuzukaColor delegate

- (void)closeSuzukaPickerView:(BOOL)_isChangeColor{
    [UIView transitionWithView:suzukaPickerController.view duration:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [suzukaPickerController.view removeFromSuperview];
    } completion:^(BOOL finished) {
        suzukaPickerController = nil;
        if (!_isChangeColor) {
            [self openColorPickerWithRow:selectedLayerIndex];
        }
    }];
}
- (void)selectedSuzukaColor:(Color *)_color{
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setColor:_color.ColorCode];
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setColorValue:_color];
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setPatternImage:nil];
    [self setDefaultMaterialValue:(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] isPattern:NO];
    [_planTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    //HuanVB
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->setColor((int)[(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] colorValue].R1,(int)[(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] colorValue].G1,(int)[(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] colorValue].B1);
    [self drawPlan];
    //end HuanVB
    [_planTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark - JPMA Color delegate

- (void)closeColorFanController:(BOOL)_isChangeColor{
//    [UIView transitionWithView:colorFanController.view duration:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        [colorFanController.view removeFromSuperview];
//    } completion:^(BOOL finished) {
//        colorFanController = nil;
//        if (!_isChangeColor) {
//            [self openColorPickerWithRow:selectedLayerIndex];
//        }
//    }];
    [colorFanController dismissViewControllerAnimated:YES completion:^{
        colorFanController = nil;
        if (!_isChangeColor) {
            [self openColorPickerWithRow:selectedLayerIndex];
        }
    }];
}

- (void)selectedColorValue:(Color *)_colorValue{
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setColor:_colorValue.ColorCode];
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setColorValue:_colorValue];
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setPatternImage:nil];
    [self setDefaultMaterialValue:(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] isPattern:NO];
    [_planTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->setColor((int)[(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] colorValue].R1,(int)[(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] colorValue].G1,(int)[(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] colorValue].B1);
    [self drawPlan];
    [_planTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)cancelSelectJPMAColor:(LayerObject *)_layer{
    [self cancelChangeColorWithLayer:_layer];
}

#pragma mark - Pick Color delegate
- (void)dismissPickColorController:(BOOL)_isChangeColor {
    [UIView transitionWithView:csColorViewController.view duration:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [pickColorController.view removeFromSuperview];
    } completion:^(BOOL finished) {
        pickColorController = nil;
        [self openColorPickerWithRow:selectedLayerIndex];
    }];
}

- (void)selectedPickColor:(Color *)_color {
    [UIView transitionWithView:csColorViewController.view duration:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [pickColorController.view removeFromSuperview];
    } completion:^(BOOL finished) {
        pickColorController = nil;
        [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setColor:_color.ColorCode];
        [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setColorValue:_color];
        [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setPatternImage:nil];
        [self setDefaultMaterialValue:(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] isPattern:NO];
        [_planTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        //HuanVB
        [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->setColor((int)[(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] colorValue].R1,(int)[(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] colorValue].G1,(int)[(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] colorValue].B1);
        [self drawPlan];
        //end HuanVB
        [_planTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }];
}

#pragma mark - CSColor delegate

- (void)dismissCSColorController:(BOOL)_isChangeColor{
    [UIView transitionWithView:csColorViewController.view duration:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [csColorViewController.view removeFromSuperview];
    } completion:^(BOOL finished) {
        csColorViewController = nil;
        if (!_isChangeColor) {
            [self openColorPickerWithRow:selectedLayerIndex];
        }
    }];
}

- (void)selectedCSColor:(Color *)_color{
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setColor:_color.ColorCode];
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setColorValue:_color];
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setPatternImage:nil];
    [self setDefaultMaterialValue:(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] isPattern:NO];
    [_planTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    //HuanVB
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->setColor((int)[(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] colorValue].R1,(int)[(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] colorValue].G1,(int)[(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] colorValue].B1);
    [self drawPlan];
    //end HuanVB
    [_planTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)cancelSelectCSColorWithLayer:(LayerObject *)_layer{
    [self cancelChangeColorWithLayer:_layer];
}

#pragma mark - Suzuka Roof delegate
- (void)dismissSuzukaRoofColorController:(BOOL)_isChangeColor{
    [UIView transitionWithView:suzukaRoofController.view duration:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [suzukaRoofController.view removeFromSuperview];
    } completion:^(BOOL finished) {
        suzukaRoofController = nil;
        if (!_isChangeColor) {
            [self openColorPickerWithRow:selectedLayerIndex];
        }
    }];
}

- (void)selectedSuzukaRoofColor:(Color *)_color{
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setColor:_color.ColorCode];
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setColorValue:_color];
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setPatternImage:nil];
    [self setDefaultMaterialValue:(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] isPattern:NO];
    [_planTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    //HuanVB
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->setColor((int)[(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] colorValue].R1,(int)[(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] colorValue].G1,(int)[(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] colorValue].B1);
    [self drawPlan];
    //end HuanVB
    [_planTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)cancelSelectSuzukaRoofColorWithLayer:(LayerObject *)_layer {
    [self cancelChangeColorWithLayer:_layer];
}

#pragma mark - BarrierColor delegate

- (void)dismissBarrierColorController:(BOOL)_isChangeColor{
    [UIView transitionWithView:barrierColorController.view duration:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [barrierColorController.view removeFromSuperview];
    } completion:^(BOOL finished) {
        barrierColorController = nil;
        if (!_isChangeColor) {
            [self openColorPickerWithRow:selectedLayerIndex];
        }
    }];
}

- (void)selectedBarrierPattern:(NSString *)_barrierPattern{
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setColor:_barrierPattern];
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setColorValue:nil];
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setPatternImage:_barrierPattern];
    [self setDefaultMaterialValue:(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] isPattern:YES];
    [_planTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    cv::Mat imgPattern;
    UIImage *_i = [UIImage imageNamed:_barrierPattern];
    UIImageToMat(_i,imgPattern);
    _i = nil;
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->setColor(imgPattern);
    imgPattern.release();
    [self drawPlan];
    [_planTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

- (void)cancelBarrierPattern:(LayerObject *)_layer{
    [self cancelChangeColorWithLayer:_layer];
}

#pragma mark - Cancel all change color action

- (void)cancelChangeColorWithLayer:(LayerObject *)_layer{
    if (_layer.patternImage) {
        [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setColor:_layer.color];
        [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setColorValue:nil];
        [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setPatternImage:_layer.patternImage];
        [self setDefaultMaterialValue:(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] isPattern:YES];
        [_planTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        cv::Mat imgPattern;
        UIImage *_i = [UIImage imageNamed:_layer.patternImage];
        UIImageToMat(_i,imgPattern);
        _i = nil;
        [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->setColor(imgPattern);
        imgPattern.release();
        [self drawPlan];
        [_planTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
    else if (_layer.colorValue){
        [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setColor:_layer.colorValue.ColorCode];
        [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setColorValue:_layer.colorValue];
        [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] setPatternImage:nil];
        [self setDefaultMaterialValue:(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] isPattern:NO];
        [_planTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->setColor((int)[(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] colorValue].R1,(int)[(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] colorValue].G1,(int)[(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] colorValue].B1);
        [self drawPlan];
        [_planTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
}
#pragma mark - BUTTONS ACTION

#pragma mark - add path button

- (IBAction)drawModeChanged:(id)sender {
    isEraserMode = [(UISwitch *)sender isOn];
}

#pragma mark - logout button

- (IBAction)action_logout:(id)sender {
    isSavedPlan = YES;
    [self savePlanToDatabase];
//    [self.navigationController popToRootViewControllerWithFlipStyle:MPFlipStyleDirectionBackward];
    [self.navigationController fadePopRootViewController];
}

- (IBAction)undoAction:(id)sender {
    
    seedPoint = cv::Point(-1,-1);
    if (undoIndex >= [actionJourner count]-1){
        undoIndex = (int)[actionJourner count]-1;
    }
    if (undoIndex>=0){
        _bt_redo.enabled= YES;
        ActionObject *a = (ActionObject *)[actionJourner objectAtIndex:undoIndex];
        if(a.action_type==ACTION_TYPE::ACTION_ADDAREA){
            [(LayerObject *)[layerDatasource objectAtIndex:a.index_post] mask]->undo();
            [self drawPlan];
        }
        else if (a.action_type == ACTION_TYPE::ACTION_ERASE_LAYERS){
            for(int i = (int)[layerDatasource count]-1; i>=0; i--)
            {
                [(LayerObject *)[layerDatasource objectAtIndex:i] mask]->undo();
            }
            [self drawPlan];
        }
        
        undoIndex--;
        if (undoIndex < 0){
            undoIndex = 0;
            _bt_undo.enabled = NO;
        }
    }
}

- (IBAction)redoAction:(id)sender {
    if (undoIndex < 0){
        _bt_redo.enabled = NO;
        return;
    }
    if (undoIndex<[actionJourner count]){
        _bt_undo.enabled = YES;
        ActionObject *a = (ActionObject *)[actionJourner objectAtIndex:undoIndex];
        if(a.action_type == ACTION_TYPE::ACTION_ADDAREA){
            [(LayerObject *)[layerDatasource objectAtIndex:a.index_post] mask]->redo();
            [self drawPlan];
        } else if (a.action_type==ACTION_TYPE::ACTION_ERASE_LAYERS){
            for(int i = (int)[layerDatasource count]-1; i>=0; i--)
            {
                [(LayerObject *)[layerDatasource objectAtIndex:i] mask]->redo();
            }
            [self drawPlan];
        }
        undoIndex++;
        if (undoIndex>[actionJourner count]-1)
        {
            undoIndex = (int)[actionJourner count]-1;
            _bt_redo.enabled = NO;
        }
    }
}
- (IBAction)thresholdChanged:(id)sender {
     if (isProcessing)
     {
         _thresholdSlider.value = preTolerance;
         return;
     }
    int tol = (int)(([(UISlider *)sender value]));
    if (tol==preTolerance) return;
    preTolerance = tol;
    for (LayerObject *obj in layerDatasource) {
        obj.mask->setTolerance(tol);
    }
    if (seedPoint.x>=0){
        if (!isProcessing){
            isProcessing = true;
            [self maskProcessing:seedPoint withAddMask:false];
            
        }
    }
}


- (void)showHUD{
    if (HUD == nil)
    {
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.mode = MBProgressHUDModeIndeterminate;
        HUD.labelText = @"Processing...";
        HUD.dimBackground = YES;
        HUD.delegate = self;
    }
    [HUD show:YES];
}


- (IBAction)action_removeLastPoint:(id)sender {
    [(UIView *)[buttonPointArray lastObject] removeFromSuperview];
    [buttonPointArray removeLastObject];
    [pointArray removeLastObject];
    [myPath removeAllPoints];
    if ([pointArray count] == 0) {
        shapeLayer.path = myPath.CGPath;
        _bt_removeLastPoint.hidden = YES;
        _menuView.alpha = 1.0;
        _menuView.userInteractionEnabled = YES;
        return;
    }
    [myPath moveToPoint:[(NSValue *)[pointArray objectAtIndex:0] CGPointValue]];
    for (int i = 1; i < [pointArray count]; i ++) {
        [myPath addLineToPoint:[(NSValue *)[pointArray objectAtIndex:i] CGPointValue]];
    }
    [self refresPointer:NO];
    if (pointArray.count == 2) {
        _slider_penWidth.enabled = YES;
        _bg_scrollPen.image = [UIImage imageNamed:@"ws_scollbarOn"];
        shapeLayer.lineWidth = _slider_penWidth.value;
        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        shapeLayer.lineDashPhase = 0;
        shapeLayer.lineCap = @"round";
        shapeLayer.lineJoin = @"round";
        [shapeLayer setLineDashPattern:nil];
        for (UIView *pointView in buttonPointArray) {
            ((CAShapeLayer *)[pointView.layer.sublayers lastObject]).fillColor = [UIColor greenColor].CGColor;
        }
    }
    else{
        _slider_penWidth.enabled = NO;
        _bg_scrollPen.image = [UIImage imageNamed:@"ws_scollbarOff"];
        shapeLayer.lineDashPhase = 2.0f;
        shapeLayer.fillColor = [UIColor whiteColor].CGColor;
        shapeLayer.fillRule = kCAFillRuleEvenOdd;
        shapeLayer.lineWidth = 2;
        shapeLayer.strokeColor = [UIColor blackColor].CGColor;
        [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:15],[NSNumber numberWithInt:15], nil]];
    }
    shapeLayer.path = myPath.CGPath;
    if ([pointArray count] < 2) {
        _bt_complete.hidden = YES;
    }
}

- (IBAction)action_CompletePointPath:(id)sender {
    _bt_complete.hidden = YES;
    _menuView.alpha = 1.0;
    _menuView.userInteractionEnabled = YES;
    _bt_removeLastPoint.hidden = YES;
    BOOL isPointLine = NO;
    if ([buttonPointArray count] == 2) {
        isPointLine = YES;
    }
    for (UIView *point in buttonPointArray) {
        [point removeFromSuperview];
    }
    [buttonPointArray removeAllObjects];
    [myPath removeAllPoints];
    
    shapeLayer.path = myPath.CGPath;
    std::vector<cv::Point> polygon;
    for (NSValue *value in pointArray) {
        polygon.push_back(cv::Point([value CGPointValue].x,[value CGPointValue].y));
    }
    ACTION_TYPE actionType = ACTION_TYPE::ACTION_ADDAREA;
    cv::Mat layerMask = [self getMaskedRegion];
    if (_tool_handEraser.selected == YES) // Fix Bug SUZUKADECO-306 //if (isEraserMode)
    {       
        if (isEraseLayers)
        {
            if (isPointLine) {
                [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->eraseMaskByPolygon(imgResizedSrc, polygon, _slider_penWidth.value - 2, false, layerMask);
            }
            else {
                [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->addMaskByPoints(imgResizedSrc, polygon, false, layerMask);
            }
            actionType = ACTION_TYPE::ACTION_ERASE_LAYERS;
        }
        else {
            if (isPointLine) {
                [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->eraseMaskByPolygon(imgResizedSrc, polygon, _slider_penWidth.value - 2, false, layerMask);
            }
            else{
                [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->addMaskByPoints(imgResizedSrc, polygon, false, layerMask);
            }
        }
    }
    else{
        if (isPointLine) {
            [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->eraseMaskByPolygon(imgResizedSrc, polygon, _slider_penWidth.value - 2, true, layerMask);
        }
        else {
            [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->addMaskByPoints(imgResizedSrc, polygon, true, layerMask);
        }
    }
    [pointArray removeAllObjects];
    [self drawPlan];
    [self addAreaAction:actionType];
    isSavedPlan = YES;
    [self savePlanToDatabase];
}

- (IBAction)slider_penWidthChanged:(id)sender {
    if (isCreatePointMode) {
        if (pointArray.count == 2) {
            shapeLayer.lineWidth = _slider_penWidth.value;
            shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
            shapeLayer.lineDashPhase = 0;
            shapeLayer.lineCap = @"round";
            shapeLayer.lineJoin = @"round";
            [shapeLayer setLineDashPattern:nil];
        }
    }
    [self updatePenWidthValue:_slider_penWidth];
}
- (IBAction)slider_transparentChanged:(id)sender {
    NSLog(@"%f",_slider_transparent.value);
    if (selectedLayerIndex>=0 && layerDatasource.count>=1){
        LayerObject * layer = (LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex];
        [ layer mask]->setTransparent((int(_slider_transparent.value)));
        [layer mask]->clearCache();
        layer.transparent = int(_slider_transparent.value);
        [self drawPlan];
    }
        isSavedPlan = YES;
        [self savePlanToDatabase];
    
}
- (void)setSliderTransparentValue{
    [self sliderTransarentEnable:true];
    _slider_transparent.value = ((LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex]).transparent;
      [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->setTransparent((int(_slider_transparent.value)));
    [(LayerObject *)[layerDatasource objectAtIndex:selectedLayerIndex] mask]->clearCache();
    [self drawPlan];
}
- (void)sliderTransarentEnable: (BOOL) _value{
    if (_value){
        _slider_transparent.enabled = true;
        _bg_scrollTransparent.image = [UIImage imageNamed:@"ws_scollbarOn"];
    }else{
        _slider_transparent.enabled = false;
        _bg_scrollTransparent.image = [UIImage imageNamed:@"ws_scollbarOff"];
    }
}

- (void)updatePenWidthValue:(NYSliderPopover *)_penslider{
    CGSize size = _penslider.popover.frame.size;
    _penslider.popover.circle.frame = CGRectMake((size.width - _penslider.value)/2, (size.height - _penslider.value)/2, _penslider.value, _penslider.value);
    CGRect box = CGRectMake(0, 0, _penslider.value, _penslider.value);
    UIBezierPath *ballBezierPath = [UIBezierPath bezierPathWithOvalInRect:box];
    _penslider.popover.circle.path = ballBezierPath.CGPath;
}

- (IBAction)switch_showLoupeChanged:(id)sender {
//    isLoupeVisible = _switch_showLoupe.isOn;
}

- (IBAction)setNewLayer:(id)sender {
    if ([layerDatasource count] >= 10) {
        return;
    }
    @try {
        [self removePath];
        [self removePointPath];
        
        LayerObject *layer = [[LayerObject alloc] init];
        layer.type = LAYER_UNSET;
        layer.name = @"未設定";
        layer.color = @"未設定";
        Color *colorValue = [[Color alloc] init];
        colorValue.R1 = 210;
        colorValue.G1 = 204;
        colorValue.B1 = 102;
        colorValue.ColorCode = @"未設定";
        layer.colorValue = colorValue;
        [self setDefaultMaterialValue:layer isPattern:NO];
        layer.mask = new CMask();//(0, 125, 0);
        int tol = (int)((self.thresholdSlider.value));
        layer.mask->setTolerance(tol);
        
        layer.transparent = 50; //QuyPV add
        
        for (Plan *plan in planArray) {
            Material *newMaterial = [Material new];
            newMaterial.planID = plan.planID;
            newMaterial.type = layer.type;
            newMaterial.R1 = layer.colorValue.R1;
            newMaterial.G1 = layer.colorValue.G1;
            newMaterial.B1 = layer.colorValue.B1;
            newMaterial.No = layer.colorValue.No;
            newMaterial.patternImage = layer.patternImage;
            
            newMaterial.feature = layer.feature;
            newMaterial.gloss = layer.gloss;
            newMaterial.pattern = layer.pattern;
            
            newMaterial.transparent = layer.transparent; //QuyPV add
            
            if (newMaterial.patternImage.length > 0) {
                newMaterial.colorCode = layer.patternImage;
            }
            else
                newMaterial.colorCode = layer.color;
            newMaterial.imageLink = @"";
            [newMaterial save];
        }
        

//        [layerDatasource insertObject:layer atIndex:0];
        [layerDatasource addObject:layer];
        selectedLayerIndex = layerDatasource.count - 1;
        [_planTableView reloadData];
//        [_planTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [_planTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedLayerIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        for (ActionObject *obj in actionJourner) {
            obj.index_post++;
            obj.index++;
        }
        if ([layerDatasource count] >= 10) {
            [(UIButton *)sender setEnabled:NO];
        }
        
        [self setSliderTransparentValue];//QuyPV add
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:[exception description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    @finally {
        
    }
}

- (IBAction)setEditingMode:(id)sender {
    [_planTableView setEditing:!_planTableView.isEditing animated:YES];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == alertView.cancelButtonIndex) {
        if (alertView.tag == TAG_ALERT_NEWHOUSE) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"save_plan_confirmation", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"no", nil) otherButtonTitles:NSLocalizedString(@"yes", nil), nil];
            alert.tag = TAG_ALERT_CONFIRM_QUIT;
            [alert show];
        }
        else if (alertView.tag == TAG_ALERT_CONFIRM_QUIT){
//            [self.navigationController popToRootViewControllerWithFlipStyle:MPFlipStyleDirectionBackward];
            [self.navigationController fadePopRootViewController];
        }
        return;
    }
    if (alertView.tag == TAG_ALERT_CONFIRM_QUIT) {
        [self showAlertCreateNewHouse];
        return;
    }
    if (alertView.tag == TAG_ALERT_NEWHOUSE) {
        //save new house
        NSString *houseName = [alertView textFieldAtIndex:0].text;
        if (houseName.length <= 0) {
            [self showAlertCreateNewHouse];
            return;
        }
        houseID = [self createNewHousePlan:houseName];
        if (houseID != 0) {
            [self savePlanToDatabase];
        }
        return;
    }
}

#pragma mark - database
- (NSDateFormatter *)formatter {
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = @"yyyy.MM.dd";
    }
    return _formatter;
}

- (void)showAlertCreateNewHouse{
    if (IS_OS_8_OR_LATER){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"enter_plan_name", nil) message:NSLocalizedString(@"enter_plan_name_description", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.text = NSLocalizedString(@"home", nil);
            textField.delegate = (id)self;
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"back", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:^{
            }];
            UIAlertController *cancelAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"creating_plan", nil) message:@"" preferredStyle:UIAlertControllerStyleAlert];
            [cancelAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"no", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self.navigationController fadePopRootViewController];
            }]];
            [cancelAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self showAlertCreateNewHouse];
            }]];
            [self presentViewController:cancelAlert animated:YES completion:^{
                
            }];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"continue", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *houseName = [(UITextField *)[alertController.textFields objectAtIndex:0] text];
            if (houseName.length <= 0) {
                [self showAlertCreateNewHouse];
                return;
            }
            houseID = [self createNewHousePlan:houseName];
            if (houseID != 0) {
                [self savePlanToDatabase];
            }
        }]];
        [self presentViewController:alertController animated:YES completion:^{
            
        }];
    }
    else{
//    STAlertView *stAlertView = nil;
        _stAlertView = [[STAlertView alloc] initWithTitle:NSLocalizedString(@"enter_plan_name", nil) message:NSLocalizedString(@"enter_plan_name_description", nil) textFieldHint:@"" textFieldValue:NSLocalizedString(@"home", nil) cancelButtonTitle:NSLocalizedString(@"back", nil) otherButtonTitles:NSLocalizedString(@"continue", nil) cancelButtonBlock:^{
            _confirmAlertView = [[STAlertView alloc] initWithTitle:NSLocalizedString(@"creating_plan", nil) message:@"" cancelButtonTitle:NSLocalizedString(@"no", nil) otherButtonTitles:NSLocalizedString(@"yes", nil) cancelButtonBlock:^{
                [self.navigationController fadePopRootViewController];
            } otherButtonBlock:^{
                [self showAlertCreateNewHouse];
            }];
        } otherButtonBlock:^(NSString * result) {
            NSString *houseName = result;
            if (houseName.length <= 0) {
                [self showAlertCreateNewHouse];
                return;
            }
            houseID = [self createNewHousePlan:houseName];
            if (houseID != 0) {
                [self savePlanToDatabase];
            }
        }];
        [_stAlertView.alertView textFieldAtIndex:0].delegate = (id)self;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    UITextPosition *beginning = [textField beginningOfDocument];
    [textField setSelectedTextRange:[textField textRangeFromPosition:beginning
                                                          toPosition:beginning]];
}

- (int)createNewHousePlan:(NSString *)houseName{
    if ([houseName isEqualToString:NSLocalizedString(@"home", nil)]) {
        House *lastDefautNameHouse = [[House instancesWhere:[NSString stringWithFormat:@"houseName like '%%@'",NSLocalizedString(@"home", nil)]] lastObject];
        if (lastDefautNameHouse) {
            int index = [[lastDefautNameHouse.houseName stringByReplacingOccurrencesOfString:NSLocalizedString(@"home", nil) withString:@""] intValue];
            if (index == 0) {
                houseName = [NSString stringWithFormat:@"1 %@", NSLocalizedString(@"home", nil)];
            }
            else
                houseName = [NSString stringWithFormat:@"%d %@",index + 1, NSLocalizedString(@"home", nil)];
        }
        else
            houseName = [NSString stringWithFormat:@"1 %@", NSLocalizedString(@"home", nil)];
    }
    __block int lastID = -1;
    House *newHouse = [House new];
    newHouse.houseName = houseName;
    newHouse.date = [_formatter stringFromDate:[NSDate date]];
    newHouse.applyPlan = @"未定";
    newHouse.longitude = longitude;
    newHouse.latitude = latitude;
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]]];
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (!error) {
            NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"HousePlan_%@.png",[self generateRandomString]]];
            newHouse.houseImage = savedImagePath;
            NSData *imageData = UIImagePNGRepresentation(MatToUIImage(imgResizedSrc));
            [imageData writeToFile:savedImagePath atomically:NO];
            
            //QuyPV
            NSString *savedImageThumnailPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"HouseThumnail_%@.png",[self generateRandomString]]];
            UIImage *imgThumnail = MatToUIImage(imgResizedSrc);//[MatToUIImage(imgResizedSrc) resizedImageByWidth:240];
            NSData *imageDataThumnail = UIImagePNGRepresentation(imgThumnail);
            
            newHouse.houseImageThumnail = savedImageThumnailPath;
            [imageDataThumnail writeToFile:savedImageThumnailPath atomically:NO];
            //End_QuyPV
        }
    }
    @catch (NSException *exception) {
        newHouse.houseImage = @"";
    }
    @finally {
        [newHouse save];
        [[FCModel databaseQueue] inDatabase:^(FMDatabase *db) {
            lastID = (int)[db lastInsertRowId];
        }];
        return lastID;
    }
}

- (void)configPlanArray{
    if (!planArray) {
        planArray = [[NSMutableArray alloc] initWithArray:[Plan instancesWhere:[NSString stringWithFormat:@"houseID = %d",houseID]]];
        planIndexPage = (int)[planArray count] - 1;
    }
    else{
        [planArray setArray:[Plan instancesWhere:[NSString stringWithFormat:@"houseID = %d",houseID]]];
    }
    if (planArray.count <= 1) {
        _bt_removePlan.enabled = NO;
    }
    else{
        _bt_removePlan.enabled = YES;
        if (planArray.count >= 5) {
            _bt_addPlan.enabled = NO;
        }
        else
            _bt_addPlan.enabled = YES;
    }
    if (planIndexPage >= planArray.count)
        planIndexPage = (int)[planArray count] - 1;
    _lb_planValue.text = [NSString stringWithFormat:@"Plan %d",MAX((int)planArray.count + 1, 1)];
    [self configNextPreviousButton];
}

- (void)configNextPreviousButton{
    if ([planArray count] >= 2) {
//        _btNext.enabled = YES;
        if (planIndexPage > 0) {
            _btPrevious.enabled = YES;
        }
        else{
            _btPrevious.enabled = NO;
        }
//        if (planIndexPage < [planArray count] - 1) {
            _btNext.enabled = YES;
//        }
//        else
//            _btNext.enabled = NO;
    }
    else{
        _btNext.enabled = NO;
        _btPrevious.enabled = NO;
    }
}

- (IBAction)savePlan:(id)sender {
    isSavedPlan = YES;
    _bt_savePlan.enabled = NO;
    dispatch_queue_t processQueue = dispatch_queue_create("PROCESS_SAVE", NULL);
    dispatch_async(processQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            _bt_savePlan.enabled = YES;
        });
    });
}

- (IBAction)createNewPlan:(id)sender {
    _bt_addPlan.enabled = NO;
    self.menuView.userInteractionEnabled = NO;
    dispatch_queue_t processQueue = dispatch_queue_create("PROCESS_SAVE", NULL);
    dispatch_async(processQueue, ^{
        isSavedPlan = YES;
        [self savePlanToDatabase];
        isSavedPlan = NO;
        BOOL isSuccess = [self savePlanToDatabase];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                CATransition *animation = [CATransition animation];
                animation.delegate = (id)self;
                animation.duration = 0.7;
                animation.type = @"pageCurl";
                animation.subtype = kCATransitionFromRight;
                [[self.view layer] addAnimation:animation forKey:@"animation"];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saving error. Please try again." message:@"" delegate:nil cancelButtonTitle:NSLocalizedString(@"close", nil) otherButtonTitles:nil];
                [alert show];
                self.menuView.userInteractionEnabled = YES;
            }
        });
    });
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if(flag)
        self.menuView.userInteractionEnabled = YES;
}

- (BOOL)savePlanToDatabase{
    @try {
        House *tempHouse = [House instanceWithPrimaryKey:@(houseID)];
        NSString *documentsDirectory = [[tempHouse houseImage] stringByDeletingLastPathComponent];
        if (isSavedPlan) {
//            Plan *savedPlan = [Plan instanceWithPrimaryKey:@(planIndex)];
//            NSFileManager *fileManager = [NSFileManager defaultManager];
//            NSError *error;
//            [fileManager removeItemAtPath:savedPlan.imageLink error:&error];
            NSArray *allMaterial = [Material instancesWhere:@"planID = ?",@(planIndex)];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            for (Material *material in allMaterial) {
                @try {
//                    NSLog(@"remove mask %@",material.imageLink);
                    [fileManager removeItemAtPath:material.imageLink error:&error];
                }
                @catch (NSException *exception) {
                    NSLog(@"remove mask error %@ [%@]",material.imageLink, exception.description);
                    continue;
                }
                @finally {
                }
            }
            [Material executeUpdateQuery:[NSString stringWithFormat:@"DELETE FROM $T WHERE planID = %d",planIndex]];
        }
        else{
            Plan *newPlan = [Plan new];
            newPlan.planName = [NSString stringWithFormat:@"Plan %d",MAX((int)planArray.count + 1, 1)];
            newPlan.applyPlan = 0;
            newPlan.houseID = houseID;
            [newPlan save];
            __block int lastID;
            [[FCModel databaseQueue] inDatabase:^(FMDatabase *db) {
                lastID = (int)[db lastInsertRowId];
            }];
        
            planIndex = lastID;
            planIndexPage = (int)planArray.count + 1;
        }
        NSMutableArray *masks = [NSMutableArray array];
        NSArray *layersToSave = [NSArray arrayWithArray:layerDatasource];
        for (LayerObject *obj in layersToSave) {
            Material *materialObj = [Material new];
            materialObj.planID = planIndex;
            materialObj.type = obj.type;
            materialObj.R1 = obj.colorValue.R1;
            materialObj.G1 = obj.colorValue.G1;
            materialObj.B1 = obj.colorValue.B1;
//            materialObj.No = obj.colorValue.No;
            materialObj.No = obj.mask->getReferenceColor();
            materialObj.patternImage = obj.patternImage;
            
            materialObj.feature = obj.feature;
            materialObj.gloss = obj.gloss;
            materialObj.pattern = obj.pattern;
            materialObj.transparent = obj.transparent;
            
            if (materialObj.patternImage.length > 0) {
                materialObj.colorCode = obj.patternImage;
            }
            else
                materialObj.colorCode = obj.color;
            cv::Mat currentMask = obj.mask->getCurrentMask();
            if (currentMask.data != NULL){
                
                std::string dir;
                @try {
                    dir = [self writeMasking: (currentMask) withDirectory:[documentsDirectory lastPathComponent]];
                }
                @catch (NSException *exception) {
                }
                @finally {
                    if (dir.size()>1)
                        materialObj.imageLink = [NSString stringWithCString:dir.c_str() encoding:[NSString defaultCStringEncoding]];
                    else
                        materialObj.imageLink = @"";
                }
            }
                else materialObj.imageLink = @"";
            [masks addObject:materialObj.imageLink];
            [materialObj save];
        }
        for (Plan *plan in planArray) {
            NSArray *materials = [Material instancesWhere:[NSString stringWithFormat:@"planID = %d",plan.planID]];
            @try {
                int count = 0;
                for (Material *material in materials) {
                    material.imageLink = [masks objectAtIndex:count];
                    material.No = [(LayerObject *)layersToSave[count] mask]->getReferenceColor();
                    [material save];
                    count += 1;
                }
            }
            @catch (NSException *exception) {
                
            }
            @finally {
            }
        }
        
        if (!isSavedPlan) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self configPlanArray];
                [self loadPlanAtIndex:(int)planArray.count - 1 isNext:YES];
            });
        }
        NSError *error;
        for (NSString *imageLink in lastSavedLayer) {
            @try {
                [[NSFileManager defaultManager] removeItemAtPath:imageLink error:&error];
            }
            @catch (NSException *exception) {
                continue;
            }
            @finally {
            }
        }
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
        return NO;
    }
    @finally {
        
    }
}

- (IBAction)applyPlanAction:(id)sender {
    if (planObj.applyPlan == 0) {
        [_applyIcon setImage:[UIImage imageNamed:@"iconLike20"] forState:UIControlStateNormal];
        [Plan executeUpdateQuery:[NSString stringWithFormat:@"UPDATE Plan SET applyPlan = 0 WHERE houseID = %d",houseID]];
        [Plan executeUpdateQuery:[NSString stringWithFormat:@"UPDATE Plan SET applyPlan = 1 WHERE planID = %d",planIndex]];
        [House executeUpdateQuery:[NSString stringWithFormat:@"UPDATE House SET applyPlan = 'Plan %d' WHERE houseID = %d",planIndex,houseID]];
        
    }
    else{
        [_applyIcon setImage:[UIImage imageNamed:@"iconUnlike20"] forState:UIControlStateNormal];
        [Plan executeUpdateQuery:[NSString stringWithFormat:@"UPDATE Plan SET applyPlan = 0 WHERE planID = %d",planIndex]];
        [House executeUpdateQuery:[NSString stringWithFormat:@"UPDATE House SET applyPlan = '未設定' WHERE houseID = %d",houseID]];
    }
}

- (void)setMaterialDefault:(Material *)_obj isPattern:(BOOL)_isPattern{
    MaterialDefault *defaultMaterial;
    switch (_obj.type) {
        case 1:
        case 2:
        case 3:
        case 4:
            defaultMaterial = [MaterialDefault instanceWithPrimaryKey:@(_obj.type)];
            break;
        case 5:
        case 6:
        case 7:
        {
            if (_isPattern) {
                defaultMaterial = [MaterialDefault instanceWithPrimaryKey:@(5)];
            }else{
                defaultMaterial = [MaterialDefault instanceWithPrimaryKey:@(6)];
            }
        }
            break;
        default:
            defaultMaterial = [MaterialDefault instanceWithPrimaryKey:@(0)];
            break;
    }
    _obj.feature = defaultMaterial.feature;
    _obj.gloss = defaultMaterial.gloss;
    _obj.pattern = defaultMaterial.pattern;
}

- (void)setDefaultMaterialValue:(LayerObject *)_layer isPattern:(BOOL)isPattern{
    MaterialDefault *defaultMaterial;
    switch (_layer.type) {
        case 1:
        case 2:
        case 3:
        case 4:
            defaultMaterial = [MaterialDefault instanceWithPrimaryKey:@(_layer.type)];
            break;
        case 5:
        case 6:
        case 7:
        {
            if (isPattern) {
                defaultMaterial = [MaterialDefault instanceWithPrimaryKey:@(5)];
            }else{
                defaultMaterial = [MaterialDefault instanceWithPrimaryKey:@(6)];
            }
        }
            break;
        default:
            defaultMaterial = [MaterialDefault instanceWithPrimaryKey:@(0)];
            break;
    }
    _layer.feature = defaultMaterial.feature;
    _layer.gloss = defaultMaterial.gloss;
    _layer.pattern = defaultMaterial.pattern;
}

-(NSString*)generateRandomString {
    NSMutableString* string = [NSMutableString stringWithCapacity:15];
    for (int i = 0; i < 10; i++) {
        [string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
    }
    return string;
}

- (IBAction)gotoLayout:(id)sender {
    isSavedPlan = YES;
    [self savePlanToDatabase];
    UIInterfaceOrientation orientation;
    if (_imageView.image.size.width >= _imageView.image.size.height) {
        orientation = UIInterfaceOrientationLandscapeLeft;
    }
    else
        orientation = UIInterfaceOrientationPortrait;
    if (UIInterfaceOrientationIsLandscape(layoutOrientation) == UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        layoutOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    }
    LayoutViewController *layoutController = [[LayoutViewController alloc] initWithPlanID:planIndex withImageOrientation:orientation];
    layoutController.delegate = (id)self;
    [self.navigationController pushFadeViewController:layoutController];
    flipToLayout = YES;
}

- (void)closeLayoutController{
    [self.navigationController fadePopViewController];
}

- (void)updateApplyPlanStatus:(int)status atIndex:(int)_planIndex{
    
    if (status == 0) {
        if (_planIndex == planIndexPage) {
            [_applyIcon setImage:[UIImage imageNamed:@"iconUnlike20"] forState:UIControlStateNormal];
        }
        [(Plan *)[planArray objectAtIndex:_planIndex] setApplyPlan:0];
    }
    else{
        if (_planIndex == planIndexPage) {
            [_applyIcon setImage:[UIImage imageNamed:@"iconLike20"] forState:UIControlStateNormal];
        }
        else{
            [_applyIcon setImage:[UIImage imageNamed:@"iconUnlike20"] forState:UIControlStateNormal];
        }
//        [(Plan *)[planArray objectAtIndex:_planIndex] setApplyPlan:1];
        for (int i = 0; i < [planArray count]; i ++) {
            if (i == _planIndex) {
                [(Plan *)planArray[i] setApplyPlan:1];
            }
            else
                [(Plan *)planArray[i] setApplyPlan:0];
        }
    }
}

- (IBAction)toolAction:(id)sender {
    [self removePath];
    [self removePointPath];
    seedPoint = cv::Point(-1, -1);
    isCreatePointMode = NO;
    _bt_complete.hidden = YES;
    _bt_removeLastPoint.hidden = YES;
    
    _menuView.alpha = 1.0;
    _menuView.userInteractionEnabled = YES;
    
    _tool_pen.selected = NO;
    _tool_eraser.selected = NO;
    _tool_handDraw.selected = NO;
    _tool_handEraser.selected = NO;
    if (sender == _tool_pen || sender == _tool_handDraw) {
        isEraserMode = NO;
        _lb_penWidth.text = NSLocalizedString(@"pen_width", nil);
        if (sender == _tool_pen) {
            isCreatePointMode = NO;
            _tool_pen.selected = YES;
            _slider_penWidth.enabled = YES;
            _thresholdSlider.enabled = YES;
            _bg_scrollPen.image = [UIImage imageNamed:@"ws_scollbarOn"];
            _bg_scrollThreshold.image = [UIImage imageNamed:@"ws_scollbarOn"];
        }
        else{
            _tool_handDraw.selected = YES;
            isCreatePointMode = YES;
            _thresholdSlider.enabled = NO;
            _slider_penWidth.enabled = YES;
            _bg_scrollPen.image = [UIImage imageNamed:@"ws_scollbarOff"];
            _bg_scrollThreshold.image = [UIImage imageNamed:@"ws_scollbarOff"];
        }
    }
    else{
        isEraserMode = YES;
        _lb_penWidth.text = NSLocalizedString(@"eraser_width", nil);
        if (sender == _tool_eraser) {
            isCreatePointMode = NO;
            _tool_eraser.selected = YES;
            _slider_penWidth.enabled = YES;
            _thresholdSlider.enabled = NO;
            _bg_scrollPen.image = [UIImage imageNamed:@"ws_scollbarOn"];
            _bg_scrollThreshold.image = [UIImage imageNamed:@"ws_scollbarOff"];
        }
        else{
            _tool_handEraser.selected = YES;
            isCreatePointMode = YES;
            _thresholdSlider.enabled = NO;
            _slider_penWidth.enabled = NO;
            _bg_scrollPen.image = [UIImage imageNamed:@"ws_scollbarOff"];
            _bg_scrollThreshold.image = [UIImage imageNamed:@"ws_scollbarOff"];
            
        }
    }
}

- (IBAction)nextPlan:(id)sender {
    _btNext.enabled = NO;
    dispatch_queue_t processQueue = dispatch_queue_create("PROCESS_SAVE", NULL);
    dispatch_async(processQueue, ^{
        isSavedPlan = YES;
        [self savePlanToDatabase];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (planIndexPage < planArray.count - 1) {
                planIndexPage = planIndexPage + 1;
            }
            else
                planIndexPage = 0;
            [self loadPlanAtIndex:planIndexPage isNext:YES];
            [self configNextPreviousButton];
        });
    });
}

- (IBAction)previousPlan:(id)sender {
    _btPrevious.enabled = NO;
    dispatch_queue_t processQueue = dispatch_queue_create("PROCESS_SAVE", NULL);
    dispatch_async(processQueue, ^{
        isSavedPlan = YES;
        [self savePlanToDatabase];
        dispatch_async(dispatch_get_main_queue(), ^{
            planIndexPage = planIndexPage - 1;
            [self loadPlanAtIndex:planIndexPage isNext:NO];
            [self configNextPreviousButton];
        });
    });
}

- (IBAction)tapToBanner:(id)sender {
    //https://www.facebook.com/High-Quality-Paint-from-Japan-Suzukafine-coltd-107856050931009/?view_public_for=107856050931009
    //http://www.suzukafine.co.jp
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"banner_url", nil)]];
}

- (IBAction)gotoEditImage:(id)sender {
    isSavedPlan = YES;
    [self savePlanToDatabase];
    flipToLayout = YES;
    EditImageViewController *editImageController = [[EditImageViewController alloc] initWithcvOriginalImage:imgResizedSrc withLayoutOrientation:layoutOrientation andLayerDatasource:layerDatasource];
    editImageController.delegate = (id)self;
    [self.navigationController pushFadeViewController:editImageController];
}

- (void)editImageComplete:(cv::Mat)_cvimageUpdated{
    [self.navigationController fadePopViewController];
    imgResizedSrc = _cvimageUpdated.clone();
    House *tempHouse = [House instanceWithPrimaryKey:@(houseID)];
    NSData *imageData = UIImagePNGRepresentation(MatToUIImage(imgResizedSrc));
    [imageData writeToFile:tempHouse.houseImage atomically:NO];
    for(int i = (int)[layerDatasource count]-1; i>=0; i--)
    {
        [(LayerObject *)[layerDatasource objectAtIndex:i] mask]->clearCache();
    }
    [self drawPlan];
    [self savePlanToDatabase];
}

- (void)setLabelStyle:(THLabel *)_label {
    _label.textInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    _label.strokePosition = THLabelStrokePositionOutside;
    _label.strokeColor = kStrokeColor;
    _label.strokeSize = kStrokeSize;
    _label.textColor = [UIColor whiteColor];
}

- (NSString *)getPatternImage:(NSString *)_pattern{
    return [patternNames objectForKey:_pattern];
}

@end
