一个简单轻量级上下拉刷新的库。

###主要原理是使用KVO来监听scrollView的offset等属性，使用UIScrollView类别的方式引入到项目中，支持UITableView和UICollectionView。

##KVO不会崩溃的哈~~

##KVO in HFRefresh has no crash!!!

主要接口及使用方式：

```
// 添加下拉刷新
- (void)addPullDownToRefreshWithHandler:(HFRefreshBLock)refreshBlock;

// 模拟手势触发刷新
- (void)triggleToReFresh;

// 停止刷新
- (void)stopToFresh;



// 添加上拉加载更多
- (void)addLoadMoreForNextPageWithHandler:(HFLoadMoreBLock)loadMoreBlock;

// 停止加载
- (void)stopToLoadMore;

```
