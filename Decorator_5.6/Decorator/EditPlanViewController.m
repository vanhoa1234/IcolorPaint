//
//  EditPlanViewController.m
//  Decorator
//
//  Created by Hoang Le on 11/18/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "EditPlanViewController.h"
#import "House.h"
#import "EditPlanCell.h"
#import "OrderViewController.h"
#import "Plan.h"
#import "Material.h"
#import "PlanViewController.h"
#import <MessageUI/MessageUI.h>
#import "LayoutViewController.h"
#import "MapViewController.h"
#import "UIImage+ResizeMagick.h"
#import "SettingViewController.h"
#import "ArchiveObject.h"
//#import "ZipArchive.h"
#import "MZFormSheetController.h"
#import "ZipArchive.h"
#import "MBProgressHUD.h"
#import "RTSpinKitView.h"
#import "LayoutPosition.h"
@interface EditPlanViewController (){
    BOOL isEditingMode;
    int selectedIndex;
    ActionType actionType;
    MZFormSheetController *formSheetController;
    NSString *zippedPath;
    MBProgressHUD *Hud;
}

@end

@implementation EditPlanViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        _background.image = [UIImage imageNamed:@"BG_04.jpg"];
    }
    else{
        _background.image = [UIImage imageNamed:@"BG_02.jpg"];
    }
    isEditingMode = NO;
    datasource = [[NSMutableArray alloc] initWithArray:[[[House allInstances] reverseObjectEnumerator] allObjects]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    documentsDirectory = [documentsDirectory stringByDeletingLastPathComponent];
    BOOL isChange = NO;
    if ([datasource count] > 0) {
        for (House *house in datasource) {
            NSString *applicationPath = [[house.houseImage componentsSeparatedByString:@"/Documents/"] objectAtIndex:0];
            if (![applicationPath isEqualToString:documentsDirectory]) {
                isChange = YES;
                    [house setHouseImage:[house.houseImage stringByReplacingOccurrencesOfString:applicationPath withString:documentsDirectory]];
                    [house setHouseImageThumnail:[house.houseImageThumnail stringByReplacingOccurrencesOfString:applicationPath withString:documentsDirectory]];
                    [house save];
                    NSArray *allPlans = [Plan instancesWhere:@"houseID = ?",@(house.houseID)];
                    for (Plan *plan in allPlans) {
                        NSArray *allMaterials = [Material instancesWhere:@"planID = ?",@(plan.planID)];
                        for (Material *material in allMaterials) {
                            [material setImageLink:[material.imageLink stringByReplacingOccurrencesOfString:applicationPath withString:documentsDirectory]];
                            [material save];
                        }
                    }
            }
        }
    }
    if (isChange) {
        datasource = [[NSMutableArray alloc] initWithArray:[[[House allInstances] reverseObjectEnumerator] allObjects]];
    }
    [_planTableView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importPlanSucess:) name:@"ImportSucess" object:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;{
    if (UIInterfaceOrientationIsPortrait(fromInterfaceOrientation)) {
        _background.image = [UIImage imageNamed:@"BG_02.jpg"];
    }
    else{
        _background.image = [UIImage imageNamed:@"BG_04.jpg"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        _title1.font = [UIFont boldSystemFontOfSize:9];
        _title2.font = [UIFont boldSystemFontOfSize:9];
        _title3.font = [UIFont boldSystemFontOfSize:9];
        _title4.font = [UIFont boldSystemFontOfSize:9];
        _title5.font = [UIFont boldSystemFontOfSize:9];
    }
    isEditingMode = NO;
    if ([[SettingViewController getLoginOfficerName] length] != 0 || [[SettingViewController getOfficePassword] length] != 0) {
        isCorrectUsernamePassword = YES;
    }
    else
        isCorrectUsernamePassword = NO;
    datasource = [[NSMutableArray alloc] initWithArray:[[[House allInstances] reverseObjectEnumerator] allObjects]];
    _planTableView.layer.cornerRadius = 30.0f;
    _bgTableView.image = [[UIImage imageNamed:@"ws_BG_table"] stretchableImageWithLeftCapWidth:300 topCapHeight:300];
}

- (void)importPlanSucess:(NSNotification *)n{
    [datasource setArray:[[[House allInstances] reverseObjectEnumerator] allObjects]];
    [_planTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backToMenu:(id)sender {
//    [self.navigationController popViewControllerWithFlipStyle:MPFlipStyleDirectionBackward];
    [self.navigationController fadePopViewController];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return _headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return 40;
    } else {
        return 60;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [datasource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellIdentifier";
    EditPlanCell *tbCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (tbCell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditPlanCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[EditPlanCell class]])
            {
                tbCell = (EditPlanCell *)currentObject;
                tbCell.selectionStyle = UITableViewCellSelectionStyleNone;
                tbCell.backgroundColor = [UIColor clearColor];
                
                
                [tbCell.bt_homeIcon addTarget:self action:@selector(gotoMasking:) forControlEvents:UIControlEventTouchUpInside];
                [tbCell.bt_layout addTarget:self action:@selector(gotoLayout:) forControlEvents:UIControlEventTouchUpInside];
//                [tbCell.bt_order addTarget:self action:@selector(gotoOrder:) forControlEvents:UIControlEventTouchUpInside];
                [tbCell.bt_map addTarget:self action:@selector(showMapLocation:) forControlEvents:UIControlEventTouchUpInside];
                [tbCell.bt_editName addTarget:self action:@selector(editPlanName:) forControlEvents:UIControlEventTouchUpInside];
                tbCell.txt_planName.delegate = (id)self;
                break;
            }
        }
    }
    if (actionType == EDIT_PLAN_MODE) {
        [tbCell.bt_edit addTarget:self action:@selector(showEditMenu:) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        [tbCell.bt_edit addTarget:self action:@selector(exportPlan:) forControlEvents:UIControlEventTouchUpInside];
    }
    House *obj = [datasource objectAtIndex:indexPath.row];
    if (obj.latitude == 0.0f && obj.longitude == 0.0f) {
        tbCell.bt_map.hidden = YES;
    }
    else
        tbCell.bt_map.hidden = NO;
    
    tbCell.lb_no.text = [NSString stringWithFormat:@"%d",(int)indexPath.row+1];
    UIImage *img = [UIImage imageWithContentsOfFile:obj.houseImageThumnail];
    //[tbCell.bt_homeIcon setBackgroundImage:img forState:UIControlStateNormal];
    tbCell.img_home.image = img;
    tbCell.img_home.layer.cornerRadius = 10.0f;
    tbCell.img_home.layer.masksToBounds = YES;
    tbCell.txt_planName.text = obj.houseName;
    tbCell.lb_date.text = [NSString stringWithFormat:@"%@",obj.date];
    if (isEditingMode) {
        tbCell.bt_edit.hidden = NO;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            tbCell.lb_no.hidden = YES;
        }
    } else {
        tbCell.bt_edit.hidden = YES;
        tbCell.lb_no.hidden = NO;
    }
    
    if ((indexPath.row + 1) % 2 == 0 && (indexPath.row + 1) % 3 != 0) {
        tbCell.view_feature.backgroundColor = [UIColor colorWithRed:254./255. green:222./255. blue:209./255. alpha:1];
    }
    else if ((indexPath.row+1) % 3 == 0){
        tbCell.view_feature.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    }
    else
        tbCell.view_feature.backgroundColor = [UIColor colorWithRed:225./255. green:225./255. blue:225./255. alpha:1];
    tbCell.bt_edit.tag = indexPath.row;
    tbCell.bt_homeIcon.tag = indexPath.row;
    tbCell.bt_layout.tag = indexPath.row;
//    tbCell.bt_order.tag = indexPath.row;
    tbCell.bt_map.tag = indexPath.row;
    tbCell.bt_editName.tag = indexPath.row;
    return tbCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

#pragma mark - textfield delegate
- (void)textFieldDidEndEditing:(UITextField *)textField{
    EditPlanCell *cell = (EditPlanCell *)[_planTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
    House *obj = [datasource objectAtIndex:selectedIndex];
    [obj setHouseName:cell.txt_planName.text];
    [obj save];
    cell.txt_planName.userInteractionEnabled = NO;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - cell action
- (void)editPlanName:(id)sender{
    selectedIndex = (int)[(UIButton *)sender tag];
    EditPlanCell *cell = (EditPlanCell *)[_planTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
    cell.txt_planName.userInteractionEnabled = YES;
    [cell.txt_planName becomeFirstResponder];
}

- (void)showMapLocation:(id)sender{
    House *obj = [datasource objectAtIndex:[(UIButton *)sender tag]];
    MapViewController *mapController = [[MapViewController alloc] initWithHouses:[NSArray arrayWithObject:obj]];
    //    [self.navigationController pushViewController:mapController flipStyle:MPFlipStyleDirectionBackward];
    [self.navigationController pushFadeViewController:mapController];
}

- (void)gotoMasking:(id)sender{
    selectedIndex = (int)[(UIButton *)sender tag];
    House *obj = [datasource objectAtIndex:selectedIndex];
    NSArray *plans = [Plan instancesWhere:[NSString stringWithFormat:@"houseID = %d",obj.houseID]];
    UIImage *image = [UIImage imageWithContentsOfFile:obj.houseImage];
    if (!image) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Image not found!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    UIInterfaceOrientation layoutOrientation;
    if (image.size.height > image.size.width) {
        layoutOrientation = UIInterfaceOrientationPortrait;
    }
    else
        layoutOrientation = UIInterfaceOrientationLandscapeLeft;
    if (UIInterfaceOrientationIsLandscape(layoutOrientation) == UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        layoutOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    }
    BOOL isResizeImage = YES;
    NSString *imageFolder = [obj.houseImage stringByDeletingLastPathComponent];
    if ([imageFolder.lastPathComponent isEqualToString:@"Documents"]) {
        isResizeImage = NO;
    }
    if (plans.count == 0) {
        PlanViewController *planController = [[PlanViewController alloc] initWithImage:image withResizeImage:isResizeImage andImageOrientation:image.imageOrientation withHouseID:(int)obj.houseID andLayoutOrientation:layoutOrientation];
        [self.navigationController pushFadeViewController:planController];
    }
    else{
        Plan *plan = [plans lastObject];
        NSMutableArray *materials = [[NSMutableArray alloc] initWithArray:[Material instancesWhere:[NSString stringWithFormat:@"planID = %d",plan.planID]]];
        PlanViewController *planController = [[PlanViewController alloc] initWithImage:image withResizeImage:isResizeImage andImageOrientation:image.imageOrientation withHouseID:(int)obj.houseID planID:(int)plan.planID andLayers:materials andLayoutOrientation:layoutOrientation];
        [self.navigationController pushFadeViewController:planController];
    }
}

- (void)gotoLayout:(id)sender{
    selectedIndex = (int)[(UIButton *)sender tag];
    House *obj = [datasource objectAtIndex:selectedIndex];
    NSArray *plans = [Plan instancesWhere:[NSString stringWithFormat:@"houseID = %d",obj.houseID]];
    if (plans.count > 0) {
        UIInterfaceOrientation orientation;
        UIImage *thumbnail = [UIImage imageWithContentsOfFile:obj.houseImageThumnail];
        if (thumbnail.size.height > thumbnail.size.width) {
            orientation = UIInterfaceOrientationPortrait;
        }
        else
            orientation = UIInterfaceOrientationLandscapeLeft;
        if (UIInterfaceOrientationIsLandscape(orientation) == UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            orientation = [[UIApplication sharedApplication] statusBarOrientation];
        }
        Plan *planObj = [plans lastObject];
        LayoutViewController *layoutController = [[LayoutViewController alloc] initWithPlanID:(int)planObj.planID withImageOrientation:orientation];
        [self.navigationController pushFadeViewController:layoutController];
    }
}

- (void)gotoOrder:(id)sender{
    selectedIndex = (int)[(UIButton *)sender tag];
    if (!isCorrectUsernamePassword) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"enter_your_id", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"continue", nil) otherButtonTitles:nil];
        [alert show];
    }
    else{
        House *obj = [datasource objectAtIndex:[(UIButton *)sender tag]];
        OrderViewController *orderViewController = [[OrderViewController alloc] initWithHouseID:(int)obj.houseID andName:obj.houseName];
        [self.navigationController pushFadeViewController:orderViewController];
    }
}

#pragma mark - button action

- (IBAction)editPlanList:(id)sender {
    actionType = EDIT_PLAN_MODE;
    isEditingMode = !isEditingMode;
    [_planTableView reloadData];
}

- (void)showEditMenu:(id)sender{
    selectedIndex = (int)[(UIButton *)sender tag];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"copy_confirmation", nil),NSLocalizedString(@"delete_confirmation", nil), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.alertViewStyle == UIAlertViewStyleLoginAndPasswordInput) {
        if ([SettingViewController getLoginOfficerName].length != 0 || [SettingViewController getOfficePassword].length != 0) {
            if ([[alertView textFieldAtIndex:0].text isEqualToString:[SettingViewController getLoginOfficerName]] &&
                [[alertView textFieldAtIndex:1].text isEqualToString:[SettingViewController getOfficePassword]]) {
                isCorrectUsernamePassword = YES;
            }
            
        }
        else if ([[alertView textFieldAtIndex:0].text isEqualToString:kFixOfficerName] &&
                 [[alertView textFieldAtIndex:1].text isEqualToString:kFixOfficerPassword]) {
            [[NSUserDefaults standardUserDefaults] setValue:kFixOfficerName
                                                     forKey:kLoginOfficerName];
            [[NSUserDefaults standardUserDefaults] setValue:kFixOfficerPassword
                                                     forKey:kOfficerPassword];
            isCorrectUsernamePassword = YES;
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"input_not_correct", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
            [alert show];
        }
        if (isCorrectUsernamePassword) {
            House *obj = [datasource objectAtIndex:selectedIndex];
            OrderViewController *orderViewController = [[OrderViewController alloc] initWithHouseID:(int)obj.houseID andName:obj.houseName];
            [self.navigationController pushFadeViewController:orderViewController];
        }
    }
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    @try {
        int houseID = (int)[(House *)[datasource objectAtIndex:selectedIndex] houseID];
        if (buttonIndex == 1) {
            //copy
            [self copyHouse:houseID];
        }
        else if (buttonIndex == 2){
            //delete
            [self deleteHouse:houseID];
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

- (void)copyHouse:(int)_houseID{
    @try {
        __block int lastHouseID;
        House *oldHouse = [datasource objectAtIndex:selectedIndex];
        House *newHouse = [House new];
        newHouse.houseName = oldHouse.houseName;
        newHouse.houseImage = oldHouse.houseImage;
        newHouse.backgroundImg = oldHouse.backgroundImg;
        newHouse.date = [[self formatter] stringFromDate:[NSDate date]];
        newHouse.applyPlan = @"未定";
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]]];
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (!error) {
            NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"HousePlan_%@.png",[self generateRandomString]]];
            newHouse.houseImage = savedImagePath;
            NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:oldHouse.houseImage]);
            [imageData writeToFile:savedImagePath atomically:YES];
            
            NSString *savedImageThumnailPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"HouseThumnail_%@.png",[self generateRandomString]]];
            NSData *imageDataThumnail = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:oldHouse.houseImageThumnail]);
            newHouse.houseImageThumnail = savedImageThumnailPath;
            [imageDataThumnail writeToFile:savedImageThumnailPath atomically:NO];
        }
        newHouse.longitude = oldHouse.longitude;
        newHouse.latitude = oldHouse.latitude;
        [newHouse save];
        [[FCModel databaseQueue] inDatabase:^(FMDatabase *db) {
            lastHouseID = (int)[db lastInsertRowId];
        }];
        newHouse.houseID = lastHouseID;
        NSArray *layoutPosition = [LayoutPosition instancesWhere:@"houseID = ?",@(oldHouse.houseID)];
        for (LayoutPosition *layout in layoutPosition) {
            LayoutPosition *newLayout = [LayoutPosition new];
            newLayout.houseID = lastHouseID;
            newLayout.type = layout.type;
            newLayout.xValue = layout.xValue;
            newLayout.yValue = layout.yValue;
            newLayout.width = layout.width;
            newLayout.height = layout.height;
            [newLayout save];
        }
        NSArray *comments = [Comment instancesWhere:@"houseID = ?",@(oldHouse.houseID)];
        for (Comment *comment in comments) {
            Comment *newComment = [Comment new];
            newComment.houseID = lastHouseID;
            newComment.content = comment.content;
            newComment.xValue = comment.xValue;
            newComment.yValue = comment.yValue;
            newComment.width = comment.width;
            newComment.height = comment.height;
            [newComment save];
        }
        
        NSArray *plans = [Plan instancesWhere:[NSString stringWithFormat:@"houseID = %d",_houseID]];
        for (Plan *obj in plans) {
            __block int lastID;
            Plan *newPlan = [Plan new];
            newPlan.imageLink = obj.imageLink;
            newPlan.planName = obj.planName;
            newPlan.applyPlan = obj.applyPlan;
            newPlan.houseID = lastHouseID;
            [newPlan save];
            [[FCModel databaseQueue] inDatabase:^(FMDatabase *db) {
                lastID = (int)[db lastInsertRowId];
            }];
            NSArray *materials = [Material instancesWhere:[NSString stringWithFormat:@"planID = %d",obj.planID]];
            for (Material *material in materials) {
                Material *newMaterial = [Material new];
                newMaterial.planID = lastID;
                newMaterial.type = material.type;
                newMaterial.colorCode = material.colorCode;
                newMaterial.feature = material.feature;
                newMaterial.gloss = material.gloss;
                newMaterial.pattern = material.pattern;
                NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                cacheDir = [cacheDir stringByAppendingPathComponent:documentsDirectory];
                if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDir]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:nil];
                }
                NSString *maskLink = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"masking_huan_%@.png",[self generateRandomString]]];
                NSData *maskImage = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:material.imageLink]);
                [maskImage writeToFile:maskLink atomically:YES];
                newMaterial.imageLink = maskLink;
                newMaterial.patternImage = material.patternImage;
                newMaterial.R1 = material.R1;
                newMaterial.G1 = material.G1;
                newMaterial.B1 = material.B1;
                newMaterial.No = material.No;
                [newMaterial save];
            }
        }
        [datasource insertObject:newHouse atIndex:0];
        isEditingMode = !isEditingMode;
        [_planTableView reloadData];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR. Please try again later" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    @finally {
        
    }
}

