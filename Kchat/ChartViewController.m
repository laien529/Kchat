//
//  ChartViewController.m
//  Kchat
//
//  Created by csc on 2016/9/25.
//  Copyright © 2016年 cedric cheng. All rights reserved.
//

#import "ChartViewController.h"
#import "AFNetworking.h"
#import "ResourceHelper.h"
#import "JSONKit.h"
#import "Kchat-Swift.h"
#import "DayAxisValueFormatter.h"

#define ITEM_COUNT 12

@interface ChartViewController ()<ChartViewDelegate,IChartAxisValueFormatter>{
    AFHTTPSessionManager *afmanager;
}
@property (nonatomic, strong) IBOutlet BarChartView *barChartView;
@property (nonatomic, strong) IBOutlet CandleStickChartView *stickChartView;


@end

@implementation ChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.req_freq   = @"d";
    self.req_type   = @"H";
    self.req_url    = @"http://ichart.yahoo.com/table.csv?s=600019.SS&g=d";
    months = @[@"2016/09/09",@"2016/09/09",@"2016/09/09",@"2016/09/09",@"2016/09/11"];
    [self initBarChartView];
    [self initStickChartView];
}

- (void)initBarChartView {
    [self setupBarLineChartView:_barChartView];
    
    _barChartView.delegate = self;
    
    _barChartView.drawBarShadowEnabled = NO;
    _barChartView.drawValueAboveBarEnabled = YES;
    _barChartView.maxVisibleCount = 60;
    _barChartView.highlightFullBarEnabled = NO;
    ChartXAxis *xAxis = _barChartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.labelFont = [UIFont systemFontOfSize:10.f];
    xAxis.drawGridLinesEnabled = NO;
    xAxis.granularity = 1.0; // only intervals of 1 day
    xAxis.labelCount = 7;
    xAxis.valueFormatter = self;
    
    NSNumberFormatter *leftAxisFormatter = [[NSNumberFormatter alloc] init];
    leftAxisFormatter.minimumFractionDigits = 0;
    leftAxisFormatter.maximumFractionDigits = 1;
//    leftAxisFormatter.negativeSuffix = @" t";
    leftAxisFormatter.positiveSuffix = @" t";
    
    ChartYAxis *leftAxis = _barChartView.leftAxis;
    leftAxis.labelFont = [UIFont systemFontOfSize:10.f];
    leftAxis.labelCount = 3;
    leftAxis.valueFormatter = [[ChartDefaultAxisValueFormatter alloc] initWithFormatter:leftAxisFormatter];
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;
    leftAxis.spaceTop = 0.15;
    leftAxis.axisMinimum = 1.0; // this replaces startAtZero = YES
    
    ChartYAxis *rightAxis = _barChartView.rightAxis;
    rightAxis.enabled = NO;
    rightAxis.drawGridLinesEnabled = YES;
    rightAxis.labelFont = [UIFont systemFontOfSize:10.f];
    rightAxis.labelCount = 8;
    rightAxis.valueFormatter = leftAxis.valueFormatter;
    rightAxis.spaceTop = 0.15;
    rightAxis.axisMinimum = 1.0; // this replaces startAtZero = YES
    
    ChartLegend *l = _barChartView.legend;
    l.horizontalAlignment = ChartLegendHorizontalAlignmentLeft;
    l.verticalAlignment = ChartLegendVerticalAlignmentBottom;
    l.orientation = ChartLegendOrientationHorizontal;
    l.drawInside = NO;
    l.form = ChartLegendFormDefault;
    l.formSize = 9.0;
    l.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
    l.xEntrySpace = 4.0;
    
    XYMarkerView *marker = [[XYMarkerView alloc]
                            initWithColor: [UIColor colorWithWhite:180/255. alpha:1.0]
                            font: [UIFont systemFontOfSize:12.0]
                            textColor: UIColor.whiteColor
                            insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0)
                            xAxisValueFormatter: _barChartView.xAxis.valueFormatter];
    marker.chartView = _barChartView;
    marker.minimumSize = CGSizeMake(80.f, 40.f);
//    _barChartView.marker = marker;
    [self updateBarChartData];
}

