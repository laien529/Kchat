//
//  DemoBaseViewController.h
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//
#define formatString(obj1,obj2) [NSString stringWithFormat:@"%@%@",obj1,obj2]
#import <UIKit/UIKit.h>
#import <Charts/Charts-swift.h>

@interface DemoBaseViewController : UIViewController
{
@protected
    NSArray *parties;
}

@property (nonatomic, strong) IBOutlet UIButton *optionsButton;
@property (nonatomic, strong) IBOutlet NSArray *options;

@property (nonatomic, assign) BOOL shouldHideData;

- (void)handleOption:(NSString *)key forChartView:(ChartViewBase *)chartView;

- (void)updateChartData;

- (void)setupPieChartView:(PieChartView *)chartView;
- (void)setupRadarChartView:(RadarChartView *)chartView;
- (void)setupBarLineChartView:(BarLineChartViewBase *)chartView;

@end
