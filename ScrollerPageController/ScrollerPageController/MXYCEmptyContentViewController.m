//
//  MXYCEmptyContentViewController.m
//  ScrollerPageController
//
//  Created by 胡金友 on 16/5/20.
//  Copyright © 2016年 胡金友. All rights reserved.
//

#import "MXYCEmptyContentViewController.h"

@interface MXYCEmptyContentViewController ()

@end

@implementation MXYCEmptyContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:arc4random_uniform(100) / 200.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
