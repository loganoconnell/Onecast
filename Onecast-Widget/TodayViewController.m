//
//  TodayViewController.m
//  Onecast-Widget
//
//  Created by Kevin O'Connell on 6/5/15.
//  Copyright (c) 2015 Logan O'Connell. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 200);
    
    UITapGestureRecognizer *tapOnLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openApp)];
    self.temperatureLabel.userInteractionEnabled = YES;
    [self.temperatureLabel addGestureRecognizer:tapOnLabel];
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.AppsByLogan.Onecast"];
    [defaults synchronize];
    self.temperatureLabel.text = [defaults stringForKey:@"temperature"];
    self.infoLabel.text = [defaults stringForKey:@"info"];
    self.hiloLabel.text = [defaults stringForKey:@"hilo"];
    self.iconView.image = [UIImage imageWithData:[defaults dataForKey:@"icon"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.AppsByLogan.Onecast"];
    [defaults synchronize];
    self.temperatureLabel.text = [defaults stringForKey:@"temperature"];
    self.infoLabel.text = [defaults stringForKey:@"info"];
    self.hiloLabel.text = [defaults stringForKey:@"hilo"];
    self.iconView.image = [UIImage imageWithData:[defaults dataForKey:@"icon"]];
    
    completionHandler(NCUpdateResultNewData);
}

-(UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsZero;
}

- (void)openApp {
    NSURL *url = [NSURL URLWithString:@"Onecast://"];
    [self.extensionContext openURL:url completionHandler:nil];
}

@end
