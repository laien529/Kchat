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

@interface ChartViewController ()<ChartViewDelegate> {
    AFHTTPSessionManager *afmanager;
    NSArray *dataArray;
    NSString *_productId;
    NSString *_pageNo;
}
@property (nonatomic, weak) IBOutlet BarChartView *barChartView;
@property (nonatomic, weak) IBOutlet CandleStickChartView *stickChartView;

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
    [self initChartView];

    [self getData];
}



- (void)viewWillAppear:(BOOL)animated{
}

- (void)getData{
    
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
            [self setData];

            
            if ([dataArray.lastObject isKindOfClass:[NSDictionary class]]) {
                if (_kChartViewDelegate && [_kChartViewDelegate respondsToSelector:@selector(didSelectChart:)]) {
                    [_kChartViewDelegate didSelectChart:dataArray.lastObject];

                }
            }
        }
        
    } else {
        
    }
}

- (void)initChartView{
    [self initStickChartView];
    [self initBarChartView];
}

- (void)setData{
    [self setStickDataCount];
    [self setBarDataCount];
    [self setOffSet];
}

- (void)initStickChartView{
    
    _stickChartView.delegate = self;
    _stickChartView.borderLineWidth = 0.5;
    _stickChartView.drawBordersEnabled = YES;
    _stickChartView.descriptionText = @"";
    _stickChartView.scaleYEnabled = NO;
    _stickChartView.dragEnabled = YES;
    _stickChartView.doubleTapToZoomEnabled = NO;
    [_stickChartView setClipsToBounds:YES];
    
    _stickChartView.legend.enabled = NO;
    _stickChartView.dragDecelerationEnabled = YES;
    
    //x轴
    ChartXAxis *xAxis = _stickChartView.xAxis;
    xAxis.drawGridLinesEnabled = NO;
    xAxis.drawAxisLineEnabled = NO;
    [xAxis setGridLineDashLengths:@[@(3), @(2), @(0)]];
    [xAxis setLabelTextColor:[UIColor colorWithRed:45/255. green:57/255. blue:69/255. alpha:1]];
    [xAxis setGridColor:[UIColor colorWithRed:151/255. green:133/255. blue:147/255. alpha:1]];
    xAxis.labelPosition = XAxisLabelPositionBottom;
    //左Y轴
    ChartYAxis *leftAxis = _stickChartView.leftAxis;
    leftAxis.labelCount = 4;
    leftAxis.drawZeroLineEnabled = NO;
    [leftAxis setGridLineDashLengths:@[@(3), @(2), @(0)]];
    leftAxis.drawGridLinesEnabled = YES;
    leftAxis.drawAxisLineEnabled = NO  ;
    leftAxis.drawLabelsEnabled = YES;
    [leftAxis setLabelTextColor:[UIColor colorWithRed:45/255. green:57/255. blue:69/255. alpha:1]];
    [leftAxis setGridColor:[UIColor colorWithRed:151/255. green:133/255. blue:147/255. alpha:1]];
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
    NSNumberFormatter *leftAxisFormatter = [[NSNumberFormatter alloc] init];
    leftAxisFormatter.minimumFractionDigits = 0;
    leftAxisFormatter.maximumFractionDigits = 1;
    leftAxisFormatter.positiveSuffix = @"";
    leftAxis.valueFormatter = leftAxisFormatter;
    
    //右Y轴
    ChartYAxis *rightAxis = _stickChartView.rightAxis;
    rightAxis.labelCount = 4;
    rightAxis.drawLabelsEnabled = NO;
    rightAxis.drawZeroLineEnabled = NO;
    rightAxis.drawGridLinesEnabled = NO;
    [rightAxis setGridColor:[UIColor colorWithRed:151/255. green:133/255. blue:147/255. alpha:1]];
    //不显示标题
    _stickChartView.legend.enabled = NO;
    
}

