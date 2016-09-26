//
//  ViewController.m
//  Kchat
//
//  Created by csc on 2016/9/22.
//  Copyright © 2016年 cedric cheng. All rights reserved.
//

#import "ViewController.h"
#import "ChartViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _chartView.backgroundColor = [UIColor yellowColor];
    
    ChartViewController *indexViewController = [[ChartViewController alloc] init];
    indexViewController.view.frame = CGRectMake(0, 0, CGRectGetWidth(_chartView.frame), CGRectGetHeight(_chartView.frame));
    indexViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_chartView addSubview:indexViewController.view];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate{
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
