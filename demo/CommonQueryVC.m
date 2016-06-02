//
//  CommonQueryVC.m
//  HealthKitDemo
//
//  Created by xxb on 16/6/1.
//  Copyright © 2016年 xxb. All rights reserved.
//

#import "CommonQueryVC.h"
#import "AppDelegate.h"
@import HealthKit;

@interface CommonQueryVC ()<UIPickerViewDataSource,UIPickerViewDelegate>{
    //特征
    NSArray *_characteristicSource;   //HKCharacteristicType
    NSInteger _characteristicCurrentRow;
    //数量样本
    NSArray *_quantitySource;
    NSInteger _quantityCurrentRow;
}

@property (weak, nonatomic) IBOutlet UIPickerView *characteristicPicker;
@property (weak, nonatomic) IBOutlet UILabel *characteristicLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *quantityPicker;
@property (weak, nonatomic) IBOutlet UITextView *quantityTextView;



@end

@implementation CommonQueryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _characteristicSource = @[
                  @{@"title":@"出生日期",@"type":HKCharacteristicTypeIdentifierDateOfBirth},
                  @{@"title":@"性别",@"type":HKCharacteristicTypeIdentifierBiologicalSex}];
    [_characteristicPicker reloadAllComponents];
    _characteristicCurrentRow = 0;
    
    _quantitySource = @[
                    @{@"title":@"步数",@"type":HKQuantityTypeIdentifierStepCount,@"unit":[HKUnit countUnit],@"unitTitle":@"数([HKUnit countUnit])"},
                    @{@"title":@"步行＋跑步距离",@"type":HKQuantityTypeIdentifierDistanceWalkingRunning,@"unit":[HKUnit meterUnit],@"unitTitle":@"米([HKUnit meterUnit])"}];
    _quantityCurrentRow = 0;
    _quantityTextView.text = @"";
}

#pragma mark - delegate

#pragma mark -UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(pickerView == _characteristicPicker){
        return _characteristicSource.count;
    }else if(pickerView == _quantityPicker){
        return _quantitySource.count;
    }else{
        return 0;
    }
}

#pragma mark -UIPickerViewDelegate

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSArray *dataSource;
    if(pickerView == _characteristicPicker){
        dataSource = _characteristicSource;
    }else if(pickerView == _quantityPicker){
        dataSource = _quantitySource;
    }else{
        
    }
    NSDictionary *dict = dataSource[row];
    return dict[@"title"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSArray *dataSource;
    if(pickerView == _characteristicPicker){
        dataSource = _characteristicSource;
        _characteristicCurrentRow = row;
    }else if(pickerView == _quantityPicker){
        _quantityCurrentRow = row;
    }else{
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -event

- (IBAction)teQuery:(id)sender {
    //特征查询
    NSDictionary *dict = _characteristicSource[_characteristicCurrentRow];
    //1.先判断HealthKit在该设备上是否可用
    if ([HKHealthStore isHealthDataAvailable]){
        NSLog(@"HealthKit在该设备上可用");
        //2.请求获取HealthKit数据的权限，每种数据都要请求一次
        HKCharacteristicType *characteristicType = [HKCharacteristicType characteristicTypeForIdentifier:dict[@"type"]];
        NSSet *read = [NSSet setWithObjects:characteristicType, nil];
        [[AppDelegate shareInstance].healthStore requestAuthorizationToShareTypes:nil readTypes:read completion:^(BOOL success, NSError * _Nullable error) {
            if(success){
                NSLog(@"请求权限成功");
                //3.判断是否有权限获取某类数据
                if([[AppDelegate shareInstance].healthStore authorizationStatusForType:characteristicType]){
                    NSLog(@"拥有权限访问");
                    //4.向HealthKit查询数据
                    if([dict[@"type"] isEqualToString:HKCharacteristicTypeIdentifierDateOfBirth]){
                        //出生日期
                        NSError *error;
                        NSDate *birthDate = [[AppDelegate shareInstance].healthStore dateOfBirthWithError:&error];
                        if(error){
                            NSLog(@"%@", error.localizedDescription);
                        }else if(!birthDate){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                _characteristicLabel.text = @"没有找到数据";
                            });
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                _characteristicLabel.text = [NSString stringWithFormat:@"%@", birthDate];
                            });
                        }
                    }else if([dict[@"type"] isEqualToString:HKCharacteristicTypeIdentifierBiologicalSex]){
                        //性别
                        NSError *error;
                        HKBiologicalSexObject *sex = [[AppDelegate shareInstance].healthStore biologicalSexWithError:&error];
                        if(error){
                            NSLog(@"%@", error.localizedDescription);
                        }else if(!sex){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                _characteristicLabel.text = @"没有找到数据";
                            });
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                _characteristicLabel.text = [NSString stringWithFormat:@"%ld", (long)sex.biologicalSex];
                            });
                        }
                    }
                }else{
                    NSLog(@"没有权限访问");
                }
            }else{
                NSLog(@"请求权限失败");
            }
        }];
    }else{
        NSLog(@"HealthKit在该设备上不可用");
    }
}

- (IBAction)quantityQuery:(id)sender {
    //数量样本查询
    NSDictionary *dict = _quantitySource[_quantityCurrentRow];
    //1.先判断HealthKit在该设备上是否可用
    if ([HKHealthStore isHealthDataAvailable]){
        NSLog(@"HealthKit在该设备上可用");
        //2.请求获取HealthKit数据的权限，每种数据都要请求一次
        HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:dict[@"type"]];
        NSSet *read = [NSSet setWithObjects:quantityType, nil];
        [[AppDelegate shareInstance].healthStore requestAuthorizationToShareTypes:nil readTypes:read completion:^(BOOL success, NSError * _Nullable error) {
            if(success){
                NSLog(@"请求权限成功");
                //3.判断是否有权限获取某类数据
                if([[AppDelegate shareInstance].healthStore authorizationStatusForType:quantityType]){
                    NSLog(@"拥有权限访问");
                    //4.向HealthKit查询数据
                    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
                    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:quantityType predicate:nil limit:HKObjectQueryNoLimit sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                        if (!results) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                _quantityTextView.text = @"没有找到数据";
                            });
                            return;
                        }
                        NSString *textViewText = @"";
                        for(HKQuantitySample *sample in results){
                            HKSource *source = sample.sourceRevision.source;
                            HKQuantity *quantity = sample.quantity;
                            HKUnit *heightUnit = dict[@"unit"];
                            double value = [quantity doubleValueForUnit:heightUnit];
                            //来源、值、额外信息的字典、开始日期、结束日期
                            NSString *content = [NSString stringWithFormat:@"source[%@],value[%g],metedata[%@],startDate[%@],endDate[%@]\n", source.name, value, sample.metadata, sample.startDate, sample.endDate];
                            textViewText = [textViewText stringByAppendingString:content];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            _quantityTextView.text = textViewText;
                        });
                    }];
                    [[AppDelegate shareInstance].healthStore executeQuery:query];
                }else{
                    NSLog(@"没有权限访问");
                }
            }else{
                NSLog(@"请求权限失败");
            }
        }];
    }else{
        NSLog(@"HealthKit在该设备上不可用");
    }
}


@end