- (void)initStickChartView{
    _stickChartView.delegate = self;
    
    _stickChartView.chartDescription.enabled = NO;
    
    _stickChartView.maxVisibleCount = 30;
    _stickChartView.pinchZoomEnabled = NO;
    _stickChartView.drawGridBackgroundEnabled = NO;
    
    ChartXAxis *xAxis = _stickChartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionBottom;
    xAxis.drawGridLinesEnabled = NO;
    xAxis.valueFormatter = self;
    ChartYAxis *leftAxis = _stickChartView.leftAxis;
    leftAxis.labelCount = 4;
    leftAxis.drawGridLinesEnabled = YES;
    leftAxis.drawAxisLineEnabled = YES  ;
    
    ChartYAxis *rightAxis = _stickChartView.rightAxis;
    rightAxis.enabled = NO;
    
    _stickChartView.legend.enabled = NO;
    [self updateStickChartData];

}
- (void)viewWillAppear:(BOOL)animated{
}

/*
-(void)getData{
    self.status.text = @"Loading...";
    if(_chartMode == 0){
        [self.candleChart getSection:2].hidden = YES;
    }else{
        [self.candleChart getSection:2].hidden = NO;
    }
//    NSString *reqURL = [[NSString alloc] initWithFormat:self.req_url];
    NSLog(@"url:%@",self.req_url);
    
    NSURL *url = [NSURL URLWithString:[self.req_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    afmanager = [AFHTTPSessionManager manager];
    afmanager.responseSerializer = [AFHTTPResponseSerializer serializer];

//    afmanager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/csv", nil];
//        afmanager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", nil];

    [afmanager GET:_req_url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *res = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"responseObject==%@",responseObject);
        [self requestFinished:res];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)requestFinished:(NSString*)response
{
    self.status.text = @"";
    NSMutableArray *data =[[NSMutableArray alloc] init];
    NSMutableArray *category =[[NSMutableArray alloc] init];
    
    NSString *content = response;
    NSArray *lines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSInteger idx;
    for (idx = lines.count-1; idx > 0; idx--) {
        NSString *line = lines[idx];
        if([line isEqualToString:@""]){
            continue;
        }
        NSArray   *arr = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        [category addObject:arr[0]];
        
        NSMutableArray *item =[[NSMutableArray alloc] init];
        [item addObject:arr[1]];
        [item addObject:arr[4]];
        [item addObject:arr[2]];
        [item addObject:arr[3]];
        [item addObject:arr[5]];
        [data addObject:item];
    }
    
    if(data.count==0){
        self.status.text = @"Error!";
        return;
    }
    
    if (_chartMode == 0) {
        if([self.req_type isEqualToString:@"T"]){
//            if(self.timer != nil){
//                [self.timer invalidate];
//            }
            [self.candleChart reset];
            [self.candleChart clearData];
            [self.candleChart clearCategory];
            
            if([self.req_freq hasSuffix:@"m"]){
                self.req_type = @"L";
//                self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(getData) userInfo:nil repeats:YES];
            }
        }else{
//            NSString *time = category[0];
//            if([time isEqualToString:self.lastTime]){
//                if([time hasSuffix:@"1500"]){
//                    if(self.timer != nil){
//                        [self.timer invalidate];
//                    }
//                }
//                return;
//            }
//            if ([time hasSuffix:@"1130"] || [time hasSuffix:@"1500"]) {
//                if(self.tradeStatus == 1){
//                    self.tradeStatus = 0;
//                }
//            }else{
//                self.tradeStatus = 1;
//            }
        }
    }else{
//        if(self.timer != nil){
//            [self.timer invalidate];
//        }
        [self.candleChart reset];
        [self.candleChart clearData];
        [self.candleChart clearCategory];
    }
    
    self.lastTime = [category lastObject];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [self generateData:dic From:data];
    [self setData:dic];
    
    if(_chartMode == 0){
        [self setCategory:category];
    }else{
        NSMutableArray *cate = [[NSMutableArray alloc] init];
        for(int i=60;i<category.count;i++){
            [cate addObject:category[i]];
        }
        [self setCategory:cate];
    }
    
    [self.candleChart setNeedsDisplay];
}
*/

