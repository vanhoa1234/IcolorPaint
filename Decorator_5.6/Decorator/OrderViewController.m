//
//  OrderViewController.m
//  Decorator
//
//  Created by Hoang Le on 11/25/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "OrderViewController.h"
#import "Plan.h"
#import "Material.h"
#import "House.h"
#import "MDSpreadViewHeaderCell.h"
#import "OrderDetailViewController.h"
#import "LayoutViewController.h"
#import <MessageUI/MessageUI.h>
#import "LayerObject.h"
#import <QuartzCore/QuartzCore.h>
#import "SettingViewController.h"
@interface OrderViewController (){
    int houseID;
    NSString *houseName;
    NSMutableArray *planDatasource;
    NSMutableArray *materialDatasource;
    NSMutableArray *selectedMaterials;
    int maxCount;
    int maxIndex;
    
    int selectedCount;
    BOOL isFromLayout;
    NSDictionary *patternNames;
}

@end

@implementation OrderViewController

- (id)initWithHouseID:(int)_houseID andName:(NSString *)_houseName{
    self = [super init];
    if (self) {
        houseID = _houseID;
        houseName = _houseName;
    }
    return self;
}

- (id)initWithHouseID:(int)_houseID andName:(NSString *)_houseName isFromLayout:(BOOL)_isfromLayout{
    self = [super init];
    if (self) {
        houseID = _houseID;
        houseName = _houseName;
        isFromLayout = _isfromLayout;
    }
    return self;
}


