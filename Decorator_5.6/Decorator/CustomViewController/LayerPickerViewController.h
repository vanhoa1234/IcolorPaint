//
//  LayerPickerViewController.h
//  Decorator
//
//  Created by Hoang Le on 9/23/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LayerObject;

@protocol LayerPickerViewControllerDelegate <NSObject>
@optional
- (void)closeLayerPicker;
- (void)selectedLayerType:(LayerObject *)_layerObj;
@end

@interface LayerPickerViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSArray *currentLayes;
@property (nonatomic, assign) id<LayerPickerViewControllerDelegate> delegate;
- (IBAction)closeLayerPicker:(id)sender;

@end