- (void)initBarChartView {
    
    _barChartView.delegate = self;
    _barChartView.drawBordersEnabled = YES;
    _barChartView.borderLineWidth = 0.5;
    _barChartView.borderColor = [UIColor darkGrayColor];
    _barChartView.descriptionText = @"";
    _barChartView.dragEnabled = YES;
    _barChartView.scaleYEnabled = NO;
    _barChartView.doubleTapToZoomEnabled = NO;
    _barChartView.legend.enabled = NO;
    _barChartView.autoScaleMinMaxEnabled = YES;
    
    
    //    [_barChartView setVisibleXRangeMaximum:60];
    
    
    
    //X轴
    ChartXAxis *xAxis = _barChartView.xAxis;
    xAxis.drawLabelsEnabled = NO;
    xAxis.drawGridLinesEnabled = NO;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelTextColor = [UIColor grayColor];
    xAxis.gridColor = [UIColor grayColor];
    
    
    NSNumberFormatter *leftAxisFormatter = [[NSNumberFormatter alloc] init];
    leftAxisFormatter.minimumFractionDigits = 0;
    leftAxisFormatter.maximumFractionDigits = 1;
    
    //Y轴 左
    ChartYAxis *leftAxis = _barChartView.leftAxis;
    leftAxis.axisMinValue = 0;
    leftAxis.drawGridLinesEnabled = YES;
    leftAxis.drawAxisLineEnabled = NO;
    leftAxis.labelTextColor = [UIColor grayColor];
    leftAxis.drawLabelsEnabled = YES;
    [leftAxis setGridLineDashLengths:@[@(9), @(3), @(0)]];
    leftAxis.labelCount = 3;
    leftAxis.axisMinValue = 0;
    leftAxis.showOnlyMinMaxEnabled = NO;
    leftAxis.valueFormatter = leftAxisFormatter;
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
    leftAxis.spaceTop = 5;
    
    //    _barChartView.rightAxis.enabled = NO;
    _barChartView.rightAxis.drawAxisLineEnabled = NO;
    _barChartView.rightAxis.drawLabelsEnabled = NO;
    _barChartView.rightAxis.drawGridLinesEnabled = NO;
}

- (void)setStickDataCount {
    
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *xVals1 = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < dataArray.count; i++) {
        NSDictionary *dataDic = [dataArray objectAtIndex:i];
        
        double high = ((NSNumber*)dataDic[@"high"]).doubleValue;
        double low = ((NSNumber*)dataDic[@"low"]).doubleValue;
        double open = ((NSNumber*)dataDic[@"open"]).doubleValue;
        double close = ((NSNumber*)dataDic[@"close"]).doubleValue;
        [yVals1 addObject:[[CandleChartDataEntry alloc] initWithXIndex:i shadowH:high shadowL:low open:open close:close]];
        NSString *dateString = dataDic[@"date"];
        [xVals1 addObject:dateString];
    }
    
    months = [NSArray arrayWithArray:xVals1];
    
    CandleChartDataSet *set1 = [[CandleChartDataSet alloc] initWithYVals:yVals1 label:@""];
    set1.showCandleBar = YES;
    
    set1.axisDependency = AxisDependencyLeft;
    [set1 setDrawHorizontalHighlightIndicatorEnabled:NO];
    [set1 setColor:[UIColor colorWithWhite:80/255.f alpha:1.f]];
    set1.highlightColor = [UIColor darkGrayColor];
    set1.highlightLineWidth = 0.5;
    set1.shadowColor = [UIColor lightGrayColor];
    set1.shadowWidth = 0.5;
    [set1 setDrawHorizontalHighlightIndicatorEnabled:NO];
    [set1 setDrawHighlightIndicators:YES];
    set1.decreasingColor = [UIColor colorWithRed:211/255.f green:61/255.f blue:50/255.f alpha:1.f];
    set1.decreasingFilled = YES;
    set1.increasingColor = [UIColor colorWithRed:44/255.f green:185/255.f blue:80/255.f alpha:1.f];
    set1.increasingFilled = YES;
    set1.neutralColor = [UIColor colorWithRed:44/255. green:185/255 blue:80/255. alpha:1];
    
    CandleChartData *data = [[CandleChartData alloc] initWithXVals:xVals1 dataSet:set1];
    _stickChartView.data = data;
    
    [_stickChartView moveViewToX:dataArray.count - 1];

}



