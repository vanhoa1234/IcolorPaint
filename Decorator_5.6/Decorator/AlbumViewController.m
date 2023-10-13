//
//  AlbumViewController.m
//  Decorator
//
//  Created by Hoang Le on 9/16/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "AlbumViewController.h"
#import "PlanViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+UIImage_Extensions.h"
#import "MWPhoto.h"
#import <CoreLocation/CoreLocation.h>
#import <Photos/Photos.h>
#import "MBProgressHUD.h"

typedef enum {
    SHOW_GROUP = 0,
    SHOW_ASSET = 1
}SHOW_TYPE;
typedef enum {
    PTShowcaseTagThumbnail  = 10,
    PTShowcaseTagText       = 20,
    PTShowcaseTagDetailText = 30,
} PTShowcaseTag;

@interface AlbumViewController ()<GMGridViewDataSource, GMGridViewActionDelegate>{
    ALAssetsLibrary* library;
//    __gm_weak GMGridView *_gmGridView;
    NSMutableArray *_groupDataSource;
    NSMutableArray *_assetDataSource;
    SHOW_TYPE type;
    BOOL isIphone;
}

@end

@implementation AlbumViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        library = [[ALAssetsLibrary alloc] init];
        type = SHOW_GROUP;
        _groupDataSource = [[NSMutableArray alloc] init];
        _assetDataSource = [[NSMutableArray alloc] init];
        _gmGridView.mainSuperView = self.navigationController.view;
        [self performSelectorOnMainThread:@selector(getAllAlbum) withObject:nil waitUntilDone:NO];
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
        library = [[ALAssetsLibrary alloc] init];
        type = SHOW_GROUP;
        _groupDataSource = [[NSMutableArray alloc] init];
        _assetDataSource = [[NSMutableArray alloc] init];
//        [self performSelectorOnMainThread:@selector(getAllAlbum) withObject:nil waitUntilDone:NO];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        _background.image = [UIImage imageNamed:@"BG_02.jpg"];
    }
    else{
        _background.image = [UIImage imageNamed:@"BG_04.jpg"];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_gmGridView layoutSubviews];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isIphone = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone;
    /*
    CGRect gridRect;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        gridRect = CGRectMake(30, 120, self.view.frame.size.width - 30, self.view.frame.size.height - 90);
    } else {
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            gridRect = CGRectMake(10, 160, self.view.frame.size.width - 10, self.view.frame.size.height - 170);
        } else {
            gridRect = CGRectMake(10, 140, self.view.frame.size.width - 10, self.view.frame.size.height - 150);
        }
    }
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:gridRect];
    gmGridView.clipsToBounds = YES;
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    gmGridView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:gmGridView];
     _gmGridView = gmGridView;
     */
    _gmGridView.clipsToBounds = YES;
    _gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    
    _gmGridView.style = GMGridViewStyleSwap;
    _gmGridView.itemSpacing = 0;
    _gmGridView.minEdgeInsets = UIEdgeInsetsMake(5, 0, 50, 0);
