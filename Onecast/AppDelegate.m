//
//  AppDelegate.m
//  Onecast
//
//  Created by Kevin O'Connell on 6/5/15.
//  Copyright (c) 2015 Logan O'Connell. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Manager.h"
#import <TSMessages/TSMessage.h>
#import <EAIntroView/EAIntroView.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[ViewController alloc] init];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [TSMessage setDefaultViewController:self.window.rootViewController];

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasBeenLaunched"]) {
        EAIntroPage *page1 = [EAIntroPage page];
        page1.title = @"Welcome to Onecast!";
        page1.titlePositionY = ([UIScreen mainScreen].bounds.size.height / 2) + 110;
        page1.titleFont = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:60];
        page1.titleColor = [UIColor whiteColor];
        page1.desc = @"Swipe left to begin using the app!";
        page1.descPositionY = ([UIScreen mainScreen].bounds.size.height / 2) - 55;
        page1.descFont = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:30];
        page1.descColor = [UIColor grayColor];
        page1.bgColor = [UIColor blackColor];
        EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.window.bounds andPages:@[page1]];
        intro.skipButton = nil;
        intro.pageControl = nil;
        [intro showInView:self.window animateDuration:0.0];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasBeenLaunched"];
    }
    
    [TSMessage showNotificationInViewController:self.window.rootViewController title:@"Loading..." subtitle:@"" image:nil type:TSMessageNotificationTypeMessage duration:TSMessageNotificationDurationEndless callback:nil buttonTitle:nil buttonCallback:nil atPosition:TSMessageNotificationPositionTop canBeDismissedByUser:NO];
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.AppsByLogan.Onecast"];
    [[Manager sharedManager] findCurrentLocation];
    [defaults setObject:[NSString stringWithFormat:@"%.0f",[Manager sharedManager].currentCondition.temperature.floatValue] forKey:@"temperature"];
    [defaults setObject:[NSString stringWithFormat:@"%@ | %@, %@", [[Manager sharedManager].currentCondition.condition capitalizedString], [[Manager sharedManager].currentCondition.locationName capitalizedString], [Manager sharedManager].currentCondition.locationCountry] forKey:@"info"];
    [defaults setObject:[NSString  stringWithFormat:@"%.0f° | %.0f°", [Manager sharedManager].currentCondition.tempHigh.floatValue, [Manager sharedManager].currentCondition.tempLow.floatValue] forKey:@"hilo"];
    [defaults setObject:UIImagePNGRepresentation([UIImage imageNamed:[NSString stringWithFormat:@"Weather Icons/%@.png", [[Manager sharedManager].currentCondition imageName]]]) forKey:@"icon"];
    [defaults synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.AppsByLogan.Onecast"];
    [[Manager sharedManager] findCurrentLocation];
    [defaults setObject:[NSString stringWithFormat:@"%.0f",[Manager sharedManager].currentCondition.temperature.floatValue] forKey:@"temperature"];
    [defaults setObject:[NSString stringWithFormat:@"%@ | %@, %@", [[Manager sharedManager].currentCondition.condition capitalizedString], [[Manager sharedManager].currentCondition.locationName capitalizedString], [Manager sharedManager].currentCondition.locationCountry] forKey:@"info"];
    [defaults setObject:[NSString  stringWithFormat:@"%.0f° | %.0f°", [Manager sharedManager].currentCondition.tempHigh.floatValue, [Manager sharedManager].currentCondition.tempLow.floatValue] forKey:@"hilo"];
    [defaults setObject:UIImagePNGRepresentation([UIImage imageNamed:[NSString stringWithFormat:@"Weather Icons/%@.png", [[Manager sharedManager].currentCondition imageName]]]) forKey:@"icon"];
    [defaults synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.AppsByLogan.Onecast"];
    [[Manager sharedManager] findCurrentLocation];
    [defaults setObject:[NSString stringWithFormat:@"%.0f",[Manager sharedManager].currentCondition.temperature.floatValue] forKey:@"temperature"];
    [defaults setObject:[NSString stringWithFormat:@"%@ | %@, %@", [[Manager sharedManager].currentCondition.condition capitalizedString], [[Manager sharedManager].currentCondition.locationName capitalizedString], [Manager sharedManager].currentCondition.locationCountry] forKey:@"info"];
    [defaults setObject:[NSString  stringWithFormat:@"%.0f° | %.0f°", [Manager sharedManager].currentCondition.tempHigh.floatValue, [Manager sharedManager].currentCondition.tempLow.floatValue] forKey:@"hilo"];
    [defaults setObject:UIImagePNGRepresentation([UIImage imageNamed:[NSString stringWithFormat:@"Weather Icons/%@.png", [[Manager sharedManager].currentCondition imageName]]]) forKey:@"icon"];
    [defaults synchronize];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.AppsByLogan.Onecast"];
    [[Manager sharedManager] findCurrentLocation];
    [defaults setObject:[NSString stringWithFormat:@"%.0f",[Manager sharedManager].currentCondition.temperature.floatValue] forKey:@"temperature"];
    [defaults setObject:[NSString stringWithFormat:@"%@ | %@, %@", [[Manager sharedManager].currentCondition.condition capitalizedString], [[Manager sharedManager].currentCondition.locationName capitalizedString], [Manager sharedManager].currentCondition.locationCountry] forKey:@"info"];
    [defaults setObject:[NSString  stringWithFormat:@"%.0f° | %.0f°", [Manager sharedManager].currentCondition.tempHigh.floatValue, [Manager sharedManager].currentCondition.tempLow.floatValue] forKey:@"hilo"];
    [defaults setObject:UIImagePNGRepresentation([UIImage imageNamed:[NSString stringWithFormat:@"Weather Icons/%@.png", [[Manager sharedManager].currentCondition imageName]]]) forKey:@"icon"];
    [defaults synchronize];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

@end