- (void)deleteHouse:(int)_houseID{
    @try {
        NSArray *plans = [Plan instancesWhere:[NSString stringWithFormat:@"houseID = %d",_houseID]];
        for (Plan *obj in plans) {
            [Material executeUpdateQuery:[NSString stringWithFormat:@"DELETE FROM $T WHERE planID = %d",obj.planID]];
        }
        [Plan executeUpdateQuery:[NSString stringWithFormat:@"DELETE FROM $T WHERE houseID = %d",_houseID]];
        [House executeUpdateQuery:[NSString stringWithFormat:@"DELETE FROM $T WHERE houseID = %d",_houseID]];
        [datasource removeObjectAtIndex:selectedIndex];
        isEditingMode = !isEditingMode;
        [_planTableView reloadData];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR. Please try again later" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    @finally {
    }
}

- (NSDateFormatter *)formatter {
    if (!_dateformatter) {
        _dateformatter = [[NSDateFormatter alloc] init];
        _dateformatter.dateFormat = @"yyyy.MM.dd";
    }
    return _dateformatter;
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
    [self dismissViewControllerAnimated:YES completion:^{
        [self cleanZippedFile];
    }];
}

- (void)cleanZippedFile{
    if ([[NSFileManager defaultManager] fileExistsAtPath:zippedPath]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:zippedPath error:&error];
        if (error) {
        }
    }
}

