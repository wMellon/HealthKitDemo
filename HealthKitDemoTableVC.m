//
//  HealthKitDemoTableVC.m
//  HealthKitDemo
//
//  Created by xxb on 16/5/31.
//  Copyright © 2016年 xxb. All rights reserved.
//

#import "HealthKitDemoTableVC.h"
#import "AddDataVC.h"
#import "CommonQueryVC.h"
#import "AnchoredObjectQueryVC.h"

@interface HealthKitDemoTableVC (){
    NSArray *_dataSource;
}

@end

@implementation HealthKitDemoTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    _dataSource = @[@"保存healthKit",@"普通查询",@"锚定对象查询"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = _dataSource[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:{
            AddDataVC *add = [[AddDataVC alloc] init];
            [self.navigationController pushViewController:add animated:YES];
        }
            break;
        case 1:{
            CommonQueryVC *commonQuery = [[CommonQueryVC alloc] init];
            [self.navigationController pushViewController:commonQuery animated:YES];
        }
            break;
        case 2:{
            AnchoredObjectQueryVC *anchoredQuery = [[AnchoredObjectQueryVC alloc] init];
            [self.navigationController pushViewController:anchoredQuery animated:YES];
        }
            break;
        default:
            break;
    }
}


@end