- (void)setBarDataCount{
    
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < dataArray.count; i++) {
        
        NSDictionary *dataDic = [dataArray objectAtIndex:i];
        [xVals addObject:dataDic[@"date"]];
        
        double val = ((NSNumber*)dataDic[@"volume"]).doubleValue;
        
        [yVals addObject:[[BarChartDataEntry alloc] initWithValue:val xIndex:i]];
    }
    
    BarChartDataSet *set1 = [[BarChartDataSet alloc] initWithYVals:yVals label:@""];
    set1.barSpace = 0.5f;
    set1.highlightEnabled = YES;
    set1.highlightAlpha = 1;
    set1.highlightColor = [UIColor darkGrayColor];
    set1.drawValuesEnabled = NO;
    [set1 setColor:[UIColor colorWithRed:145/255. green:199/255. blue:147/255. alpha:1]];
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    BarChartData *data = [[BarChartData alloc] initWithXVals:xVals dataSets:dataSets];
    _barChartView.data = data;
    
    ChartViewPortHandler *viewPortHandlerBar = _barChartView.viewPortHandler;
    [viewPortHandlerBar setMaximumScaleX:3];
    [viewPortHandlerBar setMinimumScaleX:1];
    [_barChartView setVisibleXRangeMinimum:60];
    [_barChartView setVisibleXRangeMaximum:180];
    
    [_barChartView moveViewToX:dataArray.count - 1];
    [_barChartView notifyDataSetChanged];
    [_barChartView invalidateIntrinsicContentSize];

}

#pragma mark - ChartViewDelegate

//选中

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight {
    NSLog(@"chartValueSelected");

//    if (chartView == _barChartView) {
//        return;
//    }
    NSInteger clickIndex = entry.xIndex;
//    [_barChartView. objectAtIndex:clickIndex];
//    [_barChartView highlightValueWithX:6 dataSetIndex:clickIndex callDelegate:NO];
//    _stickChartView.dragEnabled = NO;
    dispatch_main_sync_safe(^(){
        if (clickIndex < dataArray.count) {
            if (_kChartViewDelegate && [_kChartViewDelegate respondsToSelector:@selector(didSelectChart:)]) {
                NSDictionary *dict = [dataArray objectAtIndex:clickIndex];
                [_kChartViewDelegate didSelectChart:dict];
            }
        }
    });
}

//取消选中
- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView {
//    _stickChartView.dragEnabled = YES;

}

//缩放回调
- (void)chartScaled:(ChartViewBase *)chartView scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY{
    if (chartView == _stickChartView) {
//        [_barChartView zoom:<#(CGFloat)#> scaleY:<#(CGFloat)#> x:<#(CGFloat)#> y:<#(CGFloat)#>:scaleX scaleY:scaleY];

    }else{
//        [_stickChartView zoomToCenterWithScaleX:scaleX scaleY:scaleY];
    }
}

//拖动回调
- (void)chartTranslated:(ChartViewBase *)chartView dX:(CGFloat)dX dY:(CGFloat)dY{
    if (chartView == _stickChartView) {
//        [_barChartView.delecgate chartTranslated:_barChartView dX:dX dY:dY];
//        [_barChartView moveViewToX:chartView.chartXMax];
//        [_barChartView setNeedsDisplay];
    }else{
//        [_stickChartView.delegate chartTranslated:_stickChartView dX:dX dY:dY];
    }
}
//x轴标签
- (NSString *)stringForValue:(double)value
                        axis:(ChartAxisBase *)axis {
        return months[(int)value % months.count];
}

/*设置量表对齐*/
- (void) setOffSet{
    float lineLeft = _stickChartView.viewPortHandler.offsetLeft;
    float barLeft = _barChartView.viewPortHandler.offsetLeft;
    float lineRight = _stickChartView.viewPortHandler.offsetRight;
    float barRight = _barChartView.viewPortHandler.offsetRight;
    float barBottom = _barChartView.viewPortHandler.offsetBottom;
//    float offset,Left, offsetRight;
    float transLeft = 0, transRight = 0;
    
    /*注：setExtraLeft...函数是针对图表相对位置计算，比如A表offLeftA=20dp,B表offLeftB=30dp,则A.setExtraLeftOffset(10),并不是30，还有注意单位转换*/
    if (barLeft < lineLeft) {
        /* offsetLeft = Utils.convertPixelsToDp(lineLeft - barLeft);
         barChart.setExtraLeftOffset(offsetLeft);*/
        transLeft = lineLeft;
    } else {
        transLeft = barLeft;
    }
    /*注：setExtraRight...函数是针对图表绝对位置计算，比如A表offRightA=20dp,B表offRightB=30dp,则A.setExtraLeftOffset(30),并不是10，还有注意单位转换*/
    if (barRight < lineRight) {
        /*  offsetRight = Utils.convertPixelsToDp(lineRight);
         barChart.setExtraRightOffset(offsetRight);*/
        transRight = lineRight;
    } else {
        transRight = barRight;
    }
    [_barChartView setViewPortOffsetsWithLeft:transLeft top:15 right:transRight bottom:barBottom];
    [_barChartView notifyDataSetChanged];
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
