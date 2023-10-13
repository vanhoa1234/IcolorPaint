//
//  DecoratorUtil.m
//  Decorator
//
//  Created by Hoang Le on 12/4/13.
//  Copyright (c) 2013 Hoang Le. All rights reserved.
//

#import "DecoratorUtil.h"

@implementation DecoratorUtil
+ (NSString *)generateOrderEmail:(House *)_house andPlan:(NSArray *)plans {
	NSString *output = @"";
    @try {
        NSString *getStr = [[NSUserDefaults standardUserDefaults] stringForKey:kNameOder];
        output = [output stringByAppendingString:@"<p><h3>[注文者]</h3></p>"];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>%@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kAddressOder];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>%@</p>", getStr.length == 0 ? @"":getStr]];
        
        output = [output stringByAppendingString:@"<p><h3>[発送先]</h3></p>"];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kZipcode];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>郵便番号 : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kAddress];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>住所１ : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kAddress2];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>住所２ : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kPhoneNumberOder];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>電話番号 : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kFax];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>FAX番号 : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kMobilePhone];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>携帯電話 : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kEmailOder];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>メールアドレス : %@</p>", getStr.length == 0 ? @"":getStr]];
        
        output = [output stringByAppendingString:@"<p><h3>[お取り扱い販売店]</h3></p>"];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kNameStore];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>販売店 : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePhone];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>電話番号 : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kStoreFax];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>FAX番号 : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kEmailStore];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>メールアドレス : %@</p>", getStr.length == 0 ? @"":getStr]];
        
        output = [output stringByAppendingString:@"</br><p>注文内容</p>"];
//        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kPhoneNumberOder];
//        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>お取り扱い販売店名 : %@</p></br>", getStr.length == 0 ? @"":getStr]];
//        
//        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kNameStore];
//        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>販売店名 : %@</p>", getStr.length == 0 ? @"":getStr]];
//        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>物件名 : %@</p></br><p>注文内容</p>", _house.houseName]];
        
        for (Plan *_plan in plans) {
            output = [output stringByAppendingString:[NSString stringWithFormat:@"<p><h3>%@</h3></p>", _plan.planName]];
            NSArray *materials = [Material instancesWhere:[NSString stringWithFormat:@"planID = %d", _plan.planID]];
            for (Material *obj in materials) {
                output = [output stringByAppendingString:[NSString stringWithFormat:@"<ul><li>品名：%@</li>", [obj feature]]];
                output = [output stringByAppendingString:[NSString stringWithFormat:@"<li>つやの種類：%@</li>", obj.gloss]];
                if ([obj.pattern isEqualToString:@"フラット"]) {
                    output = [output stringByAppendingString:@"<li>柄・工法：フラット</li>"];
                    output = [output stringByAppendingString:[NSString stringWithFormat:@"<li>仕上げ方法：</li>"]];
                }
                else if ([obj.pattern isEqualToString:@"砂壁状下地"]){
                    output = [output stringByAppendingString:@"<li>柄・工法：</li>"];
                    output = [output stringByAppendingString:@"<li>仕上げ方法：リシン上に塗装</li>"];
                }
                else if ([obj.pattern isEqualToString:@"凹凸模様下地"]){
                    output = [output stringByAppendingString:@"<li>柄・工法：吹</li>"];
                    output = [output stringByAppendingString:@"<li>仕上げ方法：吹付けタイル</li>"];
                }
                else if ([obj.pattern isEqualToString:@"凸部処理下地"]){
                    output = [output stringByAppendingString:@"<li>柄・工法：押</li>"];
                    output = [output stringByAppendingString:@"<li>仕上げ方法：吹付けタイル</li>"];
                }
                else if ([obj.pattern isEqualToString:@"さざなみ模様下地"]){
                    output = [output stringByAppendingString:@"<li>柄・工法：パターンローラー</li>"];
                    output = [output stringByAppendingString:@"<li>仕上げ方法：リメークプラ</li>"];
                }
                else{
                    output = [output stringByAppendingString:[NSString stringWithFormat:@"<li>柄・工法：%@</li>", obj.pattern]];
                    output = [output stringByAppendingString:[NSString stringWithFormat:@"<li>仕上げ方法：</li>"]];
                }
                output = [output stringByAppendingString:[NSString stringWithFormat:@"<li>色番号：%@</li>", obj.colorCode]];
                if (obj.type != 4) {
                    output = [output stringByAppendingString:[NSString stringWithFormat:@"<li>素材：ボード</li><li>サイズ : 210 x 300</li><li>枚数 : 1枚</li></ul></br>"]];
                }
                else {
                    output = [output stringByAppendingString:[NSString stringWithFormat:@"<li>素材：ブリキ</li><li>サイズ : 90 x 210</li><li>枚数 : 1枚</li></ul>"]];
                }
            }
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:exception.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    @finally {
        return output;
    }
}

