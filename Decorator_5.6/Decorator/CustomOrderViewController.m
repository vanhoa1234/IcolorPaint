//
//  CustomOrderViewController.m
//  Decorator
//
//  Created by Hoang Le on 11/26/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "CustomOrderViewController.h"
#import "Feature.h"
#import "MaterialDefault.h"
#import "LayerObject.h"

@interface CustomOrderViewController (){
    Material *material;
    NSMutableArray *glossArray;
    NSMutableArray *patternArray;
    int selectedGloss,selectedPattern;
}

@end

@implementation CustomOrderViewController
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

- (IBAction)backToOrderDetail:(id)sender {
//    [self.navigationController popViewControllerWithFlipStyle:MPFlipStyleDirectionBackward];
    [self.navigationController fadePopViewController];
}

- (IBAction)changeGloss:(id)sender {
    [(UIButton *)[_customView viewWithTag:(100+selectedGloss)] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setUnhightlightButton:(UIButton *)[_customView viewWithTag:(300+selectedGloss)]];
    int tag = (int)[(UIButton *)sender tag];
    selectedGloss = tag % 100;
    [(UIButton *)[_customView viewWithTag:(100+selectedGloss)] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self setHightlightButton:(UIButton *)[_customView viewWithTag:tag]];
}

- (IBAction)changePattern:(id)sender {
    [(UIButton *)[_customView viewWithTag:(200+selectedPattern)] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setUnhightlightButton:(UIButton *)[_customView viewWithTag:(400+selectedPattern)]];
    int tag = (int)[(UIButton *)sender tag];
    selectedPattern = tag % 100;
    [(UIButton *)[_customView viewWithTag:(200+selectedPattern)] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self setHightlightButton:(UIButton *)[_customView viewWithTag:tag]];
}

