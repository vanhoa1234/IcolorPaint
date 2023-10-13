//
//  PreviewModalViewController.m
//  Decorator
//
//  Created by Hoang Le on 7/3/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import "PreviewModalViewController.h"

@interface PreviewModalViewController (){
    UIImage *previewImage;
    
}

@end

@implementation PreviewModalViewController
@synthesize delegate;
@synthesize orientation;
- (id)initWithPreviewImage:(UIImage *)_previewImage{
    self = [super init];
    if (self) {
        previewImage = _previewImage;
    }
    return self;
}

- (id)initWithPreviewImage:(UIImage *)_previewImage andOrientation:(UIInterfaceOrientation)_orientation{
    self = [super init];
    if (self) {
        previewImage = _previewImage;
        orientation = _orientation;
    }
    return self;
}

- (IBAction)closePreview:(id)sender {
    [delegate closePreviewModal];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.previewImageView.image = previewImage;
    self.previewImageView.center = self.view.center;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
