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
@property (nonatomic, copy) HFLoadMoreBLock handlerBLock;

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


- (HFLoadMoreBLock)handlerBLock
{
    return objc_getAssociatedObject(self, &HFRefreshHandlerFooterString);
}


- (void)setHandlerBLock:(HFLoadMoreBLock)handlerBLock
{
    objc_setAssociatedObject(self, &HFRefreshHandlerFooterString, handlerBLock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


#pragma mark - 对外提供的方法
- (void)addLoadMoreForNextPageWithHandler:(HFLoadMoreBLock)loadMoreBlock
{
    self.handlerBLock = loadMoreBlock;
    
    CGFloat bottomY = CGRectGetHeight(self.frame) > self.contentSize.height ? CGRectGetHeight(self.frame) : self.contentSize.height;
    CGFloat originBottom = self.contentInset.bottom;
    
    bottomY = bottomY + originBottom;
    
    HFRefreshFootor *footer = [[HFRefreshFootor alloc] initWithFrame:CGRectMake(0, bottomY, self.bounds.size.width, HFRefreshFooterHeight)];
    footer.scrollView = self;
    
    [self addSubview:footer];
    [self bringSubviewToFront:footer];
    self.refreshFooter = footer;
    __weak typeof(self) weakSelf = self;
    [footer setLoadMoreEventBlock:^{
        if (weakSelf.handlerBLock) {
            weakSelf.handlerBLock();
        }
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
