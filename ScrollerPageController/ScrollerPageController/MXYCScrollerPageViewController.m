//
//  MXYCScrollerPageViewController.m
//  ScrollerPageController
//
//  Created by 胡金友 on 16/5/18.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "MXYCScrollerPageViewController.h"
#import "MXYCScrollerHeader.h"

@interface _MXYCContentCachedDataModel : NSObject

@property (retain, nonatomic) MXYCScrollerTitleModel *cachedPageTitleModel;                // 页面的标题，也可说是页面的唯一的标识

@property (retain, nonatomic) NSMutableDictionary *cachedData;          // 缓存的页面中网络请求到的数据，只对 MXYCScrollerPageDataCacheTypeCacheData 类型有用

@property (retain, nonatomic) UIViewController *cachedViewController;   // 缓存的每次创建的视图，只对 MXYCScrollerPageDataCacheTypeCachePage 类型有用

/**
 *  @author JyHu, 16-05-20 17:05:59
 *
 *  构造方法，把一个数组转换成缓存类
 *
 *  @param titles 页面标题数组
 *
 *  @return NSArray
 *
 *  @since 6.6.4
 */
+ (NSArray *)instanceWithTitlesArray:(NSArray *)titles;

/**
 *  @author JyHu, 16-05-20 17:05:26
 *
 *  构造方法，用一个页面的标题来创建这个页面的缓存
 *
 *  @param title 页面的标题
 *
 *  @return self
 *
 *  @since 6.6.4
 */
+ (_MXYCContentCachedDataModel *)instanceWithTitleModel:(MXYCScrollerTitleModel *)titleModel;

@end

@implementation _MXYCContentCachedDataModel

+ (_MXYCContentCachedDataModel *)instanceWithTitleModel:(MXYCScrollerTitleModel *)titleModel
{
    _MXYCContentCachedDataModel *model = [[_MXYCContentCachedDataModel alloc] init];
    
    model.cachedPageTitleModel = titleModel;
    model.cachedData = [[NSMutableDictionary alloc] init];
    
    return model;
}

+ (NSArray *)instanceWithTitlesArray:(NSArray *)titles
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:titles.count];
    
    for (NSInteger i = 0; i < titles.count; i ++)
    {
        [array addObject:[_MXYCContentCachedDataModel instanceWithTitleModel:titles[i]]];
    }
    
    return array;
}

@end

@interface MXYCScrollerPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (copy, nonatomic) UIViewController * (^generateBlock)(NSInteger);                     // 创建页面的block

@property (retain, nonatomic) NSMutableArray <_MXYCContentCachedDataModel *> *cachedPageInfo;   // 缓存页面信息

/**
 *  缓存的复用页面的数据
 *  key 为复用的 identifier
 *  value 为一个可变数组，用来存放复用的视图
 */
@property (retain, nonatomic) NSMutableDictionary <NSString *, NSMutableArray *> *cachedTinyReusefulViewControllers;

@property (assign, nonatomic) NSInteger cachedCurrentIndex;             // 当前页面的索引

@property (assign, nonatomic) NSInteger cachedTempCurrentIndex;         // 暂时缓存当前的索引，只有在滚动结束以后才赋值给真正的缓存 cachedCurrentIndex

@property (copy, nonatomic) void (^scrollCompletion)(NSInteger);        // 滚动完成后的回传索引的block

@property (assign, nonatomic) MXYCScrollerPageDataCacheType cacheType;  // 缓存机制

@end

@implementation MXYCScrollerPageViewController

// 重写系统的初始化方法
- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style
        navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation
                      options:(NSDictionary<NSString *,id> *)options
{
    self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options];
    
    if (self)
    {
        self.delegate = self;
        self.dataSource = self;
        self.cachedCurrentIndex = 0;
        self.cachedTempCurrentIndex = 0;
        self.cacheType = MXYCScrollerPageDataCacheTypeNoCache;
        self.defaultShowingEmptyViewController = [[UIViewController alloc] init];
        self.defaultShowingEmptyViewController.view.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.1];
                
        self.view.translatesAutoresizingMaskIntoConstraints = NO;
                
        [self.view setAutoresizesSubviews:NO];
    }
    
    return self;
}

