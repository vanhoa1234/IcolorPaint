//
//  CropImageViewController.m
//  Decorator
//
//  Created by Hoang Le on 11/29/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "CropImageViewController.h"
#import "UIImage-Extension.h"
@interface CropImageViewController (){
    MBProgressHUD *HUD;
}

@end

@implementation CropImageViewController
@synthesize cropperView,delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithImage:(UIImage*)newImage andframeSize:(CGSize)frameSize andcropSize:(CGSize)cropSize
{
    self = [super init];
	
	if (self) {
        
        if(newImage.size.width <= cropSize.width || newImage.size.height <= cropSize.height)
        {
            newImage = [newImage resizedImageToFitInSize:CGSizeMake(cropSize.width*1.3, cropSize.height*1.3) scaleIfSmaller:YES];
        }
        self.view.backgroundColor = [UIColor blackColor];
        cropperView = [[UzysImageCropper alloc]
                       initWithImage:newImage
                       andframeSize:frameSize
                       andcropSize:cropSize];
        [self.contentView addSubview:cropperView];
    }
    
    return self;
    
}

- (id)initWithImage:(UIImage*)newImage andframeSize:(CGSize)frameSize andcropSize:(CGSize)cropSize andImage:(NSString *)imageName{
    self = [super init];
	
	if (self) {
        
        if(newImage.size.width <= cropSize.width || newImage.size.height <= cropSize.height)
        {
            newImage = [newImage resizedImageToFitInSize:CGSizeMake(cropSize.width*1.3, cropSize.height*1.3) scaleIfSmaller:YES];
        }
        self.view.backgroundColor = [UIColor blackColor];
        cropperView = [[UzysImageCropper alloc]
                       initWithImage:newImage
                       andframeSize:frameSize
                       andcropSize:cropSize andImage:imageName];
        [self.contentView addSubview:cropperView];
    }
    
    return self;
}

- (void)myProgressTask {
    // This just increases the progress indicator in a loop
    float progress = 0.0f;
    while (progress < 1.0f) {
        progress += 0.01f;
        HUD.progress = progress;
        usleep(30000);
    }
}

- (void)showHUD{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.yOffset = -200;
	[self.view addSubview:HUD];
    HUD.mode = MBProgressHUDModeAnnularDeterminate;
    HUD.labelText = @"表示したい所を自由に拡大してください。";
	// Regiser for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
    [HUD showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"IsShowCropGuide"] isEqualToString:@"0"] || [[NSUserDefaults standardUserDefaults] valueForKey:@"IsShowCropGuide"] == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"IsShowCropGuide"];
        [self showHUD];
    }
    
//    [TSMessage showNotificationInViewController:self title:@"表示したい所を自由に拡大してください。" subtitle:@"" image:nil type:TSMessageNotificationTypeSuccess duration:6 callback:^{
//        
//    } buttonTitle:nil buttonCallback:nil atPosition:TSMessageNotificationPositionBottom canBeDismisedByUser:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    [delegate imageCropperDidCancel:self];
}

- (IBAction)saveAction:(id)sender {
    UIImage *cropped =[cropperView getCroppedImage];
	[delegate imageCropper:self didFinishCroppingWithImage:cropped];
}

- (IBAction)rotateAction:(id)sender {
    [cropperView actionRotate];
}

- (IBAction)resetAction:(id)sender {
    [cropperView actionRestore];
}
@end
