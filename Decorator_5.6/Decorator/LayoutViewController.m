//
//  LayoutViewController.m
//  Decorator
//
//  Created by Hoang Le on 11/28/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "LayoutViewController.h"
#import "THLabel.h"
#import "Material.h"
#import "Plan.h"
#import "House.h"
//#import "CropImageViewController.h"
#import "BackgroundPickerViewController.h"
#import "OutputPickerViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <MessageUI/MessageUI.h>
#import "OrderViewController.h"
#import "SettingViewController.h"
#import "NSString+Japanese.h"
#import "PlanViewController.h"
#import "UIImageViewAligned.h"
#import "ExportMapModalController.h"
#import "MZFormSheetController.h"
#include <opencv2/opencv.hpp>
//#include <opencv2/highgui/ios.h>
#include <opencv2/imgcodecs/ios.h>
#import <objc/message.h>
#import "LayerObject.h"
#import "LayoutPosition.h"
#import "Comment.h"
//#import "LayoutCollectionViewCell_4Cell.h"
#import "LayoutCollectionViewCell_6Cell.h"
#import "LayoutCollectionViewCell_Portrait.h"

#define kShadowColor1		[UIColor blackColor]
#define kShadowColor2		[UIColor colorWithWhite:0.0 alpha:0.75]
#define kShadowOffset		CGSizeMake(0.0, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 4.0 : 2.0)
#define kShadowBlur			(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 10.0 : 5.0)

#define kStrokeColor		[UIColor blackColor]
#define kStrokeSize			(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 2.0 : 2.0)

#define kGradientStartColor	[UIColor colorWithRed:255.0 / 255.0 green:193.0 / 255.0 blue:127.0 / 255.0 alpha:1.0]
#define kGradientEndColor	[UIColor colorWithRed:255.0 / 255.0 green:163.0 / 255.0 blue:64.0 / 255.0 alpha:1.0]

@interface LayoutViewController (){
    SPUserResizableView *sp_image;
    SPUserResizableView *sp_thumbnail;
    SPUserResizableView *sp_table;
    SPUserResizableView *currentlyEditingView;
    SPUserResizableView *lastEditedView;
    
    int selectedTag;
    NSMutableArray *datasource;
    int planID;
    int houseID;
    UIImage *generatedImage;
    UIImage *originalImage;
    Plan *planObj;
    NSMutableArray *layoutPlanArray;
    int planIndexPage;
    BOOL isEdited;
    House *houseObj;
    int actionType;
    
    BOOL isCorrectUsernamePassword;
    BOOL isChangeZDplanStatus;
    BOOL isChangeZDimageStatus;
    BOOL isChangeZDthumnailStatus;
    BOOL isChangeZDapplyiconStatus;
    BOOL isChangeSPnameStatus;
    BOOL isChangeSPtableStatus;
    
    NSString *backgroundImageName;
    MZFormSheetController *formSheetContainer;
    int exportFormat;
    
    NSMutableArray *tagHistory;
    NSMutableArray *frameHistory;
    
    NSMutableArray *comments;
    NSMutableArray *commentLabels;
    int historyIndex;
    
//    NSMutableArray *barrierPatternList;
//    NSMutableArray *barrierViewList;
    
    cv::Mat imgSrc;
    cv::Mat imgDst;
    
    CGRect imageViewRect;
    CGRect thumbnailRect;
    CGRect tableRect;
    
    BOOL flagImage,flagThumbnail,flagTable;
    int lastTag;
    
    LayoutPosition *imagePosition,*thumbnailPosition,*tablePosition;
    BOOL isNeedReloadPlanData;
    NSDictionary *patternNames;
    BOOL isIphone;
}

@property (strong, nonatomic) UIImageView *img_big;
@property (strong, nonatomic) UIView *view_thumbnail;
@property (strong, nonatomic) THLabel *lb_thumbnail;
@property (strong, nonatomic) UIImageView *img_thumbnail;
@property (strong, nonatomic) UITableView *planTableView;
@property (strong, nonatomic) UIPopoverController *layoutPopoverController;
@property (strong, nonatomic) BackgroundPickerViewController *backgroundPicker;
@property (strong, nonatomic) OutputPickerViewController *outputPicker;
@end

@implementation LayoutViewController
//static int TAG_NAME = 0;
//static int TAG_PLAN = 1;
static const int TAG_THUMBNAIL = 1002;
static const int TAG_IMAGE = 1003;
static const int TAG_TABLE = 1004;


