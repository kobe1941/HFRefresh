//
//  UIScrollView+HFRefreshPullDown.m
//  HFRefresh
//
//  Created by 胡峰 on 16/9/11.
//  Copyright © 2016年 胡峰. All rights reserved.
//

#import "UIScrollView+HFRefreshPullDown.h"
#import "HFRefreshHeader.h"
#import <objc/runtime.h>

static const NSString *HFRefreshHeaderString;
static const NSString *HFRefreshHandlerString;

@interface UIScrollView ()

@property (nonatomic, strong) HFRefreshHeader *refreshHeader;

@end


@implementation UIScrollView (HFRefreshPullDown)

#pragma mark - 关联对象和属性
- (HFRefreshHeader *)refreshHeader
{
    return objc_getAssociatedObject(self, &HFRefreshHeaderString);
}

- (void)setRefreshHeader:(HFRefreshHeader *)refreshHeader
{
    objc_setAssociatedObject(self, &HFRefreshHeaderString, refreshHeader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark - 对外提供的方法
- (void)addPullDownToRefreshWithHandler:(HFRefreshBLock)refreshBlock
{
    CGFloat originY = -HFRefreshHeaderHeight - self.contentInset.top;
    HFRefreshHeader *header = [[HFRefreshHeader alloc] initWithFrame:CGRectMake(0, originY, self.bounds.size.width, HFRefreshHeaderHeight)];
    header.scrollView = self;
    
    [self addSubview:header];
    [self bringSubviewToFront:header];
    self.refreshHeader = header;

    [header setRefreshEventBlock:^{
        refreshBlock();
    }];
}

- (void)triggleToReFresh
{
    [self.refreshHeader triggleToReFresh];
}

- (void)stopToFresh
{
    [self.refreshHeader setRefreshStatus:HFRefreshNormal];
}

- (void)resetPullToRefresh
{
    self.refreshHeader.scrollView = nil;
}

@end
