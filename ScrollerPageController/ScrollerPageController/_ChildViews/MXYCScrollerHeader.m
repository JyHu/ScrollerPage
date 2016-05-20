//
//  MXYCScrollerHeader.m
//  ScrollerPageController
//
//  Created by 胡金友 on 16/5/18.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "MXYCScrollerHeader.h"

#define kScrollerHeaderScrollDuration 0.35f

@interface MXYCScrollerHeader()

@property (retain, nonatomic) UIScrollView *titleContentScroll;

@property (assign, nonatomic) NSInteger cachedCurrintIndex;

@property (weak, nonatomic) NSMutableArray *cachedTitles;

@end

@implementation MXYCScrollerHeader

- (id)init
{
    return [self initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.cachedCurrintIndex = 0;
        
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.titleContentScroll = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.titleContentScroll.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.titleContentScroll];
}

- (void)layoutTitles
{
    
}

#pragma mark - 

- (void)updateHeaderTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (index >= 0 && index < self.cachedTitles.count + 1)
    {
        [self.cachedTitles insertObject:title atIndex:index];
    }
}

- (void)scrollToIndex:(NSInteger)index
{
    if (self.cachedCurrintIndex >= 0 && self.cachedCurrintIndex < self.cachedTitles.count)
    {
        
    }
}

- (void)scrollToPreview
{
    if (self.cachedCurrintIndex > 0)
    {
        [self scrollToIndex:self.cachedCurrintIndex - 1];
    }
}

- (void)scrollToNext
{
    if (self.cachedCurrintIndex < self.cachedTitles.count - 1)
    {
        [self scrollToIndex:self.cachedCurrintIndex + 1];
    }
}

#pragma mark - getter

@end
