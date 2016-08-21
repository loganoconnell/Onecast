//
//  ViewController.m
//  Onecast
//
//  Created by Kevin O'Connell on 6/5/15.
//  Copyright (c) 2015 Logan O'Connell. All rights reserved.
//

#import "ViewController.h"
#import "Manager.h"
#import <TSMessages/TSMessage.h>

@import CoreLocation;

@interface ViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat screenHeight;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) NSDateFormatter *hourlyFormatter;
@property (nonatomic, strong) NSDateFormatter *dailyFormatter;

@property (nonatomic, strong) NSDateFormatter *sunTimeFormatter;

@property (nonatomic, strong) UIVisualEffectView *flipViewBG;
@property (nonatomic, strong) UIVisualEffectView *tableViewBG;

@property (nonatomic, strong) UILabel *temperatureLabel;
@property (nonatomic, strong) UILabel *hiloLabel;
@property (nonatomic, strong) UILabel *cityLabel;
@property (nonatomic, strong) UILabel *conditionsLabel;

@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic) BOOL isFlipped;

@end

@implementation ViewController

- (id)init {
    if (self = [super init]) {
        _hourlyFormatter = [[NSDateFormatter alloc] init];
        _hourlyFormatter.dateFormat = @"h a";
        
        _dailyFormatter = [[NSDateFormatter alloc] init];
        _dailyFormatter.dateFormat = @"EEEE";
        
        _sunTimeFormatter = [[NSDateFormatter alloc] init];
        _sunTimeFormatter.dateFormat = @"h:mm a";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    int bgNumber = arc4random_uniform(52);
    NSString *bgNumberString = [NSString stringWithFormat:@"Weather Backgrounds/%d.jpg", bgNumber];
    UIImage *background = [UIImage imageNamed:bgNumberString];
    
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    self.tableViewBG = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    self.tableViewBG.frame = [UIScreen mainScreen].bounds;
    self.tableViewBG.alpha = 0;
    [self.view addSubview:self.tableViewBG];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES;
    [self.view addSubview:self.tableView];

    _isFlipped = NO;
    
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 30;
    
    CGFloat flipBGSize = [UIScreen mainScreen].bounds.size.width - 120;
    
    CGRect hiloFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, hiloHeight);
    
    CGRect temperatureFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, temperatureHeight);
    
    CGRect iconFrame = CGRectMake(([UIScreen mainScreen].bounds.size.width / 2) - 40, 0, iconHeight, iconHeight);
    
    CGRect conditionsFrame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2, 0, [UIScreen mainScreen].bounds.size.width / 2, 30);
    
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    _flipViewBG = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    _flipViewBG.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - flipBGSize) / 2, (_screenHeight - flipBGSize) / 2, flipBGSize, flipBGSize);
    _flipViewBG.layer.cornerRadius = _flipViewBG.frame.size.width / 2;
    _flipViewBG.clipsToBounds = YES;
    [header addSubview:_flipViewBG];
    UITapGestureRecognizer *tapOnFlipBG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(triggerFlipBG)];
    [_flipViewBG addGestureRecognizer:tapOnFlipBG];
    
    _temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    _temperatureLabel.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2 + 15);
    _temperatureLabel.backgroundColor = [UIColor clearColor];
    _temperatureLabel.textColor = [UIColor whiteColor];
    _temperatureLabel.textAlignment = NSTextAlignmentCenter;
    _temperatureLabel.text = @"0";
    _temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
    [header addSubview:_temperatureLabel];
    
    _hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    _hiloLabel.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, _temperatureLabel.center.y);
    _hiloLabel.backgroundColor = [UIColor clearColor];
    _hiloLabel.textColor = [UIColor whiteColor];
    _hiloLabel.textAlignment = NSTextAlignmentCenter;
    _hiloLabel.text = @"0° | 0°";
    _hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:42];
    _hiloLabel.alpha = 0.0;
    [header addSubview:_hiloLabel];
    
    _cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    _cityLabel.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, _temperatureLabel.frame.origin.y - 15);
    _cityLabel.backgroundColor = [UIColor clearColor];
    _cityLabel.textColor = [UIColor whiteColor];
    _cityLabel.textAlignment = NSTextAlignmentCenter;
    _cityLabel.text = @"Loading...";
    _cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    _cityLabel.textAlignment = NSTextAlignmentCenter;
    _cityLabel.alpha = 0.0;
    [header addSubview:_cityLabel];
    
    _conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    _conditionsLabel.center = CGPointMake(_conditionsLabel.center.x, _temperatureLabel.frame.origin.y - 15);
    _conditionsLabel.backgroundColor = [UIColor clearColor];
    _conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    _conditionsLabel.textColor = [UIColor whiteColor];
    [header addSubview:_conditionsLabel];
    
    _iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    _iconView.center = CGPointMake(_iconView.center.x, _temperatureLabel.frame.origin.y - 15);
    _iconView.contentMode = UIViewContentModeScaleAspectFit;
    _iconView.backgroundColor = [UIColor clearColor];
    [header addSubview:_iconView];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor whiteColor];
    [_refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = _refreshControl;
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];
    
    [[RACObserve([Manager sharedManager], currentCondition)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(Condition *newCondition) {
         _temperatureLabel.text = [NSString stringWithFormat:@"%.0f",newCondition.temperature.floatValue];
         _conditionsLabel.text = [newCondition.condition capitalizedString];
         _cityLabel.text = [NSString stringWithFormat:@"%@, %@", [newCondition.locationName capitalizedString], newCondition.locationCountry];
         
         _iconView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Weather Icons/%@.png", [newCondition imageName]]];
         
         [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(dismissNotification) userInfo:nil repeats:NO];
     }];
    
    RAC(_hiloLabel, text) = [[RACSignal combineLatest:@[
                                                       RACObserve([Manager sharedManager], currentCondition.tempHigh),
                                                       RACObserve([Manager sharedManager], currentCondition.tempLow)]
                                              reduce:^(NSNumber *hi, NSNumber *low) {
                                                  return [NSString  stringWithFormat:@"%.0f° | %.0f°",hi.floatValue,low.floatValue];
                                              }]
                            
                            deliverOn:RACScheduler.mainThreadScheduler];
    
    [[RACObserve([Manager sharedManager], hourlyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
     }];
    
    [[RACObserve([Manager sharedManager], dailyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
     }];
    
    [[Manager sharedManager] findCurrentLocation];
    
    [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(changeBackground) userInfo:nil repeats:YES];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.backgroundImageView.frame = bounds;
    self.tableViewBG.frame = bounds;
    self.tableView.frame = bounds;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)changeBackground {
    int bgNumber = arc4random_uniform(52);
    NSString *bgNumberString = [NSString stringWithFormat:@"Weather Backgrounds/%d.jpg", bgNumber];
    UIImage *background = [UIImage imageNamed:bgNumberString];
    
    if (background) {
        [UIView transitionWithView:self.backgroundImageView duration:2.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.backgroundImageView.image = background;
        } completion:nil];
    }
    else {
        [self changeBackground];
    }
}

- (void)triggerFlipBG {
    if (!_isFlipped) {
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _temperatureLabel.alpha = 0.0;
            _conditionsLabel.alpha = 0.0;
            _iconView.alpha = 0.0;
        } completion:^(BOOL success) {
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _hiloLabel.alpha = 1.0;
                _cityLabel.alpha = 1.0;
            } completion:^(BOOL success) {
                _isFlipped = YES;
            }];
        }];
    }
    else {
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _hiloLabel.alpha = 0.0;
            _cityLabel.alpha = 0.0;
        } completion:^(BOOL success) {
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _temperatureLabel.alpha = 1.0;
                _conditionsLabel.alpha = 1.0;
                _iconView.alpha = 1.0;
            } completion:^(BOOL success) {
                _isFlipped = NO;
            }];
        }];
    }
}

