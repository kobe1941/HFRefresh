//
//  UIImage+HFRefresh.m
//  用于读取bundle里的arrow图片
//
//  Created by 胡峰 on 16/9/25.
//  Copyright © 2016年 胡峰. All rights reserved.
//

#import "UIImage+HFRefresh.h"

@implementation UIImage (HFRefresh)

+ (NSBundle *)hf_refreshBundle
{
    static NSBundle *refreshBundle = nil;
    if (!refreshBundle) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"HFRefresh" ofType:@"bundle"];
        refreshBundle = [NSBundle bundleWithPath:bundlePath];
    }
    
    return refreshBundle;
}

+ (UIImage *)hf_arrowImage
{
    static UIImage *arrowImage = nil;
    if (!arrowImage) {
        arrowImage = [UIImage imageWithContentsOfFile:[[self hf_refreshBundle] pathForResource:@"hf_arrow@2x" ofType:@"png"]];
    }
    
    return arrowImage;
}

@end
