//
//  MXYCScrollerHeader.h
//  ScrollerPageController
//
//  Created by 胡金友 on 16/5/18.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXYCScrollerTitleModel.h"

@interface MXYCScrollerHeader : UIView

- (void)setupTitles:(NSArray <MXYCScrollerTitleModel *> *)titles;

- (void)insertHeaderTitleModel:(MXYCScrollerTitleModel *)titleModel atIndex:(NSInteger)index;

- (void)scrollToIndex:(NSInteger)index;

@property (assign, nonatomic, readonly) NSInteger currentIndex;

- (void)selectTitleComption:(void (^)(NSInteger index))selectComp;

@end
