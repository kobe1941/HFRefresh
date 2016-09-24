//
//  HFRefreshFootor.m
//  HFRefresh
//
//  Created by 胡峰 on 16/9/17.
//  Copyright © 2016年 胡峰. All rights reserved.
//

#import "HFRefreshFootor.h"


const CGFloat HFRefreshFooterHeight = 60;
const CGFloat HFTriggleFooterThrold = HFRefreshFooterHeight;

@interface HFRefreshFootor ()

@property (nonatomic, strong) UIImageView *arrowImage;
@property (nonatomic, strong) UIActivityIndicatorView *loadMoreIndicator;
@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, assign) HFLoadMoreStatus laodMoreStatus;
// scrollView最初的偏移量
@property (nonatomic, assign) CGFloat originInsetTop;
@property (nonatomic, assign) CGFloat originInsetBottom;
@property (nonatomic, copy) LoadMoreEventBlock loadMoreBLock;

@end

@implementation HFRefreshFootor

- (void)dealloc
{
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
    [self addSubview:self.loadMoreIndicator];
    [self addSubview:self.textLabel];
    
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:160]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:24]];
    
    self.arrowImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arrowImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.textLabel attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arrowImage attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:60]];
    
    self.loadMoreIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.loadMoreIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.arrowImage attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.loadMoreIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.arrowImage attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self setLoadMoreStatus:HFLoadMoreNormal];
}

#pragma mark - getter && setter
- (UIImageView *)arrowImage
{
    if (!_arrowImage) {
        _arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refreshArrow"]];
    }
    return _arrowImage;
}

- (UIActivityIndicatorView *)loadMoreIndicator
{
    if (!_loadMoreIndicator) {
        _loadMoreIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return _loadMoreIndicator;
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
        [_scrollView removeObserver:self forKeyPath:@"contentSize"];
    }
    
    if (scrollView) {
        // 如有在scrollView初始化之后才去设置insets的场景，则可以把contentInsets也加入观察
        // 用于更新originInsetTop和originInsetBottom两个值
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];

        // 保存scrolView最初的inset
        self.originInsetTop = scrollView.contentInset.top;
        self.originInsetBottom = scrollView.contentInset.bottom;
    }
    _scrollView = scrollView;
}


- (void)setLoadMoreStatus:(HFLoadMoreStatus)loadMoreStatus;
{
    _laodMoreStatus = loadMoreStatus;
    switch (loadMoreStatus) {
        case HFLoadMoreNormal: {
            self.loadMoreIndicator.hidden = YES;
            [self.loadMoreIndicator stopAnimating];
            self.arrowImage.hidden = NO;
            // 箭头翻转动画
            [UIView animateWithDuration:0.2 animations:^{
                self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI*2);
            }];
            
            self.textLabel.text = @"上拉加载更多";
            UIEdgeInsets insets = self.scrollView.contentInset;
            insets.top = self.originInsetTop;
            insets.bottom = self.originInsetBottom;
            
            [UIView animateWithDuration:0.2 animations:^{
                self.scrollView.contentInset = insets;
            }];
            break;
        }
        case HFLoadMoreTriggle: {
            self.loadMoreIndicator.hidden = YES;
            [self.loadMoreIndicator stopAnimating];
            self.arrowImage.hidden = NO;
            // 箭头翻转动画
            [UIView animateWithDuration:0.2 animations:^{
                self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
            }];
            
            self.textLabel.text = @"释放立即加载";
            break;
        }
        case HFLoadMoreLoading: {
            self.loadMoreIndicator.hidden = NO;
            [self.loadMoreIndicator startAnimating];
            self.arrowImage.hidden = YES;
            self.arrowImage.transform = CGAffineTransformMakeRotation(M_PI*2);
            self.textLabel.text = @"加载中...";
            
            UIEdgeInsets insets = self.scrollView.contentInset;
            insets.bottom = self.originInsetBottom + HFTriggleFooterThrold;
            if (self.scrollView.contentSize.height < self.scrollView.frame.size.height) {
                // 针对contentSize较小时做兼容
                insets.top -= HFTriggleFooterThrold;
            }
            
            [UIView animateWithDuration:0.2 animations:^{
                self.scrollView.contentInset = insets;
            }];

            // 触发下拉刷新的网络请求
            if (self.loadMoreBLock) {
                self.loadMoreBLock();
            }
            break;
        }
    }
}

