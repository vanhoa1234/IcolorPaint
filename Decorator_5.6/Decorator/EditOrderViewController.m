//
//  EditOrderViewController.m
//  Decorator
//
//  Created by Hoang Le on 11/26/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "EditOrderViewController.h"
#import "MaterialCell.h"
#import "CustomOrderViewController.h"
#import "Feature.h"
#import "JPMA.h"
#import "MaterialDefault.h"
#import "LayerObject.h"

@interface EditOrderViewController (){
    NSMutableArray *datasource;
    Material *material;
    int selectedIndex;
//    int selectedTag;
}

@end

@implementation EditOrderViewController
@synthesize delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithMaterial:(Material *)_material{
    self = [super init];
    if (self) {
        material = _material;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _lb_type.text = [DecoratorUtil getTypeNameByID:(int)material.type];
    _img_type.image = [UIImage imageNamed:[DecoratorUtil getTypeImageByID:(int)material.type]];
    int materialType;
    if (material.type > 5 && material.type <= 7) {
        materialType = 5;
    }
    else
        materialType = (int)material.type;
    if (material.patternImage.length > 0) {
        datasource = [[NSMutableArray alloc] initWithArray:[Feature instancesWhere:[NSString stringWithFormat:@"type = %d and featureName = '%@'",materialType,material.feature]]];
    }
    else
        datasource = [[NSMutableArray alloc] initWithArray:[Feature instancesWhere:[NSString stringWithFormat:@"type = %d",materialType]]];
    
    [self removeLastObjectDatasourceWithJPMAColor];
    
    int count = 0;
    
    if ([datasource count] > 0) {
        for (Feature *obj in datasource) {
            if ([obj.featureName isEqualToString:material.feature]) {
                break;
            }
            count += 1;
        }
        selectedIndex = count;
        [_featureTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
        [[(MaterialCell *)[_featureTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]] view_feature] setBackgroundColor:[UIColor colorWithRed:102./255. green:204./255. blue:1 alpha:1]];
    }
    
    
}
//Sart_QuyPV
//Bug 348: Check Material color code is JPMA then Remove last Datasource
- (void) removeLastObjectDatasourceWithJPMAColor{
    if (material.patternImage.length==0 && material.type == 5) {
        [datasource removeLastObject];
    }
    
}
//End_QuyPV
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

- (IBAction)backToOrderDetail:(id)sender {
//    [self.navigationController popViewControllerWithFlipStyle:MPFlipStyleDirectionBackward];
    [self.navigationController fadePopViewController];
}

- (IBAction)saveOrderDetail:(id)sender {
    MaterialCell *cell = (MaterialCell *)[_featureTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
    material.feature = cell.fname.text;
    material.gloss = cell.fgloss.text;
    material.pattern = cell.fpattern.text;
    if (material.type >= LAYER_BALUSTRADE && material.type <= LAYER_WALL3) {
        MaterialDefault *defaultMaterial;
        if (material.type >= LAYER_WALL) {
            if (material.patternImage.length > 0) {
                defaultMaterial = [MaterialDefault instanceWithPrimaryKey:@(5)];
            }
            else
                defaultMaterial = [MaterialDefault instanceWithPrimaryKey:@(6)];
        }
        else{
            defaultMaterial = [MaterialDefault instanceWithPrimaryKey:@(material.type)];
        }
        defaultMaterial.feature = material.feature;
        defaultMaterial.gloss = material.gloss;
        defaultMaterial.pattern = material.pattern;
        [defaultMaterial save];
    }
    [delegate savedEditOder:material];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [datasource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellIdentifier";
    MaterialCell *tbCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (tbCell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MaterialCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[MaterialCell class]])
            {
                tbCell = (MaterialCell *)currentObject;
                tbCell.view_feature.layer.cornerRadius = 20.0f;
                tbCell.view_feature.layer.masksToBounds = YES;
                tbCell.backgroundColor = [UIColor clearColor];
                break;
            }
        }
    }
    Feature *obj = [datasource objectAtIndex:indexPath.row];
    tbCell.fname.text = obj.featureName;
    if (selectedIndex == indexPath.row) {
        tbCell.fgloss.text = material.gloss;
        tbCell.fpattern.text = material.pattern;
    }
    else{
        tbCell.fgloss.text = [[obj.glossRef componentsSeparatedByString:@";"] objectAtIndex:0];
        tbCell.fpattern.text = [[obj.patternRef componentsSeparatedByString:@";"] objectAtIndex:0];
    }
    tbCell.fdescription.text = [NSString stringWithFormat:@"①	%@",obj.description];
    tbCell.img_feature.image = [UIImage imageNamed:[DecoratorUtil getMaterialIcon:(int)obj.type andKind:obj.featureName]];
    tbCell.bt_setting.tag = indexPath.row;
    [tbCell.bt_setting addTarget:self action:@selector(customOrder:) forControlEvents:UIControlEventTouchUpInside];
    return tbCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedIndex = (int)indexPath.row;
    [[(MaterialCell *)[tableView cellForRowAtIndexPath:indexPath] view_feature] setBackgroundColor:[UIColor colorWithRed:102./255. green:204./255. blue:1 alpha:1]];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[(MaterialCell *)[tableView cellForRowAtIndexPath:indexPath] view_feature] setBackgroundColor:[UIColor clearColor]];
}

- (void)customOrder:(id)sender{
    if (selectedIndex != [(UIButton *)sender tag]) {
        [[(MaterialCell *)[_featureTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]] view_feature] setBackgroundColor:[UIColor clearColor]];
        selectedIndex = (int)[(UIButton *)sender tag];
        [[(MaterialCell *)[_featureTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]] view_feature] setBackgroundColor:[UIColor colorWithRed:102./255. green:204./255. blue:1 alpha:1]];
    }
    
    [_featureTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    
    MaterialCell *cell = (MaterialCell *)[_featureTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
    Material *newMaterial = material;
    newMaterial.feature = cell.fname.text;
    newMaterial.gloss = cell.fgloss.text;
    newMaterial.pattern = cell.fpattern.text;
    CustomOrderViewController *customViewController = [[CustomOrderViewController alloc] initWithMaterial:material];
    customViewController.delegate = (id)self;
//    [self.navigationController pushViewController:customViewController flipStyle:MPFlipStyleDefault];
    [self.navigationController pushFadeViewController:customViewController];
}

- (void)savedCustomOrder:(Material *)_savedMaterial{
    MaterialCell *cell = (MaterialCell *)[_featureTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
    cell.fgloss.text = _savedMaterial.gloss;
    cell.fpattern.text = _savedMaterial.pattern;
//    [self.navigationController popViewControllerWithFlipStyle:MPFlipStyleDirectionBackward];
    [self.navigationController fadePopViewController];
}

@end
