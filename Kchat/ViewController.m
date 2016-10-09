//
//  ViewController.m
//  Kchat
//
//  Created by csc on 2016/9/22.
//  Copyright © 2016年 cedric cheng. All rights reserved.
//

#import "ViewController.h"
#import "ChartViewController.h"

@interface ViewController ()<KchartViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _chartView.backgroundColor = [UIColor yellowColor];
    
    ChartViewController *indexViewController = [[ChartViewController alloc] init];
    indexViewController.kChartViewDelegate = self;
    indexViewController.view.frame = CGRectMake(0, 0, CGRectGetWidth(_chartView.frame), CGRectGetHeight(_chartView.frame));
    indexViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_chartView addSubview:indexViewController.view];
}

- (void)didSelectChart:(NSDictionary *)selectedDicData{
    _productNameLabel.text = selectedDicData[@"productName"];
    _closeLabel.text = formatString(selectedDicData[@"close"],@"");
    _differenceLabel.text = [NSString stringWithFormat:@"%@(%@)",selectedDicData[@"differencePrice"],selectedDicData[@"differenceRate"]];
    _dateLabel.text = formatString(selectedDicData[@"date"],@"");
    _openLabel.text = formatString(@"开:",selectedDicData[@"open"]);
    _lastCloseLabel.text = formatString(@"昨收:",selectedDicData[@"lastClose"]);
    _highLabel.text = formatString(@"高:",selectedDicData[@"high"]);
    _lowLabel.text = formatString(@"低:",selectedDicData[@"low"]);
    _volLabel.text = formatString(@"成交:",selectedDicData[@"volume"]);

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
