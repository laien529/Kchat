//
//  ChartViewController.m
//  Kchat
//
//  Created by csc on 2016/9/25.
//  Copyright © 2016年 cedric cheng. All rights reserved.
//

#import "ChartViewController.h"
#import "AFNetworking.h"
#import "JSONKit.h"
#import "MBProgressHUD.h"

#define ITEM_COUNT 12

@interface ChartViewController ()<ChartViewDelegate,IChartAxisValueFormatter> {
    AFHTTPSessionManager *afmanager;
    NSArray *dataArray;
    NSString *_productId;
    NSString *_pageNo;
}
@property (nonatomic, strong) IBOutlet BarChartView *barChartView;
@property (nonatomic, strong) IBOutlet CandleStickChartView *stickChartView;

@end

@implementation ChartViewController

- (id)initWithProductId:(NSString*)productId dataRange:(NSString*)dataRange{
    self = [[ChartViewController alloc]init];
    _productId = productId;
    _pageNo = dataRange;
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.req_url = [NSString stringWithFormat:@"http://jwuat.hngangxin.com/api/1/data/getKChartResource.json?dataProductId=%@&pageNo=%@", _productId ? _productId : @"", _pageNo ? _pageNo : @"1"] ;
    
    [self getData];
}



- (void)viewWillAppear:(BOOL)animated{
}

-(void)getData{
    
    NSLog(@"url:%@",self.req_url);
    
    NSURL *url = [NSURL URLWithString:[self.req_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    afmanager = [AFHTTPSessionManager manager];
    afmanager.responseSerializer = [AFHTTPResponseSerializer serializer];

//    afmanager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/csv", nil];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [afmanager GET:_req_url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        NSString *res = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"responseObject==%@",responseObject);
        [self requestFinished:res];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    }];
}

- (void)requestFinished:(NSString*)response{

    NSData* jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *dict = [jsonData objectFromJSONData];
    NSNumber *resultCode = dict[@"resultCode"];
    if (resultCode.integerValue == 0) {
       
        dataArray = [NSArray arrayWithArray:dict[@"resultEntity"][@"kChartResource"]];
        if (dataArray.count > 0) {
            
            if ([dataArray.lastObject isKindOfClass:[NSDictionary class]]) {
                if (_kChartViewDelegate && [_kChartViewDelegate respondsToSelector:@selector(didSelectChart:)]) {
                    [_kChartViewDelegate didSelectChart:dataArray.lastObject];

                }
            }
            [self initStickChartView];
            [self initBarChartView];
        }
        
    } else {
        
    }
}