+ (NSString *)generateOrderEmail:(House *)_house andPlan:(NSArray *)plans andMaterial:(NSArray *)materials{
    NSString *output = @"";
    @try {
        NSString *getStr = [[NSUserDefaults standardUserDefaults] stringForKey:kNameOder];
        output = [output stringByAppendingString:@"<p><h3>[注文者]</h3></p>"];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>%@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kAddressOder];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>%@</p>", getStr.length == 0 ? @"":getStr]];
        
        output = [output stringByAppendingString:@"<p><h3>[発送先]</h3></p>"];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kZipcode];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>郵便番号 : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kAddress];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>住所１ : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kAddress2];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>住所２ : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kPhoneNumberOder];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>電話番号 : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kFax];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>FAX番号 : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kMobilePhone];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>携帯電話 : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kEmailOder];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>メールアドレス : %@</p>", getStr.length == 0 ? @"":getStr]];
        
        output = [output stringByAppendingString:@"<p><h3>[お取り扱い販売店]</h3></p>"];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kNameStore];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>販売店 : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePhone];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>電話番号 : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kStoreFax];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>FAX番号 : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kEmailStore];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>メールアドレス : %@</p>", getStr.length == 0 ? @"":getStr]];
        
        output = [output stringByAppendingString:@"</br><p>注文内容</p>"];
        NSMutableArray *planMaterials = [NSMutableArray array];
        for (Plan *_plan in plans) {
            for (Material *obj in materials) {
                if (obj.planID == _plan.planID) {
                    [planMaterials addObject:obj];
                }
            }
            if (planMaterials.count > 0) {
                output = [output stringByAppendingString:[NSString stringWithFormat:@"<p><h3>%@</h3></p>", _plan.planName]];
            }
            for (Material *obj in planMaterials) {
                output = [output stringByAppendingString:[NSString stringWithFormat:@"<ul><li>品名：%@</li>", [obj feature]]];
                output = [output stringByAppendingString:[NSString stringWithFormat:@"<li>つやの種類：%@</li>", obj.gloss]];
                if ([obj.pattern isEqualToString:@"フラット"]) {
                    output = [output stringByAppendingString:@"<li>柄・工法：フラット</li>"];
                    output = [output stringByAppendingString:[NSString stringWithFormat:@"<li>仕上げ方法：</li>"]];
                }
                else if ([obj.pattern isEqualToString:@"砂壁状下地"]){
                    output = [output stringByAppendingString:@"<li>柄・工法：</li>"];
                    output = [output stringByAppendingString:@"<li>仕上げ方法：リシン上に塗装</li>"];
                }
                else if ([obj.pattern isEqualToString:@"凹凸模様下地"]){
                    output = [output stringByAppendingString:@"<li>柄・工法：吹</li>"];
                    output = [output stringByAppendingString:@"<li>仕上げ方法：吹付けタイル</li>"];
                }
                else if ([obj.pattern isEqualToString:@"凸部処理下地"]){
                    output = [output stringByAppendingString:@"<li>柄・工法：押</li>"];
                    output = [output stringByAppendingString:@"<li>仕上げ方法：吹付けタイル</li>"];
                }
                else if ([obj.pattern isEqualToString:@"さざなみ模様下地"]){
                    output = [output stringByAppendingString:@"<li>柄・工法：パターンローラー</li>"];
                    output = [output stringByAppendingString:@"<li>仕上げ方法：リメークプラ</li>"];
                }
                else{
                    output = [output stringByAppendingString:[NSString stringWithFormat:@"<li>柄・工法：%@</li>", obj.pattern]];
                    output = [output stringByAppendingString:[NSString stringWithFormat:@"<li>仕上げ方法：</li>"]];
                }
                output = [output stringByAppendingString:[NSString stringWithFormat:@"<li>色番号：%@</li>", obj.colorCode]];
                if (obj.type != 4) {
                    output = [output stringByAppendingString:[NSString stringWithFormat:@"<li>素材：ボード</li><li>サイズ : 210 x 300（A4サイズ)</li><li>枚数 : 1枚</li></ul></br>"]];
                }
                else {
                    output = [output stringByAppendingString:[NSString stringWithFormat:@"<li>素材：ブリキ</li><li>サイズ : 90 x 210</li><li>枚数 : 1枚</li></ul>"]];
                }
            }
            [planMaterials removeAllObjects];
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:exception.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    @finally {
        return output;
    }
}

