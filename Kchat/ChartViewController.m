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
    ChartViewBase *srcChart;
    ChartViewBase *dstChart;
    double clickTime;
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
    _stickChartView.autoScaleMinMaxEnabled = YES;
    _barChartView.autoScaleMinMaxEnabled = YES;

    [self setOffSet];
}

- (void)initStickChartView{
    
    _stickChartView.delegate = self;
    _stickChartView.borderLineWidth = 0.5;
    _stickChartView.drawBordersEnabled = YES;
    _stickChartView.descriptionText = @"";
    _stickChartView.scaleYEnabled = NO;
    _stickChartView.scaleXEnabled = YES;
    _stickChartView.dragEnabled = YES;
    _stickChartView.doubleTapToZoomEnabled = NO;
    _stickChartView.highlightPerTapEnabled = NO;
//    _stickChartView.highlightFullBarEnabled = YES;
//    _stickChartView.highlightPerDragEnabled = NO;
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [longGesture setDelaysTouchesBegan:NO];
    [_stickChartView addGestureRecognizer:longGesture];
    //x轴
    ChartXAxis *xAxis = _stickChartView.xAxis;
    xAxis.drawLabelsEnabled = YES;
    xAxis.drawGridLinesEnabled = NO;
    xAxis.drawAxisLineEnabled = NO;
    [xAxis setGridLineDashLengths:@[@(3), @(2), @(0)]];
    [xAxis setLabelTextColor:[UIColor colorWithRed:45/255. green:57/255. blue:69/255. alpha:1]];
    [xAxis setGridColor:[UIColor colorWithRed:151/255. green:133/255. blue:147/255. alpha:1]];
    xAxis.labelPosition = XAxisLabelPositionBottom;
    //左Y轴
    ChartYAxis *leftAxis = _stickChartView.leftAxis;
    leftAxis.labelCount = 5;
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
    leftAxis.spaceTop = 0;
    //右Y轴
    ChartYAxis *rightAxis = _stickChartView.rightAxis;
    rightAxis.labelCount = 4;
    rightAxis.drawLabelsEnabled = NO;
    rightAxis.drawZeroLineEnabled = NO;
    rightAxis.drawGridLinesEnabled = NO;
    [rightAxis setGridColor:[UIColor colorWithRed:151/255. green:133/255. blue:147/255. alpha:1]];
    //不显示标题
    _stickChartView.legend.enabled = NO;
    _stickChartView.dragDecelerationEnabled = YES;

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
    _barChartView.scaleXEnabled = YES;
    _barChartView.highlightPerTapEnabled = NO;
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [longGesture setDelaysTouchesBegan:NO];
    [_barChartView addGestureRecognizer:longGesture];
    //X轴
    ChartXAxis *xAxis = _barChartView.xAxis;
    xAxis.drawLabelsEnabled = NO;
    xAxis.drawGridLinesEnabled = NO;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelTextColor = [UIColor darkGrayColor];
    xAxis.gridColor = [UIColor grayColor];
    
    
    NSNumberFormatter *leftAxisFormatter = [[NSNumberFormatter alloc] init];
    leftAxisFormatter.minimumFractionDigits = 0;
    leftAxisFormatter.maximumFractionDigits = 1;
    
    //Y轴 左
    ChartYAxis *leftAxis = _barChartView.leftAxis;
    leftAxis.drawGridLinesEnabled = YES;
    leftAxis.drawAxisLineEnabled = NO;
    leftAxis.labelTextColor = [UIColor darkGrayColor];
    leftAxis.drawLabelsEnabled = YES;
    [leftAxis setGridLineDashLengths:@[@(3), @(2), @(0)]];
    leftAxis.labelCount = 2;
//    leftAxis.axisMinValue = 0;
    leftAxis.showOnlyMinMaxEnabled = NO;
    leftAxis.valueFormatter = leftAxisFormatter;
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
//    leftAxis.spaceTop = 5;
    
    //    _barChartView.rightAxis.enabled = NO;
    _barChartView.rightAxis.drawAxisLineEnabled = NO;
    _barChartView.rightAxis.drawLabelsEnabled = NO;
    _barChartView.rightAxis.drawGridLinesEnabled = NO;
    
    _barChartView.dragDecelerationEnabled = YES;
//    _barChartView.dragDecelerationFrictionCoef = 0.2f;
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
    
//    months = [NSArray arrayWithArray:xVals1];
    
    CandleChartDataSet *set1 = [[CandleChartDataSet alloc] initWithYVals:yVals1 label:@"kchart"];
    set1.barSpace = 0.1;
    set1.drawHorizontalHighlightIndicatorEnabled = NO;
    set1.highlightEnabled = YES;
    set1.showCandleBar = YES;
    set1.highlightColor = [UIColor darkGrayColor];
    set1.valueFont = [UIFont systemFontOfSize:10.0f];
    set1.drawValuesEnabled = NO;
    set1.decreasingColor = [UIColor colorWithRed:44/255.f green:185/255.f blue:80/255.f alpha:1.f];
    set1.decreasingFilled = YES;
    set1.increasingColor = [UIColor colorWithRed:211/255.f green:61/255.f blue:50/255.f alpha:1.f];
    set1.increasingFilled = YES;
    [set1 setDrawHighlightIndicators:YES];
    set1.highlightLineWidth = 0.5;
    set1.neutralColor = [UIColor colorWithRed:44/255. green:185/255 blue:80/255. alpha:1];
    set1.axisDependency = AxisDependencyLeft;
    set1.shadowWidth = 0.2;
    set1.shadowColorSameAsCandle = YES;
    CandleChartData *data = [[CandleChartData alloc] initWithXVals:xVals1 dataSet:set1];
    _stickChartView.data = data;
    

    ChartViewPortHandler *viewPortHandlerBar = _stickChartView.viewPortHandler;
    [viewPortHandlerBar setMaximumScaleX:6];
    [_stickChartView setVisibleXRangeMaximum:180];
    [viewPortHandlerBar refreshWithNewMatrix:[viewPortHandlerBar setZoomWithScaleX:3 scaleY:1] chart:_stickChartView invalidate:YES];

    [_stickChartView moveViewToX:dataArray.count - 1];
    [_stickChartView notifyDataSetChanged];
    [_stickChartView invalidateIntrinsicContentSize];

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
    
    BarChartDataSet *set1 = [[BarChartDataSet alloc] initWithYVals:yVals label:@"kchart"];
    set1.barSpace = 0.5f;
    set1.highlightEnabled = YES;
    set1.highlightAlpha = 1;
    set1.highlightColor = [UIColor darkGrayColor];
    set1.highlightLineWidth = 0.5;
    set1.drawValuesEnabled = NO;
    [set1 setColor:[UIColor colorWithRed:145/255. green:199/255. blue:147/255. alpha:1]];
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    BarChartData *data = [[BarChartData alloc] initWithXVals:xVals dataSets:dataSets];
    _barChartView.data = data;
    
    ChartViewPortHandler *viewPortHandlerBar = _barChartView.viewPortHandler;
    [viewPortHandlerBar setMaximumScaleX:6];
    [_barChartView setVisibleXRangeMaximum:180];
    [viewPortHandlerBar refreshWithNewMatrix:[viewPortHandlerBar setZoomWithScaleX:3 scaleY:1] chart:_barChartView invalidate:YES];

    
    [_barChartView moveViewToX:dataArray.count - 1];
    [_barChartView invalidateIntrinsicContentSize];
    [_barChartView setNeedsDisplay];

}

