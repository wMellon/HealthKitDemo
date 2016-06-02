//
//  AnchoredObjectQueryVC.m
//  HealthKitDemo
//
//  Created by xxb on 16/6/1.
//  Copyright © 2016年 xxb. All rights reserved.
//

#import "AnchoredObjectQueryVC.h"
#import "AppDelegate.h"
@import HealthKit;

@interface AnchoredObjectQueryVC ()<UIPickerViewDataSource,UIPickerViewDelegate>{
    //数量样本
    NSArray *_quantitySource;
    NSInteger _quantityCurrentRow;
    HKQueryAnchor *_anchor;    //锚定对象
    HKAnchoredObjectQuery *_anchoredQuery;
}

@property (weak, nonatomic) IBOutlet UIPickerView *quantityPicker;
@property (weak, nonatomic) IBOutlet UITextView *quantityTextView;

@end

@implementation AnchoredObjectQueryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
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
    return _quantitySource.count;
}

#pragma mark -UIPickerViewDelegate

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSDictionary *dict = _quantitySource[row];
    return dict[@"title"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    _quantityCurrentRow = row;
}


#pragma mark - event

- (IBAction)query:(id)sender {
    if(_anchor){
        _anchor = nil;
        _anchoredQuery = nil;
        _quantityTextView.text = @"";
    }
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
//                    _anchor = [HKQueryAnchor anchorFromValue:0];
                    _anchoredQuery = [[HKAnchoredObjectQuery alloc] initWithType:quantityType predicate:nil anchor:_anchor limit:HKObjectQueryNoLimit resultsHandler:^(HKAnchoredObjectQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable sampleObjects, NSArray<HKDeletedObject *> * _Nullable deletedObjects, HKQueryAnchor * _Nullable newAnchor, NSError * _Nullable error) {
                        _anchor = newAnchor;
                        NSString *content = [NSString stringWithFormat:
                                             @"other:%@\n\
                                             delete:%@\n\
                                             -----以上是第一次从healthKit加载数据------\n", sampleObjects, deletedObjects];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            _quantityTextView.text = [_quantityTextView.text stringByAppendingString:content];
                        });
                    }];
                    __weak typeof(self) weakSelf = self;
                    _anchoredQuery.updateHandler = ^(HKAnchoredObjectQuery *query, NSArray<__kindof HKSample *> * __nullable addedObjects, NSArray<HKDeletedObject *> * __nullable deletedObjects, HKQueryAnchor * __nullable newAnchor, NSError * __nullable error){
                        //只要healthKit数据有更新（新增、删除）这个方法都会调用到
                        _anchor = newAnchor;
                        NSString *content = [NSString stringWithFormat:
                                             @"-----以下是增量更新数据-----\n\
                                             add:%@\n\
                                             delete:%@\n", addedObjects, deletedObjects];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.quantityTextView.text = [weakSelf.quantityTextView.text stringByAppendingString:content];
                        });
                    };
                    [[AppDelegate shareInstance].healthStore executeQuery:_anchoredQuery];
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