- (void)setLoadMoreEventBlock:(LoadMoreEventBlock)loadMoreblock
{
    self.loadMoreBLock = loadMoreblock;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    // newSuperview存在且如果不是UIScrollView，直接返回。移除的时候newSuperview是nil
    if (newSuperview && ![newSuperview isKindOfClass:[UIScrollView class]]) {
        return;
    }
    
    UIScrollView *scrollView = (UIScrollView *)newSuperview;
    // 移除KVO，此处不能用_scrollView
    [self.superview removeObserver:self forKeyPath:@"contentOffset"];
    [self.superview removeObserver:self forKeyPath:@"contentSize"];
    
    if (newSuperview) { // 新的父控件
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        // 保存scrolView最初的inset
        self.originInsetTop = scrollView.contentInset.top;
        self.originInsetBottom = scrollView.contentInset.bottom;
    }
    
    _scrollView = scrollView;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([object isKindOfClass:[UIScrollView class]]) {
        if ([keyPath isEqualToString:@"contentOffset"]) {
            CGPoint contentOffset = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
            [self adjustRefreshStatusWithOffset:contentOffset.y];
        } else if ([keyPath isEqualToString:@"contentSize"]) {
            CGSize contentSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
            CGRect tempFrame = self.frame;
            
            CGFloat bottomY = CGRectGetHeight(self.scrollView.frame) > contentSize.height ? CGRectGetHeight(self.scrollView.frame) : contentSize.height;
            if (self.scrollView.contentSize.height < self.scrollView.frame.size.height) {
                bottomY -= self.originInsetTop;
            } else {
                bottomY += self.originInsetBottom;
            }
            tempFrame.origin.y = bottomY;
            
            self.frame = tempFrame;
        }
    }
}

- (void)adjustRefreshStatusWithOffset:(CGFloat)offset
{
    // 只要是触发状态且手指松开，则进入刷新状态，不用关注此时的offset，因为KVO的offset变化的太快导致不准确
    // 否则根据offset来判断会有误差
    CGFloat scrollHeight = self.scrollView.frame.size.height;
    CGFloat contentHeight = self.scrollView.contentSize.height;
    CGFloat maxHeight = contentHeight >= scrollHeight ? contentHeight : scrollHeight;
    
    CGFloat fullHeight = offset + scrollHeight; //+ self.originInsetTop;
    CGFloat throld = maxHeight + HFRefreshFooterHeight;//+ self.originInsetTop;
    if (self.scrollView.contentSize.height < self.scrollView.frame.size.height) {
        throld -= self.originInsetTop;
    } else {
        throld += self.originInsetBottom;
    }
    
//    NSLog(@"offset=%f, throld=%f, top=%f, originTop=%f, bottom=%f, originBottom=%f", offset, throld, self.scrollView.contentInset.top, self.originInsetTop, self.scrollView.contentInset.bottom, self.originInsetBottom);
//    NSLog(@"fullHeight=%f, throld=%f, self.frame=%@", fullHeight, throld, NSStringFromCGRect(self.frame));
    if (self.laodMoreStatus == HFLoadMoreTriggle && !self.scrollView.isDragging) {
        [self setLoadMoreStatus:HFLoadMoreLoading];
    } else if ((self.laodMoreStatus == HFLoadMoreNormal) && (fullHeight > throld)) {
        [self  setLoadMoreStatus:HFLoadMoreTriggle];
    } else if ((self.laodMoreStatus != HFLoadMoreNormal) && (fullHeight <= throld)) {
        if (self.laodMoreStatus != HFLoadMoreLoading) { // 排除掉正在刷新时，手势滑动取消刷新动画的情况
            [self setLoadMoreStatus:HFLoadMoreNormal];
        }
    }
}


@end
