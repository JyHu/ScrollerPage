//
//  MXYCScrollerPageViewController.m
//  ScrollerPageController
//
//  Created by 胡金友 on 16/5/18.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "MXYCScrollerPageViewController.h"
#import "MXYCScrollerHeader.h"
#import "MXYCEmptyContentViewController.h"

@interface _MXYCContentCachedDataModel : NSObject

@property (retain, nonatomic) NSString *pageTitle;

@property (retain, nonatomic) NSMutableDictionary *cachedData;

@property (retain, nonatomic) UIViewController *cachedViewController;

+ (NSArray *)instanceWithTitlesArray:(NSArray *)titles;

+ (_MXYCContentCachedDataModel *)instanceWithTitle:(NSString *)title;

@end

@implementation _MXYCContentCachedDataModel

+ (_MXYCContentCachedDataModel *)instanceWithTitle:(NSString *)title
{
    _MXYCContentCachedDataModel *model = [[_MXYCContentCachedDataModel alloc] init];
    
    model.pageTitle = title;
    model.cachedData = [[NSMutableDictionary alloc] init];
    
    return model;
}

+ (NSArray *)instanceWithTitlesArray:(NSArray *)titles
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:titles.count];
    
    for (NSInteger i = 0; i < titles.count; i ++)
    {
        [array addObject:[_MXYCContentCachedDataModel instanceWithTitle:titles[i]]];
    }
    
    return array;
}

@end

@interface MXYCScrollerPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (copy, nonatomic) UIViewController * (^generateBlock)(NSInteger);

@property (retain, nonatomic) NSMutableArray *cachedPageInfo;

@property (retain, nonatomic) NSMutableDictionary *cachedTinyReusefulViewControllers;

@property (assign, nonatomic) NSInteger cachedCurrentIndex;

@property (retain, nonatomic) MXYCScrollerHeader *scrollHeader;

@property (copy, nonatomic) void (^scrollCompletion)(NSInteger);

@property (assign, nonatomic) MXYCScrollerPageDataCacheType cacheType;

//@property (retain, nonatomic) NSMutableDictionary *cachedAllReusefulViewControllers;

@end

@implementation MXYCScrollerPageViewController

- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary<NSString *,id> *)options
{
    self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options];
    
    if (self)
    {
        self.delegate = self;
        self.dataSource = self;
        self.cachedCurrentIndex = 0;
        self.cacheType = MXYCScrollerPageDataCacheTypeNoCache;
        self.defaultShowingEmptyViewController = [[MXYCEmptyContentViewController alloc] init];
    }
    
    return self;
}

- (id)init
{
    return [self initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                   navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                 options:@{UIPageViewControllerOptionInterPageSpacingKey : @20}];
}

- (id)initWithCachType:(MXYCScrollerPageDataCacheType)type
{
    self = [self init];
    
    if (self)
    {
        self.cacheType = type;
    }
    
    return self;
}

- (id)initWithTitles:(NSArray *)titles
{
    self = [self init];
    
    if (self)
    {
        if (titles && titles.count > 0)
        {
            [self.cachedPageInfo addObjectsFromArray:[_MXYCContentCachedDataModel instanceWithTitlesArray:titles]];
        }
        else
        {
            [self setViewControllers:@[self.defaultShowingEmptyViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        }
    }
    
    return self;
}

- (id)initWithTitles:(NSArray *)titles cacheType:(MXYCScrollerPageDataCacheType)type
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
    
}

#pragma mark - handle methods

- (void)setupWithGenerateBlock:(UIViewController *(^)(NSInteger))generateBlock
{
    if (generateBlock)
    {
        self.generateBlock = generateBlock;
    }
    
    [self scrollToIndex:0];
}

- (BOOL)insertPageWithTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (index < self.cachedPageInfo.count + 1 && index >= 0)
    {
        for (_MXYCContentCachedDataModel *tempModel in self.cachedPageInfo)
        {
            if ([tempModel.pageTitle isEqualToString:title])
            {
                return NO;
            }
        }
        
        [self.cachedPageInfo insertObject:[_MXYCContentCachedDataModel instanceWithTitle:title] atIndex:index];
        
        if (index == self.cachedCurrentIndex)
        {
            [self scrollToIndex:index];
        }
        
        return YES;
    }
    
    return NO;
}

