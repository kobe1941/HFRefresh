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

@interface HFRefreshHeader : UIView


// 下拉刷新的scrollView，weak避免循环引用
@property (nonatomic, weak) UIScrollView *scrollView;

- (void)setRefreshStatus:(HFRefreshStatus)refreshStatus;

@end
