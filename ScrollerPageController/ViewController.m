//
//  ViewController.m
//  ScrollerPageController
//
//  Created by 胡金友 on 16/5/18.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "ViewController.h"
#import "MXYCScrollerPageViewController.h"
#import "TestViewController.h"
#import "MXYCPageViewController.h"

@interface ViewController ()

@property (retain, nonatomic) NSArray *testsTitles;

@property (retain, nonatomic) MXYCPageViewController *scrollVC;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.testsTitles = @[[MXYCScrollerTitleModel instanceWithTitle:@"1" data:nil],
                         [MXYCScrollerTitleModel instanceWithTitle:@"2" data:nil],
                         [MXYCScrollerTitleModel instanceWithTitle:@"3" data:nil],
                         [MXYCScrollerTitleModel instanceWithTitle:@"4" data:nil],
                         [MXYCScrollerTitleModel instanceWithTitle:@"5" data:nil],
                         [MXYCScrollerTitleModel instanceWithTitle:@"6" data:nil],
                         [MXYCScrollerTitleModel instanceWithTitle:@"7" data:nil],
                         [MXYCScrollerTitleModel instanceWithTitle:@"8" data:nil]];
    
    
    
    
    MXYCScrollerPageDataCacheType testCacheType = kTestControlType;
    
    
    self.scrollVC = [[MXYCPageViewController alloc] initPageCurlTypeWithCachType:testCacheType];
    
//    self.scrollVC = [[MXYCPageViewController alloc] initWithTitles:nil cacheType:testCacheType];
    
    
    
    [self.scrollVC setupWithGenerateBlock:^UIViewController *(NSInteger index) {
        
#if kTestControlType == 0
        
        return [[TestViewController alloc] init];
        
#else
        if (index == 0)
        {
            UIViewController *viewController = [self.scrollVC dequenceContentViewControllerWithIdentifier:@"HomePage" atIndex:index];
            
            if (!viewController)
            {
                viewController = [[TestViewController alloc] init];
            }
            
            viewController.optionalData = [NSString stringWithFormat:@"%zd", index];
            
#   if kTestControlType == 2
            
            viewController.reUsefulIdentifier = @"HomePage";
            
#   endif
            
            return viewController;
        }
        
        UIViewController *viewController = [self.scrollVC dequenceContentViewControllerWithIdentifier:@"ContentPage" atIndex:index];
        
        if (!viewController)
        {
            viewController = [[TestViewController alloc] init];
        }
        
        viewController.optionalData = [NSString stringWithFormat:@"%zd", index];
        
#   if kTestControlType == 2
        
        viewController.reUsefulIdentifier = @"ContentPage";
        
#   endif
        
        return viewController;
#endif
    }];
    [_scrollVC scrollToIndexCompletion:^(NSInteger index) {
        
        self.title = [NSString stringWithFormat:@"Current : %zd", index];
    }];
    _scrollVC.view.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64);
    [self addChildViewController:_scrollVC];
    [self.view addSubview:_scrollVC.view];
    
    [_scrollVC updateWithTitles:_testsTitles];
    
    UIBarButtonItem *insertBarButton = [[UIBarButtonItem alloc] initWithTitle:@"插入"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self action:@selector(insertPage)];
    UIBarButtonItem *updateBarButton = [[UIBarButtonItem alloc] initWithTitle:@"更新"
                                                                        style:UIBarButtonItemStyleDone target:self
                                                                       action:@selector(updatePages)];
    
    self.navigationItem.rightBarButtonItems = @[insertBarButton, updateBarButton];
    
    
    
    /*
     使用方法，这样是缓存数据的。
     
    MXYCPageViewController *pageVC = [[MXYCPageViewController alloc] init];
    [pageVC setupWithGenerateBlock:^UIViewController *(NSInteger index) {
        if (index == 0)
        {
            // 假设第1个是首页
            
            UIViewController *viewController = [pageVC dequenceContentViewControllerWithIdentifier:@"homePage_identifier" atIndex:index];
            
            if (!viewController)
            {
                viewController = [[TestViewController alloc] init];
            }
            
            return viewController;
        }
        
        // 假设后面的都是正常的页面。
        
        UIViewController *viewController = [pageVC dequenceContentViewControllerWithIdentifier:@"normalPage_identifier" atIndex:index];
        
        if (!viewController)
        {
            viewController = [[TestViewController alloc] init];
        }
        
        return viewController;
    }];
    pageVC.view.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64);
    [self addChildViewController:pageVC];
    [self.view addSubview:pageVC.view];
    
    [pageVC updateWithTitles:@[@"t1", @"t2", @"t3", @"t4"]];
     */
}

- (void)insertPage
{
    [self.scrollVC insertPageWithModel:[MXYCScrollerTitleModel instanceWithTitle:[NSString stringWithFormat:@"%zd", arc4random() % 1000] data:nil] atIndex:self.scrollVC.currentPageIndex];
}

- (void)updatePages
{
    [self.scrollVC updateWithTitles:@[@"j", @"bk", @"k", @"nb", @"mn"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