- (IBAction)showMapView:(id)sender {
    MapViewController *mapController = [[MapViewController alloc] initWithHouses:datasource];
    [self.navigationController pushFadeViewController:mapController];
}

- (IBAction)exportHousePlan:(id)sender {
    actionType = EXPORT_PLAN_MODE;
    isEditingMode = !isEditingMode;
    [_planTableView reloadData];
}

- (void)exportPlan:(id)sender{
    actionType = NONE_ACTION;
    isEditingMode = !isEditingMode;
    [_planTableView reloadData];
    selectedIndex = (int)[(UIButton *)sender tag];
    UIActionSheet *actionSheet;
    if (IS_OS_7_OR_LATER) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:(id)self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"send_mail", nil),NSLocalizedString(@"send_bluetooth", nil), nil];
    }
    else{
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:(id)self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"send_mail", nil), nil];
    }
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    int exportType = 0;
    if (buttonIndex == 0) {
        exportType = 0;
    }
    else if (buttonIndex == 1){
        exportType = 1;
    }
    @try {
        ArchiveObject *archiveObj = [[ArchiveObject alloc] init];
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            [archiveObj setIsPhone:[NSNumber numberWithBool:YES]];
        } else {
            [archiveObj setIsPhone:[NSNumber numberWithBool:NO]];
        }
        House *house = [[House alloc] initWithHouse:[datasource objectAtIndex:selectedIndex]];
        [archiveObj setHouseObj:house];
        
        NSArray *plans = [Plan instancesWhere:@"houseID = ?",@(house.houseID)];
        [archiveObj setPlans:(NSArray<Plan,ConvertOnDemand> *)[NSArray arrayWithArray:plans]];
        NSArray *layoutPosition = [LayoutPosition instancesWhere:@"houseID = ?",@(house.houseID)];
        [archiveObj setLayoutPosition:(NSArray<LayoutPosition,ConvertOnDemand,Optional> *)[NSArray arrayWithArray:layoutPosition]];
        NSArray *comments = [Comment instancesWhere:@"houseID = ?",@(house.houseID)];
        [archiveObj setComments:(NSArray<Comment,ConvertOnDemand,Optional>*)comments];
        NSMutableArray *materialArr = [NSMutableArray array];
        for (Plan *obj in plans) {
            NSArray *materials = [Material instancesWhere:[NSString stringWithFormat:@"planID = %d",obj.planID]];
            [materialArr addObjectsFromArray:materials];
        }
        [archiveObj setMaterials:(NSMutableArray<Material,ConvertOnDemand> *)[NSMutableArray arrayWithArray:materialArr]];
        
        isEditingMode = !isEditingMode;
        [_planTableView reloadData];
        
        [self startZipWithArchiveObject:archiveObj andExportType:exportType];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR. Please try again later" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    @finally {
        
    }
}