- (id)initPageCurlTypeWithCachType:(MXYCScrollerPageDataCacheType)type
{
    return [self initWithCachType:type];
}

// 重写系统的初始化方法
- (id)init
{
    return [self initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                   navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                 options:@{UIPageViewControllerOptionInterPageSpacingKey : @20}];
}

/**
 *  @author JyHu, 16-05-20 12:05:06
 *
 *  初始化方法
 *
 *  @param type 缓存数据的机制
 *
 *  @return self
 *
 *  @since 6.6.4
 */
- (id)initWithCachType:(MXYCScrollerPageDataCacheType)type
{
    self = [self init];
    
    if (self)
    {
        self.cacheType = type;
    }
    
    return self;
}

/**
 *  @author JyHu, 16-05-19 17:05:14
 *
 *  初始化方法
 *
 *  @param titles 每个页面的标题，注意，每页的标题需要是唯一的
 *
 *  @return self
 *
 *  @since 6.6.4
 */
- (id)initWithTitles:(NSArray <MXYCScrollerTitleModel *> *)titles
{
    self = [self init];
    
    if (self)
    {
        if (titles && titles.count > 0)
        {
            // 如果存在有效的标题数组的话，就加入缓存
            [self.cachedPageInfo addObjectsFromArray:[_MXYCContentCachedDataModel instanceWithTitlesArray:titles]];
        }
    }
    
    return self;
}

- (id)initWithTitles:(NSArray <MXYCScrollerTitleModel *> *)titles cacheType:(MXYCScrollerPageDataCacheType)type
{
    self = [self initWithTitles:titles];
    
    if (self)
    {
        self.cacheType = type;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.cachedPageInfo && self.cachedPageInfo.count > 0)
    {
        // 如果标题数组无效，在页面出现的时候展示一个空白的页面
        
        [self setViewControllers:@[self.defaultShowingEmptyViewController]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:self.transitionStyle == UIPageViewControllerTransitionStyleScroll
                      completion:nil];
    }
    
    for (UIGestureRecognizer *ges in self.gestureRecognizers)
    {
        ges.enabled = NO;
    }
    
    [self enumateScrollView:self.view];
}

- (void)enumateScrollView:(UIView *)view
{
    for (UIView *tempViw in view.subviews)
    {
        if ([tempViw isKindOfClass:[UIScrollView class]])
        {
            ((UIScrollView *)tempViw).scrollEnabled = NO;
            
            return;
        }
    }
}

#pragma mark - handle methods

// 设置创建页面的block
- (void)setupWithGenerateBlock:(UIViewController *(^)(NSInteger))generateBlock
{
    if (generateBlock)
    {
        self.generateBlock = generateBlock;
    }
    
    // 设置完成以后，滚动到第一个页面，如果没有的话，就不滚动
    [self scrollToIndex:0 needAnimation:self.transitionStyle == UIPageViewControllerTransitionStyleScroll];
}

/**
 *  @author JyHu, 16-05-20 12:05:49
 *
 *  插入一个视图，如果
 *
 *  @param title 当前页面的标题，注意不要跟之前的又重复，否则会插入失败
 *  @param index 要插入的索引，注意不要越界，否则会插入失败
 *
 *  时候加入缓存成功
 *
 *  @since 6.6.4
 */
