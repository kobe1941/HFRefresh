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

// 添加上拉加载更多
- (void)hf_addLoadMoreForNextPageWithHandler:(HFLoadMoreBLock)loadMoreBlock;

// 停止加载
- (void)hf_stopLoadMore;

// 无更多数据，去掉上拉加载更多控件，下拉刷新时可再次添加
- (void)hf_loadMoreNoMore;

// 用于取消KVO的监听，防止页面返回后造成崩溃
//- (void)hf_resetLoadMoreForNextPage;

@end