//    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
//        _gmGridView.minEdgeInsets = UIEdgeInsetsMake(15, 10, 15, 10);
//    } else {
//        _gmGridView.minEdgeInsets = UIEdgeInsetsMake(15, 10, 15, 10);
//    }
    _gmGridView.centerGrid = NO;
    _gmGridView.actionDelegate = self;
    _gmGridView.dataSource = self;
    _gmGridView.mainSuperView = self.navigationController.view;
    [self.view bringSubviewToFront:_toolbar];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (UIInterfaceOrientationIsPortrait(fromInterfaceOrientation)) {
        _background.image = [UIImage imageNamed:@"BG_02.jpg"];
    }
    else{
        _background.image = [UIImage imageNamed:@"BG_04.jpg"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backToMenuViewController:(id)sender {
    if (_segmentedControl.selectedSegmentIndex == 0 && type == SHOW_ASSET) {
        [self getAllAlbum];
    }
    else {
        if (self.navigationController != nil) {

            [self.navigationController fadePopViewController];
        } else {
//            [self dismissViewControllerAnimated:YES completion:nil];
            [_delegate cancelAlbum];
            
        }
    }
}

- (IBAction)assetTypeChanged:(id)sender {
    switch ([(UISegmentedControl *)sender selectedSegmentIndex]) {
        case 0:
            [self getAllAlbum];
            break;
        case 1:
            [self getAssetFromGroupLibrary];
            break;
        default:
            break;
    }
}

#pragma mark - get asset

- (void)getAssetFromGroupLibrary{
    [library enumerateGroupsWithTypes:ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [self getAssetFromGroup:group];
        }
    } failureBlock:^(NSError *error) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"AssetsLibrary access denied"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)getAllAlbum{
    NSMutableArray* __groups = [NSMutableArray array];
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group){
            if (group.numberOfAssets > 0) {
                [__groups addObject:group];
            }
        }
        else{
            [_groupDataSource setArray:[[__groups reverseObjectEnumerator] allObjects]];
            type = SHOW_GROUP;
            CATransition *animation = [CATransition animation];
            animation.delegate = (id)self;
            animation.duration = 0.7;
            animation.timingFunction = UIViewAnimationCurveEaseInOut;
            @try {
                animation.type = @"pageCurl";
                animation.subtype = kCATransitionFromRight;
            }
            @catch (NSException *exception) {
                animation.type = kCATransitionFade;
                animation.subtype = kCATransitionFromBottom;
            }
            @finally {
                [_gmGridView reloadData];
                [[self.view layer] addAnimation:animation forKey:@"animation"];
            }
        }
    } failureBlock:^(NSError *error) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"AssetsLibrary access denied"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)getAssetFromGroup:(ALAssetsGroup *)group{
    [_assetDataSource removeAllObjects];
    NSMutableArray* assets = [NSMutableArray array];
    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result){
            [assets addObject:result];
        }
        else{
            [_assetDataSource setArray:[[assets reverseObjectEnumerator] allObjects]];
            type = SHOW_ASSET;
            CATransition *animation = [CATransition animation];
            animation.delegate = (id)self;
            animation.duration = 0.7;
            animation.timingFunction = UIViewAnimationCurveEaseInOut;
            @try {
                animation.type = @"pageCurl";
                animation.subtype = kCATransitionFromRight;
            }
            @catch (NSException *exception) {
                animation.type = kCATransitionFade;
                animation.subtype = kCATransitionFromBottom;
            }
            @finally {
                [_gmGridView reloadData];
                [[self.view layer] addAnimation:animation forKey:@"animation"];
            }

        }
    }];
}

#pragma mark - showcase
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView{
    if (type == SHOW_GROUP) {
        return [_groupDataSource count];
    }
    else
        return [_assetDataSource count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation{
    if (type == SHOW_GROUP) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
//            return CGSizeMake(270, 236+20);
            if (UIInterfaceOrientationIsLandscape(orientation)) {
                return CGSizeMake(gridView.bounds.size.width/4, 256);
            }
            return CGSizeMake(gridView.bounds.size.width/3, 256);
        } else {
            if (UIInterfaceOrientationIsLandscape(orientation)) {
                return CGSizeMake(gridView.bounds.size.width/3, 200);
            }
            return CGSizeMake(gridView.bounds.size.width/2, gridView.bounds.size.width/2);
//            return CGSizeMake(180, 180);
        }
        
    }
    else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return CGSizeMake(105.0, 105.0);
    } else {
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            return CGSizeMake(gridView.bounds.size.width/5, 105);
        }
        return CGSizeMake(gridView.bounds.size.width/3, 105);
    }
