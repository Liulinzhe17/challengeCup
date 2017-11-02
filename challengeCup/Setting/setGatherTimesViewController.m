//
//  setGatherTimesViewController.m
//  spy on
//
//  Created by 柳麟喆 on 2017/8/29.
//  Copyright © 2017年 lzLiu. All rights reserved.
//

#import "setGatherTimesViewController.h"
#import "SelectPositionViewController.h"
#import "gatherTimeCell.h"
#import "autoLocCell.h"
#import "poiModel.h"
@interface setGatherTimesViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *myTableView;
}

@property(nonatomic,strong)gatherTimeCell *gtCell;
@property(nonatomic,strong)autoLocCell *alCell;
@property(nonatomic,strong)NSDictionary *dicStart;
@property(nonatomic,strong)NSDictionary *dicEnd;

@end

@implementation setGatherTimesViewController
#pragma mark - 懒加载
-(NSDictionary *)dicStart{
    if (!_dicStart) {
        _dicStart=[[NSDictionary alloc]init];
    }
    return _dicStart;
}
-(NSDictionary *)dicEnd{
    if (!_dicEnd) {
        _dicEnd=[[NSDictionary alloc]init];
    }
    return _dicEnd;
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
    
    //添加观察者
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getStartOrEnd:) name:@"startOrEnd" object:nil];
    
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 保存并返回
-(void)save{
    //更新用户的起点和终点
    if (self.dicStart.count>0) {
        [USER setObject:self.dicStart forKey:@"startPoint"];
    }
    if (self.dicEnd.count>0){
        [USER setObject:self.dicEnd forKey:@"endPoint"];
    }
    //更新用户的定位周期
    [USER setInteger:self.gtCell.slider.value forKey:@"gatherTimes"];
    [USER setBool:self.alCell.isAuto forKey:@"isAutoGather"];
    
    //NSLog(@"用户配置：gatherTimes:%@,isAutoGather:%@",[USER objectForKey:@"gatherTimes"],[USER objectForKey:@"isAutoGather"]);
    [[NSNotificationCenter defaultCenter]postNotificationName:@"settings" object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 通知回调
-(void)getStartOrEnd:(NSNotification *)noti{
    NSDictionary *dic=noti.object;
    NSInteger type=[[dic objectForKey:@"type"]integerValue];//1为起点，2位终点
    poiModel *p=[dic objectForKey:@"poiModel"];
    NSString *address=p.address;
    if (type==1) {
        self.dicStart=@{@"type":[dic objectForKey:@"type"],@"address":p.address,@"longitude":p.longitude,@"latitude":p.latitude};
        [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]].textLabel.text=address;
        [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]].textLabel.textColor=LLZRGBA(42, 53, 250, 1.0);
    }else if (type==2){
        self.dicEnd=@{@"type":[dic objectForKey:@"type"],@"address":p.address,@"longitude":p.longitude,@"latitude":p.latitude};;
        [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]].textLabel.text=address;
        [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]].textLabel.textColor=LLZRGBA(38, 160, 100, 1.0);
    }else{
        NSLog(@"startOrEnd通知回调错误");
    }
}
#pragma mark - tableviewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 2;
            break;
        default:
            break;
    }
    return 1;
}

//配置特定行中的单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (indexPath.section==0) {
        self.gtCell = [[gatherTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"gtcellID"];
        return self.gtCell;
    }
    if (indexPath.section==1) {
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
    if (indexPath.section==2) {
        if(cell==nil)
        {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor=LLZRGBA(220, 80, 70, 1.0);
        if (indexPath.row==0) {
            cell.imageView.image=[UIImage imageNamed:@"起点32.png"];
            NSString *str=[[USER objectForKey:@"startPoint"]objectForKey:@"address"];
            if(str){
                cell.textLabel.textColor=LLZRGBA(42, 53, 250, 1.0);
                cell.textLabel.text=str;
            }else{
                cell.textLabel.text=@"请选择起点";
            }
        }else if(indexPath.row==1){
            cell.imageView.image=[UIImage imageNamed:@"终点32.png"];
            NSString *str=[[USER objectForKey:@"endPoint"]objectForKey:@"address"];
            if(str){
                cell.textLabel.textColor=LLZRGBA(38, 160, 100, 1.0);
                cell.textLabel.text=str;
            }else{
                cell.textLabel.text=@"请选择终点";
            }
        }
        return cell;
    }
    return cell;
}

//设置单元格的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return 60;
    }
    if (indexPath.section==2) {
        return 50;
    }
    return 40;
}
//每组的头标题
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return @"每次定位的间隔时间";
    }else if (section==2){
        return @"起点和终点";
    }
    else{
        return @"";
    }
}
//显示每组的头部标题有多高
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 50;
    }else{
        return 30;
    }
}
//选中cell之后的操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView cellForRowAtIndexPath:indexPath].selected=NO;//选完之后不变灰
    if (indexPath.section==2) {
        SelectPositionViewController *sp=[[SelectPositionViewController alloc]init];
        if (indexPath.row==0) {
            sp.type=1;//起点
        }else if (indexPath.row==1) {
            sp.type=2;//终点
        }
        UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:sp];
        [self presentViewController:nav animated:YES completion:nil];
        
    }
}
@end