- (void)dismissNotification {
    [TSMessage dismissActiveNotification];
    
    [TSMessage showNotificationInViewController:self title:@"Connected!" subtitle:@"" image:nil type:TSMessageNotificationTypeSuccess duration:TSMessageNotificationDurationAutomatic callback:nil buttonTitle:nil buttonCallback:nil atPosition:TSMessageNotificationPositionTop canBeDismissedByUser:YES];
}

-(void)refreshView {
    
    [_refreshControl beginRefreshing];

    [[RACObserve([Manager sharedManager], currentCondition)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(Condition *newCondition) {
         [_refreshControl endRefreshing];
         [self.tableView reloadData];
     }];
    
    [[RACObserve([Manager sharedManager], hourlyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [_refreshControl endRefreshing];
         [self.tableView reloadData];
     }];
    
    [[RACObserve([Manager sharedManager], dailyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [_refreshControl endRefreshing];
         [self.tableView reloadData];
     }];
    
    [[Manager sharedManager] findCurrentLocation];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return MIN([[Manager sharedManager].hourlyForecast count], 6) + 1;
    }
    
    else if (section == 1) {
        return MIN([[Manager sharedManager].dailyForecast count], 6) + 1;
    }
    else {
        return 7;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Hourly Forecast"];
        }
        else {
            Condition *weather = [Manager sharedManager].hourlyForecast[indexPath.row - 1];
            [self configureHourlyCell:cell weather:weather];
        }
    }
    else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Daily Forecast"];
        }
        else {
            Condition *weather = [Manager sharedManager].dailyForecast[indexPath.row - 1];
            [self configureDailyCell:cell weather:weather];
        }
    }
    else {
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Other Information"];
        }
        else {
            [self configureOtherInformationCell:cell row:indexPath.row];
        }
    }
    
    return cell;
}

- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}

- (void)configureHourlyCell:(UITableViewCell *)cell weather:(Condition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.hourlyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°",weather.temperature.floatValue];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Weather Icons/%@.png", [weather imageName]]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)configureDailyCell:(UITableViewCell *)cell weather:(Condition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.dailyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f° | %.0f°",weather.tempHigh.floatValue,weather.tempLow.floatValue];
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Weather Icons/%@.png", [weather imageName]]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)configureOtherInformationCell:(UITableViewCell *)cell row:(NSInteger)row {
    
    Condition *weather = [Manager sharedManager].currentCondition;
    switch (row) {
    case 1:
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
        cell.textLabel.text = @"Humidity";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f%%",weather.humidity.floatValue];
        cell.imageView.image = [UIImage imageNamed:@"Weather Icons/weather-humidity.png"];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
    case 2:
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
        cell.textLabel.text = @"Pressure";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f PSI",weather.pressure.floatValue * 0.0145];
        cell.imageView.image = [UIImage imageNamed:@"Weather Icons/weather-pressure.png"];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
    case 3:
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
        cell.textLabel.text = @"Wind Speed";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f MPH",weather.windSpeed.floatValue];
        cell.imageView.image = [UIImage imageNamed:@"Weather Icons/weather-windSpeed.png"];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
    case 4:
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
        cell.textLabel.text = @"Wind Direction";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°",weather.windBearing.floatValue];
        cell.imageView.image = [UIImage imageNamed:@"Weather Icons/weather-windDirection.png"];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
    case 5:
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
        cell.textLabel.text = @"Sunrise";
        cell.detailTextLabel.text = [self.sunTimeFormatter stringFromDate:weather.sunrise];
        cell.imageView.image = [UIImage imageNamed:@"Weather Icons/weather-sunrise.png"];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
    case 6:
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
        cell.textLabel.text = @"Sunset";
        cell.detailTextLabel.text = [self.sunTimeFormatter stringFromDate:weather.sunset];
        cell.imageView.image = [UIImage imageNamed:@"Weather Icons/weather-sunset.png"];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            break;
    default:
            break;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return self.screenHeight / (CGFloat)cellCount;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    
    CGFloat percent = MIN(position / height, 1.0);
    
    self.tableViewBG.alpha = percent;
}

@end
