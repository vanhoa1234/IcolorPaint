//
//  OutputPickerViewController.m
//  Decorator
//
//  Created by Hoang Le on 12/2/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "OutputPickerViewController.h"

@interface OutputPickerViewController ()

@end

@implementation OutputPickerViewController

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
    self.contentSizeForViewInPopover = CGSizeMake(240, 308);
}
- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)emailAction:(id)sender {
    [_delegate outputAction:OUTPUT_MAIL withFormat:(int)_segFormat.selectedSegmentIndex];
}

- (IBAction)printAction:(id)sender {
    [_delegate outputAction:OUTPUT_PRINTER withFormat:(int)_segFormat.selectedSegmentIndex];
}

- (IBAction)twitterAction:(id)sender {
    [_delegate outputAction:OUTPUT_TWITTER withFormat:(int)_segFormat.selectedSegmentIndex];
}

- (IBAction)facebookAction:(id)sender {
    [_delegate outputAction:OUTPUT_FACEBOOK withFormat:(int)_segFormat.selectedSegmentIndex];
}

- (IBAction)selectedOutputType:(id)sender {
    if ([(UISegmentedControl *)sender selectedSegmentIndex] == 0) {
        _lbFacebook.hidden = NO;
        _lbTwitter.hidden = NO;
        _btFacebook.hidden = NO;
        _btTwitter.hidden = NO;
    }
    else{
        _lbFacebook.hidden = YES;
        _lbTwitter.hidden = YES;
        _btFacebook.hidden = YES;
        _btTwitter.hidden = YES;
    }
}
@end
