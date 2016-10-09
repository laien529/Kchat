//
//  ViewController.h
//  Kchat
//
//  Created by csc on 2016/9/22.
//  Copyright © 2016年 cedric cheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property(nonatomic,weak) IBOutlet UIView *chartView;
@property (nonatomic,weak) IBOutlet UILabel *productNameLabel;
@property (nonatomic,weak) IBOutlet UILabel *closeLabel;
@property (nonatomic,weak) IBOutlet UILabel *differenceLabel;
@property (nonatomic,weak) IBOutlet UILabel *differenceRateLabel;
@property (nonatomic,weak) IBOutlet UILabel *dateLabel;
@property (nonatomic,weak) IBOutlet UILabel *openLabel;
@property (nonatomic,weak) IBOutlet UILabel *lastCloseLabel;
@property (nonatomic,weak) IBOutlet UILabel *highLabel;
@property (nonatomic,weak) IBOutlet UILabel *lowLabel;
@property (nonatomic,weak) IBOutlet UILabel *volLabel;

@end

