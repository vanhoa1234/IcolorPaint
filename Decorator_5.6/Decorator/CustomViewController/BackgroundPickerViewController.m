//
//  BackgroundPickerViewController.m
//  Decorator
//
//  Created by Hoang Le on 12/2/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "BackgroundPickerViewController.h"
#import "GMGridView.h"

@interface BackgroundPickerViewController ()<GMGridViewDataSource, GMGridViewActionDelegate>{
    __gm_weak GMGridView *_gmGridView;
    NSMutableArray *_backgroundData;
    UIInterfaceOrientation backgroundOrientation;
}

@end

@implementation BackgroundPickerViewController
- (id)initWithOrientation:(UIInterfaceOrientation)_orientation{
    self = [super init];
    if (self) {
        backgroundOrientation = _orientation;
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (BOOL)shouldAutorotate{
//    return YES;
//}
//
//- (NSUInteger)supportedInterfaceOrientations{
//    return backgroundOrientation;
////    if (UIInterfaceOrientationIsLandscape(backgroundOrientation)) {
////        return UIInterfaceOrientationMaskLandscapeLeft;
////    }
////    else
////        return UIInterfaceOrientationMaskPortrait;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.contentSizeForViewInPopover = CGSizeMake(500, 400);
    _backgroundData = [[NSMutableArray alloc] initWithObjects:@"255,255,255",@"115,117,117",@"28, 29, 33",@"CorkBoard02.jpg",@"BGR_02.jpg",@"BGR_03.jpg",@"BGR_04.jpg",@"BGR_05.jpg",@"wallpaper-428336.jpg", nil];
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:CGRectMake(10, 55, self.view.frame.size.width - 5, self.view.frame.size.height - 55)];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.backgroundColor = [UIColor clearColor];
    gmGridView.layer.masksToBounds = YES;
    [self.view addSubview:gmGridView];
    
    _gmGridView = gmGridView;
    _gmGridView.style = GMGridViewStyleSwap;
    _gmGridView.itemSpacing = 20;
    _gmGridView.minEdgeInsets = UIEdgeInsetsMake(15, 0, 15, 0);
    _gmGridView.centerGrid = NO;
    _gmGridView.actionDelegate = self;
    _gmGridView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissMe:(id)sender {
    [_delegate dismissBackgroundPicker];
}

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [_backgroundData count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            CGSize cell = CGSizeMake(([UIScreen mainScreen].bounds.size.width - 60) / 3, ([UIScreen mainScreen].bounds.size.width - 60) / 3 * 0.75);
            return cell;
        } else {
            CGSize cell = CGSizeMake(([UIScreen mainScreen].bounds.size.width - 60) / 3, ([UIScreen mainScreen].bounds.size.width - 60) / 3 * 0.75);
            return cell;
        }
        return CGSizeMake(293, 220);
    }
    else {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            CGSize cell = CGSizeMake(([UIScreen mainScreen].bounds.size.width - 60) / 3, ([UIScreen mainScreen].bounds.size.width - 60) / 3 / 0.75);
            return cell;
        } else {
            CGSize cell = CGSizeMake(([UIScreen mainScreen].bounds.size.width - 40) / 2, ([UIScreen mainScreen].bounds.size.width - 40) / 2 / 0.75);
            return cell;
        }
        return CGSizeMake(220, 293);
    }
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        cell.contentView = view;
    }
    if (index == 0) {
        cell.contentView.layer.contents = nil;
        cell.contentView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    }
    else if (index == 1) {
        cell.contentView.layer.contents = nil;
        cell.contentView.backgroundColor = [UIColor colorWithRed:115/255.0f green:117/255.0f blue:117/255.0f alpha:1];
    }
    else if (index == 2){
        cell.contentView.layer.contents = nil;
        cell.contentView.backgroundColor = [UIColor colorWithRed:28/255.0f green:29/255.0f blue:33/255.0f alpha:1];
    }
    else{
//        cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"t_%@",[_backgroundData objectAtIndex:index]]]];
        cell.contentView.layer.contents = (id)[UIImage imageNamed:[NSString stringWithFormat:@"t_%@",[_backgroundData objectAtIndex:index]]].CGImage;
    }
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    return cell;
}


- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return NO; //index % 2 == 0;
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
//    if (position == 0) {
//        [_delegate selectedBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
//    }
//    else if (position == 1) {
//        [_delegate selectedBackgroundColor:[UIColor colorWithRed:115/255.0f green:117/255.0f blue:117/255.0f alpha:1]];
//    }
//    else if (position == 2){
//        [_delegate selectedBackgroundColor:[UIColor colorWithRed:28/255.0f green:29/255.0f blue:33/255.0f alpha:1]];
//    }
//    else
        [_delegate selectedBackgroundImage:[_backgroundData objectAtIndex:position]];
}

@end
