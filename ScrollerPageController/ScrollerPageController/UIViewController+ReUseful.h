//
//  UIViewController+ReUseful.h
//  ScrollerPageController
//
//  Created by 胡金友 on 16/5/19.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXYCScrollerTitleModel.h"

@class MXYCScrollerPageViewController;

@interface UIViewController (ReUseful)

#pragma mark - 用来重写的方法，不能自己调用
#pragma mark -

/**
 *  @author JyHu, 16-05-20 13:05:01
 *
 *  刷新页面用的，具体页面必须实现的
 *
 *  @param data                 缓存的数据，如果没有缓存的话，返回的是nil
 *  @param need                 是否需要连接后台请求数据
 *  @param scrollViewController scrollViewController
 *
 *  @since 6.6.4
 */
- (void)triggerToRefreshWithCachedData:(id)cachedData
                     originalTitleData:(MXYCScrollerTitleModel *)titleModel
             needRequestDataFromServer:(BOOL)need
                        ofSuperScoller:(MXYCScrollerPageViewController *)scrollViewController;

/**
 *  @author JyHu, 16-05-20 13:05:11
 *
 *  通知一下当前页面马上要被复用了
 *
 *  参见 `MXYCScrollerPageViewController` 的 `dequenceContentViewControllerWithIdentifier:atIndex:` 方法
 *
 *  @param index                  将要加载的页面的索引
 *  @param scrollerViewController scrollerViewController
 *
 *  @since 6.6.4
 */
- (void)contentViewControllerWillBeReusedForIndex:(NSInteger)index SuperScroller:(MXYCScrollerPageViewController *)scrollerViewController;

#pragma mark - 其他的参数
#pragma mark -

/**
 *  @author JyHu, 16-05-20 17:05:38
 *
 *  复用的标识，类似TableViewCell的identifier
 *
 *  @since 6.6.4
 */
@property (retain, nonatomic) NSString *reUsefulIdentifier;

/**
 *  @author JyHu, 16-05-20 17:05:51
 *
 *  缓存数据用的，因为每个页面都可能有很多个请求，所以用urlKey来标记每个接口请求到得数据
 *
 *  @since 6.6.4
 */
@property (copy, nonatomic) void (^cacheMyData)(NSString *urlKey, id data);

/**
 *  @author JyHu, 16-05-20 17:05:16
 *
 *  每个页面唯一的标记，类似于tag，是根据每个页面的title的hash来算出来的
 *
 *  不用tag是因为当页面更新或插入的时候，页面的标记会乱掉。
 *
 *  @since 6.6.4
 */
@property (assign, nonatomic) NSUInteger uniquePageTag;

/**
 *  @author JyHu, 16-05-20 17:05:46
 *
 *  给每个页面额外添加的数据，在不同页面复用的时候可以进行使用
 *
 *  @since 6.6.4
 */
@property (assign, nonatomic) id optionalData;

@end