@synthesize layoutOrientation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (id)initWithPlanID:(int)_planID withImageOrientation:(UIInterfaceOrientation)_orientation{
    self = [super init];
    if (self) {
        planID = _planID;
        planObj = [Plan instanceWithPrimaryKey:@(planID)];
        houseID = (int)planObj.houseID;
        layoutOrientation = _orientation;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (UIInterfaceOrientationIsLandscape(layoutOrientation) != UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            int (*action)(id, SEL, int) = (int (*)(id, SEL, int)) objc_msgSend;
            action([UIDevice currentDevice], @selector(setOrientation:),layoutOrientation);
        }
    }
    patternNames = @{@"外壁材_1_A":@"WB2256",@"外壁材_1_B":@"WB2256",@"外壁材_1_C":@"WB2256",@"外壁材_1_D":@"WB2256",@"外壁材_2_A":@"WB2289",@"外壁材_2_B":@"WB2289",@"外壁材_2_C":@"WB2289",@"外壁材_2_D":@"WB2289",@"外壁材_3_A":@"WB2285",@"外壁材_3_B":@"WB2285",@"外壁材_3_C":@"WB2285",@"外壁材_3_D":@"WB2285",@"外壁材_4_A":@"WB2225",@"外壁材_4_B":@"WB2225",@"外壁材_4_C":@"WB2225",@"外壁材_4_D":@"WB2225",@"外壁材_5_A":@"WB2178",@"外壁材_5_B":@"WB2178",@"外壁材_5_C":@"WB2178",@"外壁材_5_D":@"WB2178",@"外壁材_6_A":@"WB2142",@"外壁材_6_B":@"WB2142",@"外壁材_6_C":@"WB2142",@"外壁材_6_D":@"WB2142",@"外壁材_7_A":@"WB2391",@"外壁材_7_B":@"WB2391",@"外壁材_7_C":@"WB2391",@"外壁材_7_D":@"WB2391",@"外壁材_8_A":@"WB2393",@"外壁材_8_B":@"WB2393",@"外壁材_8_C":@"WB2393",@"外壁材_8_D":@"WB2393",@"外壁材_9_A":@"WB2117",@"外壁材_9_B":@"WB2117",@"外壁材_9_C":@"WB2117",@"外壁材_9_D":@"WB2117",@"外壁材_10_A":@"WB2140",@"外壁材_10_B":@"WB2140",@"外壁材_10_C":@"WB2140",@"外壁材_10_D":@"WB2140",@"外壁材_11_A":@"WB2170",@"外壁材_11_B":@"WB2170",@"外壁材_11_C":@"WB2170",@"外壁材_11_D":@"WB2170",@"外壁材_12_A":@"WB2179",@"外壁材_12_B":@"WB2179",@"外壁材_12_C":@"WB2179",@"外壁材_12_D":@"WB2179",@"外壁材_13_A":@"WB2144",@"外壁材_13_B":@"WB2144",@"外壁材_13_C":@"WB2144",@"外壁材_13_D":@"WB2144",@"外壁材_14_A":@"WB2394",@"外壁材_14_B":@"WB2394",@"外壁材_14_C":@"WB2394",@"外壁材_14_D":@"WB2394",@"外壁材_15_A":@"WB2149",@"外壁材_15_B":@"WB2149",@"外壁材_15_C":@"WB2149",@"外壁材_15_D":@"WB2149",@"外壁材_16_A":@"WB2333",@"外壁材_16_B":@"WB2333",@"外壁材_16_C":@"WB2333",@"外壁材_16_D":@"WB2333",@"外壁材_17_A":@"WB3220",@"外壁材_17_B":@"WB3220",@"外壁材_17_C":@"WB3220",@"外壁材_17_D":@"WB3220",@"外壁材_18_A":@"WB3252",@"外壁材_18_B":@"WB3252",@"外壁材_18_C":@"WB3252",@"外壁材_18_D":@"WB3252",@"外壁材_19_A":@"WB3175",@"外壁材_19_B":@"WB3175",@"外壁材_19_C":@"WB3175",@"外壁材_19_D":@"WB3175",@"外壁材_20_A":@"WB3147",@"外壁材_20_B":@"WB3147",@"外壁材_20_C":@"WB3147",@"外壁材_20_D":@"WB3147",@"外壁材_21_A":@"WB3335",@"外壁材_21_B":@"WB3335",@"外壁材_21_C":@"WB3335",@"外壁材_21_D":@"WB3335",@"外壁材_22_A":@"WB3281",@"外壁材_22_B":@"WB3281",@"外壁材_22_C":@"WB3281",@"外壁材_22_D":@"WB3281",@"外壁材_23_A":@"WB2118",@"外壁材_23_B":@"WB2118",@"外壁材_23_C":@"WB2118",@"外壁材_23_D":@"WB2118",@"外壁材_24_A":@"WB2141",@"外壁材_24_B":@"WB2141",@"外壁材_24_C":@"WB2141",@"外壁材_24_D":@"WB2141",@"外壁材_25_A":@"WB2168",@"外壁材_25_B":@"WB2168",@"外壁材_25_C":@"WB2168",@"外壁材_25_D":@"WB2168",@"外壁材_26_A":@"WB2172",@"外壁材_26_B":@"WB2172",@"外壁材_26_C":@"WB2172",@"外壁材_26_D":@"WB2172",@"外壁材_27_A":@"WB2174",@"外壁材_27_B":@"WB2174",@"外壁材_27_C":@"WB2174",@"外壁材_27_D":@"WB2174",@"外壁材_28_A":@"WB2223",@"外壁材_28_B":@"WB2223",@"外壁材_28_C":@"WB2223",@"外壁材_28_D":@"WB2223",@"外壁材_29_A":@"WB2287",@"外壁材_29_B":@"WB2287",@"外壁材_29_C":@"WB2287",@"外壁材_29_D":@"WB2287",@"外壁材_30_A":@"WB2295",@"外壁材_30_B":@"WB2295",@"外壁材_30_C":@"WB2295",@"外壁材_30_D":@"WB2295",@"外壁材_31_A":@"WB2386",@"外壁材_31_B":@"WB2386",@"外壁材_31_C":@"WB2386",@"外壁材_31_D":@"WB2386",@"外壁材_32_A":@"WB3183",@"外壁材_32_B":@"WB3183",@"外壁材_32_C":@"WB3183",@"外壁材_32_D":@"WB3183",@"外壁材_33_A":@"WB3284",@"外壁材_33_B":@"WB3284",@"外壁材_33_C":@"WB3284",@"外壁材_33_D":@"WB3284",@"外壁材_34_A":@"WB3288",@"外壁材_34_B":@"WB3288",@"外壁材_34_C":@"WB3288",@"外壁材_34_D":@"WB3288",@"外壁材_35_A":@"WB3396",@"外壁材_35_B":@"WB3396",@"外壁材_35_C":@"WB3396",@"外壁材_35_D":@"WB3396"};
    tagHistory = [NSMutableArray array];
    frameHistory = [NSMutableArray array];
    [self checkUndoRedoStatus];
    
    if ([[SettingViewController getLoginOfficerName] length] != 0 || [[SettingViewController getOfficePassword] length] != 0) {
        isCorrectUsernamePassword = YES;
    }
    else
        isCorrectUsernamePassword = NO;
    _contentView.clipsToBounds = YES;
    _contentView.layer.cornerRadius = 20.0f;
    _backgroundImage.layer.cornerRadius = 20.0f;
    _backgroundImage.layer.masksToBounds = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"LayoutCollectionViewCell_Portrait" bundle:nil] forCellWithReuseIdentifier:@"PORTRAIT_CELL"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LayoutCollectionViewCell_6Cell" bundle:nil] forCellWithReuseIdentifier:@"SIX_CELL"];
    
    layoutPlanArray = [[NSMutableArray alloc] initWithArray:[Plan instancesWhere:[NSString stringWithFormat:@"houseID = %d",planObj.houseID]]];
    planIndexPage = 0;
    for (Plan *plan in layoutPlanArray) {
        if (plan.planID == planID) {
            break;
        }
        planIndexPage += 1;
    }
    
    NSArray *language = [NSLocale preferredLanguages];
    if (language.count > 0) {
        NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:language.firstObject];
        NSString *languageCode = [languageDic objectForKey:@"kCFLocaleLanguageCodeKey"];
        if ([languageCode isEqualToString:@"vi"]) {
            _logoWidthConstraint.constant = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 320 : 200;
        } else {
        }
    }
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        isIphone = YES;
        _lb_planName.font = [UIFont boldSystemFontOfSize:20];
        _txt_houseName.font = [UIFont systemFontOfSize:14];
        _bt_applyPlan.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _lb_logoPrefix.font = [UIFont boldSystemFontOfSize:13];
    } else {
        isIphone = NO;
    }
    [self changeItemPosition];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    if (UIInterfaceOrientationIsPortrait(layoutOrientation) && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        _lb_planName.font = [UIFont boldSystemFontOfSize:20];
        _txt_houseName.font = [UIFont boldSystemFontOfSize:20];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    if (sp_image != nil || sp_thumbnail != nil || sp_table != nil) {
        return;
    }
    if (UIInterfaceOrientationIsPortrait(layoutOrientation) && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        _planTopConstraint.constant = 0;
        _planRightConstraint.active = NO;
        _planLeftConstraint.constant = 20;
        _applyRightConstraint.constant = 20;
        _nameTopConstraint.constant = 30;
    } else {
        _planLeftConstraint.active = NO;
    }
    @try {
            if (!datasource) {
                datasource = [[NSMutableArray alloc] initWithArray:[Material instancesWhere:[NSString stringWithFormat:@"planID = %d",planID]]];
                houseObj = [House instanceWithPrimaryKey:@(planObj.houseID)];
            }
            else{
                houseObj = [House instanceWithPrimaryKey:@(houseID)];
            }
            backgroundImageName = houseObj.backgroundImg;
            if (backgroundImageName.length > 0) {
                [self selectedBackgroundImage:backgroundImageName];
            }
            else
                backgroundImageName = @"255,255,255";
            
            UIImageToMat([UIImage imageWithContentsOfFile:houseObj.houseImage],imgSrc);
            [self generatePlanImage];
            
            imagePosition = [[LayoutPosition instancesWhere:[NSString stringWithFormat:@"houseID = %d and type = %d",houseID,TAG_IMAGE]] lastObject];
            thumbnailPosition = [[LayoutPosition instancesWhere:[NSString stringWithFormat:@"houseID = %d and type = %d",houseID,TAG_THUMBNAIL]] lastObject];
            tablePosition = [[LayoutPosition instancesWhere:[NSString stringWithFormat:@"houseID = %d and type = %d",houseID,TAG_TABLE]] lastObject];
            
            if (planObj.applyPlan == 1) {
                [_bt_applyPlan setImage:[UIImage imageNamed:@"iconLike20"] forState:UIControlStateNormal];
            }
            else
                [_bt_applyPlan setImage:[UIImage imageNamed:@"iconUnlike20"] forState:UIControlStateNormal];
            _lb_username.text = [SettingViewController getUserName];
            _txt_houseName.text = houseObj.houseName;
//            _txt_houseName.font = [UIFont boldSystemFontOfSize:22.0f];
            _lb_planName.text = planObj.planName;
            
            CGSize imageSize;
            _img_big = [[UIImageView alloc] initWithImage:generatedImage];
            _img_big.layer.borderWidth = 3.0f;
            _img_big.layer.borderColor = [UIColor whiteColor].CGColor;
            if (UIInterfaceOrientationIsLandscape(layoutOrientation)) {
//                int imageMax = generatedImage.size.width == generatedImage.size.height ? _draggableViewContainer.frame.size.height - 60 : 760;
                int imageMax = 0;
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                    imageMax = _draggableViewContainer.frame.size.height;
                    imageSize = CGSizeMake(imageMax * generatedImage.size.width/generatedImage.size.height, imageMax);
                } else {
                    imageMax = _draggableViewContainer.frame.size.width - 180;
                    imageSize = CGSizeMake(imageMax, imageMax * generatedImage.size.height/generatedImage.size.width);
                }
                
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                    sp_image = [[SPUserResizableView alloc] initWithFrame:CGRectMake(20, 0, imageSize.width, imageSize.height) isHideEditControl:YES];
                } else {
                    sp_image = [[SPUserResizableView alloc] initWithFrame:CGRectMake(0, 0, _draggableViewContainer.frame.size.width - 170, (_draggableViewContainer.frame.size.width - 170) * imageSize.height / imageSize.width) isHideEditControl:YES];
                }
            }
            else{
                imageSize = CGSizeMake(530,530 *generatedImage.size.height/generatedImage.size.width);
                int imageMax = 0;
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                    imageMax = _draggableViewContainer.frame.size.width - 230;
                } else {
                    imageMax = _draggableViewContainer.frame.size.width - 100;
                }
                imageSize = CGSizeMake(imageMax, imageMax * generatedImage.size.height/generatedImage.size.width);
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                    sp_image = [[SPUserResizableView alloc] initWithFrame:CGRectMake(0, 40, imageSize.width, imageSize.height) isHideEditControl:YES];
                } else {
                    CGFloat height = (_draggableViewContainer.frame.size.width - 100) * imageSize.height / imageSize.width;
                    sp_image = [[SPUserResizableView alloc] initWithFrame:CGRectMake(-5, (_draggableViewContainer.frame.size.height - height)/2, _draggableViewContainer.frame.size.width - 100, height) isHideEditControl:YES];
                }
            }
            _img_big.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
            
            sp_image.tag = TAG_IMAGE;
            sp_image.delegate = self;
            sp_image.contentView = _img_big;
            sp_image.preventChangeSizeRatio = YES;
            if (UIInterfaceOrientationIsLandscape(layoutOrientation)){
                sp_image.minHeight = 140*generatedImage.size.height/generatedImage.size.width;
                sp_image.minWidth = 140;
            }
            else{
                sp_image.minHeight = 140*generatedImage.size.height/generatedImage.size.width;
                sp_image.minWidth = 140;
            }
            
            if (imagePosition) {
                sp_image.frame = CGRectMake(imagePosition.xValue, imagePosition.yValue, imagePosition.width, imagePosition.height);
            }
            [self.draggableViewContainer addSubview:sp_image];
            
            
            if (UIInterfaceOrientationIsLandscape(layoutOrientation)){
//                _lb_thumbnail = [[THLabel alloc] initWithFrame:CGRectMake(780, 25, 240, 30)];
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                    _lb_thumbnail = [[THLabel alloc] initWithFrame:CGRectMake(_draggableViewContainer.frame.size.width - 245, 20, 240, 20)];
                } else {
                    _lb_thumbnail = [[THLabel alloc] initWithFrame:CGRectMake(_draggableViewContainer.frame.size.width - 180, 10, 180, 20)];
                }
            }
            else {
//                _lb_thumbnail = [[THLabel alloc] initWithFrame:CGRectMake(530, 5, 240, 30)];
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                    _lb_thumbnail = [[THLabel alloc] initWithFrame:CGRectMake(_draggableViewContainer.frame.size.width - 240, 30, 240, 20)];
                } else {
                    _lb_thumbnail = [[THLabel alloc] initWithFrame:CGRectMake(_draggableViewContainer.frame.size.width - 125, sp_image.frame.origin.y - 10, 130, 20)];
                }
            }
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            _lb_thumbnail.font = [UIFont fontWithName:@"SFProText-Bold" size:11.0f];
        } else {
            _lb_thumbnail.font = [UIFont fontWithName:@"SFProText-Bold" size:19.0f];
        }
            _lb_thumbnail.strokeSize = 3.0f;
            _lb_thumbnail.textAlignment = NSTextAlignmentCenter;
            _lb_thumbnail.textColor = [UIColor whiteColor];
            [self setLabelStyle:_lb_thumbnail];
            _lb_thumbnail.text = NSLocalizedString(@"before_process", nil);
            
            if (UIInterfaceOrientationIsLandscape(layoutOrientation)){
                _img_thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 240, 240*generatedImage.size.height/generatedImage.size.width)];
                _view_thumbnail = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 240*generatedImage.size.height/generatedImage.size.width)];
            }
            else{
                _img_thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 240, 240*generatedImage.size.height/generatedImage.size.width)];
                _img_thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 240, 240*generatedImage.size.height/generatedImage.size.width)];
                _view_thumbnail = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 240*generatedImage.size.height/generatedImage.size.width)];
            }
            _img_thumbnail.layer.borderWidth = 2.0f;
            _img_thumbnail.layer.borderColor = [UIColor whiteColor].CGColor;
            [_img_thumbnail setImage:[UIImage imageWithContentsOfFile:houseObj.houseImageThumnail]];
            _img_thumbnail.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            
            [_view_thumbnail addSubview:_img_thumbnail];
            _view_thumbnail.clipsToBounds = YES;
            _view_thumbnail.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            if (UIInterfaceOrientationIsLandscape(layoutOrientation)){
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                    sp_thumbnail = [[SPUserResizableView alloc] initWithFrame:CGRectMake(_draggableViewContainer.frame.size.width - 245, 30, 240, 240*generatedImage.size.height/generatedImage.size.width) isHideEditControl:YES];
                } else {
                    sp_thumbnail = [[SPUserResizableView alloc] initWithFrame:CGRectMake(_draggableViewContainer.frame.size.width - 180, 20, 180, 180*generatedImage.size.height/generatedImage.size.width) isHideEditControl:YES];
                }
            }
            else{
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                    sp_thumbnail = [[SPUserResizableView alloc] initWithFrame:CGRectMake(_draggableViewContainer.frame.size.width - 240, 40, 240, 240*generatedImage.size.height/generatedImage.size.width) isHideEditControl:YES];
                } else {
                    sp_thumbnail = [[SPUserResizableView alloc] initWithFrame:CGRectMake(_draggableViewContainer.frame.size.width - 125, sp_image.frame.origin.y, 130, 130*generatedImage.size.height/generatedImage.size.width) isHideEditControl:YES];
                }
                
            }
            sp_thumbnail.tag = TAG_THUMBNAIL;
            sp_thumbnail.delegate = self;
            sp_thumbnail.contentView = _view_thumbnail;//contentView;
            if (UIInterfaceOrientationIsLandscape(layoutOrientation)){
                sp_thumbnail.minHeight = 140*generatedImage.size.height/generatedImage.size.width;
                sp_thumbnail.minWidth = 140;
            }
            else{
                sp_thumbnail.minHeight = 140*generatedImage.size.height/generatedImage.size.width;
                sp_thumbnail.minWidth = 140;
            }
            sp_thumbnail.preventChangeSizeRatio = YES;
            if (thumbnailPosition) {
                sp_thumbnail.frame = CGRectMake(thumbnailPosition.xValue, thumbnailPosition.yValue, thumbnailPosition.width, thumbnailPosition.height);
                _lb_thumbnail.frame = CGRectMake(sp_thumbnail.frame.origin.x, sp_thumbnail.frame.origin.y - 10, sp_thumbnail.frame.size.width, 20);
            }
            [self.draggableViewContainer addSubview:_lb_thumbnail];
            [self.draggableViewContainer addSubview:sp_thumbnail];
        
            _planTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 240, 260) style:UITableViewStylePlain];
            _planTableView.userInteractionEnabled = NO;
            _planTableView.layer.cornerRadius = 10.0f;
            _planTableView.layer.masksToBounds = YES;
            _planTableView.dataSource = self;
            _planTableView.delegate = self;
            _planTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            if (UIInterfaceOrientationIsLandscape(layoutOrientation)){
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                    sp_table = [[SPUserResizableView alloc] initWithFrame:CGRectMake(_draggableViewContainer.frame.size.width - 245, sp_thumbnail.frame.origin.y + sp_thumbnail.frame.size.height + 30, 240, sp_image.frame.size.height - sp_thumbnail.frame.size.height - 60) isHideEditControl:YES];
                } else {
                    sp_table = [[SPUserResizableView alloc] initWithFrame:CGRectMake(_draggableViewContainer.frame.size.width - 180, sp_thumbnail.frame.origin.y + sp_thumbnail.frame.size.height - 20, 180, sp_image.frame.size.height - sp_thumbnail.frame.size.height) isHideEditControl:YES];
                }
            }
            else{
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                    sp_table = [[SPUserResizableView alloc] initWithFrame:CGRectMake(_draggableViewContainer.frame.size.width - 240, sp_thumbnail.frame.origin.y + sp_thumbnail.frame.size.height, 240, sp_image.frame.size.height - sp_thumbnail.frame.size.height) isHideEditControl:YES];
                } else {
                    sp_table = [[SPUserResizableView alloc] initWithFrame:CGRectMake(_draggableViewContainer.frame.size.width - 125, sp_thumbnail.frame.origin.y + sp_thumbnail.frame.size.height - 10, 130, sp_image.frame.size.height - sp_thumbnail.frame.size.height + 10) isHideEditControl:YES];
                }
                    
            }
            sp_table.tag = TAG_TABLE;
            sp_table.contentView = _planTableView;
            sp_table.delegate = self;
            sp_table.minWidth = 60;
            sp_table.minHeight = 60;
            if (tablePosition && !CGRectEqualToRect(CGRectZero, CGRectMake(tablePosition.xValue, tablePosition.yValue, tablePosition.width, tablePosition.height))) {
                sp_table.frame = CGRectMake(tablePosition.xValue, tablePosition.yValue, tablePosition.width, tablePosition.height);
            }
            [self.draggableViewContainer addSubview:sp_table];
            
            imageViewRect = sp_image.frame;
            thumbnailRect = sp_thumbnail.frame;
            tableRect = sp_table.frame;
            
            
            [tagHistory addObject:[NSNumber numberWithInt:TAG_IMAGE]];
            [frameHistory addObject:[NSValue valueWithCGRect:imageViewRect]];
            [tagHistory addObject:[NSNumber numberWithInt:TAG_THUMBNAIL]];
            [frameHistory addObject:[NSValue valueWithCGRect:thumbnailRect]];
            [tagHistory addObject:[NSNumber numberWithInt:TAG_TABLE]];
            [frameHistory addObject:[NSValue valueWithCGRect:tableRect]];
            historyIndex = tagHistory.count - 1;
            [self configureNextPreviousButton];
            
            comments = [[NSMutableArray alloc] initWithArray:[Comment instancesWhere:[NSString stringWithFormat:@"houseID = %d",houseID]]];
            commentLabels = [[NSMutableArray alloc] initWithCapacity:comments.count];
            if (comments.count > 0) {
                for (Comment *comment in comments) {
                    [self hideEditingOnMoving];
                    UITextView *newTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, comment.width, comment.height)];
                    newTextView.font = [UIFont boldSystemFontOfSize:30.0f];
                    newTextView.backgroundColor = [UIColor clearColor];
                    newTextView.userInteractionEnabled = NO;
                    newTextView.delegate = (id)self;
                    newTextView.text = comment.content;
                    SPUserResizableView *newUserResizableView = [[SPUserResizableView alloc] initWithFrame:CGRectMake(comment.xValue, comment.yValue, comment.width, comment.height) isHideEditControl:NO andIsShowDeleteControl:YES];
                    newUserResizableView.delegate = (id)self;
                    newUserResizableView.contentView = newTextView;
                    [self.contentView addSubview:newUserResizableView];
                    [self.contentView bringSubviewToFront:newUserResizableView];
                    [newUserResizableView showEditingHandles];
                    [commentLabels addObject:newTextView];
                }
            }
            UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideEditingHandles)];
            [gestureRecognizer setDelegate:(id)self];
            [self.contentView addGestureRecognizer:gestureRecognizer];
        }
        @catch (NSException *exception) {
            [self saveLayoutToQuit];
            [self.navigationController fadePopViewController];
        }
        @finally {
            
        }
        });
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)saveLayoutToQuit{
    [House executeUpdateQuery:@"UPDATE $T SET backgroundImg = ? WHERE houseID = ?",backgroundImageName,@(houseID)];
    [LayoutPosition executeUpdateQuery:@"DELETE FROM LayoutPosition WHERE houseID = ?",@(houseID)];
    LayoutPosition *imageToSave = [LayoutPosition new];
    imageToSave.houseID = houseID;
    imageToSave.type = TAG_IMAGE;
    imageToSave.xValue = sp_image.frame.origin.x;
    imageToSave.yValue = sp_image.frame.origin.y;
    imageToSave.width = sp_image.frame.size.width;
    imageToSave.height = sp_image.frame.size.height;
    [imageToSave save];
    
    LayoutPosition *thumbnailToSave = [LayoutPosition new];
    thumbnailToSave.houseID = houseID;
    thumbnailToSave.type = TAG_THUMBNAIL;
    thumbnailToSave.xValue = sp_thumbnail.frame.origin.x;
    thumbnailToSave.yValue = sp_thumbnail.frame.origin.y;
    thumbnailToSave.width = sp_thumbnail.frame.size.width;
    thumbnailToSave.height = sp_thumbnail.frame.size.height;
    [thumbnailToSave save];
    
    LayoutPosition *tableToSave = [LayoutPosition new];
    tableToSave.houseID = houseID;
    tableToSave.type = TAG_TABLE;
    tableToSave.xValue = sp_table.frame.origin.x;
    tableToSave.yValue = sp_table.frame.origin.y;
    tableToSave.width = sp_table.frame.size.width;
    tableToSave.height = sp_table.frame.size.height;
    [tableToSave save];
    
    [Comment executeUpdateQuery:@"DELETE FROM Comment WHERE houseID = ?",@(houseID)];
    for (UITextView *textView in commentLabels) {
        Comment *commentToSave = [Comment new];
        commentToSave.houseID = houseID;
        commentToSave.content = textView.text;
        commentToSave.xValue = textView.superview.frame.origin.x;
        commentToSave.yValue = textView.superview.frame.origin.y;
        commentToSave.width = textView.superview.frame.size.width;
        commentToSave.height = textView.superview.frame.size.height;
        [commentToSave save];
    }
}