//    return CGSizeMake(105.0, 105.0);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index{
    GMGridViewCell *cell;
    if (type == SHOW_GROUP) {
        ALAssetsGroup *group = [_groupDataSource objectAtIndex:index];
        UIImage *groupImage = [UIImage imageWithCGImage:[group posterImage]];
        NSComparisonResult orientation = [self getImageOrientation:groupImage.size];
        cell = [self GMGridView:gridView cellForContentType:SHOW_GROUP withOrientation:orientation];
        NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
        if ([groupName isEqualToString:@"Camera Roll"]) {
            groupName = NSLocalizedString(@"camera", nil);
        }
        else if ([groupName isEqualToString:@"My Photo Stream"]){
            groupName = NSLocalizedString(@"album", nil);
        }
        [(UILabel *)[cell viewWithTag:PTShowcaseTagText] setText:groupName];
        [(UIImageView *)[cell viewWithTag:PTShowcaseTagThumbnail] setImage:groupImage];
    }
    else{
        ALAsset *asset = [_assetDataSource objectAtIndex:index];
        UIImage *assetImage = [UIImage imageWithCGImage:[asset thumbnail]];
        NSComparisonResult orientation = [self getImageOrientation:[asset defaultRepresentation].dimensions];
        cell = [self GMGridView:gridView cellForContentType:SHOW_ASSET withOrientation:orientation];
        [(UIImageView *)[cell viewWithTag:PTShowcaseTagThumbnail] setImage:assetImage];
    }
    return cell;
}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position{
    if (type == SHOW_GROUP) {
        ALAssetsGroup *group = [_groupDataSource objectAtIndex:position];
        [self getAssetFromGroup:group];
    }
    else if (type == SHOW_ASSET){
        if (_delegate != nil) {
            ALAsset *asset = [_assetDataSource objectAtIndex:position];
            [_delegate selectedPhoto:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]]];
        } else {
            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:(id)self];
            browser.wantsFullScreenLayout = YES;
    //        browser.displayActionButton = YES;
            [browser setInitialPageIndex:position];
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            [self.navigationController pushFadeViewController:browser];
        }
    }
}

- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index{
    return NO;
}

