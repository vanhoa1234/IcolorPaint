//
//  AlbumViewController.h
//  Decorator
//
//  Created by Hoang Le on 9/16/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"
#import "GMGridView.h"

@protocol AlbumViewControllerDelegate <NSObject>
@optional
- (void)selectedPhoto:(UIImage *)image;
- (void)cancelAlbum;
@end

@interface AlbumViewController : UIViewController<MWPhotoBrowserDelegate>

@property (nonatomic, assign) id<AlbumViewControllerDelegate> delegate;
- (IBAction)backToMenuViewController:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
- (IBAction)assetTypeChanged:(id)sender;
@property (weak, nonatomic) IBOutlet GMGridView *gmGridView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UISwitch *switch_resizeImage;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@end