- (void)initStickChartView{
    
    _stickChartView.delegate = self;
    _stickChartView.chartDescription.enabled = NO;
    _stickChartView.pinchZoomEnabled = NO;
    _stickChartView.doubleTapToZoomEnabled = NO;
    _stickChartView.scaleYEnabled = NO;
    [_stickChartView setNoDataText:@""];
    [_stickChartView setClipsToBounds:YES];
    [_stickChartView setDrawMarkers:NO];
    _stickChartView.drawGridBackgroundEnabled = NO;
    _stickChartView.drawBordersEnabled = YES;
//    [_stickChartView setYAxisMinWidth:AxisDependencyRight width:0.2];
//        [_stickChartView setVisibleXRangeMinimum:1.2];
    [_stickChartView setVisibleXRangeMaximum:1];
    
    //x轴
    ChartXAxis *xAxis = _stickChartView.xAxis;_stickChartView.clipsToBounds = YES;
    xAxis.drawGridLinesEnabled = YES;
    [xAxis setGridLineDashLengths:@[@(3), @(2), @(0)]];
    xAxis.drawAxisLineEnabled = NO;
    xAxis.valueFormatter = self;
//    xAxis.centerAxisLabelsEnabled = YES;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.avoidFirstLastClippingEnabled = YES;
//    xAxis.drawLimitLinesBehindDataEnabled = YES;
    //左Y轴
    ChartYAxis *leftAxis = _stickChartView.leftAxis;
    leftAxis.labelCount = 4;
//    leftAxis.drawAxisLineEnabled = YES;

    leftAxis.drawZeroLineEnabled = NO;
    [leftAxis setGridLineDashLengths:@[@(3), @(2), @(0)]];
    leftAxis.drawGridLinesEnabled = YES;
//    leftAxis.drawLimitLinesBehindDataEnabled = YES;
    leftAxis.drawAxisLineEnabled = NO  ;
    leftAxis.drawLabelsEnabled = YES;
    NSNumberFormatter *leftAxisFormatter = [[NSNumberFormatter alloc] init];
    leftAxisFormatter.minimumFractionDigits = 0;
    leftAxisFormatter.maximumFractionDigits = 1;
    leftAxisFormatter.positiveSuffix = @"";
    leftAxis.valueFormatter = [[ChartDefaultAxisValueFormatter alloc] initWithFormatter:leftAxisFormatter];
    
    //右Y轴
    ChartYAxis *rightAxis = _stickChartView.rightAxis;
    rightAxis.labelCount = 4;
    rightAxis.drawLabelsEnabled = NO;
    rightAxis.enabled = YES;
    rightAxis.drawZeroLineEnabled = NO;
    rightAxis.drawGridLinesEnabled = NO;

    //不显示标题
    _stickChartView.legend.enabled = NO;
    
    [self setStickDataCount:dataArray.count range:dataArray.count];
}

- (void)setStickDataCount:(NSInteger)count range:(double)range {
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *xVals1 = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++) {
        NSDictionary *dataDic = [dataArray objectAtIndex:i];
        
        double high = ((NSNumber*)dataDic[@"high"]).doubleValue;
        double low = ((NSNumber*)dataDic[@"low"]).doubleValue;
        double open = ((NSNumber*)dataDic[@"open"]).doubleValue;
        double close = ((NSNumber*)dataDic[@"close"]).doubleValue;
        [yVals1 addObject:[[CandleChartDataEntry alloc] initWithX:i shadowH:high shadowL:low open:open close:close]];
        NSString *dateString = dataDic[@"date"];
        [xVals1 addObject:dateString];
        
    }
    
    months = [NSArray arrayWithArray:xVals1];
    
    CandleChartDataSet *set1 = [[CandleChartDataSet alloc] initWithValues:yVals1 label:@""];
    set1.showCandleBar = YES;
    set1.axisDependency = AxisDependencyLeft;
    [set1 setColor:[UIColor colorWithWhite:80/255.f alpha:1.f]];
    set1.highlightColor = [UIColor darkGrayColor];
    set1.highlightLineWidth = 1;
    set1.shadowColor = [UIColor lightGrayColor];
    set1.shadowWidth = 0.7;
    set1.decreasingColor = [UIColor colorWithRed:211/255.f green:61/255.f blue:50/255.f alpha:1.f];
    set1.decreasingFilled = YES;
    set1.increasingColor = [UIColor colorWithRed:44/255.f green:185/255.f blue:80/255.f alpha:1.f];
    set1.increasingFilled = YES;
    set1.neutralColor = UIColor.blueColor;
    CandleChartData *data = [[CandleChartData alloc] initWithDataSet:set1];
    
    _stickChartView.data = data;
}

