//
//  MXYCPageViewController.m
//  ScrollerPageController
//
//  Created by 胡金友 on 16/5/23.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "MXYCPageViewController.h"

@interface MXYCPageViewController ()

@property (retain, nonatomic) MXYCScrollerHeader *scrollerHeader;   // 顶部的标签视图

@property (copy, nonatomic) void (^scrolCompletion)(NSInteger);     // 下面的滚动视图滚动结束以后的回传索引

@end

@implementation MXYCPageViewController

#pragma mark - 将这个组合类的初始化方法跟滚动视图的初始化方法都相接，省的外部在用的时候出现多层引用
#pragma mark -

- (id)initPageCurlTypeWithCachType:(MXYCScrollerPageDataCacheType)type
{
    self = [super init];
    
    if (self)
    {
        self.scrollerPageVC = [[MXYCScrollerPageViewController alloc] initPageCurlTypeWithCachType:type];
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.scrollerPageVC = [[MXYCScrollerPageViewController alloc] init];
    }
    
    return self;
}

- (id)initWithTitles:(NSArray *)titles
{
    self = [super init];
    
    if (self)
    {
        self.scrollerPageVC = [[MXYCScrollerPageViewController alloc] initWithTitles:titles];
    }
    
    return self;
}

- (id)initWithCachType:(MXYCScrollerPageDataCacheType)type
{
    self = [super init];
    
    if (self)
    {
        self.scrollerPageVC = [[MXYCScrollerPageViewController alloc] initWithCachType:type];
    }
    
    return self;
}

- (id)initWithTitles:(NSArray *)titles cacheType:(MXYCScrollerPageDataCacheType)type
{
    self = [super init];
    
    if (self)
    {
        self.scrollerPageVC = [[MXYCScrollerPageViewController alloc] initWithTitles:titles cacheType:type];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 添加头部视图
    self.scrollerHeader = [[MXYCScrollerHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    self.scrollerHeader.backgroundColor = [UIColor blackColor];
    [self.scrollerHeader selectTitleComption:^(NSInteger index) {
        [self.scrollerPageVC scrollToIndex:index needAnimation:YES];
        if (self.scrolCompletion)
        {
            self.scrolCompletion(index);
        }
    }];
    [self.scrollerHeader setupTitles:self.scrollerPageVC.pageTitles];
    [self.view addSubview:self.scrollerHeader];
    
    
    // 添加滚动视图
    self.scrollerPageVC.view.frame = self.view.bounds;
    self.scrollerPageVC.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
                                                UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.scrollerPageVC.view.backgroundColor = [UIColor greenColor];
    [self addChildViewController:self.scrollerPageVC];
    [self.view addSubview:self.scrollerPageVC.view];
    
    [self.view bringSubviewToFront:self.scrollerHeader];
}

- (void)setupWithGenerateBlock:(UIViewController * (^)(NSInteger index))generateBlock
{
    [self.scrollerPageVC setupWithGenerateBlock:generateBlock];
}

- (BOOL)insertPageWithModel:(MXYCScrollerTitleModel *)titleModel atIndex:(NSInteger)index
{
    [self.scrollerHeader insertHeaderTitleModel:titleModel atIndex:index];
    return [self.scrollerPageVC insertPageWithModel:titleModel atIndex:index];
}

/**
 *  @author JyHu, 16-05-20 12:05:43
 *
 *  使用标题来更新所有的视图，此时会清空所有的数据
 *
 *  @param titles 每个页面的标题，注意，每页的标题需要是唯一的
 *
 *  @since 6.6.4
 */
- (void)updateWithTitles:(NSArray *)titles
{
    [self.scrollerPageVC updateWithTitles:titles];
    [self.scrollerHeader setupTitles:titles];
    [self.scrollerHeader scrollToIndex:0];
}

/**
 *  @author JyHu, 16-05-20 12:05:40
 *
 *  滚动到指定的页面
 *
 *  @param index 页面的索引
 *  @param need  是否需要滚动的动画
 *
 *  @since 6.6.4
 */
- (void)scrollToIndex:(NSInteger)index needAnimation:(BOOL)need
{
    [self.scrollerPageVC scrollToIndex:index needAnimation:need];
    [self.scrollerHeader scrollToIndex:index];
}

/**
 *  @author JyHu, 16-05-20 12:05:35
 *
 *  获取被复用的页面
 *
 *  @param identifier 页面的唯一标识，如果缓存机制是只缓存页面的话，这个参数可以不设置
 *  @param index      要加载的页面的索引
 *
 *  @return 复用的页面
 *
 *  @since 6.6.4
 */
- (UIViewController *)dequenceContentViewControllerWithIdentifier:(NSString *)identifier atIndex:(NSInteger)index
{
    return [self.scrollerPageVC dequenceContentViewControllerWithIdentifier:identifier atIndex:index];
}

- (void)scrollToIndexCompletion:(void (^)(NSInteger index))completion
{
    self.scrolCompletion = completion;
    
    [self.scrollerPageVC scrollToIndexCompletion:^(NSInteger ind) {
        [self.scrollerHeader scrollToIndex:ind];
        if (completion)
        {
            completion(ind);
        }
    }];
}

- (void)setDefaultShowingEmptyViewController:(UIViewController *)defaultShowingEmptyViewController
{
    self.scrollerPageVC.defaultShowingEmptyViewController = defaultShowingEmptyViewController;
}

- (UIViewController *)defaultShowingEmptyViewController
{
    return self.scrollerPageVC.defaultShowingEmptyViewController;
}

- (NSArray <MXYCScrollerTitleModel *> *)pageTitles
{
    return self.scrollerPageVC.pageTitles;
}

- (NSInteger)currentPageIndex
{
    return self.scrollerPageVC.currentPageIndex;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
