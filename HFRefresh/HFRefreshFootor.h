//
//  HFRefreshFootor.h
//  HFRefresh
//
//  Created by 胡峰 on 16/9/17.
//  Copyright © 2016年 胡峰. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat HFRefreshFooterHeight;

typedef NS_ENUM(NSInteger, HFLoadMoreStatus) {
    HFLoadMoreNormal, // 正常状态
    HFLoadMoreTriggle, // 滑动距离触发箭头翻转
    HFLoadMoreLoading, // 开始刷新，显示刷新动画
};

typedef void(^LoadMoreEventBlock)(void);

@interface HFRefreshFootor : UIView


// 下拉刷新的scrollView，weak避免循环引用
@property (nonatomic, weak) UIScrollView *scrollView;


// 切换控件的状态
- (void)setLoadMoreStatus:(HFLoadMoreStatus)loadMoreStatus;

// 触发刷新后用于回调scrollView的上拉加载网络请求
- (void)setLoadMoreEventBlock:(LoadMoreEventBlock)loadMoreblock;

@end