- (void)generatePlanImage{
    imgDst.release();
    for (Material *obj in datasource) {
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
        layer.colorValue = color;
        layer.patternImage = obj.patternImage;
        
        layer.feature = obj.feature;
        layer.gloss = obj.gloss;
        layer.pattern = obj.pattern;
        layer.transparent = obj.transparent;
        if (layer.patternImage == nil)
            layer.mask = new CMask((int)color.R1, (int)color.G1, (int)color.B1);//(0, 125, 0);
        else {
            layer.mask = new CMask(0, 125, 0);
            cv::Mat imgPattern;
            UIImage *_i = [UIImage imageNamed:layer.patternImage];
            UIImageToMat(_i,imgPattern);
            _i = nil;
            layer.mask->setColor(imgPattern);
            imgPattern.release();
        }
        
        layer.mask->setTolerance(10);
        layer.mask->iniMaskByImagePath(std::string([obj.imageLink UTF8String]));
        layer.mask->setReferenceColor(obj.No);
        layer.mask->setTransparent(layer.transparent);
        layer.mask->Paint(imgSrc, imgDst);
        if ([obj.colorCode isEqualToString:@"未設定"]) {
            layer.mask->setDefaultColor(true);
        }
    }
    
    if (imgDst.data) {
        generatedImage = MatToUIImage(imgDst);
    } else {
        generatedImage = MatToUIImage(imgSrc);
    }
}