- (IBAction)backToEditPlan:(id)sender {
//    [self.navigationController popViewControllerWithFlipStyle:MPFlipStyleDirectionBackward];
    [self.navigationController fadePopViewController];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //_lb_title.text = houseName;
    _maskTableView.image = [[UIImage imageNamed:@"ws_BG_table"] stretchableImageWithLeftCapWidth:300 topCapHeight:300];
    _spreadView.layer.cornerRadius = 20.0f;
    planDatasource = [[NSMutableArray alloc] initWithArray:[Plan instancesWhere:[NSString stringWithFormat:@"houseID = %d",houseID]]];
    maxIndex = 0;
    if (planDatasource.count > 0) {
        materialDatasource = [[NSMutableArray alloc] init];
        for (int i = 0;i < [planDatasource count];i++) {
            NSArray *materials = [Material instancesWhere:[NSString stringWithFormat:@"planID = %d and (type <= 7)",[(Plan *)[planDatasource objectAtIndex:i] planID]]];
            [materialDatasource addObject:materials];
//            NSLog(@"%@",materialDatasource);
            if (maxCount < materials.count) {
                maxCount = (int)materials.count;
                maxIndex = i;
            }
        }
    }
    selectedMaterials = [[NSMutableArray alloc] init];
    for (NSArray *materialPlan in materialDatasource) {
        for (Material *material in materialPlan) {
            if (material.isSelected) {
                [selectedMaterials addObject:material];
            }
        }
    }
    selectedCount = (int)[selectedMaterials count];
    if (selectedCount > 0) {
        _bt2.enabled = YES;
    }
    else
        _bt2.enabled = NO;
    patternNames = @{@"外壁材_1_A":@"WB2256",@"外壁材_1_B":@"WB2256",@"外壁材_1_C":@"WB2256",@"外壁材_1_D":@"WB2256",@"外壁材_2_A":@"WB2289",@"外壁材_2_B":@"WB2289",@"外壁材_2_C":@"WB2289",@"外壁材_2_D":@"WB2289",@"外壁材_3_A":@"WB2285",@"外壁材_3_B":@"WB2285",@"外壁材_3_C":@"WB2285",@"外壁材_3_D":@"WB2285",@"外壁材_4_A":@"WB2225",@"外壁材_4_B":@"WB2225",@"外壁材_4_C":@"WB2225",@"外壁材_4_D":@"WB2225",@"外壁材_5_A":@"WB2178",@"外壁材_5_B":@"WB2178",@"外壁材_5_C":@"WB2178",@"外壁材_5_D":@"WB2178",@"外壁材_6_A":@"WB2142",@"外壁材_6_B":@"WB2142",@"外壁材_6_C":@"WB2142",@"外壁材_6_D":@"WB2142",@"外壁材_7_A":@"WB2391",@"外壁材_7_B":@"WB2391",@"外壁材_7_C":@"WB2391",@"外壁材_7_D":@"WB2391",@"外壁材_8_A":@"WB2393",@"外壁材_8_B":@"WB2393",@"外壁材_8_C":@"WB2393",@"外壁材_8_D":@"WB2393",@"外壁材_9_A":@"WB2117",@"外壁材_9_B":@"WB2117",@"外壁材_9_C":@"WB2117",@"外壁材_9_D":@"WB2117",@"外壁材_10_A":@"WB2140",@"外壁材_10_B":@"WB2140",@"外壁材_10_C":@"WB2140",@"外壁材_10_D":@"WB2140",@"外壁材_11_A":@"WB2170",@"外壁材_11_B":@"WB2170",@"外壁材_11_C":@"WB2170",@"外壁材_11_D":@"WB2170",@"外壁材_12_A":@"WB2179",@"外壁材_12_B":@"WB2179",@"外壁材_12_C":@"WB2179",@"外壁材_12_D":@"WB2179",@"外壁材_13_A":@"WB2144",@"外壁材_13_B":@"WB2144",@"外壁材_13_C":@"WB2144",@"外壁材_13_D":@"WB2144",@"外壁材_14_A":@"WB2394",@"外壁材_14_B":@"WB2394",@"外壁材_14_C":@"WB2394",@"外壁材_14_D":@"WB2394",@"外壁材_15_A":@"WB2149",@"外壁材_15_B":@"WB2149",@"外壁材_15_C":@"WB2149",@"外壁材_15_D":@"WB2149",@"外壁材_16_A":@"WB2333",@"外壁材_16_B":@"WB2333",@"外壁材_16_C":@"WB2333",@"外壁材_16_D":@"WB2333",@"外壁材_17_A":@"WB3220",@"外壁材_17_B":@"WB3220",@"外壁材_17_C":@"WB3220",@"外壁材_17_D":@"WB3220",@"外壁材_18_A":@"WB3252",@"外壁材_18_B":@"WB3252",@"外壁材_18_C":@"WB3252",@"外壁材_18_D":@"WB3252",@"外壁材_19_A":@"WB3175",@"外壁材_19_B":@"WB3175",@"外壁材_19_C":@"WB3175",@"外壁材_19_D":@"WB3175",@"外壁材_20_A":@"WB3147",@"外壁材_20_B":@"WB3147",@"外壁材_20_C":@"WB3147",@"外壁材_20_D":@"WB3147",@"外壁材_21_A":@"WB3335",@"外壁材_21_B":@"WB3335",@"外壁材_21_C":@"WB3335",@"外壁材_21_D":@"WB3335",@"外壁材_22_A":@"WB3281",@"外壁材_22_B":@"WB3281",@"外壁材_22_C":@"WB3281",@"外壁材_22_D":@"WB3281",@"外壁材_23_A":@"WB2118",@"外壁材_23_B":@"WB2118",@"外壁材_23_C":@"WB2118",@"外壁材_23_D":@"WB2118",@"外壁材_24_A":@"WB2141",@"外壁材_24_B":@"WB2141",@"外壁材_24_C":@"WB2141",@"外壁材_24_D":@"WB2141",@"外壁材_25_A":@"WB2168",@"外壁材_25_B":@"WB2168",@"外壁材_25_C":@"WB2168",@"外壁材_25_D":@"WB2168",@"外壁材_26_A":@"WB2172",@"外壁材_26_B":@"WB2172",@"外壁材_26_C":@"WB2172",@"外壁材_26_D":@"WB2172",@"外壁材_27_A":@"WB2174",@"外壁材_27_B":@"WB2174",@"外壁材_27_C":@"WB2174",@"外壁材_27_D":@"WB2174",@"外壁材_28_A":@"WB2223",@"外壁材_28_B":@"WB2223",@"外壁材_28_C":@"WB2223",@"外壁材_28_D":@"WB2223",@"外壁材_29_A":@"WB2287",@"外壁材_29_B":@"WB2287",@"外壁材_29_C":@"WB2287",@"外壁材_29_D":@"WB2287",@"外壁材_30_A":@"WB2295",@"外壁材_30_B":@"WB2295",@"外壁材_30_C":@"WB2295",@"外壁材_30_D":@"WB2295",@"外壁材_31_A":@"WB2386",@"外壁材_31_B":@"WB2386",@"外壁材_31_C":@"WB2386",@"外壁材_31_D":@"WB2386",@"外壁材_32_A":@"WB3183",@"外壁材_32_B":@"WB3183",@"外壁材_32_C":@"WB3183",@"外壁材_32_D":@"WB3183",@"外壁材_33_A":@"WB3284",@"外壁材_33_B":@"WB3284",@"外壁材_33_C":@"WB3284",@"外壁材_33_D":@"WB3284",@"外壁材_34_A":@"WB3288",@"外壁材_34_B":@"WB3288",@"外壁材_34_C":@"WB3288",@"外壁材_34_D":@"WB3288",@"外壁材_35_A":@"WB3396",@"外壁材_35_B":@"WB3396",@"外壁材_35_C":@"WB3396",@"外壁材_35_D":@"WB3396"};
    [_spreadView reloadData];
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
}

