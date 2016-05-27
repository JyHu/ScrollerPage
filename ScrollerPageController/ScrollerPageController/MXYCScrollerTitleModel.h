//
//  MXYCScrollerTitleModel.h
//  ScrollerPageController
//
//  Created by 胡金友 on 16/5/24.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MXYCScrollerTitleModel : NSObject

// 显示的唯一的标题，注意一定要是唯一并且有效的
@property (retain, nonatomic) NSString *title;

// 这个标题下的附带的数据，在请求数据的时候会附带着返回去。
@property (assign, nonatomic) id data;

/**
 *  @author JyHu, 16-05-24 10:05:14
 *
 *  初始化构造方法
 *
 *  @param title title
 *  @param data  data description
 *
 *  @return self
 *
 *  @since 6.6.4
 */
+ (MXYCScrollerTitleModel *)instanceWithTitle:(NSString *)title data:(id)data;

@end