- (void)didResizeEnd:(SPUserResizableView *)userResizableView{
    if (userResizableView.tag == TAG_THUMBNAIL) {
        _lb_thumbnail.frame = CGRectMake(userResizableView.frame.origin.x, userResizableView.frame.origin.y - 10, userResizableView.frame.size.width, 20);
    }
}

- (void)didMoveEnd:(SPUserResizableView *)userResizableView{
    if (userResizableView.tag == TAG_THUMBNAIL) {
        _lb_thumbnail.frame = CGRectMake(userResizableView.frame.origin.x, userResizableView.frame.origin.y - 10, userResizableView.frame.size.width, 20);
    }
}

- (IBAction)actionAddText:(id)sender {
    [self hideEditingOnMoving];
    
    UITextView *newTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 100, 90)];
    newTextView.font = [UIFont boldSystemFontOfSize:30.0f];
    newTextView.backgroundColor = [UIColor clearColor];
    newTextView.userInteractionEnabled = NO;
    newTextView.delegate = (id)self;
    SPUserResizableView *newUserResizableView = [[SPUserResizableView alloc] initWithFrame:CGRectMake(100, 20, 100, 90) isHideEditControl:NO andIsShowDeleteControl:YES];
    newUserResizableView.delegate = (id)self;
    newUserResizableView.contentView = newTextView;
    [self.contentView addSubview:newUserResizableView];
    [commentLabels addObject:newTextView];
    [self.contentView bringSubviewToFront:newUserResizableView];
    [newUserResizableView showEditingHandles];
}

- (void)changeItemPosition{
    if (UIInterfaceOrientationIsLandscape(layoutOrientation)) {
//        _contentView.frame = CGRectMake(80, 32, 920, 620);
//        _bt_editHouseName.frame = CGRectMake(0, 0, 30, 30);
//        _txt_houseName.frame = CGRectMake(20, 18, 594, 34);
//        _bt_applyPlan.frame = CGRectMake(622, 10, 130, 35);
//        _lb_planName.frame = CGRectMake(760, 10, 140, 34);
//        _topView.frame = CGRectMake(0, 0, 920, 53);
        
        _bottomHeightConstraint.constant = 68;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            _txt_info.font = [UIFont fontWithName:@"SFProText-Regular" size:8.0f];
        } else {
            _lbUndo.font = [UIFont systemFontOfSize:12];
            _lbRedo.font = [UIFont systemFontOfSize:12];
            _lbComment.font = [UIFont systemFontOfSize:12];
            _lbBackground.font = [UIFont systemFontOfSize:12];
            _lbExport.font = [UIFont systemFontOfSize:12];
            _lbMasking.font = [UIFont systemFontOfSize:12];
            _lbBack.font = [UIFont systemFontOfSize:12];
        }
    }
    else{
//        _contentView.frame = CGRectMake(25, 88, 720, 821);
//        _topView.frame = CGRectMake(0, 0, 720, 68);
//        _bt_editHouseName.frame = CGRectMake(0, 20, 30, 30);
//        _txt_houseName.frame = CGRectMake(17, 35, 624, 34);
//        _bt_applyPlan.frame = CGRectMake(514, 3, 130, 35);
//        _lb_planName.frame = CGRectMake(20, 2, 140, 34);
        
        _bottomHeightConstraint.constant = 83;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            _txt_info.font = [UIFont fontWithName:@"SFProText-Regular" size:8.0f];
        } else {
            _lbUndo.font = [UIFont systemFontOfSize:12];
            _lbRedo.font = [UIFont systemFontOfSize:12];
            _lbComment.font = [UIFont systemFontOfSize:12];
            _lbBackground.font = [UIFont systemFontOfSize:12];
            _lbExport.font = [UIFont systemFontOfSize:12];
            _lbMasking.font = [UIFont systemFontOfSize:12];
            _lbBack.font = [UIFont systemFontOfSize:12];
        }
    }
}



- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([currentlyEditingView hitTest:[touch locationInView:currentlyEditingView] withEvent:nil]) {
        return NO;
    }
    return YES;
}

- (void)hideEditingHandles {
    if ([lastEditedView.contentView isKindOfClass:[UITextView class]]) {
        [(UITextView *)lastEditedView.contentView resignFirstResponder];
    }
    [lastEditedView hideEditingHandles];
}

- (void)rotateView:(SPUserResizableView *)userResizableView{
}

- (void)editContentView:(SPUserResizableView *)userResizableView{
    [(UITextView *)[userResizableView contentView] becomeFirstResponder];
}

- (void)deleteContentView:(SPUserResizableView *)userResizableView{
    [userResizableView removeFromSuperview];
    [commentLabels removeObject:userResizableView.contentView];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        _background.image = [UIImage imageNamed:@"BG_02.jpg"];
    }
    else{
        _background.image = [UIImage imageNamed:@"BG_04.jpg"];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        _background.image = [UIImage imageNamed:@"BG_02.jpg"];
    }
    else{
        _background.image = [UIImage imageNamed:@"BG_04.jpg"];
    }
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
//        _bt_editHouseName.frame = CGRectMake(0, 0, 30, 30);
//        _txt_houseName.frame = CGRectMake(20, 18, 594, 34);
//        _bt_applyPlan.frame = CGRectMake(622, 17, 130, 35);
//        _lb_planName.frame = CGRectMake(760, 17, 140, 34);
//        _topView.frame = CGRectMake(0, 0, 920, 53);
        
        _bottomHeightConstraint.constant = 68;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            _txt_info.font = [UIFont fontWithName:@"SFProText-Regular" size:8.0f];
        }
//        _draggableViewContainer.frame = CGRectMake(0, 53, 920, 499);
//        _collectionView.frame = _draggableViewContainer.frame;
    }
    else{
//        _topView.frame = CGRectMake(0, 0, 664, 68);
//        _bt_editHouseName.frame = CGRectMake(0, 30, 30, 30);
//        _txt_houseName.frame = CGRectMake(20, 35, 624, 34);
//        _bt_applyPlan.frame = CGRectMake(514, 3, 130, 35);
//        _lb_planName.frame = CGRectMake(20, 2, 140, 34);
        _bottomHeightConstraint.constant = 83;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            _txt_info.font = [UIFont fontWithName:@"SFProText-Regular" size:8.0f];
        }
//        _draggableViewContainer.frame = CGRectMake(0, 68, 664, 726);
//        _collectionView.frame = _draggableViewContainer.frame;
    }
}

- (void)setLabelStyle:(THLabel *)_label{
    _label.textInsets = UIEdgeInsetsMake(3, 3, 3, 3);
    _label.strokePosition = THLabelStrokePositionOutside;
	_label.strokeColor = kStrokeColor;
	_label.strokeSize = kStrokeSize;
    _label.textColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Text View delegate

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [House executeUpdateQuery:[NSString stringWithFormat:@"update House set houseName = '%@' where houseID = %d",_txt_houseName.text,planObj.houseID]];
    [_txt_houseName setUserInteractionEnabled:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:textView.text attributes:@{NSForegroundColorAttributeName : [UIColor blackColor],NSStrokeColorAttributeName : [UIColor whiteColor],NSStrokeWidthAttributeName : @-3.0,NSFontAttributeName : [UIFont boldSystemFontOfSize:30.0f]}];
    textView.attributedText = attributeString;
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView{
    @try {
        CGSize maximumLabelSize = CGSizeMake(9999,9999);
        CGSize labelSize = [textView.text sizeWithFont:[UIFont boldSystemFontOfSize:30] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
        [textView.superview setFrame:CGRectMake(textView.superview.frame.origin.x, textView.superview.frame.origin.y, MIN(labelSize.width + 50, 800), labelSize.height + 70)];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

#pragma mark - Table View datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return 30;
    } else {
        return 50;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return 30;
    } else {
        return 40;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return _headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [datasource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellIdentifier";
    LayoutCell *tbCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (tbCell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LayoutCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[LayoutCell class]])
            {
                tbCell = (LayoutCell *)currentObject;
                break;
            }
        }
        tbCell.lb_name.textColor = [UIColor whiteColor];
        [self setLabelStyle:tbCell.lb_name];
        tbCell.lb_color.textColor = [UIColor whiteColor];
        [self setLabelStyle:tbCell.lb_color];
    }
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        tbCell.lb_name.font = [UIFont boldSystemFontOfSize:12];
        tbCell.lb_color.font = [UIFont boldSystemFontOfSize:12];
    }
    Material *obj = [datasource objectAtIndex:indexPath.row];
    tbCell.lb_name.text = [NSString stringWithFormat:@" %@", [DecoratorUtil getTypeNameByID:(int)obj.type]];
    tbCell.lb_color.text = [NSString stringWithFormat:@" %@", NSLocalizedString(obj.colorCode, nil)];
    
    if (obj.patternImage.length > 0) {
        tbCell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:obj.patternImage]];
        if ([self getPatternImage:obj.colorCode].length > 0) {
            tbCell.lb_color.text = [NSString stringWithFormat:@" %@", [self getPatternImage:obj.colorCode]];
        }
    }
    
    else if ([obj.colorCode isEqualToString:@"-"]){
        if ((obj.R1 == 210 && obj.G1 == 204 && obj.B1 == 102) || (obj.R1 == 0 && obj.G1 == 0 && obj.B1 == 0)) {
            tbCell.contentView.backgroundColor = [UIColor whiteColor];
        } else {
            tbCell.contentView.backgroundColor = [UIColor colorWithRed:obj.R1/255.0f green:obj.G1/255.0f blue:obj.B1/255.0f alpha:1];
        }
    }
    else
        tbCell.contentView.backgroundColor = [UIColor colorWithRed:obj.R1/255.0f green:obj.G1/255.0f blue:obj.B1/255.0f alpha:1];
    
    tbCell.lb_name.letterSpacing = 2;
    tbCell.lb_color.letterSpacing = 2;
    
    return tbCell;
}

