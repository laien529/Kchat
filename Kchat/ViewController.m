//
//  ViewController.m
//  Kchat
//
//  Created by csc on 2016/9/22.
//  Copyright © 2016年 cedric cheng. All rights reserved.
//

#import "ViewController.h"
#import "ChartViewController.h"

@interface ViewController ()<KchartViewDelegate>{
    ChartViewController *_indexViewController;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _chartView.backgroundColor = [UIColor clearColor];
//    self.extendedLayoutIncludesOpaqueBars = YES;
    _indexViewController = [[ChartViewController alloc] initWithProductId:_productId dataRange:_dataRange];
    _indexViewController.kChartViewDelegate = self;
    _indexViewController.view.frame = CGRectMake(0, 0, CGRectGetWidth(_chartView.frame), CGRectGetHeight(_chartView.frame));
    _indexViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_chartView addSubview:_indexViewController.view];
}
//设置样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

//设置是否隐藏
- (BOOL)prefersStatusBarHidden {
    //    [super prefersStatusBarHidden];
    return NO;
}

//设置隐藏动画
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}
- (void)didSelectChart:(NSDictionary *)selectedDicData {
    _productNameLabel.text = selectedDicData[@"productName"];
    
    if (![formatString(selectedDicData[@"differencePrice"], @"") hasPrefix:@"-"]) {
        _closeLabel.textColor = [UIColor redColor];
        _differenceLabel.textColor = [UIColor redColor];

    }else{
        _closeLabel.textColor = [UIColor colorWithRed:82/255. green:198/255. blue:110/255. alpha:1];
        _differenceLabel.textColor = [UIColor colorWithRed:82/255. green:198/255. blue:110/255. alpha:1];

    }
    _closeLabel.text = formatString(selectedDicData[@"close"], @"");
    _differenceLabel.text = [NSString stringWithFormat:@"%@(%@)",selectedDicData[@"differencePrice"] ? selectedDicData[@"differencePrice"] : @"NA", selectedDicData[@"differenceRate"] ? selectedDicData[@"differenceRate"] : @"NA"];
    _dateLabel.text = formatString(selectedDicData[@"date"],@"");
    _openLabel.text = formatString(@"开:",selectedDicData[@"open"]);
    _lastCloseLabel.text = formatString(@"昨收:",selectedDicData[@"lastClose"] ? selectedDicData[@"lastClose"] : @"");
    _highLabel.text = formatString(@"高:",selectedDicData[@"high"]);
    _lowLabel.text = formatString(@"低:",selectedDicData[@"low"]);
    _volLabel.text = formatString(@"成交:",selectedDicData[@"volume"]);

}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (BOOL)shouldAutorotate{
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
