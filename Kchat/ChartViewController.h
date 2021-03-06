//
//  ChartViewController.h
//  Kchat
//
//  Created by csc on 2016/9/25.
//  Copyright © 2016年 cedric cheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DemoBaseViewController.h"

@protocol KchartViewDelegate <NSObject>

- (void)didSelectChart:(NSDictionary*)selectedDicData;

@end

@interface ChartViewController : UIViewController {
    NSArray<NSString *> *months;
}

@property (nonatomic,strong) NSString *lastTime;
@property (nonatomic,strong) NSString *req_url;
@property (nonatomic,strong) NSString *req_security_id;
@property (nonatomic,weak) id<KchartViewDelegate> kChartViewDelegate;

- (id)initWithProductId:(NSString*)productId dataRange:(NSString*)dataRange;
@end
