//
//  UIScrollView+HFRefreshLoadMore.h
//  HFRefresh
//
//  Created by 胡峰 on 16/9/17.
//  Copyright © 2016年 胡峰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HFLoadMoreBLock)(void);

@interface UIScrollView (HFRefreshLoadMore)

// 添加下拉刷新
- (void)addLoadMoreForNextPageWithHandler:(HFLoadMoreBLock)loadMoreBlock;


// 停止刷新
- (void)stopToLoadMore;

// 用于取消KVO的监听，防止页面返回后造成崩溃
- (void)resetLoadMoreForNextPage;

@end