- (BOOL)insertPageWithModel:(MXYCScrollerTitleModel *)titleModel atIndex:(NSInteger)index
{
    // 如果插入的位置有效，就执行插入的操作
    if (index < self.cachedPageInfo.count + 1 && index >= 0)
    {
        // 遍历已经缓存的数据，如果存在页面与当前要插入的页面标题一样的话就不插入直接返回
        for (_MXYCContentCachedDataModel *tempModel in self.cachedPageInfo)
        {
            if ([tempModel.cachedPageTitleModel.title isEqualToString:titleModel.title])
            {
                return NO;
            }
        }
        
        // 将当前的要插入的页面插入到缓存中
        [self.cachedPageInfo insertObject:[_MXYCContentCachedDataModel instanceWithTitleModel:titleModel] atIndex:index];
        
        // 如果当前插入的位置在当前页面的左右的话，刷新一下
        if (index == self.currentPageIndex - 1 || index == self.currentPageIndex || index == self.currentPageIndex + 1)
        {
            [self scrollToIndex:self.currentPageIndex needAnimation:NO];
        }
        
        return YES;
    }
    
    return NO;
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
- (void)updateWithTitles:(NSArray <MXYCScrollerTitleModel *> *)titles
{
    // 先清空所有的缓存数据
    [self.cachedPageInfo removeAllObjects];
    self.cachedCurrentIndex = 0;
    [self.cachedTinyReusefulViewControllers removeAllObjects];
    
    if (titles && titles.count > 0)
    {
        // 如果存在有效数据，则缓存起来，否则加载空白页面
        
        [self.cachedPageInfo addObjectsFromArray:[_MXYCContentCachedDataModel instanceWithTitlesArray:titles]];
        
        [self scrollToIndex:0 needAnimation:self.transitionStyle == UIPageViewControllerTransitionStyleScroll];
        
        if (self.scrollCompletion)
        {
            self.scrollCompletion(0);
        }
    }
    else
    {
        [self setViewControllers:@[self.defaultShowingEmptyViewController] direction:UIPageViewControllerNavigationDirectionForward animated:self.transitionStyle == UIPageViewControllerTransitionStyleScroll completion:nil];
    }
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
    if (index >= 0 && index < self.cachedPageInfo.count)
    {
        // 根据要跳转到的页面的位置来决定滚动方向
        [self setViewControllers:@[ [self viewControllerAtIndex:index] ]
                       direction:(index > self.cachedCurrentIndex ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse)
                        animated:need
                      completion:nil];
        
        self.cachedCurrentIndex = index;
    }
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
    // 拿出当前缓存标识下缓存的视图
    NSMutableArray *vcArr = self.cachedTinyReusefulViewControllers[identifier];
    
    if (self.cacheType == MXYCScrollerPageDataCacheTypeNoCache)
    {
        // 如果缓存机制为不需要缓存，则直接返回nil
        return nil;
    }
    
    // 如果是缓存数据并且缓存的有数据
    if (self.cacheType == MXYCScrollerPageDataCacheTypeCacheData && (vcArr && vcArr.count > 0 ))
    {
        for (UIViewController *vc in vcArr)
        {
            NSInteger vcIndex = [self indexOfViewController:vc];
            
            // 遍历去取需要的页面，一定要再当前索引及左右索引以外
            if (vcIndex != self.cachedCurrentIndex && vcIndex != self.cachedCurrentIndex - 1 && vcIndex != self.cachedCurrentIndex + 1)
            {
                if ([vc respondsToSelector:@selector(contentViewControllerWillBeReusedForIndex:SuperScroller:)])
                {
                    // 在复用之前通知一下这个页面将要被复用了
                    [vc contentViewControllerWillBeReusedForIndex:index SuperScroller:self];
                }
                
                return vc;
            }
        }
    }

    // 如果是缓存所有的页面，则直接存缓存中读取并返回
    if (self.cacheType == MXYCScrollerPageDataCacheTypeCachePage)
    {
        _MXYCContentCachedDataModel *model = self.cachedPageInfo[index];
        
        return model.cachedViewController;
    }
    
    return nil;
}

// 设置滚动结束后回传索引的block
- (void)scrollToIndexCompletion:(void (^)(NSInteger))completion
{
    self.scrollCompletion = completion;
}

#pragma mark - UIPageViewControllerDataSource

// UIPageViewController 代理
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    return [self scrollAbleViewController:viewController step:1];
}