#pragma mark - show Background Picker

- (IBAction)showBackgroundPicker:(id)sender {
    if (!_backgroundPicker) {
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) == UIInterfaceOrientationIsLandscape(layoutOrientation)) {
            _backgroundPicker = [[BackgroundPickerViewController alloc] initWithOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        }
        else
            _backgroundPicker = [[BackgroundPickerViewController alloc] initWithOrientation:layoutOrientation];
        _backgroundPicker.delegate = (id)self;
        _backgroundPicker.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    
    [self presentViewController:_backgroundPicker animated:YES completion:^{
        
    }];
}
//塗板発注登録画面でログイン名、パスワードを入力してください。
- (void)showLoginAlertWithActionType:(int)_action{
    actionType = _action;
    if (!isCorrectUsernamePassword) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"enter_your_id_password", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"continue", nil) otherButtonTitles:nil];
        [alert show];
    }
    else
        [self doActionType:actionType];
}

#pragma mark -
#pragma mark UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.alertViewStyle == UIAlertViewStyleLoginAndPasswordInput) {
        if ([SettingViewController getLoginOfficerName].length != 0 || [SettingViewController getOfficePassword].length != 0) {
            if ([[alertView textFieldAtIndex:0].text isEqualToString:[SettingViewController getLoginOfficerName]] &&
                [[alertView textFieldAtIndex:1].text isEqualToString:[SettingViewController getOfficePassword]]) {
                isCorrectUsernamePassword = YES;
            }
            
        }
        else if ([[alertView textFieldAtIndex:0].text isEqualToString:kFixOfficerName] &&
                 [[alertView textFieldAtIndex:1].text isEqualToString:kFixOfficerPassword]) {
            [[NSUserDefaults standardUserDefaults] setValue:kFixOfficerName
                                                     forKey:kLoginOfficerName];
            [[NSUserDefaults standardUserDefaults] setValue:kFixOfficerPassword
                                                     forKey:kOfficerPassword];
            isCorrectUsernamePassword = YES;
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"input_not_correct", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
        if (isCorrectUsernamePassword) {
            [self doActionType:actionType];
        }
    }
}

- (void)doActionType:(int)_action{
    if (actionType == 1){
        OrderViewController *orderController = [[OrderViewController alloc] initWithHouseID:(int)planObj.houseID andName:_txt_houseName.text isFromLayout:YES];
        [self saveLayoutToQuit];
        [self.navigationController pushFadeViewController:orderController];
    }
}