/*
-(void)setData:(NSDictionary *)dic{
    [self.candleChart appendToData:dic[@"price"] forName:@"price"];
    [self.candleChart appendToData:dic[@"vol"] forName:@"vol"];
    
    [self.candleChart appendToData:dic[@"ma10"] forName:@"ma10"];
    [self.candleChart appendToData:dic[@"ma30"] forName:@"ma30"];
    [self.candleChart appendToData:dic[@"ma60"] forName:@"ma60"];
    
    [self.candleChart appendToData:dic[@"rsi6"] forName:@"rsi6"];
    [self.candleChart appendToData:dic[@"rsi12"] forName:@"rsi12"];
    
    [self.candleChart appendToData:dic[@"wr"] forName:@"wr"];
    [self.candleChart appendToData:dic[@"vr"] forName:@"vr"];
    
    [self.candleChart appendToData:dic[@"kdj_k"] forName:@"kdj_k"];
    [self.candleChart appendToData:dic[@"kdj_d"] forName:@"kdj_d"];
    [self.candleChart appendToData:dic[@"kdj_j"] forName:@"kdj_j"];
    
    NSMutableDictionary *serie = [self.candleChart getSerie:@"price"];
    if(serie == nil)
        return;
    if(self.chartMode == 1){
        serie[@"type"] = @"candle";
    }else{
        serie[@"type"] = @"line";
    }
}

-(void)setCategory:(NSArray *)category{
    [self.candleChart appendToCategory:category forName:@"price"];
    [self.candleChart appendToCategory:category forName:@"line"];
    
}
*/
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
    if (self.shouldHideData)
    {
        _barChartView.data = nil;
        return;
    }
    
    [self setBarDataCount:30 range:30];
}
- (void)updateStickChartData
{
    if (self.shouldHideData)
    {
        _stickChartView.data = nil;
        return;
    }
    
    [self setStickDataCount:80 + 1 range:80];
}

- (void)setBarDataCount:(int)count range:(double)range
{
    double start = 0.0;
    
    _barChartView.xAxis.axisMinimum = start;
    _barChartView.xAxis.axisMaximum = start + count + 2;
    
    NSMutableArray *yVals = [[NSMutableArray alloc] init];
    
    for (int i = start; i < start + count + 1; i++)
    {
        double mult = (range + 1);
        double val = (double) (arc4random_uniform(mult));
        [yVals addObject:[[BarChartDataEntry alloc] initWithX:(double)i + 1.0 y:val]];
    }
    
    BarChartDataSet *set1 = nil;
    if (_barChartView.data.dataSetCount > 0)
    {
        set1 = (BarChartDataSet *)_barChartView.data.dataSets[0];
        set1.values = yVals;
        [_barChartView.data notifyDataChanged];
        [_barChartView notifyDataSetChanged];
    }
    else
    {
        set1 = [[BarChartDataSet alloc] initWithValues:yVals label:@"The year 2017"];
        [set1 setColor:[UIColor blueColor]];
        
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        
        BarChartData *data = [[BarChartData alloc] initWithDataSets:dataSets];
        [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];
        
        data.barWidth = 0.9f;
        
        _barChartView.data = data;
    }

}

- (void)setStickDataCount:(int)count range:(double)range
{
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < count; i++)
    {
        double mult = (range + 1);
        double val = (double) (arc4random_uniform(40)) + mult;
        double high = (double) (arc4random_uniform(9)) + 8.0;
        double low = (double) (arc4random_uniform(9)) + 8.0;
        double open = (double) (arc4random_uniform(6)) + 1.0;
        double close = (double) (arc4random_uniform(6)) + 1.0;
        BOOL even = i % 2 == 0;
        [yVals1 addObject:[[CandleChartDataEntry alloc] initWithX:i shadowH:val + high shadowL:val - low open:even ? val + open : val - open close:even ? val - close : val + close]];
    }
    
    CandleChartDataSet *set1 = [[CandleChartDataSet alloc] initWithValues:yVals1 label:@"Data Set"];
    set1.axisDependency = AxisDependencyLeft;
    [set1 setColor:[UIColor colorWithWhite:80/255.f alpha:1.f]];
    
    set1.shadowColor = UIColor.darkGrayColor;
    set1.shadowWidth = 0.7;
    set1.decreasingColor = UIColor.redColor;
    set1.decreasingFilled = YES;
    set1.increasingColor = [UIColor colorWithRed:122/255.f green:242/255.f blue:84/255.f alpha:1.f];
    set1.increasingFilled = NO;
    set1.neutralColor = UIColor.blueColor;
    
    CandleChartData *data = [[CandleChartData alloc] initWithDataSet:set1];
    
    _stickChartView.data = data;
}