- (NSInteger)spreadView:(MDSpreadView *)aSpreadView numberOfColumnsInSection:(NSInteger)section{
    return [planDatasource count];
}
- (NSInteger)spreadView:(MDSpreadView *)aSpreadView numberOfRowsInSection:(NSInteger)section{
    return maxCount;
}
- (NSInteger)numberOfColumnSectionsInSpreadView:(MDSpreadView *)aSpreadView{
    return 1;
}
- (NSInteger)numberOfRowSectionsInSpreadView:(MDSpreadView *)aSpreadView{
    return 1;
}

- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath{
    static NSString *cellIdentifier = @"Cell";
    MDSpreadViewCell *cell = [aSpreadView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIImageView *imageView;
    UIView *backgroundColor;
    if (cell == nil) {
        cell = [[MDSpreadViewCell alloc] initWithStyle:MDSpreadViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(150,2, 45, 45)];
        imageView.tag = 201;
        [cell addSubview:imageView];
        
        backgroundColor = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 196, 46)];
        backgroundColor.tag = 202;
        [cell addSubview:backgroundColor];
        [cell bringSubviewToFront:cell.textLabel];
        [cell bringSubviewToFront:imageView];
    }
    else{
        imageView = (UIImageView *)[cell viewWithTag:201];
        backgroundColor = [cell viewWithTag:202];
    }
    NSArray *obj;
    @try {
        obj = [materialDatasource objectAtIndex:columnPath.column];
        if ([[(Material *)[obj objectAtIndex:rowPath.row] colorCode] isEqualToString:@"未設定"]) {
            [(Material *)[obj objectAtIndex:rowPath.row] setColorCode:@"-"];
        }
        else if ([self getPatternImage:[(Material *)[obj objectAtIndex:rowPath.row] colorCode]].length > 0){
            [(Material *)[obj objectAtIndex:rowPath.row] setColorCode:@"-"];
        }
//        cell.textLabel.text = [(Material *)[obj objectAtIndex:rowPath.row] colorCode];
//        if ([(Material *)[obj objectAtIndex:rowPath.row] type] == LAYER_UNSET){
//            backgroundColor.backgroundColor = [UIColor whiteColor];
//            cell.textLabel.attributedText = [[NSAttributedString alloc]
//                                             initWithString:[(Material *)[obj objectAtIndex:rowPath.row] colorCode]
//                                             attributes:@{
//                                                          NSBackgroundColorAttributeName:[UIColor colorWithRed:241/255. green:105/255. blue:65/255. alpha:1],
//                                                          NSForegroundColorAttributeName:[UIColor whiteColor],
//                                                          }
//                                             ];
//        }
//        else
            if (![[(Material *)[obj objectAtIndex:rowPath.row] colorCode] isEqualToString:@"-"]) {
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.textLabel.attributedText = [[NSAttributedString alloc]
                                                 initWithString:[(Material *)[obj objectAtIndex:rowPath.row] colorCode]
                                                 attributes:@{
                                                              NSBackgroundColorAttributeName:[UIColor colorWithRed:241/255. green:105/255. blue:65/255. alpha:1],
                                                              NSForegroundColorAttributeName:[UIColor whiteColor],
                                                              }
                                                 ];
                if ([(Material *)[obj objectAtIndex:rowPath.row] patternImage].length != 0) {
                    backgroundColor.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[(Material *)[obj objectAtIndex:rowPath.row] patternImage]]];
                }
                else if ([[UIColor colorWithRed:[(Material *)[obj objectAtIndex:rowPath.row] R1]/255. green:[(Material *)[obj objectAtIndex:rowPath.row] G1]/255. blue:[(Material *)[obj objectAtIndex:rowPath.row] B1]/255. alpha:1] isEqual:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]]){
                    backgroundColor.backgroundColor = [UIColor whiteColor];
                }
                else{
                    backgroundColor.backgroundColor = [UIColor colorWithRed:[(Material *)[obj objectAtIndex:rowPath.row] R1]/255. green:[(Material *)[obj objectAtIndex:rowPath.row] G1]/255. blue:[(Material *)[obj objectAtIndex:rowPath.row] B1]/255. alpha:1];
                }
            }
            else{
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.text = @"-";
                backgroundColor.backgroundColor = [UIColor whiteColor];
            }
            if ([(Material *)[obj objectAtIndex:rowPath.row] isSelected]) {
                imageView.image = [UIImage imageNamed:@"accept.png"];
            }
            else{
                imageView.image = [UIImage imageNamed:@""];
            }
    }
    @catch (NSException *exception) {
        cell.textLabel.text = @"";
        imageView.image = nil;
    }
    @finally {
        return cell;
    }
}

