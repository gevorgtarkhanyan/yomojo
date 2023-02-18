//
//  UIColor+Yomojo.m
//  Yomojo
//
//  Created by Suren Poghosyan on 2/20/20.
//  Copyright © 2020 AcquireBPO. All rights reserved.
//

#import "UIColor+Yomojo.h"

@implementation UIColor (Yomojo)

+ (instancetype)YomoPinkColor {
    return [self colorFromHexString:@"#E1054F"];
}

+ (instancetype)YomoOrangeColor {
    return [self colorFromHexString:@"#F8901F"];
}

+ (instancetype)YomoLightOrangeColor {
    return [self colorFromHexString:@"#FFC883"];
}

+ (instancetype)YomoLightGrayColor {
    return [self colorFromHexString:@"#E7E7E7"];
}

+ (instancetype)YomoDarkGrayColor {
    return [self colorFromHexString:@"#888888"];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
