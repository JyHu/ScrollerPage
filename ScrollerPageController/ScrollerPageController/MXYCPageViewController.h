//
//  MXYCPageViewController.h
//  ScrollerPageController
//
//  Created by 胡金友 on 16/5/23.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXYCScrollerPageViewController.h"
#import "MXYCScrollerHeader.h"


/*
 
 这个类只是用作桥接的作用，将下部的滚动视图和上部的标签视图进行组合，并进行方法的传递，没有独立的方法。
 
 下部的滚动视图单独拿出来也可以使用。
 
 */


@interface MXYCPageViewController : UIViewController

/**
 *  @author JyHu, 16-05-23 16:05:34
 *
 *  滚动视图
 *
 *  @since 6.6.4
 */
@property (retain, nonatomic) MXYCScrollerPageViewController *scrollerPageVC;

#pragma mark - 初始化方法，提供了三种，还有系统的两种方法都可以使用，可以任选一种。
#pragma mark -

- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style
        navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation
                      options:(NSDictionary<NSString *,id> *)options;

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

//@property (assign, nonatomic) CGFloat correctHeight;

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
