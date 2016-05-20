//
//  TestViewController.m
//  ScrollerPageController
//
//  Created by 胡金友 on 16/5/19.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "TestViewController.h"
#import "UIViewController+ReUseful.h"

@interface TestViewController ()
<
UITableViewDelegate,
UITableViewDataSource
#if kTestControlType == 2
,
MXYCContentViewReverseTriggerDelegate
#endif
>

@property (retain, nonatomic) UITableView *table;

@property (retain, nonatomic) NSArray *tempData;

@end

@implementation TestViewController

#pragma mark - 下面的几个方法只有在数据缓存机制为 缓存数据 的时候才需要使用，其他的两种情况就不需要了
#pragma mark -

#if kTestControlType == 2

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.reverseTriggerDelegate = self;
    }
    
    return self;
}

- (void)triggerToRefreshWithData:(NSDictionary *)data needRequestDataFromServer:(BOOL)need
                  ofSuperScoller:(MXYCScrollerPageViewController *)scrollViewController
{
    if (data)
    {
        // 刷新页面
        
        self.tempData = [data allValues];
        
        [self.table reloadData];
    }
    else
    {
        self.tempData = nil;
        
        [self.table reloadData];
    }
    
    if (need)
    {
        // 请求数据
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            NSMutableArray *datasArr = [[NSMutableArray alloc] init];
            
            for (NSArray *array in [self generateAllData])
            {
                [datasArr addObject:array];
                
                if (self.cacheMyData)
                {
                    self.cacheMyData([NSString stringWithFormat:@"%zd", arc4random()], array);
                }
            }
        });
    }
}

- (void)contentViewControllerWillBeReusedForIndex:(NSInteger)index SuperScroller:(MXYCScrollerPageViewController *)scrollerViewController
{
    NSLog(@"will be reused for : %zd", index);
}

#endif

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.table.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:arc4random_uniform(100) / 100.0];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];
    
#if kTestControlType == 0
    
    [self generateData];
    
#endif
}

- (NSArray *)generateAllData
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < arc4random_uniform(5) + 1; i ++)
    {
        [arr addObject:[self generateData]];
    }
    
    self.tempData = arr;
    
    [self.table reloadData];
    
    return arr;
}

- (NSArray *)generateData
{
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < arc4random_uniform(5) + 1; i ++)
    {
        CGFloat r = arc4random_uniform(255) / 255.0;
        CGFloat g = arc4random_uniform(255) / 255.0;
        CGFloat b = arc4random_uniform(255) / 255.0;
        
        [dataArr addObject:[UIColor colorWithRed:r green:g blue:b alpha:1]];
    }
    
    return dataArr;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tempData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = self.tempData[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reUsefulIdentifier"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reUsefulIdentifier"];
    }
    
    cell.textLabel.text = self.optionalData;
    
    NSArray *array = self.tempData[indexPath.section];
    
    cell.backgroundColor = (UIColor *)[array objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
