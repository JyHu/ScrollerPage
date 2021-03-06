//
//  MXYCScrollerPageViewController.h
//  ScrollerPageController
//
//  Created by 胡金友 on 16/5/18.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+ReUseful.h"
#import "MXYCScrollerTitleModel.h"




/*
 
 分页滚动视图，可以单独拿出去用。
 
 设置了三种缓存数据的方式。
 
 页面会在设置 setupWithGenerateBlock: 后才开始布局。
 
 如果是不需要缓存，则只需要操作 MXYCScrollerPageViewController 就行了，当前的子视图中的数据存储及缓存都需要自己做。
 
 如果缓存页面，跟不缓存一个样，但是系统会把每个页面都默认的保存下来，等到再次滑动到已经显示过的页面的时候不需要再创建了，页面还会停止在之前的状态。
 
 如果缓存数据，则需要在子视图每次请求到网络数据的时候利用 cacheMyData block 将数据回传过来，用于缓存，并且需要在子视图里重写 `triggerToRefreshWithData:needRequestDataFromServer:ofSuperScoller:` 方法，这个方法是控制用来控制复用页面数据刷新用的。
 
 */





typedef NS_ENUM(NSUInteger, MXYCScrollerPageDataCacheType) {
    MXYCScrollerPageDataCacheTypeNoCache,       // 不需要缓存，每次滑动到的时候都要创建
    MXYCScrollerPageDataCacheTypeCachePage,     // 缓存所有的页面
    MXYCScrollerPageDataCacheTypeCacheData,     // 只缓存页面的数据
};

/*
 
 如何缓存异步的数据，不至于请求到得数据在页面复用的时候混乱 ？
 
 */

@interface MXYCScrollerPageViewController : UIPageViewController

#pragma mark - 初始化方法，提供了三种，还有系统的两种方法都可以使用，可以任选一种。
#pragma mark -

/**
 *  @author JyHu, 16-05-19 17:05:14
 *
 *  初始化方法
 *
 *  @param titles 每个页面的标题，注意，每页的标题必须是唯一的
 *
 *  @return self
 *
 *  @since 6.6.4
 */
- (id)initWithTitles:(NSArray <MXYCScrollerTitleModel *> *)titles;

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
- (id)initWithCachType:(MXYCScrollerPageDataCacheType)type;

/**
 *  @author JyHu, 16-05-20 12:05:45
 *
 *  初始化方法
 *
 *  @param titles 每个页面的标题，注意，每页的标题需要是唯一的
 *  @param type   缓存数据的机制，默认的是不缓存任何数据
 *
 *  @return self
 *
 *  @since 6.6.4
 */
- (id)initWithTitles:(NSArray <MXYCScrollerTitleModel *> *)titles cacheType:(MXYCScrollerPageDataCacheType)type;

- (id)initPageCurlTypeWithCachType:(MXYCScrollerPageDataCacheType)type;

#pragma mark - required methods
#pragma mark -

/**
 *  @author JyHu, 16-05-19 17:05:45
 *
 *  设置创建视图的block，这个方法必须实现
 *
 *  @param generateBlock 用来获取创建的视图的block
 *
 *  @since 6.6.4
 */
- (void)setupWithGenerateBlock:(UIViewController * (^)(NSInteger index))generateBlock;

#pragma mark - 下面的方法根据需求来选择的去调用

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
- (BOOL)insertPageWithModel:(MXYCScrollerTitleModel *)titleModel atIndex:(NSInteger)index;

/**
 *  @author JyHu, 16-05-20 12:05:43
 *
 *  使用标题来更新所有的视图，此时会清空所有的数据
 *
 *  @param titles 每个页面的标题，注意，每页的标题需要是唯一的
 *
 *  @since 6.6.4
 */
- (void)updateWithTitles:(NSArray <MXYCScrollerTitleModel *> *)titles;

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
- (void)scrollToIndex:(NSInteger)index needAnimation:(BOOL)need;

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
- (UIViewController *)dequenceContentViewControllerWithIdentifier:(NSString *)identifier atIndex:(NSInteger)index;

/**
 *  @author JyHu, 16-05-20 12:05:23
 *
 *  当滚动结束以后调用的方法，可以通知使用到的页面当前滚动到的页面的索引
 *
 *  @param completion 通知的block
 *
 *  @since 6.6.4
 */
- (void)scrollToIndexCompletion:(void (^)(NSInteger index))completion;

/**
 *  @author JyHu, 16-05-20 13:05:28
 *
 *  当没有填充的视图的时候展示的，如果不设置的话，有默认的图
 *
 *  @since 6.6.4
 */
@property (retain, nonatomic) UIViewController *defaultShowingEmptyViewController;

/**
 *  @author JyHu, 16-05-20 12:05:27
 *
 *  获取缓存的titles数据
 *
 *  @since 6.6.4
 */
@property (retain, nonatomic, readonly) NSArray <MXYCScrollerTitleModel *> *pageTitles;

/**
 *  @author JyHu, 16-05-20 12:05:55
 *
 *  获取当前页面的索引值
 *
 *  @since 6.6.4
 */
@property (assign, nonatomic, readonly) NSInteger currentPageIndex;

@end