#pragma mark - ChartViewDelegate

//选中

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * __nonnull)highlight {

    if (chartView == _stickChartView) {
        [_barChartView highlightValueWithXIndex:entry.xIndex dataSetIndex:dataSetIndex callDelegate:NO];

    } else {
        [_stickChartView highlightValueWithXIndex:entry.xIndex dataSetIndex:dataSetIndex callDelegate:NO];
    }
    [_stickChartView setNeedsDisplay];
    [_barChartView setNeedsDisplay];

    NSInteger clickIndex = entry.xIndex;

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

    [_stickChartView highlightValues:nil];
    [_barChartView highlightValues:nil];
}

//缩放回调
- (void)chartScaled:(ChartViewBase *)chartView scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY{
    
    if (chartView == _stickChartView) {
        
        srcChart = _stickChartView;
        dstChart = _barChartView;
    }else{
        srcChart = _barChartView;
        dstChart = _stickChartView;
    }
    [self syncCharts];

}

//拖动回调
- (void)chartTranslated:(ChartViewBase *)chartView dX:(CGFloat)dX dY:(CGFloat)dY{
    
    
    if (chartView == _stickChartView) {
        
        srcChart = _stickChartView;
        dstChart = _barChartView;
        
    }else{
        srcChart = _barChartView;
        dstChart = _stickChartView;
    }
    
    [self syncCharts];
}

