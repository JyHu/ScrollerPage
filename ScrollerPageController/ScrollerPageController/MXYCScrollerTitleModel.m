//
//  MXYCScrollerTitleModel.m
//  ScrollerPageController
//
//  Created by 胡金友 on 16/5/24.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "MXYCScrollerTitleModel.h"

@implementation MXYCScrollerTitleModel

@synthesize title = _title;

+ (MXYCScrollerTitleModel *)instanceWithTitle:(NSString *)title data:(id)data
{
    MXYCScrollerTitleModel *model = [[MXYCScrollerTitleModel alloc] init];
    
    // 注意判断
    if (!(title && [title isKindOfClass:[NSString class]] && [title length] > 0))
    {
        return nil;
    }
    
    model.title = title;
    model.data = data;
    
    return model;
}

- (void)setTitle:(NSString *)title
{
    if (title && [title isKindOfClass:[NSString class]] && [title length] > 0)
    {
        _title = title;
    }
    else
    {
        _title = nil;
    }
}

- (NSString *)title
{
    return _title;
}

@end
