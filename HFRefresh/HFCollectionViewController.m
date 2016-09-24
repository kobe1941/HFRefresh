//
//  HFCollectionViewController.m
//  HFRefresh
//
//  Created by 胡峰 on 16/9/16.
//  Copyright © 2016年 胡峰. All rights reserved.
//

#import "HFCollectionViewController.h"
#import "HFRefresh.h"

static NSString *cellID = @"cellID";

@interface HFCollectionViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *mutableArray;
@property (nonatomic, assign) NSInteger count; // 记录上拉加载更多的次数

@end

@implementation HFCollectionViewController

- (void)dealloc
{
//    [self.collectionView resetPullToRefresh];
//    [self.collectionView resetLoadMoreForNextPage];
    NSLog(@"dealloc----->>>>> %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.collectionView];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    // 设置contentInset需要在添加下拉刷新之前
//    self.collectionView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);

    if ([[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    }
    
    [self addPullDownRefresh];
    [self addLoadMoreRefresh];
    [self.collectionView hf_triggleToRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addPullDownRefresh
{
    __weak typeof(self) weakSelf = self;
    [self.collectionView hf_addPullDownToRefreshWithHandler:^{
        NSLog(@"开始下拉刷新啦--------------");
        [weakSelf.mutableArray removeAllObjects];
        for (int i = 0; i < 10; i++) {
            [weakSelf.mutableArray addObject:@"HFRefresh"];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"下拉刷新完成------------");
            [weakSelf.collectionView reloadData];
            [weakSelf.collectionView hf_stopRefresh];
            [weakSelf addLoadMoreRefresh];
            weakSelf.count = 0;
            
        });
    }];
}

- (void)addLoadMoreRefresh
{
    __weak typeof(self) weakSelf = self;
    [self.collectionView hf_addLoadMoreForNextPageWithHandler:^{
        NSLog(@"开始上拉加载更多---------");
        [weakSelf.mutableArray addObjectsFromArray:[[weakSelf.mutableArray subarrayWithRange:NSMakeRange(0, 8)] copy]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"上拉加载更多完成---------");
            weakSelf.count++;
            if (weakSelf.count >= 4) {
                [weakSelf.collectionView hf_loadMoreNoMore];
            } else {
                [weakSelf.collectionView hf_stopLoadMore];
                [weakSelf.collectionView reloadData];
            }
        });
    }];
}

#pragma mark - getter
- (NSMutableArray *)mutableArray
{
    if (!_mutableArray) {
        _mutableArray = [NSMutableArray array];
        for (int i = 0; i < 10; i++) {
            [_mutableArray addObject:@"HFRefresh"];
        }
    }
    
    return _mutableArray;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        //设置布局方向为垂直流布局
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        //设置每个item的大小为100*100
        layout.itemSize = CGSizeMake(100, 100);
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
    }
    
    return _collectionView;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.mutableArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    if (indexPath.row <= 3) {
        cell.backgroundColor = [UIColor blackColor];
    } else {
        cell.backgroundColor = [UIColor purpleColor];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(80, 80);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.f;
}

#pragma mark - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// 点击高亮
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor greenColor];
}

//返回这个UICollectionView是否可以被选择
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
}

@end