//- (id)spreadView:(MDSpreadView *)aSpreadView titleForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection{
//    return @"プラン名";
//}

- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInRowSection:(NSInteger)rowSection forColumnSection:(NSInteger)columnSection{
    static NSString *cellIdentifier1 = @"CellHeaderRowSection";
    MDSpreadViewCell *cell = [aSpreadView dequeueReusableCellWithIdentifier:cellIdentifier1];
    if (cell == nil) {
        cell = [[MDSpreadViewCell alloc] initWithStyle:MDSpreadViewCellStyleDefault reuseIdentifier:cellIdentifier1];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.highlightedBackgroundView.backgroundColor = [UIColor clearColor];
    }
    cell.textLabel.text = @"プラン名";
    return cell;
}

- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInRowSection:(NSInteger)section forColumnAtIndexPath:(MDIndexPath *)columnPath{
    static NSString *cellIdentifier2 = @"CellHeaderRow";
    MDSpreadViewCell *cell = [aSpreadView dequeueReusableCellWithIdentifier:cellIdentifier2];
    if (cell == nil) {
        cell = [[MDSpreadViewCell alloc] initWithStyle:MDSpreadViewCellStyleDefault reuseIdentifier:cellIdentifier2];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.highlightedBackgroundView.backgroundColor = [UIColor clearColor];
    }
    cell.textLabel.text = [(Plan *)[planDatasource objectAtIndex:columnPath.column] planName];
    return cell;
}

- (MDSpreadViewCell *)spreadView:(MDSpreadView *)aSpreadView cellForHeaderInColumnSection:(NSInteger)section forRowAtIndexPath:(MDIndexPath *)rowPath{
    static NSString *cellIdentifier3 = @"CellHeaderColumn";
    MDSpreadViewCell *cell = [aSpreadView dequeueReusableCellWithIdentifier:cellIdentifier3];
    UIImageView *materialIcon;
    if (cell == nil) {
        cell = [[MDSpreadViewCell alloc] initWithStyle:MDSpreadViewCellStyleDefault reuseIdentifier:cellIdentifier3];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.highlightedBackgroundView.backgroundColor = [UIColor clearColor];
        materialIcon = [[UIImageView alloc] initWithFrame:CGRectMake(70,7, 39, 35)];
        materialIcon.tag = 103;
        [cell addSubview:materialIcon];
    }
    else
        materialIcon = (UIImageView *)[cell viewWithTag:103];
    @try {
        NSArray *firstRow = [materialDatasource objectAtIndex:maxIndex];
        cell.textLabel.text = [DecoratorUtil getTypeNameByID:(int)[(Material *)[firstRow objectAtIndex:rowPath.row] type]];
        materialIcon.image = [UIImage imageNamed:[DecoratorUtil getTypeImageByID:(int)[(Material *)[firstRow objectAtIndex:rowPath.row] type]]];
    }
    @catch (NSException *exception) {
        cell.textLabel.text = @"";
        materialIcon.image = nil;
    }
    @finally {
        return cell;
    }
}

