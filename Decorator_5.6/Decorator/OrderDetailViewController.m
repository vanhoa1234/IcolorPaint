//
//  OrderDetailViewController.m
//  Decorator
//
//  Created by Hoang Le on 11/25/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "MaterialDetailCell.h"
#import "Material.h"
#import "CustomOrderViewController.h"
#import "EditOrderViewController.h"
#import <MessageUI/MessageUI.h>
#import "Feature.h"
#import "SettingViewController.h"

@interface OrderDetailViewController (){
    NSMutableArray *datasource;
    NSMutableArray *plans;
    int selectedIndex;
}

@end

@implementation OrderDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithDetailList:(NSArray *)_detailList{
    self = [super init];
    if (self) {
        datasource = [[NSMutableArray alloc] initWithArray:_detailList];
    }
    return self;
}

- (id)initWithDetailList:(NSArray *)_detailList andPlans:(NSArray *)_plans{
    self = [super init];
    if (self) {
        datasource = [[NSMutableArray alloc] initWithArray:_detailList];
        plans = [[NSMutableArray alloc] initWithArray:_plans];
    }
    return self;
}

- (IBAction)backToOrder:(id)sender {
//    [self.navigationController popViewControllerWithFlipStyle:MPFlipStyleDirectionBackward];
    [self.navigationController fadePopViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedIndex = -1;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        _background.image = [UIImage imageNamed:@"BG_02.jpg"];
    }
    else{
        _background.image = [UIImage imageNamed:@"BG_04.jpg"];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;{
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [datasource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellIdentifier";
    MaterialDetailCell *tbCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (tbCell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MaterialDetailCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[MaterialDetailCell class]])
            {
                tbCell = (MaterialDetailCell *)currentObject;
//                tbCell.view_feature.layer.cornerRadius = 15.0f;
//                tbCell.view_feature.layer.borderColor = [UIColor blackColor].CGColor;
//                tbCell.view_feature.layer.borderWidth = 1.0f;
                tbCell.backgroundColor = [UIColor clearColor];
                break;
            }
        }
    }
    Material *obj = [datasource objectAtIndex:indexPath.row];
    @try {
        int type = (int)obj.type;
        if (type > 5) {
            type = 5;
        }
        Feature *feature = [[Feature instancesWhere:[NSString stringWithFormat:@"featureName = '%@' and type = %d",obj.feature,type]] objectAtIndex:0];
        tbCell.img_type.image = [UIImage imageNamed:[DecoratorUtil getTypeImageByID:(int)obj.type]];
        tbCell.img_feature.image = [UIImage imageNamed:[DecoratorUtil getMaterialIcon:(int)obj.type andKind:obj.feature]];
        tbCell.lb_type.text = [DecoratorUtil getTypeNameByID:(int)obj.type];
        tbCell.fname.text = obj.feature;
        //update description
        tbCell.fdescription.text = [NSString stringWithFormat:@"①	%@",feature.description];
        tbCell.fgloss.text = [NSString stringWithFormat:@"②	つやの種類：%@",obj.gloss];
        tbCell.fpattern.text = [NSString stringWithFormat:@"③	模様の種類：%@",obj.pattern];
        [tbCell.bt_setting setTag:indexPath.row];
        [tbCell.bt_setting addTarget:self action:@selector(customOrder:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([obj.feature isEqualToString:@"水性ジェルアートSi"]) {
            tbCell.bt_info.enabled = NO;
        }
        else
            tbCell.bt_info.enabled = YES;
        [tbCell.bt_info setTag:indexPath.row];
        [tbCell.bt_info addTarget:self action:@selector(editOrder:) forControlEvents:UIControlEventTouchUpInside];
        
        if (indexPath.row == selectedIndex) {
            tbCell.view_feature.backgroundColor = [UIColor colorWithRed:102./255. green:204./255. blue:1 alpha:1];
        }
        else
            tbCell.view_feature.backgroundColor = [UIColor clearColor];
    }
    @catch (NSException *exception) {
        [tbCell.bt_info setEnabled:NO];
        [tbCell.bt_setting setEnabled:NO];
    }
    @finally {
        return tbCell;
    }
}

- (void)customOrder:(id)sender{
    Material *obj = [datasource objectAtIndex:[(UIButton *)sender tag]];
    CustomOrderViewController *customViewController = [[CustomOrderViewController alloc] initWithMaterial:obj];
    customViewController.delegate = (id)self;
//    [self.navigationController pushViewController:customViewController flipStyle:MPFlipStyleDefault];
    [self.navigationController pushFadeViewController:customViewController];
}

- (void)editOrder:(id)sender{
    Material *obj = [datasource objectAtIndex:[(UIButton *)sender tag]];
    EditOrderViewController *editOrderController = [[EditOrderViewController alloc] initWithMaterial:obj];
    editOrderController.delegate = (id)self;
//    [self.navigationController pushViewController:editOrderController flipStyle:MPFlipStyleDefault];
    [self.navigationController pushFadeViewController:editOrderController];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedIndex = (int)indexPath.row;
    [[(MaterialDetailCell *)[tableView cellForRowAtIndexPath:indexPath] view_feature] setBackgroundColor:[UIColor colorWithRed:102./255. green:204./255. blue:1 alpha:1]];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[(MaterialDetailCell *)[tableView cellForRowAtIndexPath:indexPath] view_feature] setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - Custom Order delegate

- (void)savedCustomOrder:(Material *)_savedMaterial{
    [_savedMaterial save];
    int count = 0;
    for (Material *obj in datasource) {
        if (obj.materialID == _savedMaterial.materialID) {
            break;
        }
        count += 1;
    }
    [datasource replaceObjectAtIndex:count withObject:_savedMaterial];
    [_orderTableView reloadData];
//    [self.navigationController popViewControllerWithFlipStyle:MPFlipStyleDirectionBackward];
    [self.navigationController fadePopViewController];
}

- (void)savedEditOder:(Material *)_savedMaterial{
    [_savedMaterial save];
    int count = 0;
    for (Material *obj in datasource) {
        if (obj.materialID == _savedMaterial.materialID) {
            break;
        }
        count += 1;
    }
    [datasource replaceObjectAtIndex:count withObject:_savedMaterial];
    [_orderTableView reloadData];
//    [self.navigationController popViewControllerWithFlipStyle:MPFlipStyleDirectionBackward];
    [self.navigationController fadePopViewController];
}

- (IBAction)showEmailComposer:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
//        NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:kCCEmaillStore];
//        if (email) {
//            @try {
//                [mailComposer setToRecipients:[NSArray arrayWithObject:email]];
//            }
//            @catch (NSException *exception) {
//                [mailComposer setToRecipients:nil];
//            }
//            @finally {
//            }
//        }
//        email = [[NSUserDefaults standardUserDefaults] objectForKey:kEmailStore];
//        if (email) {
//            @try {
//                [mailComposer setCcRecipients:[NSArray arrayWithObject:email]];
//            }
//            @catch (NSException *exception) {
//                [mailComposer setCcRecipients:nil];
//            }
//            @finally {
//            }
//        }
//        [mailComposer setMessageBody:[DecoratorUtil generateOrderEmailWithMaterials:datasource] isHTML:YES];
        
//        [mailComposer setToRecipients:[NSArray arrayWithObject:@"nagoya@suzukafine.co.jp"]];
//        [mailComposer setCcRecipients:[NSArray arrayWithObject:@"ishii@yahoo.co.jp"]];
        [mailComposer setToRecipients:[NSArray arrayWithObject:[SettingViewController getCCEmailStore]]];
        [mailComposer setCcRecipients:[NSArray arrayWithObject:[SettingViewController getEmailStore]]];
        
        Plan *firstObj = [plans objectAtIndex:0];
        House *houseObj = [House instanceWithPrimaryKey:@(firstObj.houseID)];
        [mailComposer setSubject:[NSString stringWithFormat:@"塗板発注 (%@)",houseObj.houseName]];
        [mailComposer setMessageBody:[DecoratorUtil generateOrderEmail:houseObj andPlan:plans andMaterial:datasource] isHTML:YES];
        mailComposer.mailComposeDelegate = (id)self;
        [self presentViewController:mailComposer animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (IBAction)backtoTop:(id)sender {
//    [self.navigationController popToRootViewControllerWithFlipStyle:MPFlipStyleDirectionBackward];
    [self.navigationController fadePopRootViewController];
}
@end
