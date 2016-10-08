//
//  ChartViewController.h
//  Kchat
//
//  Created by csc on 2016/9/25.
//  Copyright © 2016年 cedric cheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chart.h"
#import "CandleStickChartViewController.h"
#import "DemoBaseViewController.h"
#import "BarChartViewController.h"

@interface ChartViewController : DemoBaseViewController{
    NSArray<NSString *> *months;
}

@property (nonatomic,strong) CandleStickChartViewController *candleChart;
@property (nonatomic,strong) BarChartViewController *barChart;
@property (nonatomic,strong) NSString *lastTime;
@property (nonatomic,strong) UILabel *status;
@property (nonatomic,strong) NSString *req_freq;
@property (nonatomic,strong) NSString *req_type;
@property (nonatomic,strong) NSString *req_url;
@property (nonatomic,strong) NSString *req_security_id;

//-(void)initChart;
//-(void)getData;
//-(void)generateData:(NSMutableDictionary *)dic From:(NSArray *)data;
//-(void)setData:(NSDictionary *)dic;
//-(void)setCategory:(NSArray *)category;
//-(BOOL)isCodesExpired;
//-(void)setOptions:(NSDictionary *)options ForSerie:(NSMutableDictionary *)serie;

@end