// UIPageViewController 代理
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    return [self scrollAbleViewController:viewController step:-1];
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    self.cachedTempCurrentIndex = [self indexOfViewController:[pendingViewControllers firstObject]];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed)
    {
        self.cachedCurrentIndex = self.cachedTempCurrentIndex;
        
        if (self.scrollCompletion)
        {
            self.scrollCompletion(self.cachedCurrentIndex);
        }
    }
}

/**
 *  @author JyHu, 16-05-20 18:05:53
 *
 *  当页面滚动的时候预加载左右的视图
 *
 *  @param vc 当前的视图
 *  @param st 步长，也可以说是方向，向左滑加1，向右减1
 *
 *  @return 预加载的视图
 *
 *  @since 6.6.4
 */
- (UIViewController *)scrollAbleViewController:(UIViewController *)vc step:(NSInteger)st
{
    // 获取当前页面的索引
    NSInteger index = [self indexOfViewController:vc];
    
    if (index == NSNotFound)
    {
        // 如果不存在就返回nil
        return nil;
    }
    
    index += st;    // 加上索引变化的步长
    
    return (index >= 0 && index < self.cachedPageInfo.count) ? [self viewControllerAtIndex:index] : nil;
}

#pragma mark - help methods

/**
 *  @author JyHu, 16-05-20 18:05:46
 *
 *  根据视图控制器来获取它的索引
 *
 *  @param controller 要获取索引的视图控制器
 *
 *  @return 获取到的索引
 *
 *  @since 6.6.4
 */
- (NSInteger)indexOfViewController:(UIViewController *)controller
{
    for (NSInteger i = 0; i < self.cachedPageInfo.count; i ++)
    {
        // 获取缓存
        _MXYCContentCachedDataModel *model = self.cachedPageInfo[i];
        
        // 根据缓存的唯一tag匹配是否相等
        if ([model.cachedPageTitleModel.title hash] == controller.uniquePageTag)
        {
            return i;
        }
    }
    
    return NSNotFound;
}

/**
 *  @author JyHu, 16-05-20 16:05:53
 *
 *  获取指定索引位置的视图控制器
 *
 *  @param index 索引
 *
 *  @return UIViewController
 *
 *  @since 6.6.4
 */
