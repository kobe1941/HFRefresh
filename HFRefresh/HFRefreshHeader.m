//
//  HFRefreshHeader.m
//  HFRefresh
//
//  Created by 胡峰 on 16/9/11.
//  Copyright © 2016年 胡峰. All rights reserved.
//

#import "HFRefreshHeader.h"

const CGFloat HFRefreshHeaderHeight = 60;

const CGFloat HFTriggleThrold = HFRefreshHeaderHeight;

@interface HFRefreshHeader ()

@property (nonatomic, strong) UIImageView *arrowImage;
@property (nonatomic, strong) UIActivityIndicatorView *refreshIndicator;
@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, assign) HFRefreshStatus refreshStatus;

@property (nonatomic, assign) CGFloat originInsetTop; // scrollView最初的偏移量

@property (nonatomic, copy) RefreshEventBlock refreshBLock;

@end

@implementation HFRefreshHeader

- (void)dealloc
{
    [self setScrollView:nil]; // 必须置空
    NSLog(@"dealloc-------->>>>> %@", NSStringFromClass([self class]));
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI
{
    [self addSubview:self.arrowImage];
    [self addSubview:self.refreshIndicator];
    [self addSubview:self.textLabel];
    
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:160]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:24]];
    
    self.arrowImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arrowImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arrowImage attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:60]];
    
    self.refreshIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.refreshIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.arrowImage attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.refreshIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.arrowImage attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self setRefreshStatus:HFRefreshNormal];
}

#pragma mark - getter && setter
- (UIImageView *)arrowImage
{
    if (!_arrowImage) {
        _arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refreshArrow"]];
    }
    return _arrowImage;
}

- (UIActivityIndicatorView *)refreshIndicator
{
    if (!_refreshIndicator) {
        _refreshIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return _refreshIndicator;
}

- (UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:15];
    }
    
    return _textLabel;
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    if (_scrollView) {
        [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
    
    if (scrollView) {
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        // 保存scrolView最初的inset
        self.originInsetTop = scrollView.contentInset.top;
    }
    _scrollView = scrollView;
}


- (void)setRefreshStatus:(HFRefreshStatus)refreshStatus
{
    _refreshStatus = refreshStatus;
    switch (refreshStatus) {
        case HFRefreshNormal: {
            self.refreshIndicator.hidden = YES;
            [self.refreshIndicator stopAnimating];
            self.arrowImage.hidden = NO;
            // 箭头翻转动画
            [UIView animateWithDuration:0.2 animations:^{
                self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI*2);
            }];
            
            self.textLabel.text = @"下拉可刷新";
            UIEdgeInsets insets = self.scrollView.contentInset;
            insets.top = self.originInsetTop;
            [UIView animateWithDuration:0.2 animations:^{
                self.scrollView.contentInset = insets;
            }];
            break;
        }
        case HFRefreshTriggle: {
            self.refreshIndicator.hidden = YES;
            [self.refreshIndicator stopAnimating];
            self.arrowImage.hidden = NO;
            // 箭头翻转动画
            [UIView animateWithDuration:0.2 animations:^{
                self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
            }];
            
            self.textLabel.text = @"释放立即刷新";
            break;
        }
        case HFRefreshLoading: {
            self.refreshIndicator.hidden = NO;
            [self.refreshIndicator startAnimating];
            self.arrowImage.hidden = YES;
            self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI*2);
            self.textLabel.text = @"加载中...";
            
            UIEdgeInsets insets = self.scrollView.contentInset;
            insets.top = HFTriggleThrold + self.originInsetTop;
            self.scrollView.contentInset = insets;
            // 触发下拉刷新的网络请求
            if (self.refreshBLock) {
                self.refreshBLock();
            }
            break;
        }
    }
}

- (void)setRefreshEventBlock:(RefreshEventBlock)refreshblock
{
    self.refreshBLock = refreshblock;
}

// 模拟用户手势触发刷新
- (void)triggleToReFresh
{
    UIEdgeInsets insets = self.scrollView.contentInset;
    insets.top = self.originInsetTop + HFRefreshHeaderHeight + 1;
    UIEdgeInsets finalInsets = insets;
    finalInsets.top -= 1;
    [UIView animateWithDuration:0.2 animations:^{
        self.scrollView.contentInset = insets;
    } completion:^(BOOL finished) {
        self.scrollView.contentInset = finalInsets;
    }];
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([object isKindOfClass:[UIScrollView class]] && [keyPath isEqualToString:@"contentOffset"]) {

        CGPoint contentOffset = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
        
        [self adjustRefreshStatusWithOffset:contentOffset.y];
        // 因为KVO的实现机制，不能直接读取属性，因为此时该setter方法还未生效，所以读出来的值也是旧的
//        UIScrollView *scrollView = (UIScrollView *)object;
//        [self adjustRefreshStatusWithOffset:scrollView.contentOffset.y];
    }
}

- (void)adjustRefreshStatusWithOffset:(CGFloat)offset
{
    // 只要是触发状态且手指松开，则进入刷新状态，不用关注此时的offset，因为KVO的offset变化的太快导致不准确
    // 否则根据offset来判断会有误差
    if (self.refreshStatus == HFRefreshTriggle && !self.scrollView.isDragging) {
        [self setRefreshStatus:HFRefreshLoading];
    } else if ((self.refreshStatus == HFRefreshNormal) && (offset <= -(HFRefreshHeaderHeight+self.originInsetTop))) {
        [self  setRefreshStatus:HFRefreshTriggle];
    } else if ((self.refreshStatus != HFRefreshNormal) && (offset > -(HFRefreshHeaderHeight+self.originInsetTop))) {
        if (self.refreshStatus != HFRefreshLoading) { // 排除掉正在刷新时，手势往上滑取消刷新动画的情况
            [self setRefreshStatus:HFRefreshNormal];
        }
        
    }
    
}

@end
