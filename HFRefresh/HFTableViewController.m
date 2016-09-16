//
//  HFTableViewController.m
//  HFRefresh
//
//  Created by 胡峰 on 16/9/16.
//  Copyright © 2016年 胡峰. All rights reserved.
//

#import "HFTableViewController.h"
#import "UIScrollView+HFRefreshPullDown.h"


@interface HFTableViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HFTableViewController

- (void)dealloc
{
    [self.tableView resetPullToRefresh];
    NSLog(@"dealloc----->>>>> %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    __weak typeof(self) weakSelf = self;
    [self.tableView addPullDownToRefreshWithHandler:^{
        NSLog(@"开始下拉刷新啦--------------");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"下拉刷新完成------------");
            [weakSelf.tableView stopToFresh];
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
    return 5;
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