- (void)syncCharts {
    CGAffineTransform srcMatrix;
    CGAffineTransform dstMatrix;
    
    // get src chart translation matrix:
    srcMatrix = srcChart.viewPortHandler.touchMatrix;
    
    // apply X axis scaling and position to dst charts:

    dstMatrix = [dstChart.viewPortHandler refreshWithNewMatrix:srcMatrix chart:dstChart invalidate:YES];
    
    [srcChart setNeedsLayout];
    [dstChart setNeedsLayout];
  
}
//x轴标签
//- (NSString *)stringForValue:(double)value
//                        axis:(ChartAxisBase *)axis {
//        return months[(int)value % months.count];
//}

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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
//    UITouch *touch = [touches anyObject];
//
//    clickTime = touch.timestamp;
    
}

- (void)longPress:(UIGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"longPress==%@",@"begin");
        _stickChartView.dragEnabled = NO;
        _barChartView.dragEnabled = NO;
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        NSLog(@"longPress==%@",@"change");
        UIView *view = gesture.view;
        ChartDataEntry *entry;

        if (view == _stickChartView) {
            entry = [_stickChartView getEntryByTouchPoint:[gesture locationInView:_stickChartView]];
            
            [_stickChartView.delegate chartValueSelected:_stickChartView entry:entry dataSetIndex:0 highlight:[[ChartHighlight alloc] initWithXIndex:entry.xIndex dataSetIndex:0]];
            
            
        } else {
            entry = [_barChartView getEntryByTouchPoint:[gesture locationInView:_barChartView]];
            [_barChartView.delegate chartValueSelected:_barChartView entry:entry dataSetIndex:0 highlight:[[ChartHighlight alloc] initWithXIndex:entry.xIndex dataSetIndex:0]];
        }
        [_stickChartView highlightValue:[[ChartHighlight alloc]initWithXIndex:entry.xIndex dataSetIndex:0]];
        [_barChartView highlightValue:[[ChartHighlight alloc]initWithXIndex:entry.xIndex dataSetIndex:0]];
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        NSLog(@"longPress==%@",@"end");
        [_stickChartView.delegate chartValueNothingSelected:_stickChartView];
        [_barChartView.delegate chartValueNothingSelected:_barChartView];
        if ([dataArray.lastObject isKindOfClass:[NSDictionary class]]) {
            if (_kChartViewDelegate && [_kChartViewDelegate respondsToSelector:@selector(didSelectChart:)]) {
                [_kChartViewDelegate didSelectChart:dataArray.lastObject];
                
            }
        }
        _stickChartView.dragEnabled = YES;
        _barChartView.dragEnabled = YES;
    }

    
   }

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    return;
    double diff = [touches anyObject].timestamp - clickTime;
    //当时间间隔<=1时，判断为短按。另外还要取消 performSelector...指定的延迟消息。 不然longPress总会调用
    if (diff <= 1) {
        NSLog(@"short%@",@"");
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(longPress) object:nil];
    }else{
        [_stickChartView.delegate chartValueNothingSelected:_stickChartView];
        [_barChartView.delegate chartValueNothingSelected:_barChartView];
        if ([dataArray.lastObject isKindOfClass:[NSDictionary class]]) {
            if (_kChartViewDelegate && [_kChartViewDelegate respondsToSelector:@selector(didSelectChart:)]) {
                [_kChartViewDelegate didSelectChart:dataArray.lastObject];
                
            }
        }

    }
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    return;
    UITouch *touch = [touches anyObject];
    UIView *view = [touch view];
    ChartDataEntry *entry;
    if (view == _stickChartView) {
        entry = [_stickChartView getEntryByTouchPoint:[touch locationInView:_stickChartView]];
        
        [_stickChartView.delegate chartValueSelected:_stickChartView entry:entry dataSetIndex:0 highlight:[[ChartHighlight alloc] initWithXIndex:entry.xIndex dataSetIndex:0]];
        
       
    } else {
        entry = [_barChartView getEntryByTouchPoint:[touch locationInView:_barChartView]];
        [_barChartView.delegate chartValueSelected:_barChartView entry:entry dataSetIndex:0 highlight:[[ChartHighlight alloc] initWithXIndex:entry.xIndex dataSetIndex:0]];
    }
    [_stickChartView highlightValue:[[ChartHighlight alloc]initWithXIndex:entry.xIndex dataSetIndex:0]];
    [_barChartView highlightValue:[[ChartHighlight alloc]initWithXIndex:entry.xIndex dataSetIndex:0]];

//    [self syncCharts];
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
