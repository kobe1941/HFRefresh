//
//  UIScrollView+HFRefreshPullDown.h
//  HFRefresh
//
//  Created by 胡峰 on 16/9/11.
//  Copyright © 2016年 胡峰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HFRefreshBLock)(void);

@interface UIScrollView (HFRefreshPullDown)

// 添加下拉刷新
- (void)addPullDownToRefreshWithHandler:(HFRefreshBLock)refreshBlock;

// 模拟手势触发刷新
- (void)triggleToReFresh;

// 停止刷新
- (void)stopToFresh;

// 用于取消KVO的监听，防止页面返回后造成崩溃
- (void)resetPullToRefresh;

@end
