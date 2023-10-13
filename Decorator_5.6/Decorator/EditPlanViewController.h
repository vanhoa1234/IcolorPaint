//
//  EditPlanViewController.h
//  Decorator
//
//  Created by Hoang Le on 11/18/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingTableView.h"

typedef enum {
    EDIT_PLAN_MODE = 0,
    EXPORT_PLAN_MODE = 1,
    NONE_ACTION = 2
}ActionType;

@interface EditPlanViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *datasource;
    BOOL isCorrectUsernamePassword;
}
@property (nonatomic, strong) NSArray *objectsToShare;
@property (nonatomic, strong) NSDateFormatter *dateformatter;
- (IBAction)backToMenu:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *headerView;
- (IBAction)editPlanList:(id)sender;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingTableView *planTableView;
@property (weak, nonatomic) IBOutlet UIImageView *bgTableView;
@property (weak, nonatomic) IBOutlet UIImageView *background;
- (IBAction)showMapView:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *bt_export;

- (IBAction)exportHousePlan:(id)sender;


@property (weak, nonatomic) IBOutlet UILabel *title1;
@property (weak, nonatomic) IBOutlet UILabel *title2;
@property (weak, nonatomic) IBOutlet UILabel *title3;
@property (weak, nonatomic) IBOutlet UILabel *title4;
@property (weak, nonatomic) IBOutlet UILabel *title5;

@end
