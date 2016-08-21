//
//  TodayViewController.h
//  Onecast-Widget
//
//  Created by Kevin O'Connell on 6/5/15.
//  Copyright (c) 2015 Logan O'Connell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *hiloLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@end