- (IBAction)saveEditAction:(id)sender {
    @try {
        material.gloss = [glossArray objectAtIndex:selectedGloss];
        material.pattern = [patternArray objectAtIndex:selectedPattern];
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
        
        [delegate savedCustomOrder:material];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saving successfully!" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
    }
    @catch (NSException *exception) {
        NSLog(@"error %@",[exception description]);
    }
    @finally {
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [delegate savedCustomOrder:material];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _customView.layer.cornerRadius = 20.0f;
    _customView.layer.masksToBounds = YES;
    _backgroundView.image = [[UIImage imageNamed:@"ws_BG_table"] stretchableImageWithLeftCapWidth:300 topCapHeight:300];
    [self addGlossAndPatternByType];
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

- (void)addGlossAndPatternByType{
    int materialType = (int)material.type;
    if (material.type > 5 && material.type <= 7) {
        materialType = 5;
    }
    NSArray *objs = [Feature instancesWhere:[NSString stringWithFormat:@"featureName = '%@' and type = %d",material.feature,materialType]];
    if (objs.count == 0) {
        return;
    }
    Feature *obj = [objs objectAtIndex:0];
    _lb_type.text = [DecoratorUtil getTypeNameByID:(int)material.type];
    _img_feature.image = [UIImage imageNamed:[DecoratorUtil getMaterialIcon:(int)obj.type andKind:obj.featureName]];
    _img_type.image = [UIImage imageNamed:[DecoratorUtil getTypeImageByID:(int)material.type]];
    _fname.text = obj.featureName;
    _fdescription.text = [NSString stringWithFormat:@"①	 %@",obj.description];;

    glossArray = [[NSMutableArray alloc] initWithArray:[obj.glossRef componentsSeparatedByString:@";"]];
    patternArray = [[NSMutableArray alloc] initWithArray:[obj.patternRef componentsSeparatedByString:@";"]];
    
    if (glossArray.count > 0) {
        int count = 0;
        for (int i = 0 ; i < [glossArray count]; i ++) {
            if ([[glossArray objectAtIndex:i] isEqualToString:material.gloss]) {
                count = i;
            }
            switch (i) {
                case 0:{
                    _btt_gloss1.hidden = NO;
                    _btb_gloss1.hidden = NO;
                    [_btt_gloss1 setTitle:[glossArray objectAtIndex:0] forState:UIControlStateNormal];
                    if ([[glossArray objectAtIndex:0] isEqualToString:@"つや消し"]) {
                        [_btb_gloss1 setImage:[UIImage imageNamed:@"S-00"] forState:UIControlStateNormal];
                        _lb_glossDescription.hidden = YES;
                    }
                    else if ([[glossArray objectAtIndex:0] isEqualToString:@"３分つやあり"]) {
                        [_btb_gloss1 setImage:[UIImage imageNamed:@"S-03"] forState:UIControlStateNormal];
                        _lb_glossDescription.hidden = YES;
                    }
                    else{
                        [_btb_gloss1 setImage:[UIImage imageNamed:@"S-01"] forState:UIControlStateNormal];
                        _lb_glossDescription.hidden = NO;
                    }
                }
                    break;
                case 1:{
                    _btt_gloss2.hidden = NO;
                    _btb_gloss2.hidden = NO;
                    [_btt_gloss2 setTitle:[glossArray objectAtIndex:1] forState:UIControlStateNormal];
                    [_btb_gloss2 setImage:[UIImage imageNamed:@"S-02"] forState:UIControlStateNormal];
                }
                    break;
                case 2:{
                    _btt_gloss3.hidden = NO;
                    _btb_gloss3.hidden = NO;
                    [_btt_gloss3 setTitle:[glossArray objectAtIndex:2] forState:UIControlStateNormal];
                    [_btb_gloss3 setImage:[UIImage imageNamed:@"S-03"] forState:UIControlStateNormal];
                }
                    break;
                case 3:{
                    _btt_gloss4.hidden = NO;
                    _btb_gloss4.hidden = NO;
                    [_btt_gloss4 setTitle:[glossArray objectAtIndex:3] forState:UIControlStateNormal];
                    [_btb_gloss4 setImage:[UIImage imageNamed:@"S-04"] forState:UIControlStateNormal];
                }
                    break;
                default:{
                    _btt_gloss1.hidden = NO;
                    _btb_gloss1.hidden = NO;
                    [_btt_gloss1 setTitle:[glossArray objectAtIndex:0] forState:UIControlStateNormal];
                    [_btb_gloss1 setImage:[UIImage imageNamed:@"S-01"] forState:UIControlStateNormal];
                }
                    break;
            }
        }
        selectedGloss = count;
        [(UIButton *)[_customView viewWithTag:(100+count)] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self setHightlightButton:(UIButton *)[_customView viewWithTag:(300+selectedGloss)]];
    }
    
    if (patternArray.count > 0) {
        int count = 0;
        for (int i = 0; i < [patternArray count]; i ++) {
            if ([[patternArray objectAtIndex:i] isEqualToString:material.pattern]) {
                count = i;
            }
            switch (i) {
                case 0:{
                    _btt_pattern1.hidden = NO;
                    _btb_pattern1.hidden = NO;
                    if ([material.feature isEqualToString:@"水性ジェルアートSi"]) {
                        [_btt_pattern1 setTitle:[patternArray objectAtIndex:0] forState:UIControlStateNormal];
                        [_btb_pattern1 setImage:[UIImage imageNamed:@"さざなみ模様下地"] forState:UIControlStateNormal];
                    }
                    else{
                        [_btt_pattern1 setTitle:[patternArray objectAtIndex:0] forState:UIControlStateNormal];
                        [_btb_pattern1 setImage:[UIImage imageNamed:@"フラット"] forState:UIControlStateNormal];
                    }
                }
                    break;
                case 1:{
                    _btt_pattern2.hidden = NO;
                    _btb_pattern2.hidden = NO;
                    if ([material.feature isEqualToString:@"水性ジェルアートSi"]) {
                        [_btt_pattern2 setTitle:[patternArray objectAtIndex:1] forState:UIControlStateNormal];
                        [_btb_pattern2 setImage:[UIImage imageNamed:@"凹凸模様下地"] forState:UIControlStateNormal];
                    }
                    else{
                        [_btt_pattern2 setTitle:[patternArray objectAtIndex:1] forState:UIControlStateNormal];
                        [_btb_pattern2 setImage:[UIImage imageNamed:@"砂壁模様下地"] forState:UIControlStateNormal];
                    }
                }
                    break;
                case 2:{
                    _btt_pattern3.hidden = NO;
                    _btb_pattern3.hidden = NO;
                    [_btt_pattern3 setTitle:[patternArray objectAtIndex:2] forState:UIControlStateNormal];
                    [_btb_pattern3 setImage:[UIImage imageNamed:@"凹凸模様下地"] forState:UIControlStateNormal];
                }
                    break;
                case 3:{
                    _btt_pattern4.hidden = NO;
                    _btb_pattern4.hidden = NO;
                    [_btt_pattern4 setTitle:[patternArray objectAtIndex:3] forState:UIControlStateNormal];
                    [_btb_pattern4 setImage:[UIImage imageNamed:@"凸部模様下地"] forState:UIControlStateNormal];
                }
                    break;
                case 4:{
                    _btt_pattern5.hidden = NO;
                    _btb_pattern5.hidden = NO;
                    [_btt_pattern5 setTitle:[patternArray objectAtIndex:4] forState:UIControlStateNormal];
                    [_btb_pattern5 setImage:[UIImage imageNamed:@"さざなみ模様下地"] forState:UIControlStateNormal];
                }
                    break;
                default:{
                    _btt_pattern1.hidden = NO;
                    _btb_pattern1.hidden = NO;
                    [_btt_pattern1 setTitle:[patternArray objectAtIndex:0] forState:UIControlStateNormal];
                    [_btb_pattern1 setImage:[UIImage imageNamed:@"フラット"] forState:UIControlStateNormal];
                }
                    break;
            }
        }
        selectedPattern = count;
        [(UIButton *)[_customView viewWithTag:(200+count)] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self setHightlightButton:(UIButton *)[_customView viewWithTag:(400+selectedPattern)]];
    }
}

- (void)setHightlightButton:(UIButton *)_button{
    _button.layer.borderColor = [UIColor redColor].CGColor;
    _button.layer.borderWidth = 2.0f;
    _button.layer.cornerRadius = 5.0f;
}

- (void)setUnhightlightButton:(UIButton *)_button{
    _button.layer.borderWidth = 0.0f;
}

@end
