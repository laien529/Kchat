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

@interface ChartViewController (){
    AFHTTPSessionManager *afmanager;
}

@end

@implementation ChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //add notification observer
//    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//    [center addObserver:self selector:@selector(doNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    self.view.backgroundColor = [UIColor greenColor];
    //init vars
    self.chartMode  = 1; //1,candleChart
    self.tradeStatus= 1;
    self.req_freq   = @"d";
    self.req_type   = @"H";
    self.req_url    = @"http://ichart.yahoo.com/table.csv?s=600019.SS&g=d";
    
    //candleChart
    _candleChart = [[Chart alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:_candleChart];
    //init chart
    [self initChart];
    [self getData];
}


- (void)viewWillAppear:(BOOL)animated{
}

- (void)initChart{
    NSMutableArray *padding = [@[@"20", @"20", @"20", @"20"] mutableCopy];
    [self.candleChart setPadding:padding];
    NSMutableArray *secs = [[NSMutableArray alloc] init];
    [secs addObject:@"4"];
    [secs addObject:@"1"];
    [secs addObject:@"1"];
    [self.candleChart addSections:3 withRatios:secs];
    [self.candleChart getSection:2].hidden = YES;
    [[self.candleChart sections][0] addYAxis:0];
    [[self.candleChart sections][1] addYAxis:0];
    [[self.candleChart sections][2] addYAxis:0];
    
    [self.candleChart getYAxis:2 withIndex:0].baseValueSticky = NO;
    [self.candleChart getYAxis:2 withIndex:0].symmetrical = NO;
    [self.candleChart getYAxis:0 withIndex:0].ext = 0.05;
    NSMutableArray *series = [[NSMutableArray alloc] init];
    NSMutableArray *secOne = [[NSMutableArray alloc] init];
    NSMutableArray *secTwo = [[NSMutableArray alloc] init];
    NSMutableArray *secThree = [[NSMutableArray alloc] init];
    
    //price
    NSMutableDictionary *serie = [[NSMutableDictionary alloc] init];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    serie[@"name"] = @"price";
    serie[@"label"] = @"Price";
    serie[@"data"] = data;
    serie[@"type"] = @"candle";
    serie[@"yAxis"] = @"0";
    serie[@"section"] = @"0";
    serie[@"color"] = @"249,222,170";
    serie[@"negativeColor"] = @"249,222,170";
    serie[@"selectedColor"] = @"249,222,170";
    serie[@"negativeSelectedColor"] = @"249,222,17/**/0";
    serie[@"labelColor"] = @"176,52,52";
    serie[@"labelNegativeColor"] = @"77,143,42";
    [series addObject:serie];
    [secOne addObject:serie];
    
    //MA10
    serie = [[NSMutableDictionary alloc] init];
    data = [[NSMutableArray alloc] init];
    serie[@"name"] = @"ma10";
    serie[@"label"] = @"MA10";
    serie[@"data"] = data;
    serie[@"type"] = @"line";
    serie[@"yAxis"] = @"0";
    serie[@"section"] = @"0";
    serie[@"color"] = @"255,255,255";
    serie[@"negativeColor"] = @"255,255,255";
    serie[@"selectedColor"] = @"255,255,255";
    serie[@"negativeSelectedColor"] = @"255,255,255";
    [series addObject:serie];
    [secOne addObject:serie];
    
    //MA30
    serie = [[NSMutableDictionary alloc] init];
    data = [[NSMutableArray alloc] init];
    serie[@"name"] = @"ma30";
    serie[@"label"] = @"MA30";
    serie[@"data"] = data;
    serie[@"type"] = @"line";
    serie[@"yAxis"] = @"0";
    serie[@"section"] = @"0";
    serie[@"color"] = @"250,232,115";
    serie[@"negativeColor"] = @"250,232,115";
    serie[@"selectedColor"] = @"250,232,115";
    serie[@"negativeSelectedColor"] = @"250,232,115";
    [series addObject:serie];
    [secOne addObject:serie];
    
    //MA60
    serie = [[NSMutableDictionary alloc] init];
    data = [[NSMutableArray alloc] init];
    serie[@"name"] = /**/@"ma60";
    serie[@"label"] = @"MA60";
    serie[@"data"] = data;
    serie[@"type"] = @"line";
    serie[@"yAxis"] = @"0";
    serie[@"section"] = @"0";
    serie[@"color"] = @"232,115,250";
    serie[@"negativeColor"] = @"232,115,250";
    serie[@"selectedColor"] = @"232,115,250";
    serie[@"negativeSelectedColor"] = @"232,115,250";
    [series addObject:serie];
    [secOne addObject:serie];
    
    
    //VOL
    serie = [[NSMutableDictionary alloc] init];
    data = [[NSMutableArray alloc] init];
    serie[@"name"] = @"vol";
    serie[@"label"] = @"VOL";
    serie[@"data"] = data;
    serie[@"type"] = @"column";
    serie[@"yAxis"] = @"0";
    serie[@"section"] = @"1";
    serie[@"decimal"] = @"0";
    serie[@"color"] = @"176,52,52";
    serie[@"negativeColor"] = @"77,143,42";
    serie[@"selectedColor"] = @"176,52,52";
    serie[@"negativeSelectedColor"] = @"77,143,42";
    [series addObject:serie];
    [secTwo addObject:serie];
    
    //candleChart init
    [self.candleChart setSeries:series];
    
    [[self.candleChart sections][0] setSeries:secOne];
    [[self.candleChart sections][1] setSeries:secTwo];
    [[self.candleChart sections][2] setSeries:secThree];
    [[self.candleChart sections][2] setPaging:YES];
    
    
    NSString *indicatorsString =[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"indicators" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    
    if(indicatorsString != nil){
        NSArray *indicators = [indicatorsString objectFromJSONString];
        for(NSObject *indicator in indicators){
            if([indicator isKindOfClass:[NSArray class]]){
                NSMutableArray *arr = [[NSMutableArray alloc] init];
                for(NSDictionary *indic in indicator){
                    NSMutableDictionary *serie = [[NSMutableDictionary alloc] init];
                    [self setOptions:indic ForSerie:serie];
                    [arr addObject:serie];
                }
                [self.candleChart addSerie:arr];
            }else{
                NSDictionary *indic = (NSDictionary *)indicator;
                NSMutableDictionary *serie = [[NSMutableDictionary alloc] init];
                [self setOptions:indic ForSerie:serie];
                [self.candleChart addSerie:serie];
            }
        }
    }
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 10.0/**/;
    pathAnimation.fromValue = @0.0f;
    pathAnimation.toValue = @1.0f;
    [self.candleChart.layer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    
}

-(void)setOptions:(NSDictionary *)options ForSerie:(NSMutableDictionary *)serie;{
    serie[@"name"] = options[@"name"];
    serie[@"label"] = options[@"label"];
    serie[@"type"] = options[@"type"];
    serie[@"yAxis"] = options[@"yAxis"];
    serie[@"section"] = options[@"section"];
    serie[@"color"] = options[@"color"];
    serie[@"negativeColor"] = options[@"negativeColor"];
    serie[@"selectedColor"] = options[@"selectedColor"];
    serie[@"negativeSelectedColor"] = options[@"negativeSelectedColor"];
}

-(BOOL)isCodesExpired{
    NSDate *date = [NSDate date];
    double now = [date timeIntervalSince1970];
    double last = now;
    NSString *autocompTime = (NSString *)[ResourceHelper  getUserDefaults:@"autocompTime"];
    if(autocompTime!=nil){
        last = [autocompTime doubleValue];
        if(now - last >3600*8){
            return YES;
        }else{
            return NO;
        }
    }else{
        return YES;
    }
}

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

-(void)generateData:(NSMutableDictionary *)dic From:(NSArray *)data{
    if(self.chartMode == 1){
        //price
        NSMutableArray *price = [[NSMutableArray alloc] init];
        for(int i = 60;i < data.count;i++){
            [price addObject:data[i]];
        }
        dic[@"price"] = price;
        
        //VOL
        NSMutableArray *vol = [[NSMutableArray alloc] init];
        for(int i = 60;i < data.count;i++){
            NSMutableArray *item = [[NSMutableArray alloc] init];
            [item addObject:[@"" stringByAppendingFormat:@"%f",[[data[i] objectAtIndex:4] floatValue]/100]];
            [vol addObject:item];
        }
        dic[@"vol"] = vol;
        
        //MA 10
        NSMutableArray *ma10 = [[NSMutableArray alloc] init];
        for(int i = 60;i < data.count;i++){
            float val = 0;
            for(int j=i;j>i-10;j--){
                val += [[data[j] objectAtIndex:1] floatValue];
            }
            val = val/10;
            NSMutableArray *item = [[NSMutableArray alloc] init];
            [item addObject:[@"" stringByAppendingFormat:@"%f",val]];
            [ma10 addObject:item];
        }
        dic[@"ma10"] = ma10;
        
        //MA 30
        NSMutableArray *ma30 = [[NSMutableArray alloc] init];
        for(int i = 60;i < data.count;i++){
            float val = 0;
            for(int j=i;j>i-30;j--){
                val += [[data[j] objectAtIndex:1] floatValue];
            }
            val = val/30;
            NSMutableArray *item = [[NSMutableArray alloc] init];
            [item addObject:[@"" stringByAppendingFormat:@"%f",val]];
            [ma30 addObject:item];
        }
        dic[@"ma30"] = ma30;
        
        //MA 60
        NSMutableArray *ma60 = [[NSMutableArray alloc] init];
        for(int i = 60;i < data.count;i++){
            float val = 0;
            for(int j=i;j>i-60;j--){
                val += [[data[j] objectAtIndex:1] floatValue];
            }
            val = val/60;
            NSMutableArray *item = [[NSMutableArray alloc] init];
            [item addObject:[@"" stringByAppendingFormat:@"%f",val]];
            [ma60 addObject:item];
        }
        dic[@"ma60"] = ma60;
        
        //RSI6
        NSMutableArray *rsi6 = [[NSMutableArray alloc] init];
        for(int i = 60;i < data.count;i++){
            float incVal  = 0;
            float decVal = 0;
            float rs = 0;
            for(int j=i;j>i-6;j--){
                float interval = [[data[j] objectAtIndex:1] floatValue]-[[data[j] objectAtIndex:0] floatValue];
                if(interval >= 0){
                    incVal += interval;
                }else{
                    decVal -= interval;
                }
            }
            
            rs = incVal/decVal;
            float rsi =100-100/(1+rs);
            
            NSMutableArray *item = [[NSMutableArray alloc] init];
            [item addObject:[@"" stringByAppendingFormat:@"%f",rsi]];
            [rsi6 addObject:item];
            
        }
        dic[@"rsi6"] = rsi6;
        
        //RSI12
        NSMutableArray *rsi12 = [[NSMutableArray alloc] init];
        for(int i = 60;i < data.count;i++){
            float incVal  = 0;
            float decVal = 0;
            float rs = 0;
            for(int j=i;j>i-12;j--){
                float interval = [[data[j] objectAtIndex:1] floatValue]-[[data[j] objectAtIndex:0] floatValue];
                if(interval >= 0){
                    incVal += interval;
                }else{
                    decVal -= interval;
                }
            }
            
            rs = incVal/decVal;
            float rsi =100-100/(1+rs);
            
            NSMutableArray *item = [[NSMutableArray alloc] init];
            [item addObject:[@"" stringByAppendingFormat:@"%f",rsi]];
            [rsi12 addObject:item];
        }
        dic[@"rsi12"] = rsi12;
        
        //WR
        NSMutableArray *wr = [[NSMutableArray alloc] init];
        for(int i = 60;i < data.count;i++){
            float h  = [[data[i] objectAtIndex:2] floatValue];
            float l = [[data[i] objectAtIndex:3] floatValue];
            float c = [[data[i] objectAtIndex:1] floatValue];
            for(int j=i;j>i-10;j--){
                if([[data[j] objectAtIndex:2] floatValue] > h){
                    h = [[data[j] objectAtIndex:2] floatValue];
                }
                
                if([[data[j] objectAtIndex:3] floatValue] < l){
                    l = [[data[j] objectAtIndex:3] floatValue];
                }
            }
            
            float val = (h-c)/(h-l)*100;
            NSMutableArray *item = [[NSMutableArray alloc] init];
            [item addObject:[@"" stringByAppendingFormat:@"%f",val]];
            [wr addObject:item];
        }
        dic[@"wr"] = wr;
        
        //KDJ
        NSMutableArray *kdj_k = [[NSMutableArray alloc] init];
        NSMutableArray *kdj_d = [[NSMutableArray alloc] init];
        NSMutableArray *kdj_j = [[NSMutableArray alloc] init];
        float prev_k = 50;
        float prev_d = 50;
        float rsv = 0;
        for(int i = 60;i < data.count;i++){
            float h  = [[data[i] objectAtIndex:2] floatValue];
            float l = [[data[i] objectAtIndex:3] floatValue];
            float c = [[data[i] objectAtIndex:1] floatValue];
            for(int j=i;j>i-10;j--){
                if([[data[j] objectAtIndex:2] floatValue] > h){
                    h = [[data[j] objectAtIndex:2] floatValue];
                }
                
                if([[data[j] objectAtIndex:3] floatValue] < l){
                    l = [[data[j] objectAtIndex:3] floatValue];
                }
            }
            
            if(h!=l)
                rsv = (c-l)/(h-l)*100;
            float k = 2*prev_k/3+1*rsv/3;
            float d = 2*prev_d/3+1*k/3;
            float j = d+2*(d-k);
            
            prev_k = k;
            prev_d = d;
            
            NSMutableArray *itemK = [[NSMutableArray alloc] init];
            [itemK addObject:[@"" stringByAppendingFormat:@"%f",k]];
            [kdj_k addObject:itemK];
            NSMutableArray *itemD = [[NSMutableArray alloc] init];
            [itemD addObject:[@"" stringByAppendingFormat:@"%f",d]];
            [kdj_d addObject:itemD];
            NSMutableArray *itemJ = [[NSMutableArray alloc] init];
            [itemJ addObject:[@"" stringByAppendingFormat:@"%f",j]];
            [kdj_j addObject:itemJ];
        }
        dic[@"kdj_k"] = kdj_k;
        dic[@"kdj_d"] = kdj_d;
        dic[@"kdj_j"] = kdj_j;
        
        //VR
        NSMutableArray *vr = [[NSMutableArray alloc] init];
        for(int i = 60;i < data.count;i++){
            float inc = 0;
            float dec = 0;
            float eq  = 0;
            for(int j=i;j>i-24;j--){
                float o = [[data[j] objectAtIndex:0] floatValue];
                float c = [[data[j] objectAtIndex:1] floatValue];
                
                if(c > o){
                    inc += [[data[j] objectAtIndex:4] intValue];
                }else if(c < o){
                    dec += [[data[j] objectAtIndex:4] intValue];
                }else{
                    eq  += [[data[j] objectAtIndex:4] intValue];
                }
            }
            
            float val = (inc+1*eq/2)/(dec+1*eq/2);
            NSMutableArray *item = [[NSMutableArray alloc] init];
            [item addObject:[@"" stringByAppendingFormat:@"%f",val]];
            [vr addObject:item];
        }
        dic[@"vr"] = vr;
        
    }else{
        //price
        NSMutableArray *price = [[NSMutableArray alloc] init];
        for(int i = 0;i < data.count;i++){
            [price addObject:data[i]];
        }
        dic[@"price"] = price;
        
        //VOL
        NSMutableArray *vol = [[NSMutableArray alloc] init];
        for(int i = 0;i < data.count;i++){
            NSMutableArray *item = [[NSMutableArray alloc] init];
            [item addObject:[@"" stringByAppendingFormat:@"%f",[[data[i] objectAtIndex:4] floatValue]/100]];
            [vol addObject:item];
        }
        dic[@"vol"] = vol;
        
    }
}

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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