- (NSComparisonResult)getImageOrientation:(CGSize)size{
    if (size.width > size.height) {
        return NSOrderedAscending;
    }
    else if (size.width < size.height)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView groupCellWithOrientation:(NSComparisonResult)orientation;
{
    
    NSString *cellIdentifier = orientation == NSOrderedDescending ? @"GroupPortraitCell" : @"GroupLandscapeCell";
    
    GMGridViewCell *cell = [gridView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[GMGridViewCell alloc] init];
        cell.reuseIdentifier = cellIdentifier;
        // Back Image
        
        NSString *backImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"group",
                                   orientation == NSOrderedDescending ? @"portrait" : @"landscape"];
        CGRect backImageViewFrame = isIphone ? CGRectMake(0.0, 0.0, 180.0, 180.0) : CGRectMake(0.0, 0.0, 256.0, 256.0);
        
        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:backImageViewFrame];
        backImageView.image = [UIImage imageNamed:backImageName];
        [cell addSubview:backImageView];
        
        // Thumbnail
        
        NSString *loadingImageName = [NSString stringWithFormat:@"PTShowcase.bundle/%@-%@.png", @"thumbnail-loading",
                                      orientation == NSOrderedDescending ? @"portrait" : @"landscape"];
        CGRect loadingImageViewFrame = orientation == NSOrderedDescending
        ? (isIphone ? CGRectMake(25.0, 28.0, 130.0, 180.0) : CGRectMake(60.0, 28.0, 135.0, 180.0))
        : (isIphone ? CGRectMake(25.0, 38.0, 130.0, 97.0) : CGRectMake(40.0, 50.0, 180.0, 135.0));
        
        
        UIImageView *thumbnailImage = [[UIImageView alloc] initWithFrame:loadingImageViewFrame];
        thumbnailImage.tag = PTShowcaseTagThumbnail;
        thumbnailImage.image = [UIImage imageNamed:loadingImageName];
        [cell addSubview:thumbnailImage];
    }
    
    return cell;
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView imageCellWithOrientation:(NSComparisonResult)orientation;
{
    NSString *cellIdentifier;
    if (orientation == NSOrderedSame) {
        cellIdentifier = @"ImageSameCell";
    }
    else if (orientation == NSOrderedAscending){
        cellIdentifier = @"ImageLandscapeCell";
    }
    else
        cellIdentifier = @"ImagePortraitCell";
    GMGridViewCell *cell = [gridView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[GMGridViewCell alloc] init];
        cell.reuseIdentifier = cellIdentifier;
        // Thumbnail
        
        NSString *loadingImageName;
        if (orientation == NSOrderedDescending) {
            loadingImageName = @"PTShowcase.bundle/thumbnail-loading-portrait.png";
        }
        else
            loadingImageName = @"PTShowcase.bundle/thumbnail-loading-landscape.png";
        
        CGRect loadingImageViewFrame;
        if (orientation == NSOrderedDescending) {
            loadingImageViewFrame = CGRectMake(18.0, 8.0, 80.0, 100.0);
        }
        else if (orientation == NSOrderedAscending){
            loadingImageViewFrame = CGRectMake(8.0, 28.0, 100.0, 80.0);
        }
        else
            loadingImageViewFrame = CGRectMake(13, 18, 90, 90);
        UIImageView *thumbnailView = [[UIImageView alloc] initWithFrame:loadingImageViewFrame];
        thumbnailView.tag = PTShowcaseTagThumbnail;
        thumbnailView.image = [UIImage imageNamed:loadingImageName];
        [cell addSubview:thumbnailView];
        
        // Overlap
        
        NSString *overlapImageName;
        if (orientation == NSOrderedDescending) {
            overlapImageName = @"PTShowcase.bundle/image-overlap-portrait.png";
        }
        else if (orientation == NSOrderedAscending){
            overlapImageName = @"PTShowcase.bundle/image-overlap-landscape.png";
        }
        else
            overlapImageName = @"PTShowcase.bundle/image-overlap-landscape.png";
        UIImageView *overlapView = [[UIImageView alloc] initWithFrame:loadingImageViewFrame];
        overlapView.image = [UIImage imageNamed:overlapImageName];
        [cell addSubview:overlapView];
    }
    
    return cell;
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForContentType:(SHOW_TYPE)contentType withOrientation:(NSComparisonResult)orientation
{
    GMGridViewCell *cell = nil;
    switch (contentType)
    {
        case SHOW_GROUP:
        {
            cell = [self GMGridView:gridView groupCellWithOrientation:orientation];
            break;
        }
        case SHOW_ASSET:
        {
            cell = [self GMGridView:gridView imageCellWithOrientation:orientation];
            break;
        }
        default: NSAssert(NO, @"Unknown content-type.");
    }
    CGRect frame = isIphone ? CGRectMake(0.0, 150, 180.0, 20.0) : CGRectMake(0.0, 210.0, 256.0, 20.0);
    UILabel *textLabel = [[UILabel alloc] initWithFrame:frame];
    textLabel.tag = PTShowcaseTagText;
    textLabel.font = [UIFont boldSystemFontOfSize:14.0];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    textLabel.textColor = [UIColor blackColor];
    textLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    textLabel.shadowColor = [UIColor grayColor];
    textLabel.backgroundColor = [UIColor clearColor];

    [cell addSubview:textLabel];
    return cell;
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return [_assetDataSource count];
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    ALAsset *asset = [_assetDataSource objectAtIndex:index];
//    MWPhoto *photo = [[MWPhoto alloc] initWithImage:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]]];
    MWPhoto *photo = [[MWPhoto alloc] initWithAsetURL:[asset defaultRepresentation].url];
    return photo;
}

- (void)cancelPhotoBrowser{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController fadePopViewController];
}

