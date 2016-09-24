//
//  HFRefreshHeader.h
//  HFRefresh
//
//  Created by 胡峰 on 16/9/11.
//  Copyright © 2016年 胡峰. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat HFRefreshHeaderHeight;

typedef NS_ENUM(NSInteger, HFRefreshStatus) {
    HFRefreshNormal, // 正常状态
    HFRefreshTriggle, // 滑动距离触发箭头翻转
    HFRefreshLoading, // 开始刷新，显示刷新动画
};

typedef void(^RefreshEventBlock)(void);

@interface HFRefreshHeader : UIView


// 下拉刷新的scrollView，weak避免循环引用
@property (nonatomic, weak) UIScrollView *scrollView;

// 触发刷新
- (void)hf_triggleToRefresh;

// 切换控件的状态
- (void)hf_setRefreshStatus:(HFRefreshStatus)refreshStatus;

// 触发刷新后用于回调scrollView的下拉刷新网络请求
// 回调要么用block要么用delegate
- (void)hf_setRefreshEventBlock:(RefreshEventBlock)refreshblock;


@end