+ (NSString *)generateOrderEmailWithMaterials:(NSArray *)materials{
    NSString *output = @"";
    @try {
        NSString *getStr = [[NSUserDefaults standardUserDefaults] stringForKey:kNameOder];
        output = [output stringByAppendingString:@"<p><h3>[注文者]</h3></p>"];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>%@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kAddressOder];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>%@</p>", getStr.length == 0 ? @"":getStr]];
        
        output = [output stringByAppendingString:@"<p><h3>[発送先]</h3></p>"];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kZipcode];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>郵便番号 : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kAddress];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>住所１ : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kAddress2];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>住所２ : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kPhoneNumberOder];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>電話番号 : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kFax];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>FAX番号 : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kMobilePhone];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>携帯電話 : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kEmailOder];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>メールアドレス : %@</p>", getStr.length == 0 ? @"":getStr]];
        
        output = [output stringByAppendingString:@"<p><h3>[お取り扱い販売店]</h3></p>"];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kNameStore];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>販売店 : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kStorePhone];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>電話番号 : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kStoreFax];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>FAX番号 : %@</p>", getStr.length == 0 ? @"":getStr]];
        getStr = [[NSUserDefaults standardUserDefaults] objectForKey:kEmailStore];
        output = [output stringByAppendingString:[NSString stringWithFormat:@"<p>メールアドレス : %@</p>", getStr.length == 0 ? @"":getStr]];
        
        output = [output stringByAppendingString:@"</br><p>注文内容</p>"];
        for (Material *obj in materials) {
            output = [output stringByAppendingString:[NSString stringWithFormat:@"<ul><li>品名：%@</li>", [obj feature]]];
            output = [output stringByAppendingString:[NSString stringWithFormat:@"<li>つやの種類：%@</li>", obj.gloss]];
            if ([obj.pattern isEqualToString:@"フラット"]) {
                output = [output stringByAppendingString:@"<li>柄・工法：フラット</li>"];
                output = [output stringByAppendingString:[NSString stringWithFormat:@"<li>仕上げ方法：</li>"]];
            }
            else if ([obj.pattern isEqualToString:@"砂壁状下地"]){
                output = [output stringByAppendingString:@"<li>柄・工法：</li>"];
                output = [output stringByAppendingString:@"<li>仕上げ方法：リシン上に塗装</li>"];
            }
            else if ([obj.pattern isEqualToString:@"凹凸模様下地"]){
                output = [output stringByAppendingString:@"<li>柄・工法：吹</li>"];
                output = [output stringByAppendingString:@"<li>仕上げ方法：吹付けタイル</li>"];
            }
            else if ([obj.pattern isEqualToString:@"凸部処理下地"]){
                output = [output stringByAppendingString:@"<li>柄・工法：押</li>"];
                output = [output stringByAppendingString:@"<li>仕上げ方法：吹付けタイル</li>"];
            }
            else if ([obj.pattern isEqualToString:@"さざなみ模様下地"]){
                output = [output stringByAppendingString:@"<li>柄・工法：パターンローラー</li>"];
                output = [output stringByAppendingString:@"<li>仕上げ方法：リメークプラ</li>"];
            }
            else{
                output = [output stringByAppendingString:[NSString stringWithFormat:@"<li>柄・工法：%@</li>", obj.pattern]];
                output = [output stringByAppendingString:[NSString stringWithFormat:@"<li>仕上げ方法：</li>"]];
            }
            output = [output stringByAppendingString:[NSString stringWithFormat:@"<li>色番号：%@</li>", obj.colorCode]];
            if (obj.type != 4) {
                output = [output stringByAppendingString:[NSString stringWithFormat:@"<li>素材：ボード</li><li>サイズ : 210 x 300（A4サイズ)</li><li>枚数 : 1枚</li></ul></br>"]];
            }
            else {
                output = [output stringByAppendingString:[NSString stringWithFormat:@"<li>素材：ブリキ</li><li>サイズ : 90 x 210</li><li>枚数 : 1枚</li></ul>"]];
            }
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:exception.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    @finally {
        return output;
    }
}