- (void)selectedImageIndex:(int)_index{
    [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    ALAsset *asset = [_assetDataSource objectAtIndex:_index];
    ALAssetRepresentation* representation = [asset defaultRepresentation];
    PHAsset *phasset = [PHAsset fetchAssetsWithALAssetURLs:@[representation.url] options:nil].firstObject;
    PHImageManager *manager = [[PHImageManager alloc] init];
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    option.networkAccessAllowed = YES;
    option.synchronous = NO;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [manager requestImageForAsset:phasset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (result != nil) {
//            UIImage *originalImg = [UIImage imageWithCGImage:image scale:1 orientation:(UIImageOrientation)representation.orientation];
            UIImage *correctImg = [self fixImageOrientation:result withOrientation:result.imageOrientation];
            
            PlanViewController *planViewController;
            CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
            UIInterfaceOrientation layoutOrientation;
            if (correctImg.size.height > correctImg.size.width) {
                layoutOrientation = UIInterfaceOrientationPortrait;
            }
            else
                layoutOrientation = UIInterfaceOrientationLandscapeLeft;
            if (UIInterfaceOrientationIsLandscape(layoutOrientation) == UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
                layoutOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            }
            if (location) {
                planViewController = [[PlanViewController alloc] initWithImage:correctImg withResizeImage:NO andImageOrientation:(UIImageOrientation)[representation orientation] andLongitude:location.coordinate.longitude andLatitude:location.coordinate.latitude andLayoutOrientation:layoutOrientation];
            }
            else
                planViewController = [[PlanViewController alloc] initWithImage:correctImg withResizeImage:NO andImageOrientation:(UIImageOrientation)[representation orientation] andLayoutOrientation:layoutOrientation];
            [self.navigationController pushFadeViewController:planViewController];
        }
    }];
}

- (UIImage *)fixImageOrientation:(UIImage *)originalImg withOrientation:(UIImageOrientation)orientation{
    float radian;
    switch (orientation) {
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            return originalImg;
            break;
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            radian = M_PI;
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:{
            radian = 3.0 * M_PI / 2.0;
            originalImg = [originalImg imageRotatedByRadians:radian];
            originalImg = [originalImg imageByScalingToSize:CGSizeMake(originalImg.size.height, originalImg.size.width)];
            return originalImg;
        }
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:{
            radian = M_PI / 2.0;
            originalImg = [originalImg imageRotatedByRadians:radian];
            originalImg = [originalImg imageByScalingToSize:CGSizeMake(originalImg.size.height, originalImg.size.width)];
            return originalImg;
        }
            break;
        default:
            break;
    }
    return [originalImg imageRotatedByRadians:radian];
}

- (UIImage *)imageByRotatingImage:(UIImage*)initImage fromImageOrientation:(UIImageOrientation)orientation
{
    CGImageRef imgRef = initImage.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = orientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            return initImage;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break; 
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    // Create the bitmap context
    CGContextRef    context = NULL;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (bounds.size.width * 4);
    bitmapByteCount     = (bitmapBytesPerRow * bounds.size.height);
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        return nil;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    CGColorSpaceRef colorspace = CGImageGetColorSpace(imgRef);
    context = CGBitmapContextCreate (bitmapData,bounds.size.width,bounds.size.height,8,bitmapBytesPerRow,
                                     colorspace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorspace);
    
    if (context == NULL)
        // error creating context
        return nil;
    
    CGContextScaleCTM(context, -1.0, -1.0);
    CGContextTranslateCTM(context, -bounds.size.width, -bounds.size.height);
    
    CGContextConcatCTM(context, transform);
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(context, CGRectMake(0,0,width, height), imgRef);
    
    CGImageRef imgRef2 = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    free(bitmapData);
    UIImage * image = [UIImage imageWithCGImage:imgRef2 scale:initImage.scale orientation:UIImageOrientationUp];
    CGImageRelease(imgRef2);
    return image;
}
@end