- (void)updateWithTitles:(NSArray *)titles
{
    [self.cachedPageInfo removeAllObjects];
    self.cachedCurrentIndex = 0;
    [self.cachedTinyReusefulViewControllers removeAllObjects];
    
    if (titles && titles.count > 0)
    {
        [self.cachedPageInfo addObjectsFromArray:[_MXYCContentCachedDataModel instanceWithTitlesArray:titles]];
        
        [self scrollToIndex:0];
    }
    else
    {
        [self setViewControllers:@[self.defaultShowingEmptyViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
}

- (void)scrollToIndex:(NSInteger)index
{
    if (index >= 0 && index < self.cachedPageInfo.count)
    {
        [self setViewControllers:@[
                                   [self viewControllerAtIndex:index]
                                   ]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:YES
                      completion:nil];
    }
}

- (UIViewController *)dequenceContentViewControllerWithIdentifier:(NSString *)identifier atIndex:(NSInteger)index
{
    NSMutableArray *vcArr = self.cachedTinyReusefulViewControllers[identifier];
    
    if (self.cacheType == MXYCScrollerPageDataCacheTypeNoCache)
    {
        return nil;
    }
    
    if (self.cacheType == MXYCScrollerPageDataCacheTypeCacheData && (vcArr && vcArr.count > 0 ))
    {
        for (UIViewController *vc in vcArr)
        {
            if ([self indexOfViewController:vc] != self.cachedCurrentIndex)
            {
                if (vc.reverseTriggerDelegate)
                {
                    [vc.reverseTriggerDelegate contentViewControllerWillBeReusedForIndex:index SuperScroller:self];
                }
                
                return vc;
            }
        }
    }

    if (self.cacheType == MXYCScrollerPageDataCacheTypeCachePage)
    {
        _MXYCContentCachedDataModel *model = self.cachedPageInfo[index];
        
        return model.cachedViewController;
    }
    
    return nil;
}

- (void)scrollToIndexCompletion:(void (^)(NSInteger))completion
{
    self.scrollCompletion = completion;
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [self indexOfViewController:viewController];
    
    NSLog(@"index of after , and current is %zd", index);
    
    if (index == NSNotFound)
    {
        NSLog(@"after");
        
        return nil;
    }
    
    if (self.scrollCompletion)
    {
        self.scrollCompletion(index);
    }
    
    self.cachedCurrentIndex = index;
    
    index ++;
    
    if (index == self.cachedPageInfo.count)
    {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [self indexOfViewController:viewController];
    
    NSLog(@"index of befor , and current is %zd", index);
    
    if (index == NSNotFound)
    {
        NSLog(@"before");
        
        return nil;
    }
    
    if (self.scrollCompletion)
    {
        self.scrollCompletion(index);
    }
    
    self.cachedCurrentIndex = index;
    
    if (index == 0)
    {
        return nil;
    }
    
    index --;
    
    return [self viewControllerAtIndex:index];
}

#pragma mark - help methods

- (NSInteger)indexOfViewController:(UIViewController *)controller
{
    for (NSInteger i = 0; i < self.cachedPageInfo.count; i ++)
    {
        _MXYCContentCachedDataModel *model = self.cachedPageInfo[i];
        
        if ([model.pageTitle hash] == controller.uniquePageTag)
        {
            NSLog(@"page title : %@", model.pageTitle);
            
            return i;
        }
    }
    
    return NSNotFound;
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index
{
    if (index >= 0 && index < self.cachedPageInfo.count && self.generateBlock)
    {
        UIViewController *viewController = self.generateBlock(index);
        
        _MXYCContentCachedDataModel *model = self.cachedPageInfo[index];
        
        viewController.uniquePageTag = [model.pageTitle hash];
        
        if (self.cacheType == MXYCScrollerPageDataCacheTypeCacheData)
        {
            [viewController setCacheMyData:^(NSString *urlKey, id data) {
                
                [model.cachedData setObject:data forKey:urlKey];
            }];
            
            if (viewController.reverseTriggerDelegate)
            {
                if (model.cachedData.allValues.count > 0)
                {
                    [viewController.reverseTriggerDelegate triggerToRefreshWithData:model.cachedData needRequestDataFromServer:NO ofSuperScoller:self];
                }
                else
                {
                    [viewController.reverseTriggerDelegate triggerToRefreshWithData:nil needRequestDataFromServer:YES ofSuperScoller:self];
                }
            }
            
            NSMutableArray *vcArray = self.cachedTinyReusefulViewControllers[viewController.reUsefulIdentifier];
            
            if (!vcArray)
            {
                vcArray = [[NSMutableArray alloc] init];
                
                [self.cachedTinyReusefulViewControllers setObject:vcArray forKey:viewController.reUsefulIdentifier];
            }
            
            if (vcArray.count == 0)
            {
                [vcArray addObject:viewController];
            }
            else if (![vcArray containsObject:viewController])
            {
                for (NSInteger i = vcArray.count - 1; i >= 0; i --)
                {
                    UIViewController *vc = vcArray[i];
                    
                    if ([self indexOfViewController:vc] != self.cachedCurrentIndex)
                    {
                        [vcArray removeObject:vc];
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

- (MXYCScrollerHeader *)scrollHeader
{
    if (_scrollHeader)
    {
        _scrollHeader = [[MXYCScrollerHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    }
    
    return _scrollHeader;
}

- (NSInteger)currentPageIndex
{
    return self.cachedCurrentIndex;
}

- (NSArray <NSString *> *)pageTitles
{
    if (self.cachedPageInfo.count > 0)
    {
        NSMutableArray *tempTitles = [[NSMutableArray alloc] initWithCapacity:self.cachedPageInfo.count];
        
        for (NSInteger i = 0; i < self.cachedPageInfo.count; i ++)
        {
            _MXYCContentCachedDataModel *tempModel = self.cachedPageInfo[i];
            
            [tempTitles addObject:tempModel.pageTitle];
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
