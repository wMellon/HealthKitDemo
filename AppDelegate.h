//
//  AppDelegate.h
//  HealthKitDemo
//
//  Created by xxb on 16/5/31.
//  Copyright © 2016年 xxb. All rights reserved.
//

#import <UIKit/UIKit.h>
@import HealthKit;


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) HKHealthStore *healthStore;

+(AppDelegate*)shareInstance;

@end

