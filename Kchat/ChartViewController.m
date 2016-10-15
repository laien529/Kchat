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
#import "Kchat-Swift.h"
//#import "DayAxisValueFormatter.h"
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

- (void)initBarChartView {
    
    _barChartView.delegate = self;
    _barChartView.drawBarShadowEnabled = NO;
    _barChartView.drawValueAboveBarEnabled = NO;
    _barChartView.clipsToBounds = YES;
//    _barChartView.maxVisibleCount = 60;
    _barChartView.highlightFullBarEnabled = YES;
    _barChartView.xAxis.enabled = NO;
    _barChartView.doubleTapToZoomEnabled = NO;
    _barChartView.dragEnabled = NO;
    [_barChartView setDragDecelerationEnabled:NO];
    _barChartView.legend.enabled = NO;
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
    leftAxis.drawGridLinesEnabled = YES;
    leftAxis.labelFont = [UIFont systemFontOfSize:10.f];
    leftAxis.labelCount = 3;
    leftAxis.axisRange = 3;
    leftAxis.valueFormatter = [[ChartDefaultAxisValueFormatter alloc] initWithFormatter:leftAxisFormatter];
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
    [leftAxis setDrawZeroLineEnabled:NO];

    _barChartView.rightAxis.enabled = NO;
    
    [self updateBarChartData];
}

- (void)initStickChartView{
    _stickChartView.delegate = self;
    _stickChartView.chartDescription.enabled = NO;
    _stickChartView.maxVisibleCount = 60;
    _stickChartView.pinchZoomEnabled = NO;
    _stickChartView.doubleTapToZoomEnabled = NO;
    _stickChartView.scaleYEnabled = NO;
    [_stickChartView setNoDataText:@"无数据"];
    [_stickChartView setClipsToBounds:NO];
    [_stickChartView setDrawMarkers:NO];
    _stickChartView.drawGridBackgroundEnabled = NO;
    [_stickChartView setYAxisMinWidth:AxisDependencyRight width:0.2];
//    [_stickChartView setVisibleXRangeMinimum:30];
//    [_stickChartView setVisibleXRangeMaximum:60];
    
    
    ChartXAxis *xAxis = _stickChartView.xAxis;_stickChartView.clipsToBounds = YES;
    xAxis.drawGridLinesEnabled = NO;
    xAxis.valueFormatter = self;
    xAxis.centerAxisLabelsEnabled = YES;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.drawLimitLinesBehindDataEnabled = YES;

    
    
    ChartYAxis *leftAxis = _stickChartView.leftAxis;
    leftAxis.labelCount = 4;
//    leftAxis.drawGridLinesEnabled = YES;
    leftAxis.drawLimitLinesBehindDataEnabled = YES;
//    leftAxis.drawAxisLineEnabled = YES  ;
    leftAxis.drawTopYLabelEntryEnabled = YES;
//    leftAxis.centerAxisLabelsEnabled = NO;
    leftAxis.drawLabelsEnabled = YES;
    leftAxis.gridAntialiasEnabled = NO;
    [leftAxis removeAllLimitLines];
    
    NSNumberFormatter *leftAxisFormatter = [[NSNumberFormatter alloc] init];
    leftAxisFormatter.minimumFractionDigits = 0;
    leftAxisFormatter.maximumFractionDigits = 1;
    leftAxisFormatter.positiveSuffix = @"";
    leftAxis.valueFormatter = [[ChartDefaultAxisValueFormatter alloc] initWithFormatter:leftAxisFormatter];
    
    ChartYAxis *rightAxis = _stickChartView.rightAxis;
    rightAxis.labelCount = 4;
    rightAxis.drawLabelsEnabled = NO;
    rightAxis.enabled = YES;
    
    _stickChartView.legend.enabled = NO;
    [self updateStickChartData];

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated{
//    [self.timer invalidate];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)updateBarChartData
{
//    if (self.shouldHideData)
//    {
//        _barChartView.data = nil;
//        return;
//    }
    
    [self setBarDataCount:dataArray.count range:dataArray.count];
}
- (void)updateStickChartData
{
//    if (self.shouldHideData)
//    {
//        _stickChartView.data = nil;
//        return;
//    }
    
    [self setStickDataCount:dataArray.count range:dataArray.count];
}

- (void)setBarDataCount:(NSInteger)count range:(double)range {
    double start = 0.0;
    
//    _barChartView.xAxis.axisMinimum = start;
//    _barChartView.xAxis.axisMaximum = start + count + 2;
    
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
    CandleChartDataSet *set1 = [[CandleChartDataSet alloc] initWithValues:yVals1 label:@"Data Set"];
    set1.showCandleBar = YES;
    
    set1.axisDependency = AxisDependencyRight;
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

- (void)optionTapped:(NSString *)key
{
//    [super handleOption:key forChartView:_barChartView];
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight {
    if (chartView == _barChartView) {
        return;
    }
//    _stickChartView.dragEnabled = NO;
    NSLog(@"chartValueSelected");
    NSInteger clickIndex = entry.x;
    [_barChartView setLastHighlighted:[[ChartHighlight alloc]initWithX:entry.x dataSetIndex:clickIndex]];
    if (clickIndex < dataArray.count) {
        if (_kChartViewDelegate && [_kChartViewDelegate respondsToSelector:@selector(didSelectChart:)]) {
            NSDictionary *dict = [dataArray objectAtIndex:clickIndex];
            [_kChartViewDelegate didSelectChart:dict];
        }
    }
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView {
//    _stickChartView.dragEnabled = YES;

    NSLog(@"chartValueNothingSelected");
}

- (void)chartScaled:(ChartViewBase *)chartView scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY{
    [_barChartView zoomToCenterWithScaleX:scaleX scaleY:scaleY];
}

- (void)chartTranslated:(ChartViewBase *)chartView dX:(CGFloat)dX dY:(CGFloat)dY{
    if (chartView.highlighted) {
        return;
    }
//    [_barChartView centerViewToXValue:dX yValue:dY axis:AxisDependencyLeft];
}

- (NSString *)stringForValue:(double)value
                        axis:(ChartAxisBase *)axis {
        return months[(int)value % months.count];
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
