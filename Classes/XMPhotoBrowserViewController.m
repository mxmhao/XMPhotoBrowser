//
//  XMPhotoBrowserViewController.m
//  PhotoBrowser
//
//  Created by min on 2017/10/24.
//  Copyright © 2017年 mxm. All rights reserved.
//
//  图片浏览器

#import "XMPhotoBrowserViewController.h"
#import "XMPhotoCell.h"

typedef void(^TimerBlock)(void);

@interface NSTimer (Block)

+ (NSTimer *)xm_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(TimerBlock)block;

@end

@interface XMPhotoBrowserViewController() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching>
{
    UICollectionView *_collectionView;
    UICollectionViewFlowLayout *_layout;
    NSTimer *_timer;    //隐藏NavBar的定时器，只使用一次
    UILabel *_pageLabel;    //显示当前页码底部文字
}

@end

@implementation XMPhotoBrowserViewController

#pragma mark - 生命周期
- (void)dealloc
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

static CGFloat const kSpace = 6;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化布局
    _layout = [UICollectionViewFlowLayout new];
    _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _layout.itemSize = self.view.bounds.size;//UICollectionViewCell的size与当前view一样大
    _layout.minimumInteritemSpacing = 2 * kSpace;//设置间隔
    _layout.minimumLineSpacing = 2 * kSpace;
    _layout.sectionInset = UIEdgeInsetsMake(0, kSpace, 0, kSpace);//设置最左和最右的间隔
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:_layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.pagingEnabled = YES;
    [_collectionView registerClass:[XMPhotoCell class] forCellWithReuseIdentifier:XMPhotoCellIdentifier];
    [self.view addSubview:_collectionView];
    
    float version = [UIDevice currentDevice].systemVersion.floatValue;
    if (version >= 11.00000) {
    }
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    if (version >= 10.0000) {
        _collectionView.prefetchingEnabled = YES;
        _collectionView.prefetchDataSource = self;
    }
    
    //显示当前页码底部文字
    _pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 60, self.view.bounds.size.width, 20)];//iPhoneX
    _pageLabel.textAlignment = NSTextAlignmentCenter;
    _pageLabel.textColor = [UIColor whiteColor];
    _pageLabel.text = self.title;
    [self.view addSubview:_pageLabel];
    _pageLabel.hidden = YES;
    
    //单击手势，显示或隐藏NavBar
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNavBar)];
    [self.view addGestureRecognizer:tapGes];
    
    __weak typeof(self) this = self;
    //刚显示此视图，给一个默认隐藏NavBar的操作
    _timer = [NSTimer xm_scheduledTimerWithTimeInterval:2.0 repeats:NO block:^{
        [this toggleNavBar];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //当vc被Dismissed或者pop时，要取消所有的网络请求
    if (self.beingDismissed || self.isMovingFromParentViewController) {
        [_delegate didRemoveFromSuperViewController];
    }
}

- (void)viewDidLayoutSubviews
{//当前方法调用时self.view.bounds已经是最新的rect了，所以下面直接使用
    [super viewDidLayoutSubviews];
    [_layout invalidateLayout];//使以前的布局状态失效，不然旋转屏幕时会有警告爆出
    //屏幕旋转后要调整试图的位置
    CGRect bounds = self.view.bounds;
    _layout.itemSize = bounds.size;//这里设置后会重新有效
    _pageLabel.frame = CGRectMake(0, bounds.size.height - 60, bounds.size.width, 20);//iPhoneX
    bounds.size.width += 2 * kSpace;
    bounds.origin.x = -kSpace;
    _collectionView.frame = bounds;
    
//    [_collectionView reloadData];
    //重新滚动到当前选择的图片位置，因为重新布局后图片显示的位置可能不正确
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

#pragma mark - 事件方法
//屏幕单击，隐藏或显示NavBar
- (void)toggleNavBar
{
    if (self.navigationController.isNavigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        _pageLabel.hidden = YES;
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        _pageLabel.hidden = NO;
        if (nil != _timer) {//定时器没失效的时，要使其失效
            [_timer invalidate];
            _timer = nil;
        }
    }
}

#pragma mark - UICollectionView的代理和数据源方法
//代理方法
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    XMPhotoCell *pcell = (XMPhotoCell *)cell;
    pcell.scrollView.zoomScale = 1;//每次重新显示前，要还原到未缩放的状态
}
//减速完成
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //显示当前索引
    NSInteger index = _collectionView.indexPathsForVisibleItems.firstObject.item;
    if (index == _currentIndex) {
        return;
    }
    _currentIndex = index;
    [_delegate stayAtIndex:index];
    
//    NSString *text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)_currentIndex+1, (unsigned long)_imageURLs.count];
//    _pageLabel.text = text;
//    self.title = text;
}

//数据源方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_delegate numberOfItems];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XMPhotoCell *cell = (XMPhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:XMPhotoCellIdentifier forIndexPath:indexPath];
    [_delegate imageView:cell.imageView atIndex:indexPath.item];
    return cell;
}

//预加载，有iOS11系统bug，从第三个cell开始，预加载还没完成，就开始设置cell了，导致预加载和设置的请求重复了
- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        [indexSet addIndex:indexPath.item];
    }
    [_delegate prefetchItemsAtIndexSet:indexSet];
}

@end

@implementation NSTimer (Block)

+ (NSTimer *)xm_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(TimerBlock)block
{
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(_timerBlockInvoke:) userInfo:[block copy] repeats:repeats];
}

+ (void)_timerBlockInvoke:(NSTimer *)timer
{
    TimerBlock block = timer.userInfo;
    if (block) {
        block();
    }
}

@end
