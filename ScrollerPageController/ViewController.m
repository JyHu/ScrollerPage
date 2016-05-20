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

@interface ViewController ()

@property (retain, nonatomic) NSArray *testsTitles;

@property (retain, nonatomic) MXYCScrollerPageViewController *scrollVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.testsTitles = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
    
    
    
    
    MXYCScrollerPageDataCacheType testCacheType = kTestControlType;
    
    
    
    
    self.scrollVC = [[MXYCScrollerPageViewController alloc] initWithTitles:nil cacheType:testCacheType];
    
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_scrollVC updateWithTitles:_testsTitles];
    });
    
    UIBarButtonItem *insertBarButton = [[UIBarButtonItem alloc] initWithTitle:@"插入"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self action:@selector(insertPage)];
    UIBarButtonItem *updateBarButton = [[UIBarButtonItem alloc] initWithTitle:@"更新"
                                                                        style:UIBarButtonItemStyleDone target:self
                                                                       action:@selector(updatePages)];
    
    self.navigationItem.rightBarButtonItems = @[insertBarButton, updateBarButton];
}

- (void)insertPage
{
    [self.scrollVC insertPageWithTitle:[NSString stringWithFormat:@"%zd", arc4random()] atIndex:self.scrollVC.currentPageIndex];
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
