//
//  MXYCScrollerHeader.h
//  ScrollerPageController
//
//  Created by 胡金友 on 16/5/18.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MXYCScrollerHeader : UIView

- (void)updateHeaderTitle:(NSString *)title atIndex:(NSInteger)index;

- (void)scrollToIndex:(NSInteger)index;

- (void)scrollToPreview;

- (void)scrollToNext;

@property (assign, nonatomic, readonly) NSInteger currentIndex;

@end
