//
//  HFRefreshHeader.m
//  HFRefresh
//
//  Created by 胡峰 on 16/9/11.
//  Copyright © 2016年 胡峰. All rights reserved.
//

#import "HFRefreshHeader.h"
#import "UIScrollView+HFRefreshPullDown.h"

const CGFloat HFRefreshHeaderHeight = 60;

const CGFloat HFTriggleThrold = HFRefreshHeaderHeight;

@interface HFRefreshHeader ()

@property (nonatomic, strong) UIImageView *arrowImage;
@property (nonatomic, strong) UIActivityIndicatorView *refreshIndicator;
@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, assign) HFRefreshStatus refreshStatus;

@property (nonatomic, assign) CGFloat originOffset; // scrollView最初的偏移量

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
    
    self.arrowImage.center = CGPointMake(30, 30);
    self.refreshIndicator.center = self.arrowImage.center;
    self.textLabel.frame = CGRectMake(CGRectGetMaxX(self.arrowImage.frame), CGRectGetMinY(self.arrowImage.frame), 160, 20);
    self.textLabel.center = CGPointMake(self.textLabel.center.x, self.arrowImage.center.y);
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
        [self removeObserver:_scrollView forKeyPath:@"contentOffset"];
    }
    
    if (scrollView) {
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
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
                self.arrowImage.transform = CGAffineTransformIdentity;
            }];
            
            self.textLabel.text = @"下拉可刷新";
            UIEdgeInsets insets = self.scrollView.contentInset;
            insets.top = 0;
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
            
            self.textLabel.text = @"加载中...";
            UIEdgeInsets insets = self.scrollView.contentInset;
            insets.top = HFTriggleThrold;
            self.scrollView.contentInset = insets;
            // 触发下拉刷新的网络请求
            [self.scrollView handleRefreshBlock];
            break;
        }
    }
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
    } else if (self.refreshStatus == HFRefreshNormal && offset <= -HFRefreshHeaderHeight) {
        [self  setRefreshStatus:HFRefreshTriggle];
    } else if (self.refreshStatus != HFRefreshNormal && offset > -HFRefreshHeaderHeight) {
        [self setRefreshStatus:HFRefreshNormal];
    }
    
}

@end