- (void)spreadView:(MDSpreadView *)aSpreadView didSelectCellForRowAtIndexPath:(MDIndexPath *)rowPath forColumnAtIndexPath:(MDIndexPath *)columnPath{
    @try {
        if (rowPath.row == -1) {
        }
        else{
            Material *obj = [[materialDatasource objectAtIndex:columnPath.row] objectAtIndex:rowPath.row];
            if ([obj.colorCode isEqualToString:@"-"] || [obj.colorCode isEqualToString:@"未設定"]) {
                return;
            }
            if (obj.type < LAYER_BALUSTRADE || obj.type > LAYER_WALL3) {
                return;
            }
            obj.isSelected = !obj.isSelected;
            if (obj.isSelected) {
                selectedCount += 1;
            }
            else
                selectedCount -= 1;
            if (selectedCount > 0) {
                _bt2.enabled = YES;
            }
            else
                _bt2.enabled = NO;
            [_spreadView reloadData];
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

#pragma mark Heights
// Comment these out to use normal values (see MDSpreadView.h)
- (CGFloat)spreadView:(MDSpreadView *)aSpreadView heightForRowAtIndexPath:(MDIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView heightForRowHeaderInSection:(NSInteger)rowSection
{
    return 50;
}

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView widthForColumnAtIndexPath:(MDIndexPath *)indexPath
{
    return 200;
}

- (CGFloat)spreadView:(MDSpreadView *)aSpreadView widthForColumnHeaderInSection:(NSInteger)columnSection
{
    return 120;
}

- (IBAction)gotoOrderDetail:(id)sender {
    if (selectedMaterials.count > 0) {
        [selectedMaterials removeAllObjects];
    }
    for (NSArray *materialPlan in materialDatasource) {
        for (Material *material in materialPlan) {
            if (material.isSelected) {
                [selectedMaterials addObject:material];
            }
        }
    }
    NSArray *sortedArray = [selectedMaterials sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[NSNumber numberWithInt:(int)[(Material *)obj1 type]] compare:[NSNumber numberWithInt:(int)[(Material *)obj2 type]]];
    }];
    OrderDetailViewController *detailViewController = [[OrderDetailViewController alloc] initWithDetailList:sortedArray andPlans:planDatasource];//[[OrderDetailViewController alloc] initWithDetailList:sortedArray];
//    [self.navigationController pushViewController:detailViewController flipStyle:MPFlipStyleDefault];
    [self.navigationController pushFadeViewController:detailViewController];
}

- (IBAction)showMailComposer:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        House *obj = [House instanceWithPrimaryKey:@(houseID)];
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
        
//        [mailComposer setToRecipients:[NSArray arrayWithObject:@"nagoya@suzukafine.co.jp"]];
//        [mailComposer setCcRecipients:[NSArray arrayWithObject:@"ishii@yahoo.co.jp"]];
        [mailComposer setToRecipients:[NSArray arrayWithObject:[SettingViewController getCCEmailStore]]];
        [mailComposer setCcRecipients:[NSArray arrayWithObject:[SettingViewController getEmailStore]]];
        if (selectedMaterials.count > 0) {
            [selectedMaterials removeAllObjects];
        }
        for (NSArray *materialPlan in materialDatasource) {
            for (Material *material in materialPlan) {
                if (material.isSelected) {
                    [selectedMaterials addObject:material];
                }
            }
        }
//        [mailComposer setMessageBody:[DecoratorUtil generateOrderEmail:obj andPlan:planDatasource] isHTML:YES];
        [mailComposer setSubject:[NSString stringWithFormat:@"塗板発注 (%@)",obj.houseName]];
        [mailComposer setMessageBody:[DecoratorUtil generateOrderEmail:obj andPlan:planDatasource andMaterial:selectedMaterials] isHTML:YES];
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

- (NSString *)getPatternImage:(NSString *)_pattern{
    return [patternNames objectForKey:_pattern];
}
@end