- (void)initBarChartView {
    
    _barChartView.delegate = self;
    _barChartView.drawBarShadowEnabled = NO;
    _barChartView.drawValueAboveBarEnabled = NO;
    _barChartView.drawBordersEnabled = YES;
    _barChartView.clipsToBounds = YES;
    _barChartView.highlightFullBarEnabled = YES;
    _barChartView.xAxis.enabled = NO;
    _barChartView.doubleTapToZoomEnabled = NO;
    _barChartView.dragEnabled = NO;
    [_barChartView setDragDecelerationEnabled:NO];
    _barChartView.legend.enabled = NO;
    [_barChartView setVisibleXRangeMaximum:1];

    ChartXAxis *xAxis = _barChartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelFont = [UIFont systemFontOfSize:10.f];
    xAxis.drawGridLinesEnabled = YES;
    xAxis.granularity = 1.0; // only intervals of 1 day
    xAxis.labelCount = 7;
    xAxis.valueFormatter = self;
    //    [xAxis setAxisRange:60];
    
    NSNumberFormatter *leftAxisFormatter = [[NSNumberFormatter alloc] init];
    leftAxisFormatter.minimumFractionDigits = 0;
    leftAxisFormatter.maximumFractionDigits = 1;
    leftAxisFormatter.positiveSuffix = @" t";
    
    ChartYAxis *leftAxis = _barChartView.leftAxis;
    leftAxis.labelFont = [UIFont systemFontOfSize:10.f];
    leftAxis.labelCount = 3;
    leftAxis.axisRange = 3;
    leftAxis.valueFormatter = [[ChartDefaultAxisValueFormatter alloc] initWithFormatter:leftAxisFormatter];
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
    [leftAxis setDrawZeroLineEnabled:NO];
    [leftAxis setGridLineDashLengths:@[@(3), @(2), @(0)]];
    leftAxis.drawGridLinesEnabled = YES;
    
    _barChartView.rightAxis.enabled = NO;
    
    [self setBarDataCount:dataArray.count range:dataArray.count];
}

- (void)setBarDataCount:(NSInteger)count range:(double)range {
    double start = 0.0;
    
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    for (int i = start; i < count; i++) {
        NSDictionary *dataDic = [dataArray objectAtIndex:i];
        double val = ((NSNumber*)dataDic[@"volume"]).doubleValue;
        
        [yVals addObject:[[BarChartDataEntry alloc] initWithX:(double)i y:val]];
    }
    
    BarChartDataSet *set1 = nil;
    if (_barChartView.data.dataSetCount > 0) {
        set1 = (BarChartDataSet *)_barChartView.data.dataSets[0];
        set1.values = yVals;
        [_barChartView.data notifyDataChanged];
        [_barChartView notifyDataSetChanged];
    } else {
        set1 = [[BarChartDataSet alloc] initWithValues:yVals label:@""];
        [set1 setColor:[UIColor colorWithRed:145/255. green:199/255. blue:147/255. alpha:1]];
        
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        
        BarChartData *data = [[BarChartData alloc] initWithDataSets:dataSets];
        [data setDrawValues:NO];
        data.barWidth = 0.3f;
        _barChartView.data = data;
    }
}

#pragma mark - ChartViewDelegate

//选中
- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight {
    
    if (chartView == _barChartView) {
        return;
    }
    NSInteger clickIndex = entry.x;
//    [_barChartView. objectAtIndex:clickIndex];
    [_barChartView highlightValueWithX:6 dataSetIndex:clickIndex callDelegate:NO];
//    _stickChartView.dragEnabled = NO;
    if (clickIndex < dataArray.count) {
        if (_kChartViewDelegate && [_kChartViewDelegate respondsToSelector:@selector(didSelectChart:)]) {
            NSDictionary *dict = [dataArray objectAtIndex:clickIndex];
            [_kChartViewDelegate didSelectChart:dict];
        }
    }
}

//取消选中
- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView {
//    _stickChartView.dragEnabled = YES;

}

//缩放回调
- (void)chartScaled:(ChartViewBase *)chartView scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY{
    [_barChartView zoomToCenterWithScaleX:scaleX scaleY:scaleY];
}

//拖动回调
- (void)chartTranslated:(ChartViewBase *)chartView dX:(CGFloat)dX dY:(CGFloat)dY{
//    if (chartView.highlighted) {
//        return;
//    }
    [_barChartView moveViewToAnimatedWithXValue:dX yValue:dY axis:AxisDependencyLeft duration:1];
}


//x轴标签
- (NSString *)stringForValue:(double)value
                        axis:(ChartAxisBase *)axis {
        return months[(int)value % months.count];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