- (void)optionTapped:(NSString *)key
{
    [super handleOption:key forChartView:_barChartView];
}

- (LineChartData *)generateLineData
{
    LineChartData *d = [[LineChartData alloc] init];
    
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < ITEM_COUNT; index++)
    {
        [entries addObject:[[ChartDataEntry alloc] initWithX:index + 0.5 y:(arc4random_uniform(15) + 5)]];
    }
    
    LineChartDataSet *set = [[LineChartDataSet alloc] initWithValues:entries label:@"Line DataSet"];
    [set setColor:[UIColor colorWithRed:240/255.f green:238/255.f blue:70/255.f alpha:1.f]];
    set.lineWidth = 2.5;
    [set setCircleColor:[UIColor colorWithRed:240/255.f green:238/255.f blue:70/255.f alpha:1.f]];
    set.circleRadius = 5.0;
    set.circleHoleRadius = 2.5;
    set.fillColor = [UIColor colorWithRed:240/255.f green:238/255.f blue:70/255.f alpha:1.f];
    set.mode = LineChartModeCubicBezier;
    set.drawValuesEnabled = YES;
    set.valueFont = [UIFont systemFontOfSize:10.f];
    set.valueTextColor = [UIColor colorWithRed:240/255.f green:238/255.f blue:70/255.f alpha:1.f];
    
    set.axisDependency = AxisDependencyLeft;
    
    [d addDataSet:set];
    
    return d;
}
- (BarChartData *)generateBarData
{
    NSMutableArray<BarChartDataEntry *> *entries1 = [[NSMutableArray alloc] init];
    NSMutableArray<BarChartDataEntry *> *entries2 = [[NSMutableArray alloc] init];
    
    for (int index = 0; index < ITEM_COUNT; index++)
    {
        [entries1 addObject:[[BarChartDataEntry alloc] initWithX:0.0 y:(arc4random_uniform(25) + 25)]];
        
        // stacked
        [entries2 addObject:[[BarChartDataEntry alloc] initWithX:0.0 yValues:@[@(arc4random_uniform(13) + 12), @(arc4random_uniform(13) + 12)]]];
    }
    
    BarChartDataSet *set1 = [[BarChartDataSet alloc] initWithValues:entries1 label:@"Bar 1"];
    [set1 setColor:[UIColor colorWithRed:60/255.f green:220/255.f blue:78/255.f alpha:1.f]];
    set1.valueTextColor = [UIColor colorWithRed:60/255.f green:220/255.f blue:78/255.f alpha:1.f];
    set1.valueFont = [UIFont systemFontOfSize:10.f];
    set1.axisDependency = AxisDependencyLeft;
    
    BarChartDataSet *set2 = [[BarChartDataSet alloc] initWithValues:entries2 label:@""];
    set2.stackLabels = @[@"Stack 1"];
    set2.colors = @[
                    [UIColor colorWithRed:61/255.f green:165/255.f blue:255/255.f alpha:1.f],
                    [UIColor colorWithRed:23/255.f green:197/255.f blue:255/255.f alpha:1.f]
                    ];
    set2.valueTextColor = [UIColor colorWithRed:61/255.f green:165/255.f blue:255/255.f alpha:1.f];
    set2.valueFont = [UIFont systemFontOfSize:10.f];
    set2.axisDependency = AxisDependencyLeft;
    
    float groupSpace = 0.06f;
    float barSpace = 0.02f; // x2 dataset
    float barWidth = 0.2f; // x2 dataset
    // (0.45 + 0.02) * 2 + 0.06 = 1.00 -> interval per "group"
    
    BarChartData *d = [[BarChartData alloc] initWithDataSets:@[set1]];
    d.barWidth = barWidth;
    
    // make this BarData object grouped
    [d groupBarsFromX:0.0 groupSpace:groupSpace barSpace:barSpace]; // start at x = 0
    
    return d;
}
#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

- (NSString *)stringForValue:(double)value
                        axis:(ChartAxisBase *)axis
{
    if (_barChartView.xAxis) {
        return months[(int)value % months.count];

    } else {
        return months[(int)value % months.count];
    }
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