-(NSString*)generateRandomString {
    NSMutableString* string = [NSMutableString stringWithCapacity:8];
    for (int i = 0; i < 8; i++) {
        [string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
    }
    return string;
}

- (void)startZipWithArchiveObject:(ArchiveObject *)archiveObj andExportType:(int)_exportType{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@_%f.icp",archiveObj.houseObj.houseName,[[NSDate date] timeIntervalSince1970]];
    
    NSArray *cacheDirectory = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    zippedPath = [[cacheDirectory objectAtIndex:0] stringByAppendingPathComponent:fileName];
    ZipArchive *archiveFile = [[ZipArchive alloc] init];
    archiveFile.delegate = (id)self;
        @try {
        RTSpinKitView *spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWave color:[UIColor whiteColor]];
        Hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        Hud.square = YES;
        Hud.mode = MBProgressHUDModeCustomView;
        Hud.customView = spinner;
        Hud.labelText = @"Reparing data...";
        Hud.color = [UIColor colorWithRed:238/255.0f green:105/255.0f blue:70/255.0f alpha:1];
        Hud.dimBackground = YES;
        [spinner startAnimating];
        dispatch_queue_t processQueue = dispatch_queue_create("ARCHIVE FILE", NULL);
        dispatch_async(processQueue, ^{
            NSLog(@"%@", [archiveObj toJSONString]);
            NSData *jsonData = [[archiveObj toJSONString] dataUsingEncoding:NSUTF8StringEncoding];
            //        jsonData = [jsonData subdataWithRange:NSMakeRange(0, [jsonData length] - 1)];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",[self generateRandomString]]];
            [jsonData writeToFile:filePath atomically:YES];
            
            NSMutableArray *zipFiles = [[NSMutableArray alloc] init];
            [zipFiles addObject:filePath];
            [zipFiles addObject:archiveObj.houseObj.houseImage];
            [zipFiles addObject:archiveObj.houseObj.houseImageThumnail];
            for (Material *mobj in archiveObj.materials) {
                [zipFiles addObject:mobj.imageLink];
            }
            
            [archiveFile CreateZipFile2:zippedPath Password:@"abc123iColorpaint"];
            for (NSString *filePath in zipFiles) {
                [archiveFile addFileToZip:filePath newname:[filePath lastPathComponent]];
            }
            [archiveFile CloseZipFile2];
            dispatch_async(dispatch_get_main_queue(), ^{
                [Hud hide:YES];
                if (_exportType == 0) {
                    NSData *dataToSend = [[NSFileManager defaultManager] contentsAtPath:zippedPath];
                    if ([MFMailComposeViewController canSendMail]) {
                        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
                        [mailComposer addAttachmentData:dataToSend mimeType:@"application/decorator" fileName:[zippedPath lastPathComponent]];
                        mailComposer.mailComposeDelegate = (id)self;
                        [self presentViewController:mailComposer animated:YES completion:^{
                            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                            [[NSFileManager defaultManager] removeItemAtPath:zippedPath error:nil];
                        }];
                    }
                    else
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                                        message:@"Your device doesn't support the composer sheet"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                        [[NSFileManager defaultManager] removeItemAtPath:zippedPath error:nil];
                    }
                }
                else if (_exportType == 1){
                    NSURL *zipUrl = [NSURL fileURLWithPath:zippedPath isDirectory:NO];
                    self.objectsToShare = @[zipUrl];
                    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:self.objectsToShare applicationActivities:nil];
                    activityController.popoverPresentationController.sourceView = self.view;
                    activityController.popoverPresentationController.sourceRect = _bt_export.frame;
                    [self presentViewController:activityController animated:YES completion:^{
                        
                    }];
                    [activityController setCompletionHandler:^(NSString *activityType, BOOL completed){
                        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                        [[NSFileManager defaultManager] removeItemAtPath:zippedPath error:nil];
                    }];
                }
            });
        });
        
    }
    @catch (NSException *exception) {

    }
    @finally {
        
    }
}
@end
