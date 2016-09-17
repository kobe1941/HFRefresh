//
//  ViewController.m
//  HFRefresh
//
//  Created by 胡峰 on 16/9/11.
//  Copyright © 2016年 胡峰. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+HFRefreshPullDown.h"
#import "HFTableViewController.h"
#import "HFCollectionViewController.h"
#import "UIScrollView+HFRefreshLoadMore.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.tableView];
    
//    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    __weak typeof(self) weakSelf = self;
//    [self.tableView addPullDownToRefreshWithHandler:^{
//        NSLog(@"开始下拉刷新啦--------------");
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            NSLog(@"下拉刷新完成------------");
//            [weakSelf.tableView stopToFresh];
//        });
//    }];
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.tableView triggleToReFresh];
//    });
    
    
    [self.tableView addLoadMoreForNextPageWithHandler:^{
        NSLog(@"开始上拉加载更多---------");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView stopToLoadMore];
            NSLog(@"上拉加载更多完成---------");
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 18;
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
        text = @"tableView test refresh";
    } else {
        text = @"collectionView test refresh";
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