- (IBAction)showOutputMenu:(id)sender {
    if (!_outputPicker) {
        _outputPicker = [[OutputPickerViewController alloc] init];
        _outputPicker.modalPresentationStyle = UIModalPresentationOverFullScreen;
        _outputPicker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        _outputPicker.delegate = (id)self;
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self presentViewController:_outputPicker animated:YES completion:nil];
    } else {
        if (!_layoutPopoverController) {
            _layoutPopoverController = [[UIPopoverController alloc] initWithContentViewController:_outputPicker];
            [_layoutPopoverController setPopoverContentSize:CGSizeMake(240, 308)];
            [_layoutPopoverController presentPopoverFromRect:[_bt_output frame] inView:self.bt_output.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else{
            [_layoutPopoverController setPopoverContentSize:CGSizeMake(240, 308)];
            [_layoutPopoverController presentPopoverFromRect:[_bt_output frame] inView:self.bt_output.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

- (IBAction)exitLayoutManager:(id)sender {
    if ([_delegate respondsToSelector:@selector(closeLayoutController)]) {
        [_delegate closeLayoutController];
    }
    else{
        [self saveLayoutToQuit];
        [self.navigationController fadePopViewController];
    }
}

- (void)selectedBackgroundImage:(NSString *)_imageName{
    if ([_imageName isEqualToString:@"mlmlkpE.jpg"]) {
        _backgroundImage.hidden = YES;
        backgroundImageName = _imageName;
        _contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mlmlkpE.jpg"]];
    }else{
        backgroundImageName = _imageName;
        NSArray *colorComponent = [backgroundImageName componentsSeparatedByString:@","];
        if ([colorComponent count] > 2) {
            _backgroundImage.hidden = YES;
            _contentView.backgroundColor = [UIColor colorWithRed:[colorComponent[0] floatValue]/255.0f green:[colorComponent[1] floatValue]/255.0f blue:[colorComponent[2] floatValue]/255.0f alpha:1];
        }
        else{
            _backgroundImage.hidden = NO;
            _backgroundImage.image = [UIImage imageNamed:_imageName];
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)selectedBackgroundColor:(UIColor *)_color{
    _backgroundImage.hidden = YES;
    _contentView.backgroundColor = _color;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)dismissBackgroundPicker{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)outputAction:(OutputType)type withFormat:(int)format{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [_outputPicker dismissViewControllerAnimated:NO completion:nil];
    } else {
        [_layoutPopoverController dismissPopoverAnimated:NO];
    }
    switch (type) {
        case OUTPUT_MAIL:{
            exportFormat = format;
            if (houseObj.latitude != 0 && houseObj.longitude != 0) {
                ExportMapModalController *exportMapModal = [[ExportMapModalController alloc] init];
                exportMapModal.delegate = (id)self;
                formSheetContainer = [[MZFormSheetController alloc] initWithSize:CGSizeMake(340, 44) viewController:exportMapModal andInterfaceOrientation:layoutOrientation];
                formSheetContainer.shouldCenterVertically = YES;
                formSheetContainer.transitionStyle = MZFormSheetTransitionStyleFade;
                formSheetContainer.shouldDismissOnBackgroundViewTap = YES;
                
                [formSheetContainer presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
                    
                }];
                formSheetContainer.didTapOnBackgroundViewCompletionHandler = ^(CGPoint location)
                {
                };
            }
            else{
                if ([MFMailComposeViewController canSendMail]) {
                    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
                    if (exportFormat == 0) {
                        [self hideAll];
                        UIImage *viewImage = [self captureView:self.contentView];
                        [self showAll];
                        NSData *imageData = UIImageJPEGRepresentation(viewImage, 90);
                        NSString *outputName = @"";
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        [formatter setDateFormat:@"yyyyMMdd"];
                        outputName = [NSString stringWithFormat:@"%@_%@_%@.jpg",houseObj.houseName,planObj.planName,[formatter stringFromDate:[NSDate date]]];
                        [mailComposer addAttachmentData:imageData mimeType:@"image/jpg" fileName:outputName];
                    }
                    else{
                        [self hideAll];
                        NSMutableData *imageData = [self createPDFData:self.contentView];
                        [self showAll];
                        NSString *outputName = @"";
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        [formatter setDateFormat:@"yyyyMMdd"];
                        outputName = [NSString stringWithFormat:@"%@_%@_%@.pdf",houseObj.houseName,planObj.planName,[formatter stringFromDate:[NSDate date]]];
                        [mailComposer addAttachmentData:imageData mimeType:@"application/pdf" fileName:outputName];
                    }
                    mailComposer.mailComposeDelegate = (id)self;
                    [self presentViewController:mailComposer animated:YES completion:nil];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                                    message:@"Your device doesn't support the composer sheet"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
            }
        }
            break;
        case OUTPUT_PRINTER:{
            [self hideAll];
            UIImage *viewImage = [self captureView:self.contentView];
            [self showAll];
            UIPrintInteractionController *printer = [UIPrintInteractionController sharedPrintController];
            printer.printingItem = viewImage;
            UIPrintInfo *info = [UIPrintInfo printInfo];
//            if (viewImage.size.width > viewImage.size.height)
                info.orientation = UIPrintInfoOrientationLandscape;
//            else
//                info.orientation = UIPrintInfoOrientationPortrait;
            info.outputType = UIPrintInfoOutputGeneral;
            info.duplex = UIPrintInfoDuplexLongEdge;
            printer.printInfo = info;
            printer.showsPageRange = YES;
            UIPrintInteractionCompletionHandler completionHandler =
            ^(UIPrintInteractionController *pic, BOOL completed, NSError *error) {
                if (!completed && error){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"ERROR: domain: %@, code:%u, detail:%@",error.domain,(int)error.code,[error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    NSLog(@"FAILED! due to error in domain %@ with error code %u: %@",
                          error.domain, (int)error.code, [error localizedDescription]);
                }};
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
                [printer presentAnimated:YES completionHandler:completionHandler];
            } else {
                [printer presentFromRect:_bt_output.frame inView:self.bt_output.superview animated:YES completionHandler:completionHandler];
            }
        }
            break;
        case OUTPUT_TWITTER:{
            [self hideAll];
            UIImage *viewImage = [self captureView:self.contentView];
            [self showAll];
            SLComposeViewController  *mySocialComposer;
            mySocialComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [mySocialComposer addImage:viewImage];
//            mySocialComposer.completionHandler = ^(SLComposeViewControllerResult result)
//            {
//                [self dismissViewControllerAnimated:true completion:^{}];
//            };
            [mySocialComposer setCompletionHandler:^(SLComposeViewControllerResult result) {
                switch (result) {
                    case SLComposeViewControllerResultCancelled:
                        NSLog(@"Post Canceled");
                        break;
                    case SLComposeViewControllerResultDone:
                        NSLog(@"Post Sucessful");
                        break;

                    default:
                        break;
                }
            }];
            [self presentViewController:mySocialComposer animated:YES completion:nil];
        }
            break;
        case OUTPUT_FACEBOOK:{
            [self hideAll];
            UIImage *viewImage = [self captureView:self.contentView];
            [self showAll];
            SLComposeViewController  *mySocialComposer;
            mySocialComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            [mySocialComposer addImage:viewImage];
//            mySocialComposer.completionHandler = ^(SLComposeViewControllerResult result)
//            {
//                [self dismissViewControllerAnimated:true completion:^{}];
//            };
            [mySocialComposer setCompletionHandler:^(SLComposeViewControllerResult result) {
                switch (result) {
                    case SLComposeViewControllerResultCancelled:
                        NSLog(@"Post Canceled");
                        break;
                    case SLComposeViewControllerResultDone:
                        NSLog(@"Post Sucessful");
                        break;

                    default:
                        break;
                }
            }];
            [self presentViewController:mySocialComposer animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

- (void)selectedExportType:(int)type{
    [formSheetContainer dismissAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
            if (exportFormat == 0) {
                [self hideAll];
                UIImage *viewImage = [self captureView:self.contentView];
                [self showAll];
                NSData *imageData = UIImageJPEGRepresentation(viewImage, 90);
                NSString *outputName = @"";
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyyMMdd"];
                outputName = [NSString stringWithFormat:@"%@_%@_%@.jpg",houseObj.houseName,planObj.planName,[formatter stringFromDate:[NSDate date]]];
                [mailComposer addAttachmentData:imageData mimeType:@"image/jpg" fileName:outputName];
            }
            else{
                [self hideAll];
                NSMutableData *imageData = [self createPDFData:self.contentView];
                [self showAll];
                NSString *outputName = @"";
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyyMMdd"];
                outputName = [NSString stringWithFormat:@"%@_%@_%@.pdf",houseObj.houseName,planObj.planName,[formatter stringFromDate:[NSDate date]]];
                [mailComposer addAttachmentData:imageData mimeType:@"application/pdf" fileName:outputName];
            }
            if (type == 0) {
                [mailComposer setMessageBody:[NSString stringWithFormat:@"<br>%@</br><br>http://maps.apple.com/maps?q=%f,%f</br>",[SettingViewController getUserName].length == 0 ? @"" : [SettingViewController getUserName],houseObj.latitude,houseObj.longitude] isHTML:YES];
            }
            mailComposer.mailComposeDelegate = (id)self;
            [self presentViewController:mailComposer animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                            message:@"Your device doesn't support the composer sheet"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (NSMutableData *)createPDFData:(UIView *)_viewForRender{
    // Creates a mutable data object for updating with binary data, like a byte array
    NSMutableData *pdfData = [NSMutableData data];
    
    // Points the pdf converter to the mutable data object and to the UIView to be converted
    UIGraphicsBeginPDFContextToData(pdfData, _viewForRender.bounds, nil);
    UIGraphicsBeginPDFPage();
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    
    
    // draws rect to the view and thus this is captured by UIGraphicsBeginPDFContextToData
    [_viewForRender.layer renderInContext:pdfContext];
    
    // remove PDF rendering context
    UIGraphicsEndPDFContext();
    
    return pdfData;
}

- (void)hideEditingOnMoving{
    [sp_table hideEditingHandles];
    [sp_image hideEditingHandles];
    [sp_thumbnail hideEditingHandles];
    _bt_editHouseName.hidden = YES;
    for (UIView *subview in _contentView.subviews) {
        if ([subview isKindOfClass:[SPUserResizableView class]]) {
            [(SPUserResizableView *)subview hideEditingHandles];
        }
    }
}

- (void)hideAll{
//    if (planObj.applyPlan == 0){
//        _bt_applyPlan.hidden = YES;
//    }
    [sp_table hideEditingHandles];
    [sp_image hideEditingHandles];
    [sp_thumbnail hideEditingHandles];
    _bt_editHouseName.hidden = YES;
    for (UIView *subview in _contentView.subviews) {
        if ([subview isKindOfClass:[SPUserResizableView class]]) {
            [(SPUserResizableView *)subview hideEditingHandles];
        }
    }
}

- (void)showAll{
    if (_collectionView.isHidden) {
        _bt_applyPlan.hidden = NO;
        _bt_editHouseName.hidden = NO;
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (UIImage *)captureView:(UIView *)view {
    // Get the size of the screen
    CGSize imageSize = view.frame.size;//[[UIScreen mainScreen] bounds].size;
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    // Render the view into the current graphics context
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    // Create an image from the current graphics context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // If you want to save the image to the camera roll, uncomment the following line
    //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil); // Warning: No error in this implementation. There should probably be some.
    return image;
}

- (IBAction)gotoSampleOrder:(id)sender {
    [self showLoginAlertWithActionType:1];
}

- (void)gotoColorMode{
    [_layoutPopoverController dismissPopoverAnimated:YES];
    OrderViewController *orderController = [[OrderViewController alloc] initWithHouseID:(int)planObj.houseID andName:_txt_houseName.text isFromLayout:YES];
    [self saveLayoutToQuit];
    [self.navigationController pushFadeViewController:orderController];
}
- (IBAction)nextLayout:(id)sender {
    if (planIndexPage >= [layoutPlanArray count]){
        planIndexPage = 0;
        _collectionView.hidden = YES;
        _draggableViewContainer.hidden = NO;
        _bt_editHouseName.hidden = NO;
        _bt_applyPlan.hidden = NO;
        _lb_planName.hidden = NO;
        [self configureNextPreviousButton];
        [self loadLayoutAtIndex:planIndexPage isNext:YES];
    }
    else
        planIndexPage = planIndexPage + 1;
    if (planIndexPage == 0 && !isNeedReloadPlanData) {
        _collectionView.hidden = YES;
        _draggableViewContainer.hidden = NO;
        _bt_editHouseName.hidden = NO;
        _bt_applyPlan.hidden = NO;
        _lb_planName.hidden = NO;
        [self configureNextPreviousButton];
        return;
    }
    [self loadLayoutAtIndex:planIndexPage isNext:YES];
}

- (IBAction)previousLayout:(id)sender {
    if (planIndexPage == -1){
        planIndexPage = (int)layoutPlanArray.count - 1;
        _collectionView.hidden = YES;
        _draggableViewContainer.hidden = NO;
        _bt_editHouseName.hidden = NO;
        _bt_applyPlan.hidden = NO;
        _lb_planName.hidden = NO;
        [self configureNextPreviousButton];
        [self loadLayoutAtIndex:planIndexPage isNext:YES];
    }
    else
        planIndexPage = planIndexPage - 1;
    if (planIndexPage == [layoutPlanArray count] - 1 && !isNeedReloadPlanData) {
        CATransition *animation = [CATransition animation];
        animation.delegate = (id)self;
        animation.duration = 0.3;
        animation.type = kCATransitionFade;
        animation.subtype = kCATransitionFromLeft;
        _collectionView.hidden = YES;
        _draggableViewContainer.hidden = NO;
        _bt_editHouseName.hidden = NO;
        _bt_applyPlan.hidden = NO;
        _lb_planName.hidden = NO;
        [self configureNextPreviousButton];
        [[self.view layer] addAnimation:animation forKey:@"animation"];
        return;
    }
    [self loadLayoutAtIndex:planIndexPage isNext:NO];
}

- (void)loadLayoutAtIndex:(int)_planIndex isNext:(BOOL)_isNext{
    if (_planIndex < 0 || _planIndex == [layoutPlanArray count]) {
        CATransition *animation = [CATransition animation];
        animation.delegate = (id)self;
        animation.duration = 0.3;
        animation.type = kCATransitionFade;
        if (_isNext) {
            animation.subtype = kCATransitionFromRight;
        }
        else
            animation.subtype = kCATransitionFromLeft;
        _collectionView.hidden = NO;
        _draggableViewContainer.hidden = YES;
        _bt_editHouseName.hidden = YES;
        _bt_applyPlan.hidden = YES;
        _lb_planName.hidden = YES;
        [[self.view layer] addAnimation:animation forKey:@"animation"];
        [self configureNextPreviousButton];
        isNeedReloadPlanData = NO;
        
        if (!_collectionView.dataSource) {
            _collectionView.dataSource = self;
            _collectionView.delegate = self;
        }
        return;
    }
    else if (!_collectionView.isHidden){
        _collectionView.hidden = YES;
        _draggableViewContainer.hidden = NO;
        _bt_editHouseName.hidden = NO;
        _bt_applyPlan.hidden = NO;
        _lb_planName.hidden = NO;
    }
    planObj = [layoutPlanArray objectAtIndex:_planIndex];
    planID = (int)planObj.planID;
    datasource = [[NSMutableArray alloc] initWithArray:[Material instancesWhere:[NSString stringWithFormat:@"planID = %d",planID]]];
//    savedImage = [UIImage imageWithContentsOfFile:planObj.imageLink];
    [self generatePlanImage];
    if (planObj.applyPlan == 1) {
        [_bt_applyPlan setImage:[UIImage imageNamed:@"iconLike20"] forState:UIControlStateNormal];
    }
    else
        [_bt_applyPlan setImage:[UIImage imageNamed:@"iconUnlike20"] forState:UIControlStateNormal];
    _lb_thumbnail.text = NSLocalizedString(@"before_process", nil);
    [_img_thumbnail setImage:[UIImage imageWithContentsOfFile:houseObj.houseImage]];

    CATransition *animation = [CATransition animation];
    animation.delegate = (id)self;
    animation.duration = 0.3;
    animation.type = kCATransitionFade;
    if (_isNext) {
        animation.subtype = kCATransitionFromRight;
    }
    else
        animation.subtype = kCATransitionFromLeft;
    _btNext.enabled = NO;
    _btPrevious.enabled = NO;
    _btPrevious2.enabled = NO;
    [[self.view layer] addAnimation:animation forKey:@"animation"];
    _lb_planName.text = planObj.planName;
    [_img_big setImage:generatedImage];
    [_planTableView reloadData];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag) {
        [self configureNextPreviousButton];
    }
}

- (IBAction)gotoMasking:(id)sender {
    [self saveLayoutToQuit];
    if ([_delegate respondsToSelector:@selector(closeLayoutController)]) {
        [_delegate closeLayoutController];
    }
    else{
        UIImage *image = [UIImage imageWithContentsOfFile:houseObj.houseImage];
        if (!image) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Image not found!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            return;
        }
        NSMutableArray *materials = [[NSMutableArray alloc] initWithArray:[Material instancesWhere:[NSString stringWithFormat:@"planID = %d",planObj.planID]]];
        UIInterfaceOrientation layoutMaskingOrientation;
        if (image.size.height > image.size.width) {
            layoutMaskingOrientation = UIInterfaceOrientationPortrait;
        }
        else
            layoutMaskingOrientation = UIInterfaceOrientationLandscapeLeft;
        if (UIInterfaceOrientationIsLandscape(layoutOrientation) == UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            layoutOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        }
        BOOL isResizeImage = YES;
        NSString *imageFolder = [houseObj.houseImage stringByDeletingLastPathComponent];
        if ([imageFolder.lastPathComponent isEqualToString:@"Documents"]) {
            isResizeImage = NO;
        }
        PlanViewController *planController = [[PlanViewController alloc] initWithImage:image withResizeImage:isResizeImage andImageOrientation:image.imageOrientation withHouseID:(int)houseObj.houseID planID:(int)planObj.planID andLayers:materials andLayoutOrientation:layoutMaskingOrientation];
        [self.navigationController pushFadeViewController:planController];
    }
}
- (IBAction)gotoMenu:(id)sender {
    [self saveLayoutToQuit];
    [self.navigationController fadePopRootViewController];
}

- (IBAction)applyThisPlan:(id)sender {
    if (planObj.applyPlan == 0) {
        [Plan executeUpdateQuery:[NSString stringWithFormat:@"UPDATE Plan SET applyPlan = 0 WHERE houseID = %d",houseID]];
        [Plan executeUpdateQuery:[NSString stringWithFormat:@"UPDATE Plan SET applyPlan = 1 WHERE planID = %d",planObj.planID]];
        [House executeUpdateQuery:[NSString stringWithFormat:@"UPDATE House SET applyPlan = '%@' WHERE houseID = %d",planObj.planName,houseID]];
        [_bt_applyPlan setImage:[UIImage imageNamed:@"iconLike20"] forState:UIControlStateNormal];
        
        for (Plan *plan in layoutPlanArray) {
            if (plan.planID == planObj.planID) {
                [plan setApplyPlan:1];
            }
            else
                [plan setApplyPlan:0];
        }
        if ([_delegate respondsToSelector:@selector(updateApplyPlanStatus: atIndex:)]) {
            [_delegate updateApplyPlanStatus:1 atIndex:planIndexPage];
        }
    }
    else{
        [Plan executeUpdateQuery:[NSString stringWithFormat:@"UPDATE Plan SET applyPlan = 0 WHERE planID = %d",planObj.planID]];
        [House executeUpdateQuery:[NSString stringWithFormat:@"UPDATE House SET applyPlan = '' WHERE houseID = %d",houseID]];
        [_bt_applyPlan setImage:[UIImage imageNamed:@"iconUnlike20"] forState:UIControlStateNormal];
        for (Plan *plan in layoutPlanArray) {
            [plan setApplyPlan:0];
        }
        if ([_delegate respondsToSelector:@selector(updateApplyPlanStatus: atIndex:)]) {
            [_delegate updateApplyPlanStatus:0 atIndex:planIndexPage];
        }
    }
    if (_collectionView) {
//        [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:planIndexPage+1 inSection:0]]];
        [_collectionView reloadData];
    }
}
- (IBAction)startEditHouseName:(id)sender {
    _txt_houseName.userInteractionEnabled = YES;
    [_txt_houseName becomeFirstResponder];
}

- (void)configureNextPreviousButton{
    if (layoutPlanArray.count >= 2) {
//        if (planIndexPage == -1) {
//            _btPrevious.enabled = NO;
//        }
//        else
        _btPrevious.enabled = YES;
        _btPrevious2.enabled = YES;
//        if (planIndexPage == [layoutPlanArray count]) {
//            _btNext.enabled = NO;
//        }
//        else
            _btNext.enabled = YES;
    }
    else{
        _btNext.enabled = NO;
        _btPrevious.enabled = NO;
        _btPrevious2.enabled = NO;
    }
}

- (void)checkUndoRedoStatus{
    if ([tagHistory count] == 0) {
        _bt_redo.enabled = NO;
        _bt_undo.enabled = NO;
        return;
    }
    if (historyIndex <= 3 || historyIndex >= [tagHistory count]) {
        _bt_undo.enabled = NO;
    }
    else
        _bt_undo.enabled = YES;
    if (historyIndex == [tagHistory count] - 1 || historyIndex < 0 ) {
        _bt_redo.enabled = NO;
    }
    else
        _bt_redo.enabled = YES;
}



- (IBAction)undoLayoutAction:(id)sender {
    historyIndex = historyIndex - 1;
    int viewTag = [[tagHistory objectAtIndex:historyIndex] intValue];
    if (viewTag != lastTag) {
        historyIndex -= 1;
        viewTag = [[tagHistory objectAtIndex:historyIndex] intValue];
    }
    if (historyIndex < 3) {
        sp_image.frame = imageViewRect;
        sp_table.frame = tableRect;
        sp_thumbnail.frame = thumbnailRect;
        historyIndex = 2;
        [self checkUndoRedoStatus];
        return;
    }
    SPUserResizableView *historyView = (SPUserResizableView *)[_draggableViewContainer viewWithTag:viewTag];
    CGRect viewFrame = [(NSValue *)[frameHistory objectAtIndex:historyIndex] CGRectValue];
    historyView.frame = viewFrame;
    _lb_thumbnail.frame = CGRectMake(sp_thumbnail.frame.origin.x, sp_thumbnail.frame.origin.y - 10, sp_thumbnail.frame.size.width, 20);
    [self checkUndoRedoStatus];
}

- (IBAction)redoLayoutAction:(id)sender {
    historyIndex = historyIndex + 1;
    int viewTag = [[tagHistory objectAtIndex:historyIndex] intValue];
    if (viewTag != lastTag) {
        historyIndex += 1;
        viewTag = [[tagHistory objectAtIndex:historyIndex] intValue];
    }
    if (historyIndex > tagHistory.count - 1) {
        historyIndex = (int)tagHistory.count - 1;
        return;
    }
    SPUserResizableView *historyView = (SPUserResizableView *)[_draggableViewContainer viewWithTag:viewTag];
    CGRect viewFrame = [(NSValue *)[frameHistory objectAtIndex:historyIndex] CGRectValue];
    historyView.frame = viewFrame;
    _lb_thumbnail.frame = CGRectMake(sp_thumbnail.frame.origin.x, sp_thumbnail.frame.origin.y - 10, sp_thumbnail.frame.size.width, 20);
    [self checkUndoRedoStatus];
}

- (void)userResizableViewDidBeginEditing:(SPUserResizableView *)userResizableView{
    [self hideEditingOnMoving];
    if (userResizableView == sp_image && !flagImage) {
        [tagHistory addObject:[NSNumber numberWithInt:(int)[userResizableView tag]]];
        [frameHistory addObject:[NSValue valueWithCGRect:userResizableView.frame]];
        historyIndex = (int)[tagHistory count] - 1;
        flagImage = YES;
    }
    else if (userResizableView == sp_table && !flagTable){
        [tagHistory addObject:[NSNumber numberWithInt:(int)[userResizableView tag]]];
        [frameHistory addObject:[NSValue valueWithCGRect:userResizableView.frame]];
        historyIndex = (int)[tagHistory count] - 1;
        flagTable = YES;
    }
    else if (userResizableView == sp_thumbnail && !flagThumbnail){
        [tagHistory addObject:[NSNumber numberWithInt:(int)[userResizableView tag]]];
        [frameHistory addObject:[NSValue valueWithCGRect:userResizableView.frame]];
        historyIndex = (int)[tagHistory count] - 1;
        flagThumbnail = YES;
    }
    currentlyEditingView = userResizableView;
    [self.contentView bringSubviewToFront:userResizableView];
}

- (void)userResizableViewDidEndEditing:(SPUserResizableView *)userResizableView {
    if (userResizableView != sp_image && userResizableView != sp_table && userResizableView != sp_thumbnail) {
        return;
    }
    lastEditedView = userResizableView;
    lastTag = (int)[userResizableView tag];
    [tagHistory addObject:[NSNumber numberWithInt:(int)[userResizableView tag]]];
    [frameHistory addObject:[NSValue valueWithCGRect:userResizableView.frame]];
    historyIndex = (int)[tagHistory count] - 1;
    [self checkUndoRedoStatus];
}

#pragma mark - Collection View datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return layoutPlanArray.count + 1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (UIInterfaceOrientationIsLandscape(layoutOrientation)){
        static NSString *identifier = @"SIX_CELL";
        LayoutCollectionViewCell_6Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        if (isIphone) {
            cell.lb_original.font = [UIFont boldSystemFontOfSize:11];
            cell.bt_applyPlan.titleLabel.font = [UIFont boldSystemFontOfSize:10];
            cell.lb_planName.font = [UIFont boldSystemFontOfSize:10];
        }
        
        if (indexPath.row == 0) {
            cell.lb_planName.hidden = YES;
            cell.bt_applyPlan.hidden = YES;
            if (UIInterfaceOrientationIsLandscape(layoutOrientation)) {
                cell.lb_original.hidden = NO;
            } else {
                cell.lb_original.hidden = YES;
            }
            
            cell.planImageView.image = [UIImage imageWithContentsOfFile:houseObj.houseImageThumnail];
        } else {
            if (UIInterfaceOrientationIsLandscape(layoutOrientation)) {
                cell.lb_planName.hidden = NO;
            } else {
                cell.lb_planName.hidden = YES;
            }
            
            cell.bt_applyPlan.hidden = NO;
            cell.lb_original.hidden = YES;
            [self loadCollectionCell:cell atIndex:(int)indexPath.row];
            [cell.bt_applyPlan addTarget:self action:@selector(setApplyPlanInCell:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        return cell;
    }
    else{
        static NSString *identifier = @"PORTRAIT_CELL";
        LayoutCollectionViewCell_Portrait *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        if (isIphone) {
            cell.lb_original.font = [UIFont boldSystemFontOfSize:11];
            cell.bt_applyPlan.titleLabel.font = [UIFont boldSystemFontOfSize:9];
            cell.lb_planName.font = [UIFont boldSystemFontOfSize:10];
        }
        cell.planImageView.image = [UIImage imageNamed:@"houseA1"];
        if (indexPath.row == 0) {
            cell.lb_planName.hidden = YES;
            cell.bt_applyPlan.hidden = YES;
            cell.lb_original.hidden = NO;
            cell.planImageView.image = [UIImage imageWithContentsOfFile:houseObj.houseImageThumnail];
        }
        else{
            cell.lb_planName.hidden = NO;
            cell.bt_applyPlan.hidden = NO;
            cell.lb_original.hidden = YES;
            [self loadCollectionCell:cell atIndex:(int)indexPath.row];
            [cell.bt_applyPlan addTarget:self action:@selector(setApplyPlanInCell:) forControlEvents:UIControlEventTouchUpInside];
        }
//        cell.contentView.backgroundColor = [UIColor whiteColor];
//        cell.backgroundColor = [UIColor whiteColor];
        return cell;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return 4;
    }
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return 4;
    }
    return 10;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (UIInterfaceOrientationIsLandscape(layoutOrientation)) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            CGFloat width = (collectionView.bounds.size.width - 8) / 3;
            CGFloat height = (collectionView.bounds.size.height - 4) / 2;
//            return CGSizeMake(width, width * 0.75 + 32);
            return CGSizeMake(width, height);
        } else {
//            return CGSizeMake(304, 248);
            CGFloat width = (collectionView.bounds.size.width - 20) / 3;
            CGFloat height = (collectionView.bounds.size.height - 10) / 2;
//            CGFloat height = (collectionView.bounds.size.height - 20) / 2;
//            return CGSizeMake(width, height);
            return CGSizeMake(width, height);
        }
    }
    else{
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            CGFloat width = (collectionView.bounds.size.width - 8) / 3;
            CGFloat height = (collectionView.bounds.size.height - 4) / 2;
            return CGSizeMake(width, height);
//            return CGSizeMake(width, width / 0.75 + 32);
        } else {
//            return CGSizeMake(235, 350);
            CGFloat width = (collectionView.bounds.size.width - 20) / 3;
            CGFloat height = (collectionView.bounds.size.height - 10) / 2;
            return CGSizeMake(width, height);
        }
    }
}

- (void)loadCollectionCell:(UICollectionViewCell *)cell atIndex:(int)_cellIndex{
    Plan *planCell = [layoutPlanArray objectAtIndex:_cellIndex - 1];
    if ([cell isKindOfClass:[LayoutCollectionViewCell_Portrait class]]) {
        [(LayoutCollectionViewCell_Portrait *)cell lb_planName].text = planCell.planName;
        if (planCell.applyPlan == 1) {
            [[(LayoutCollectionViewCell_Portrait *)cell bt_applyPlan] setImage:[UIImage imageNamed:@"iconLike20"] forState:UIControlStateNormal];
        } else {
            [[(LayoutCollectionViewCell_Portrait *)cell bt_applyPlan] setImage:[UIImage imageNamed:@"iconUnlike20"] forState:UIControlStateNormal];
        }
        
        [(LayoutCollectionViewCell_Portrait *)cell planImageView].image = [self generateImageOfPlan:planCell.planID];
    } else {
        [(LayoutCollectionViewCell_6Cell *)cell lb_planName].text = planCell.planName;
        
        if (planCell.applyPlan == 1) {
            [[(LayoutCollectionViewCell_6Cell *)cell bt_applyPlan] setImage:[UIImage imageNamed:@"iconLike20"] forState:UIControlStateNormal];
        } else {
            [[(LayoutCollectionViewCell_6Cell *)cell bt_applyPlan] setImage:[UIImage imageNamed:@"iconUnlike20"] forState:UIControlStateNormal];
        }
        
        [(LayoutCollectionViewCell_6Cell *)cell planImageView].image = [self generateImageOfPlan:planCell.planID];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.row == 0) {
//        return;
//    }
//    BOOL isNext;
//    if (planIndexPage < 0) {
//        isNext = YES;
//    }
//    else
//        isNext = NO;
//    planIndexPage = indexPath.row - 1;
//    _controlContainer.hidden = NO;
//    _collectionContainer.hidden = YES;
//    [self configureNextPreviousButton];
//    [self loadLayoutAtIndex:planIndexPage isNext:isNext];
}

- (UIImage *)generateImageOfPlan:(int)_planID{
    imgDst.release();
    NSMutableArray *planDatasource = [[NSMutableArray alloc] initWithArray:[Material instancesWhere:[NSString stringWithFormat:@"planID = %d",_planID]]];
    for (Material *obj in planDatasource) {
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
        layer.colorValue = color;
        layer.patternImage = obj.patternImage;
        
        layer.feature = obj.feature;
        layer.gloss = obj.gloss;
        layer.pattern = obj.pattern;
        layer.transparent = obj.transparent;
        if (layer.patternImage == nil)
            layer.mask = new CMask((int)color.R1, (int)color.G1, (int)color.B1);//(0, 125, 0);
        else {
            layer.mask = new CMask(0, 125, 0);
            cv::Mat imgPattern;
            UIImage *_i = [UIImage imageNamed:layer.patternImage];
            UIImageToMat(_i,imgPattern);
            _i = nil;
            layer.mask->setColor(imgPattern);
            imgPattern.release();
        }
        
        layer.mask->setTolerance(10);
        layer.mask->iniMaskByImagePath(std::string([obj.imageLink UTF8String]));
        layer.mask->setReferenceColor(obj.No);
        layer.mask->setTransparent(layer.transparent);
        layer.mask->Paint(imgSrc, imgDst);
        if ([obj.colorCode isEqualToString:@"未設定"]) {
            layer.mask->setDefaultColor(true);
        }
    }
    
    if (imgDst.data) {
        return MatToUIImage(imgDst);
    } else {
        return MatToUIImage(imgSrc);
    }
}

- (void)setApplyPlanInCell:(id)sender{
    NSIndexPath *selectedIndexPath = [_collectionView indexPathForCell:(UICollectionViewCell *)[[[(UIButton *)sender superview] superview] superview]];
    Plan *selectedPlan = [layoutPlanArray objectAtIndex:selectedIndexPath.row - 1];
    if (selectedPlan.applyPlan == 0) {
        [Plan executeUpdateQuery:[NSString stringWithFormat:@"UPDATE Plan SET applyPlan = 0 WHERE houseID = %d",houseID]];
        [Plan executeUpdateQuery:[NSString stringWithFormat:@"UPDATE Plan SET applyPlan = 1 WHERE planID = %d",selectedPlan.planID]];
        [House executeUpdateQuery:[NSString stringWithFormat:@"UPDATE House SET applyPlan = '%@' WHERE houseID = %d",selectedPlan.planName,houseID]];
        for (Plan *plan in layoutPlanArray) {
            if (plan.planID == selectedPlan.planID) {
                [plan setApplyPlan:1];
            }
            else
                [plan setApplyPlan:0];
        }
        if ([_delegate respondsToSelector:@selector(updateApplyPlanStatus: atIndex:)]) {
            [_delegate updateApplyPlanStatus:1 atIndex:(int)selectedIndexPath.row - 1];
        }
        for (int i = 0; i < layoutPlanArray.count; i++) {
            if ([[[(UIButton *)sender superview] superview] isKindOfClass:[LayoutCollectionViewCell_Portrait class]]) {
                [[(LayoutCollectionViewCell_Portrait *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:0]] bt_applyPlan] setImage:[UIImage imageNamed:@"iconUnlike20"] forState:UIControlStateNormal];
            }
            else{
                [[(LayoutCollectionViewCell_6Cell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:0]] bt_applyPlan] setImage:[UIImage imageNamed:@"iconUnlike20"] forState:UIControlStateNormal];
            }
        }
        [(UIButton *)sender setImage:[UIImage imageNamed:@"iconLike20"] forState:UIControlStateNormal];
    }
    else{
        [Plan executeUpdateQuery:[NSString stringWithFormat:@"UPDATE Plan SET applyPlan = 0 WHERE planID = %d",selectedPlan.planID]];
        [House executeUpdateQuery:[NSString stringWithFormat:@"UPDATE House SET applyPlan = '' WHERE houseID = %d",houseID]];
        [_bt_applyPlan setImage:[UIImage imageNamed:@"iconUnlike20"] forState:UIControlStateNormal];
        for (Plan *plan in layoutPlanArray) {
            [plan setApplyPlan:0];
        }
        if ([_delegate respondsToSelector:@selector(updateApplyPlanStatus: atIndex:)]) {
            [_delegate updateApplyPlanStatus:0 atIndex:(int)selectedIndexPath.row - 1];
        }
        [(UIButton *)sender setImage:[UIImage imageNamed:@"iconUnlike20"] forState:UIControlStateNormal];
    }
    isNeedReloadPlanData = YES;
}

- (NSString *)getPatternImage:(NSString *)_pattern{
    return [patternNames objectForKey:_pattern];
}
@end
