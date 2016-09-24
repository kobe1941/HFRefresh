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
- (void)addLoadMoreForNextPageWithHandler:(HFLoadMoreBLock)loadMoreBlock
{
    CGFloat bottomY = CGRectGetHeight(self.frame) > self.contentSize.height ? CGRectGetHeight(self.frame) : self.contentSize.height;
    CGFloat originTop = self.contentInset.top;
    CGFloat originBottom = self.contentInset.bottom;
    
    // 兼容处理，如果不想兼容contentSize较少时，直接注释if这个判断，保留else的逻辑即可.Footer里同样处理
    if (self.contentSize.height < self.frame.size.height) {
        bottomY -= originTop;
    } else {
        bottomY += originBottom;
    }
    
    HFRefreshFootor *footer = [[HFRefreshFootor alloc] initWithFrame:CGRectMake(0, bottomY, self.bounds.size.width, HFRefreshFooterHeight)];
//    footer.scrollView = self;
    
    [self addSubview:footer];
    [self bringSubviewToFront:footer];
    self.refreshFooter = footer;
    [footer setLoadMoreEventBlock:^{
        loadMoreBlock();
    }];
}


- (void)stopToLoadMore
{
    [self.refreshFooter setLoadMoreStatus:HFLoadMoreNormal];
}

- (void)resetLoadMoreForNextPage
{
    self.refreshFooter.scrollView = nil;
}

@end