+ (NSString *)getMaterialIcon:(int)_type andKind:(NSString *)_kind{
    switch (_type) {
        case 1://ban cong
            return @"S_Baslustrade01";
            break;
        case 2://ong nuoc
        {
            if ([_kind isEqualToString:@"ワイドエポーレF"]) {
                return @"S_Gutter02";
            }
            else
                return @"S_Gutter01";
        }
            break;
        case 3://mai nha
        {
            if ([_kind isEqualToString:@"ワイドエポーレF"]) {
                return @"S-06";
            }
            else
                return @"S-05";
        }
            break;
        case 4://thep
        {
            if ([_kind isEqualToString:@"ワイドエポーレF"]) {
                return @"S_Steel02";
            }
            else
                return @"S_Steel01";
        }
            break;
        case 5:
        case 6:
        case 7:
            //tuong
        {
            if ([_kind isEqualToString:@"ワイドエポーレF"] || [_kind isEqualToString:@"水性セラフレックスF"] || [_kind isEqualToString:@"エコフッソ"]) {
                return @"S_Wall02";
            }
            else
                return @"S_Wall01";
        }
            break;
        default:
            return @"";
            break;
    }
}
/*
 注文者名　(tên người đặt hàng)
 発送先 (địa chỉ giao hàng)
 連絡先 (địa điểm liên lạc)
 
 販売店名 (tên cưa hàng buôn bán)
 物件名 (tên tòa nhà)
 
 注文内容 (nội dung order)
 ①プラン１ (plan 1)
 品名：(tên sản phẩm)
 つやの種類：(loại bóng)
 柄・工法 (Pattern/ phương pháp)
 仕上げ方法 (phương pháp hoàn thiện)
 色番号：(mã mầu)
 素材(vật liệu)
 サイズ：(kích thước)
 枚数：(số tờ)
 */


+ (NSString *)getTypeNameByID:(int)_type{
    switch (_type) {
        case 1:
            return NSLocalizedString(@"軒裏", nil);
            break;
        case 2:
            return NSLocalizedString(@"雨樋", nil);
            break;
        case 3:
            return NSLocalizedString(@"屋根", nil);
            break;
        case 4:
            return NSLocalizedString(@"金属", nil);
            break;
        case 5:
            return NSLocalizedString(@"外壁①", nil);
            break;
        case 6:
            return NSLocalizedString(@"外壁②", nil);
            break;
        case 7:
            return NSLocalizedString(@"外壁③", nil);
            break;
        case 8:
            return NSLocalizedString(@"その他①", nil);
            break;
        case 9:
            return NSLocalizedString(@"その他②", nil);
            break;
        case 10:
            return NSLocalizedString(@"その他③", nil);
            break;
        default:
            return NSLocalizedString(@"未設定", nil);
            break;
    }}

+ (NSString *)getTypeImageByID:(int)_type{
    switch (_type) {
        case 1:
            return @"layer_balustrade.png";
            break;
        case 2:
            return @"layer_gutter.png";
            break;
        case 3:
            return @"layer_roof.png";
            break;
        case 4:
            return @"layer_steel.png";
            break;
        case 5:
            return @"layer_wall.png";
            break;
        case 6:
            return @"layer_wall.png";
            break;
        case 7:
            return @"layer_wall.png";
            break;
        case 8:
        case 9:
        case 10:
            return @"Flaticon_4627.png";
            break;
        default:
            return @"";
            break;
    }
}

@end
