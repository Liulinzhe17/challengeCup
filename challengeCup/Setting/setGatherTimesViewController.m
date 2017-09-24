//
//  setGatherTimesViewController.m
//  spy on
//
//  Created by 柳麟喆 on 2017/8/29.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "setGatherTimesViewController.h"
#import "gatherTimeCell.h"
#import "autoLocCell.h"

@interface setGatherTimesViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *myTableView;
}

@property(nonatomic,strong)gatherTimeCell *gtCell;
@property(nonatomic,strong)autoLocCell *alCell;

@end

@implementation setGatherTimesViewController



#pragma mark - 保存并返回
-(void)save{
    //更新用户的定位周期
    [USER setInteger:self.gtCell.slider.value forKey:@"gatherTimes"];
    [USER setBool:self.alCell.isAuto forKey:@"isAutoGather"];
    //NSLog(@"用户配置：gatherTimes:%@,isAutoGather:%@",[USER objectForKey:@"gatherTimes"],[USER objectForKey:@"isAutoGather"]);
    [[NSNotificationCenter defaultCenter]postNotificationName:@"settings" object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 视图
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"用户偏好";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.view.backgroundColor=LLZRGBA(239, 239, 244, 1.0);
    
    myTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    myTableView.delegate=self;
    myTableView.dataSource=self;
    myTableView.backgroundColor=LLZRGBA(239, 239, 244, 1.0);
    [self.view addSubview:myTableView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableviewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return 1;
    }
    if(section==1) {
        return 1;
    }else{
        return 1;
    }
}

//配置特定行中的单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (indexPath.section==0) {
        self.gtCell = [[gatherTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"gtcellID"];
        return self.gtCell;
    }if (indexPath.section==1) {
        self.alCell=[[autoLocCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"alcellID"];
        //显示自动采集偏好
        if ([[USER objectForKey:@"isAutoGather"]integerValue]==0) {
            self.alCell.autoSwitch.on=NO;
            self.alCell.isAuto=NO;
        }else{
            self.alCell.autoSwitch.on=YES;
            self.alCell.isAuto=YES;
        }
        return self.alCell;
    }
    return cell;
}

//设置单元格的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return 60;
    }
    return 40;
}
//每组的头标题
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return @"每次定位的间隔时间";
    }else{
        return @"";
    }
}
//显示每组的头部标题有多高
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 50;
    }else{
        return 10;
    }
}
@end
