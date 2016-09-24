//
//  UIScrollView+HFRefreshLoadMore.m
//  HFRefresh
//
//  Created by 胡峰 on 16/9/17.
//  Copyright © 2016年 胡峰. All rights reserved.
//

#import "UIScrollView+HFRefreshLoadMore.h"
#import "HFRefreshFootor.h"
#import <objc/runtime.h>

static const NSString *HFRefreshFooterString;
static const NSString *HFRefreshHandlerFooterString;

@interface UIScrollView ()

@property (nonatomic, strong) HFRefreshFootor *refreshFooter;

@end

@implementation UIScrollView (HFRefreshLoadMore)

#pragma mark - 关联对象和属性
- (HFRefreshFootor *)refreshFooter
{
    return objc_getAssociatedObject(self, &HFRefreshFooterString);
}

- (void)setRefreshFooter:(HFRefreshFootor *)refreshFooter
{
    objc_setAssociatedObject(self, &HFRefreshFooterString, refreshFooter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 对外提供的方法
- (void)hf_addLoadMoreForNextPageWithHandler:(HFLoadMoreBLock)loadMoreBlock
{
    if ([self.subviews containsObject:self.refreshFooter]) {
        NSLog(@"已经添加过上拉加载控件，不再重复添加------------>>>>>>>>>>>>>>>>>");
        return;
    }
    
    CGFloat bottomY = self.contentSize.height;
    CGFloat originBottom = self.contentInset.bottom;
    
    // 兼容处理
    if (self.contentSize.height > self.frame.size.height) {
        bottomY += originBottom;
    }
    
    HFRefreshFootor *footer = [[HFRefreshFootor alloc] initWithFrame:CGRectMake(0, bottomY, self.bounds.size.width, HFRefreshFooterHeight)];
//    footer.scrollView = self;
    
    [self addSubview:footer];
    [self bringSubviewToFront:footer];
    self.refreshFooter = footer;
    [footer hf_setLoadMoreEventBlock:^{
        loadMoreBlock();
    }];
    
    UIEdgeInsets insets = self.contentInset;
    insets.bottom += HFRefreshFooterHeight;
    self.contentInset = insets;
}

- (void)hf_stopLoadMore
{
    [self.refreshFooter hf_setLoadMoreStatus:HFLoadMoreNormal];
}

- (void)hf_loadMoreNoMore
{
    UIEdgeInsets insets = self.contentInset;
    insets.bottom -= HFRefreshFooterHeight; // 跟添加的时候相呼应，一个加一个减
    [UIView animateWithDuration:0.2 animations:^{
        self.contentInset = insets;
    } completion:^(BOOL finished) {
        [self.refreshFooter removeFromSuperview];
    }];
}
/*
- (void)hf_resetLoadMoreForNextPage
{
    self.refreshFooter.scrollView = nil;
}
*/
@end
