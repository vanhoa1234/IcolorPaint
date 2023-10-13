//
//  ExportMapModalController.h
//  Decorator
//
//  Created by Hoang Le on 5/5/14.
//  Copyright (c) 2014 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ExportMapModalControllerDelegate <NSObject>
@optional
- (void)selectedExportType:(int)type;

@end

@interface ExportMapModalController : UIViewController
@property (nonatomic, assign) id<ExportMapModalControllerDelegate> delegate;
- (IBAction)selectedExportType:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bt_exportMap;
@property (weak, nonatomic) IBOutlet UIButton *bt_nonExportMap;
@end