- (UIViewController *)viewControllerAtIndex:(NSInteger)index
{
    // 只有索引有效并且设置了generateBlock才能进
    if (index >= 0 && index < self.cachedPageInfo.count && self.generateBlock)
    {
        // 创建一个viewcontroller，需要在创建的时候进行判断是否有可复用的vc
        // 见 `dequenceContentViewControllerWithIdentifier:atIndex:`
        UIViewController *viewController = self.generateBlock(index);
                
        // 获取缓存的数据
        _MXYCContentCachedDataModel *model = self.cachedPageInfo[index];
        
        // 需要在这里每次都要设置唯一的tag，否则在复用的时候会出问题
        viewController.uniquePageTag = [model.cachedPageTitleModel.title hash];
        
        // 如果是缓存数据的话，要操作的步骤
        if (self.cacheType == MXYCScrollerPageDataCacheTypeCacheData)
        {
            // 当子页面中有请求到的数据需要缓存时，需要使用这个block传递过来，并进行缓存
            [viewController setCacheMyData:^(NSString *urlKey, id data) {
                
                [model.cachedData setObject:data forKey:urlKey];
            }];
            
            // 如果可以使用这个方法
            if ([viewController respondsToSelector:@selector(triggerToRefreshWithCachedData:originalTitleData:needRequestDataFromServer:ofSuperScoller:)])
            {
                if (model.cachedData.allValues.count > 0)
                {
                    // 如果缓存的有数据，需要将数据传递过去，但是不需要再次网络请求
                    [viewController triggerToRefreshWithCachedData:model.cachedData originalTitleData:model.cachedPageTitleModel needRequestDataFromServer:NO ofSuperScoller:self];
                }
                else
                {
                    // 需要进行网络请求页面数据
                    [viewController triggerToRefreshWithCachedData:nil originalTitleData:model.cachedPageTitleModel needRequestDataFromServer:YES ofSuperScoller:self];
                }
            }
            
            // 获取当前唯一标识符下缓存的视图控制器
            NSMutableArray *vcArray = self.cachedTinyReusefulViewControllers[viewController.reUsefulIdentifier];
            
            if (!vcArray)
            {
                // 如果没有的话，就创建一个并添加到缓存中
                vcArray = [[NSMutableArray alloc] init];
                
                [self.cachedTinyReusefulViewControllers setObject:vcArray forKey:viewController.reUsefulIdentifier];
            }
            
            if (vcArray.count == 0)
            {
                // 如果缓存里没有数据的话，就直接添加进去
                [vcArray addObject:viewController];
            }
            else
            {
                NSInteger tempViewControllerIndex = NSNotFound;
                
                // 获取是否存在当前被创建的视图
                for (NSInteger vcindex = 0; vcindex < vcArray.count; vcindex ++)
                {
                    UIViewController *tempViewController = vcArray[vcindex];
                    
                    if (tempViewController.uniquePageTag == viewController.uniquePageTag)
                    {
                        tempViewControllerIndex = vcindex;
                        
                        break;
                    }
                }
                
                // 保证每类缓存的不能超过3个
                if (vcArray.count > 3)
                {
                    for (NSInteger i = vcArray.count - 1; i >= 0; i --)
                    {
                        UIViewController *vc = vcArray[i];
                        
                        NSInteger vcIndex = [self indexOfViewController:vc];
                        
                        if (vcIndex != self.cachedCurrentIndex && vcIndex != self.cachedCurrentIndex - 1 && vcIndex != self.cachedCurrentIndex + 1)
                        {
                            [vcArray removeObject:vc];
                        }
                    }
                }
                else
                {
                    if (tempViewControllerIndex == NSNotFound)
                    {
                        [vcArray addObject:viewController];
                    }
                }
            }
        }
        else if (self.cacheType == MXYCScrollerPageDataCacheTypeCachePage)
        {
            model.cachedViewController = viewController;
        }

        return viewController;
    }
    
    return nil;
}

#pragma mark - Getter

- (NSMutableArray *)cachedPageInfo
{
    if (!_cachedPageInfo)
    {
        _cachedPageInfo = [[NSMutableArray alloc] init];
    }
    
    return _cachedPageInfo;
}

- (NSMutableDictionary *)cachedTinyReusefulViewControllers
{
    if (!_cachedTinyReusefulViewControllers)
    {
        _cachedTinyReusefulViewControllers = [[NSMutableDictionary alloc] init];
    }
    
    return _cachedTinyReusefulViewControllers;
}

- (NSInteger)currentPageIndex
{
    return self.cachedCurrentIndex;
}

- (NSArray <MXYCScrollerTitleModel *> *)pageTitles
{
    if (self.cachedPageInfo.count > 0)
    {
        NSMutableArray *tempTitles = [[NSMutableArray alloc] initWithCapacity:self.cachedPageInfo.count];
        
        for (NSInteger i = 0; i < self.cachedPageInfo.count; i ++)
        {
            _MXYCContentCachedDataModel *tempModel = self.cachedPageInfo[i];
            
            [tempTitles addObject:tempModel.cachedPageTitleModel];
        }
        
        return [tempTitles copy];
    }
    
    return nil;
}

- (void)setDefaultShowingEmptyViewController:(UIViewController *)defaultShowingEmptyViewController
{
    if (defaultShowingEmptyViewController && [defaultShowingEmptyViewController isKindOfClass:[UIViewController class]])
    {
        _defaultShowingEmptyViewController = defaultShowingEmptyViewController;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
