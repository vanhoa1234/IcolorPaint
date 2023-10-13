//
//  ExportMapModalController.m
//  Decorator
//
//  Created by Hoang Le on 5/5/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import "ExportMapModalController.h"

@interface ExportMapModalController ()

@end

@implementation ExportMapModalController
@synthesize delegate;
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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectedExportType:(id)sender {
    if (sender == _bt_exportMap) {
        [delegate selectedExportType:0];
    }
    else
        [delegate selectedExportType:1];
}
@end
