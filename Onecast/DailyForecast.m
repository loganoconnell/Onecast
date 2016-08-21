//
//  DailyForecast.m
//  Onecast
//
//  Created by Kevin O'Connell on 6/5/15.
//  Copyright (c) 2015 Logan O'Connell. All rights reserved.
//

#import "DailyForecast.h"

@implementation DailyForecast

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    
    return paths;
}

@end
