//
//  HFTableViewController.m
//  HFRefresh
//
//  Created by 胡峰 on 16/9/16.
//  Copyright © 2016年 胡峰. All rights reserved.
//

#import "HFTableViewController.h"
#import "HFRefresh.h"

@interface HFTableViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *mutableArray;
@property (nonatomic, assign) NSInteger count; // 记录上拉加载更多的次数

@end

@implementation HFTableViewController

- (void)dealloc
{
//    [self.tableView resetPullToRefresh];
//    [self.tableView resetLoadMoreForNextPage];
    NSLog(@"dealloc----->>>>> %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    // 设置contentInset需要在添加下拉刷新之前
//    self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
    
    if ([[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    }
    
    [self addPullDownRefresh];
    [self addLoadMoreRefresh];
    [self.tableView hf_triggleToRefresh]; // 立即触发下拉刷新
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addPullDownRefresh
{
    __weak typeof(self) weakSelf = self;
    [self.tableView hf_addPullDownToRefreshWithHandler:^{
        NSLog(@"开始下拉刷新啦--------------");
        [weakSelf.mutableArray removeAllObjects];
        for (int i = 0; i < 15; i++) {
            [weakSelf.mutableArray addObject:@"HFRefresh"];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"下拉刷新完成------------");
            [weakSelf.tableView reloadData];
            [weakSelf.tableView hf_stopRefresh];
            [weakSelf addLoadMoreRefresh];
            weakSelf.count = 0;
        });
    }];
}

- (void)addLoadMoreRefresh
{
    __weak typeof(self) weakSelf = self;
    [self.tableView hf_addLoadMoreForNextPageWithHandler:^{
        NSLog(@"开始上拉加载更多---------");
        [weakSelf.mutableArray addObjectsFromArray:[[weakSelf.mutableArray subarrayWithRange:NSMakeRange(0, 5)] copy]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"上拉加载更多完成---------");
            weakSelf.count++;
            if (weakSelf.count >= 3) {
                [weakSelf.tableView hf_loadMoreNoMore];
            } else {
                [weakSelf.tableView hf_stopLoadMore];
                [weakSelf.tableView reloadData];
            }
        });
    }];
}

#pragma mark - getter
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        _tableView.backgroundColor = [UIColor redColor];
    }
    
    return _tableView;
}

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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mutableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
