一个简单轻量级上下拉刷新的库。


主要接口及使用方式：

```
// 添加下拉刷新
- (void)hf_addPullDownToRefreshWithHandler:(HFRefreshBLock)refreshBlock;

// 模拟手势触发刷新
- (void)hf_triggleToRefresh;

// 停止刷新
- (void)hf_stopRefresh;




// 添加上拉加载更多
- (void)hf_addLoadMoreForNextPageWithHandler:(HFLoadMoreBLock)loadMoreBlock;

// 停止加载
- (void)hf_stopLoadMore;

// 无更多数据，去掉上拉加载更多控件，下拉刷新时可再次添加
- (void)hf_loadMoreNoMore;

```


仓库公布后有部分同学提了一些需求，整理后采纳了其中一些，故在master的基础上新开两个分支：

①`dev_loadmore_no_arrow`，该分支主要是将上拉加载更多的箭头图片去掉了，同时调整了loading控件的位置；

②`dev_loadmore_suit`，该分支将上拉加载更多的显示做到了自适应，只有当scrollView的contentSize+footer的自身高度>=scrollView本身frame的高度时，才显示上拉加载更多控件，同时上拉的功能才打开，否则隐藏该控件，并关闭上拉加载的功能。

有需要的同学可以根据自己的具体情况选择分支。

###master分支的效果见下图：

上拉加载更多：

![上拉加载](/readmeImage/loadmore.gif)

下拉刷新

![下拉刷新](/readmeImage/pullrefresh.gif)


上下拉一起

![上下拉一起](/readmeImage/refreshAndLoadMore.gif)


####默认的上拉加载会有箭头图片，如果不想要，可以直接注释掉。添加箭头可以更明显的看到控件状态的切换。

主要原理是使用KVO来监听scrollView的offset等属性，使用UIScrollView类别的方式引入到项目中，支持UITableView和UICollectionView。

##没有KVO 崩溃 和循环引用 ！！

##there is no KVO crash and no retain circle!!!



主要参考了`SVPullToRefresh`和`MJRefresh`，向大神们致敬！


