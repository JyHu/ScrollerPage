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

@property (retain, nonatomic) NSMutableArray *cachedTitles;

@property (retain, nonatomic) UIView *splitView;

@property (copy, nonatomic) void (^selectComp)(NSInteger index);

@end

#define kUTIL_SET_XORIGIN(V, X)     CGRect _tempRect = V.frame;    \
                                    _tempRect.origin.x = X;         \
                                    V.frame = _tempRect;

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
        
        self.cachedTitles = [[NSMutableArray alloc] init];
        
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.titleContentScroll = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.titleContentScroll.backgroundColor = [UIColor clearColor];
    [self addSubview:self.titleContentScroll];
    
    self.splitView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 2, self.frame.size.width, 2)];
    self.splitView.backgroundColor = [UIColor redColor];
    [self.titleContentScroll addSubview:self.splitView];
}

- (void)layoutTitles
{
    for (UIView *view in self.titleContentScroll.subviews)
    {
        if (view != self.splitView)
        {
            [view removeFromSuperview];
        }
    }
    
    CGFloat xOrigin = 0;
    
    for (NSInteger i = 0; i < self.cachedTitles.count; i ++)
    {
        MXYCScrollerTitleModel *titleModel = self.cachedTitles[i];
        
        UIButton *button = [self buttonWithTitle:titleModel.title xorigin:xOrigin];
        button.tag = 100 + i;
        
        CGRect rect = button.frame;
        rect.origin.x = xOrigin;
        
        [self.titleContentScroll addSubview:button];
        
        xOrigin += button.frame.size.width;
    }
    
    self.titleContentScroll.contentSize = CGSizeMake(xOrigin, self.frame.size.width);
}

- (void)selectTitle:(UIButton *)button
{
    if (self.selectComp)
    {
        self.selectComp(button.tag - 100);
        [self scrollToIndex:button.tag - 100];
    }
}

#pragma mark - 

- (UIButton *)buttonWithTitle:(NSString *)title xorigin:(CGFloat)x
{
    CGSize size = [[[NSAttributedString alloc] initWithString:title
                                                   attributes:@{
                                                                NSFontAttributeName : [UIFont systemFontOfSize:13],
                                                                NSForegroundColorAttributeName : [UIColor redColor]
                                                                }]
                   boundingRectWithSize:CGSizeMake(1000, 100)
                   options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setFrame:CGRectMake(x, 0, size.width + 20, self.frame.size.height)];
    [button addTarget:self action:@selector(selectTitle:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)setupTitles:(NSArray <MXYCScrollerTitleModel *> *)titles
{
    [self.cachedTitles removeAllObjects];
    
    [self.cachedTitles addObjectsFromArray:titles];
    
    [self layoutTitles];
}

- (void)insertHeaderTitleModel:(MXYCScrollerTitleModel *)titleModel atIndex:(NSInteger)index
{
    if (index >= 0 && index < self.cachedTitles.count + 1)
    {
        [self.cachedTitles insertObject:titleModel atIndex:index];
        
        UIButton *insertedButton = [self buttonWithTitle:titleModel.title xorigin:0];
        
        for (NSInteger i = self.cachedTitles.count - 1; i >= index; i --)
        {
            UIButton *button = (UIButton *)[self viewWithTag:100 + i];
            
            [UIView animateWithDuration:0.36 animations:^{
                
                if (i == index)
                {
                    kUTIL_SET_XORIGIN(insertedButton, button.frame.origin.x)
                    insertedButton.tag = index + 100;
                    [self.titleContentScroll addSubview:insertedButton];
                }
                
                if (button)
                {
                    button.tag ++;
                    kUTIL_SET_XORIGIN(button, insertedButton.frame.size.width + button.frame.origin.x);
                }
                
                if (i == self.cachedTitles.count - 2 && button)
                {
                    self.titleContentScroll.contentSize = CGSizeMake(button.frame.size.width + button.frame.origin.x, self.frame.size.height);
                }
            }];
        }
        
        if (index == self.cachedCurrintIndex)
        {
            [self scrollToIndex:index];
        }
    }
}

- (void)scrollToIndex:(NSInteger)index
{
    if (self.cachedCurrintIndex >= 0 && self.cachedCurrintIndex < self.cachedTitles.count)
    {
        UIButton *button = (UIButton *)[self viewWithTag:100 + index];
        CGRect rect = self.splitView.frame;
        rect.origin.x = button.frame.origin.x;
        rect.size.width = button.frame.size.width;
        
        [UIView animateWithDuration:0.36 animations:^{
            self.splitView.frame = rect;
            CGFloat offsetx = button.frame.origin.x - (self.frame.size.width - button.frame.size.width) / 2.0;
            
            if (self.titleContentScroll.contentSize.width - offsetx < self.frame.size.width)
            {
                offsetx = self.titleContentScroll.contentSize.width - self.frame.size.width;
            }
            
            if (offsetx < 0)
            {
                offsetx = 0;
            }
            
            self.titleContentScroll.contentOffset = CGPointMake(offsetx, 0);
        }];
        
        self.cachedCurrintIndex = index;
    }
}

- (void)selectTitleComption:(void (^)(NSInteger))selectComp
{
    self.selectComp = selectComp;
}

#pragma mark - getter

@end
