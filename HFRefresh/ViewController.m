//
//  ViewController.m
//  HFRefresh
//
//  Created by 胡峰 on 16/9/11.
//  Copyright © 2016年 胡峰. All rights reserved.
//

#import "ViewController.h"
#import "HFRefresh.h"
#import "HFTableViewController.h"
#import "HFCollectionViewController.h"


@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *mutableArray;
@property (nonatomic, assign) NSInteger count; // 记录上拉加载更多的次数

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // autolayout
    [self.view addSubview:self.tableView];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    // 设置contentInset需要在添加下拉刷新前边，可随意修改以测试不同的情景
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//    self.automaticallyAdjustsScrollViewInsets = NO; // ios9好像不用设置这个
    
    // 用来兼容顶部的导航栏，实际用的时候，这一块可以放到父类的viewDidLoad里去实现
    if ([[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeRight | UIRectEdgeBottom;
    }
    
    [self addPullDownRefresh]; // 添加下拉刷新
    [self addLoadMoreRefresh]; // 添加上拉加载更多
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
        for (int i = 0; i < 10; i++) {
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

// 使用者自己决定何时添加上拉加载控件
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
#warning 此处tableView的frame必须跟控制器的view保持一致，因为有Nav导航栏，控制器的view会自适应
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64);
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
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
    
    NSString *text = @"";
    if (indexPath.row <= 3) {
        text = @"UITableView        test refresh";
    } else {
        text = @"UICollectionView      test refresh";
    }
    
    cell.textLabel.text = text;//[NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    
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
    if (indexPath.row <= 3) {
        HFTableViewController *vc = [[HFTableViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        HFCollectionViewController *vc = [[HFCollectionViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
