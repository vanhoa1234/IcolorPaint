//
//  LayerPickerViewController.m
//  Decorator
//
//  Created by Hoang Le on 9/23/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "LayerPickerViewController.h"
#import "LayerObject.h"

@interface LayerPickerViewController (){
    NSArray *layerNameDatasourceTemp;
    NSArray *layerImageDatasourceTemp;
    NSArray *layerTypeDatasourceTemp;
    
    NSMutableArray *layerNameDatasource;
    NSMutableArray *layerImageDatasource;
    NSMutableArray *layerTypeDatasource;
}

@end

@implementation LayerPickerViewController
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
    
    if (_currentLayes.count == 0) {
        /*
         "外壁①" = "外壁①";
         "外壁②" = "外壁②";
         "外壁③" = "外壁③";
         "屋根" = "屋根";
         "軒裏" = "軒裏";
         "雨樋" = "雨樋";
         "金属" = "金属";
         "その他①" = "その他①";
         "その他②" = "その他②";
         "その他③" = "その他③";
         */
        layerNameDatasource = [[NSMutableArray alloc] initWithObjects:NSLocalizedString(@"外壁①", nil),NSLocalizedString(@"外壁②", nil),NSLocalizedString(@"外壁③", nil),NSLocalizedString(@"屋根", nil),NSLocalizedString(@"軒裏", nil),NSLocalizedString(@"雨樋", nil),NSLocalizedString(@"金属", nil),NSLocalizedString(@"その他①", nil),NSLocalizedString(@"その他②", nil),NSLocalizedString(@"その他③", nil), nil];
        layerImageDatasource = [[NSMutableArray alloc] initWithObjects:@"layer_wall",@"layer_wall",@"layer_wall",@"layer_roof",@"layer_balustrade",@"layer_gutter",@"layer_steel",@"Flaticon_4627",@"Flaticon_4627",@"Flaticon_4627", nil];
        layerTypeDatasource = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:LAYER_WALL],[NSNumber numberWithInt:LAYER_WALL2],[NSNumber numberWithInt:LAYER_WALL3],[NSNumber numberWithInt:LAYER_ROOF],[NSNumber numberWithInt:LAYER_BALUSTRADE],[NSNumber numberWithInt:LAYER_GUTTER],[NSNumber numberWithInt:LAYER_STEEL],[NSNumber numberWithInt:LAYER_OTHER],[NSNumber numberWithInt:LAYER_OTHER2],[NSNumber numberWithInt:LAYER_OTHER3], nil];

        [layerTypeDatasource setArray:layerTypeDatasourceTemp];
        [layerImageDatasource setArray:layerImageDatasource];
        [layerNameDatasource setArray:layerNameDatasource];
    }
    else{
        layerNameDatasourceTemp = [[NSMutableArray alloc] initWithObjects:NSLocalizedString(@"外壁①", nil),NSLocalizedString(@"外壁②", nil),NSLocalizedString(@"外壁③", nil),NSLocalizedString(@"屋根", nil),NSLocalizedString(@"軒裏", nil),NSLocalizedString(@"雨樋", nil),NSLocalizedString(@"金属", nil),NSLocalizedString(@"その他①", nil),NSLocalizedString(@"その他②", nil),NSLocalizedString(@"その他③", nil), nil];
        layerImageDatasourceTemp = [NSArray arrayWithObjects:@"layer_wall",@"layer_wall",@"layer_wall",@"layer_roof",@"layer_balustrade",@"layer_gutter",@"layer_steel",@"Flaticon_4627",@"Flaticon_4627",@"Flaticon_4627", nil];
        layerTypeDatasourceTemp = [NSArray arrayWithObjects:[NSNumber numberWithInt:LAYER_WALL],[NSNumber numberWithInt:LAYER_WALL2],[NSNumber numberWithInt:LAYER_WALL3],[NSNumber numberWithInt:LAYER_ROOF],[NSNumber numberWithInt:LAYER_BALUSTRADE],[NSNumber numberWithInt:LAYER_GUTTER],[NSNumber numberWithInt:LAYER_STEEL],[NSNumber numberWithInt:LAYER_OTHER],[NSNumber numberWithInt:LAYER_OTHER2],[NSNumber numberWithInt:LAYER_OTHER3], nil];
        
        layerNameDatasource = [[NSMutableArray alloc] init];
        layerTypeDatasource = [[NSMutableArray alloc] init];
        layerImageDatasource = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < layerTypeDatasourceTemp.count; i++) {
            BOOL isexist = NO;
            for (LayerObject *layer in _currentLayes) {
                if (layer.type == [(NSNumber *)layerTypeDatasourceTemp[i] intValue]) {
                    isexist = YES;
                    break;
                }
            }
            if (!isexist) {
                [layerTypeDatasource addObject:layerTypeDatasourceTemp[i]];
                [layerNameDatasource addObject:layerNameDatasourceTemp[i]];
                [layerImageDatasource addObject:layerImageDatasourceTemp[i]];
            }
        }
    }
}

/*LAYER_NOPAINT = 0,
 LAYER_BALUSTRADE = 1,
 LAYER_GUTTER = 2,
 LAYER_ROOF = 3,
 LAYER_STEEL = 4,
 LAYER_WALL = 5,
 LAYER_WALL2 = 6,
 LAYER_WALL3 = 7,
 LAYER_OTHER = 8,
 LAYER_OTHER2 = 9,
 LAYER_OTHER3 = 10,
 LAYER_UNSET = 11*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [layerNameDatasource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *Identifier = @"Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    cell.textLabel.text = [layerNameDatasource objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[layerImageDatasource objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LayerObject *obj = [[LayerObject alloc] init];
    obj.name = [layerNameDatasource objectAtIndex:indexPath.row];
    obj.type = (LAYER_TYPE)[(NSNumber *)[layerTypeDatasource objectAtIndex:indexPath.row] intValue];
    obj.image = [layerImageDatasource objectAtIndex:indexPath.row];
    [delegate selectedLayerType:obj];
}

- (IBAction)closeLayerPicker:(id)sender {
    [delegate closeLayerPicker];
}

//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
//    return @"※その他は塗板注文システムとは連動しないのでご注意願います。";
//}
//※その他は塗板注文システムとは連動しないのでご注意願います。
@end
