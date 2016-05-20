//
//  UIViewController+ReUseful.h
//  ScrollerPageController
//
//  Created by 胡金友 on 16/5/19.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MXYCScrollerPageViewController;

@protocol MXYCContentViewReverseTriggerDelegate <NSObject>

@required

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
- (void)triggerToRefreshWithData:(id)data needRequestDataFromServer:(BOOL)need ofSuperScoller:(MXYCScrollerPageViewController *)scrollViewController;

@optional

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

@end

@interface UIViewController (ReUseful)

/**
 *  @author JyHu, 16-05-20 14:05:20
 *
 *  如果要缓存数据的话，必须要实现的代理
 *
 *  @since 6.6.4
 */
@property (weak, nonatomic) id<MXYCContentViewReverseTriggerDelegate> reverseTriggerDelegate;

// 复用的标识，类似TableViewCell的identifier
@property (retain, nonatomic) NSString *reUsefulIdentifier;

// 缓存数据用的，因为每个页面都可能有很多个请求，所以用urlKey来标记每个接口请求到得数据
@property (copy, nonatomic) void (^cacheMyData)(NSString *urlKey, id data);

// 每个页面唯一的标记
@property (assign, nonatomic) NSUInteger uniquePageTag;

@property (assign, nonatomic) id optionalData;

@end
