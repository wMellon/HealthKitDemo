//
//  AddDataVC.m
//  HealthKitDemo
//
//  Created by xxb on 16/5/31.
//  Copyright © 2016年 xxb. All rights reserved.
//

#import "AddDataVC.h"
#import "AppDelegate.h"
@import HealthKit;

@interface AddDataVC ()<UIPickerViewDataSource,UIPickerViewDelegate>{
    NSArray *_typeSource;
    NSInteger _currentRow;
}

@property (weak, nonatomic) IBOutlet UIPickerView *typePicker;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;


@end

@implementation AddDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _typeSource = @[
                    @{@"title":@"步数",@"type":HKQuantityTypeIdentifierStepCount,@"unit":[HKUnit countUnit],@"unitTitle":@"数([HKUnit countUnit])"},
                    @{@"title":@"步行＋跑步距离",@"type":HKQuantityTypeIdentifierDistanceWalkingRunning,@"unit":[HKUnit meterUnit],@"unitTitle":@"米([HKUnit meterUnit])"}];
    [_typePicker reloadAllComponents];
    _currentRow = 0;
    NSDictionary *dict = _typeSource[_currentRow];
    _unitLabel.text = [NSString stringWithFormat:@"%@", dict[@"unitTitle"]];
}

#pragma mark - delegate

#pragma mark -UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _typeSource.count;
}

#pragma mark -UIPickerViewDelegate

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSDictionary *dict = _typeSource[row];
    return dict[@"title"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    _currentRow = row;
    NSDictionary *dict = _typeSource[row];
    _unitLabel.text = [NSString stringWithFormat:@"%@", dict[@"unitTitle"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - event

- (IBAction)save:(id)sender {
    NSDictionary *dict = _typeSource[_currentRow];
    
    //1.先判断HealthKit在该设备上是否可用
    if ([HKHealthStore isHealthDataAvailable]){
        NSLog(@"HealthKit在该设备上可用");
        //2.请求获取HealthKit数据的权限，每种数据都要请求一次
        HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:dict[@"type"]];
        NSSet *write = [NSSet setWithObjects:quantityType, nil];
        NSSet *read = [NSSet setWithObjects:quantityType, nil];
        [[AppDelegate shareInstance].healthStore requestAuthorizationToShareTypes:write readTypes:read completion:^(BOOL success, NSError * _Nullable error) {
            if(success){
                NSLog(@"请求权限成功");
                //3.判断是否有权限获取某类数据
//                if([AppDelegate shareInstance].healthStore)
                HKQuantity *writeQ = [HKQuantity quantityWithUnit:dict[@"unit"] doubleValue:[_valueTextField.text doubleValue]];
                HKQuantitySample *writeSample = [HKQuantitySample quantitySampleWithType:quantityType quantity:writeQ startDate:[NSDate date] endDate:[NSDate date]];
                [[AppDelegate shareInstance].healthStore saveObject:writeSample withCompletion:^(BOOL success, NSError * _Nullable error) {
                    if(success){
                        NSLog(@"保存healthKit成功");
                    }else{
                        NSLog(@"%@", error.localizedDescription);
                    }
                }];
            }else{
                NSLog(@"请求权限失败");
            }
        }];
    }else{
        NSLog(@"HealthKit在该设备上不可用");
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_valueTextField resignFirstResponder];
}

@end
